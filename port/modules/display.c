/*
 * This file is part of the MicroPython for Monocle:
 *      https://github.com/Itsbrilliantlabs/monocle-micropython
 *
 * Authored by: Josuah Demangeon <me@josuah.net>
 *
 * ISC Licence
 *
 * Copyright © 2022 Brilliant Labs Inc.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#include <stddef.h>

#include "py/obj.h"
#include "py/objarray.h"
#include "py/runtime.h"
#include "py/mperrno.h"

#include "nrfx_log.h"
#include "nrfx_spim.h"
#include "nrfx_systick.h"

#include "driver/bluetooth_data_protocol.h"
#include "driver/config.h"
#include "driver/ecx336cn.h"
#include "driver/fpga.h"
#include "driver/max77654.h"
#include "driver/spi.h"

#include "libgfx.h"

#define LEN(x)      (sizeof(x) / sizeof*(x))
#define VAL(str)    #str
#define STR(str)    VAL(str)

#define FPGA_ADDR_ALIGN  128

STATIC mp_obj_t display___init__(void)
{
    // TODO: remove this once full startup procedure works.
    // Set the FPGA to show the graphic buffer.
    fpga_cmd(FPGA_GRAPHICS_CLEAR);
    nrfx_systick_delay_ms(30);
    fpga_cmd(FPGA_GRAPHICS_SWAP);
    nrfx_systick_delay_ms(30);
    fpga_cmd(FPGA_GRAPHICS_ON);
    nrfx_systick_delay_ms(30);

    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_0(display___init___obj, display___init__);

gfx_obj_t gfx_obj_list[50];
size_t gfx_obj_num;

STATIC void flush_blocks(gfx_row_t yuv422, size_t pos, size_t len)
{
    assert(pos + len <= yuv422.len);

    // Easier and more generic to place this optimization here than
    // checking every time from the caller.
    if (len == 0)
    {
        return;
    }

    // set the base address
    uint32_t u32 = yuv422.y * yuv422.len + pos;
    uint8_t base[sizeof u32] = { u32 >> 24, u32 >> 16, u32 >> 8, u32 >> 0 };
    assert(u32 < OV5640_WIDTH * OV5640_HEIGHT * 2);
    fpga_cmd_write(FPGA_GRAPHICS_BASE, base, sizeof base);

    // Flush the content of the screen skipping empty bytes.
    fpga_cmd_write(FPGA_GRAPHICS_DATA, yuv422.buf + pos, len);
}

STATIC bool block_has_content(gfx_row_t yuv422, size_t pos)
{
    uint8_t black[] = GFX_YUV422_BLACK;

    assert(yuv422.len % sizeof black == 0);
    assert(pos % sizeof black == 0);
    assert(pos < yuv422.len);

    for (size_t i = pos; i < yuv422.len && i < pos + FPGA_ADDR_ALIGN; i += sizeof black)
    {
        if (memcmp(yuv422.buf + i, black, sizeof black) != 0)
        {
            return true;
        }
    }
    return false;
}

STATIC void flush_row(gfx_row_t yuv422)
{
    // Print all contiguous blocks that can be flushed altogether
    for (size_t i = 0;;)
    {
        size_t beg, end;

        // find the start position
        for (;; i+= FPGA_ADDR_ALIGN)
        {
            if (i == yuv422.len)
            {
                return;
            }
            if (block_has_content(yuv422, i))
            {
                break;
            }
        }
        beg = i;

        // find the end position
        for (; i < yuv422.len; i+= FPGA_ADDR_ALIGN)
        {
            if (!block_has_content(yuv422, i))
            {
                break;
            }
        }
        end = i;

        flush_blocks(yuv422, beg, end - beg);
    }
}

STATIC mp_obj_t display_show(void)
{
    uint8_t buf[ECX336CN_WIDTH * 2];
    uint8_t buf2[1 << 15]; memset(buf2, 0, sizeof buf2);
    gfx_row_t yuv422 = { .buf = buf, .len = sizeof buf, .y = 0 };

    // fill the display with YUV422 black pixels
    fpga_cmd(FPGA_GRAPHICS_CLEAR);
    nrfx_systick_delay_ms(30);

    // Walk through every line of the display, render it, send it to the FPGA.
    for (; yuv422.y < OV5640_HEIGHT; yuv422.y++)
    {
        // Clean the row before writing to it
        gfx_fill_black(yuv422);

        // Render a single row, and if anything was updated, also flush it
        if (gfx_render_row(yuv422, gfx_obj_list, gfx_obj_num))
        {
            flush_row(yuv422);
        }
    }

    // The framebuffer we wrote to is ready, now we can display it.
    fpga_cmd(FPGA_GRAPHICS_SWAP);

    // Empty the list of elements to draw.
    memset(gfx_obj_list, 0, sizeof gfx_obj_list);
    gfx_obj_num = 0;

    return mp_const_none;
}
MP_DEFINE_CONST_FUN_OBJ_0(display_show_obj, &display_show);

STATIC mp_obj_t display_brightness(mp_obj_t brightness_in)
{
    mp_int_t brightness = mp_obj_get_int(brightness_in);
    ecx336cn_luminance_t tab[] = {
        ECX336CN_DIM,
        ECX336CN_LOW,
        ECX336CN_MEDIUM,
        ECX336CN_HIGH,
        ECX336CN_BRIGHT,
    };

    if (brightness >= MP_ARRAY_SIZE(tab))
    {
        mp_raise_ValueError(MP_ERROR_TEXT("brightness must be between 0 and 4"));
    }

    ecx336cn_set_luminance(tab[brightness]);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(display_brightness_obj, &display_brightness);

STATIC void new_gfx(gfx_type_t type, mp_int_t x, mp_int_t y, mp_int_t width, mp_int_t height, mp_int_t rgb, gfx_arg_t arg)
{
    uint8_t yuv444[3] = GFX_RGB_TO_YUV444((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, (rgb >> 0) & 0xFF);
    gfx_obj_t *gfx;

    // Validate parameters
    assert(width >= 0);
    assert(height >= 0);
    if (rgb < 0 || rgb > 0xFFFFFF)
    {
        mp_raise_ValueError(MP_ERROR_TEXT("color must be between 0x000000 and 0xFFFFFF"));
    }

    // Get the latest free slot
    if (gfx_obj_num >= LEN(gfx_obj_list))
    {
        mp_raise_OSError(MP_ENOMEM);
    }
    gfx = gfx_obj_list + gfx_obj_num;

    // This is the only place where we increment this number.
    gfx_obj_num++;

    // Fill the new slot.
    gfx->type = type;
    gfx->x = x;
    gfx->y = y;
    gfx->width = width;
    gfx->height = height;
    memcpy(gfx->yuv444, yuv444, sizeof yuv444);
    gfx->arg = arg;
}

STATIC mp_obj_t display_line(size_t argc, mp_obj_t const args[])
{
    mp_int_t x1 = mp_obj_get_int(args[0]);
    mp_int_t y1 = mp_obj_get_int(args[1]);
    mp_int_t x2 = mp_obj_get_int(args[2]);
    mp_int_t y2 = mp_obj_get_int(args[3]);
    mp_int_t rgb = mp_obj_get_int(args[4]);
    gfx_arg_t arg = { .u32 = (x1 < x2) != (y1 < y2) };
    mp_int_t width = (x1 < x2) ? x2 - x1 : x1 - x2;
    mp_int_t height = (y1 < y2) ? y2 - y1 : y1 - y2;
    mp_int_t x = MIN(x1, x2);
    mp_int_t y = MIN(y1, y2);

    new_gfx(GFX_TYPE_LINE, x, y, width, height, rgb, arg);
    return mp_const_none;
}
MP_DEFINE_CONST_FUN_OBJ_VAR_BETWEEN(display_line_obj, 5, 5, display_line);

STATIC mp_obj_t display_text(size_t argc, mp_obj_t const args[])
{
    gfx_arg_t arg = { .ptr = mp_obj_str_get_str(args[0]) };
    mp_int_t x = mp_obj_get_int(args[1]);
    mp_int_t y = mp_obj_get_int(args[2]);
    mp_int_t rgb = mp_obj_get_int(args[3]);
    mp_int_t width = gfx_get_text_width(arg.ptr, strlen(arg.ptr));
    mp_int_t height = gfx_get_text_height();

    new_gfx(GFX_TYPE_TEXT, x, y, width, height, rgb, arg);
    return mp_const_none;
}
MP_DEFINE_CONST_FUN_OBJ_VAR_BETWEEN(display_text_obj, 4, 4, display_text);

STATIC mp_obj_t display_fill(mp_obj_t rgb_in)
{
    mp_int_t rgb = mp_obj_get_int(rgb_in);
    gfx_arg_t null = {0};

    new_gfx(GFX_TYPE_RECTANGLE, 0, 0, OV5640_WIDTH, OV5640_HEIGHT, rgb, null);
    return mp_const_none;
}
MP_DEFINE_CONST_FUN_OBJ_1(display_fill_obj, display_fill);

STATIC mp_obj_t display_hline(size_t argc, mp_obj_t const args[])
{
    mp_int_t x = mp_obj_get_int(args[0]);
    mp_int_t y = mp_obj_get_int(args[1]);
    mp_int_t width = mp_obj_get_int(args[2]);
    mp_int_t height = 1;
    mp_int_t rgb = mp_obj_get_int(args[3]);
    gfx_arg_t null = {0};

    new_gfx(GFX_TYPE_RECTANGLE, x, y, width, height, rgb, null);
    return mp_const_none;
}
MP_DEFINE_CONST_FUN_OBJ_VAR_BETWEEN(display_hline_obj, 4, 4, display_hline);

STATIC mp_obj_t display_vline(size_t argc, mp_obj_t const args[])
{
    mp_int_t x = mp_obj_get_int(args[0]);
    mp_int_t y = mp_obj_get_int(args[1]);
    mp_int_t height = mp_obj_get_int(args[2]);
    mp_int_t width = 1;
    mp_int_t rgb = mp_obj_get_int(args[3]);
    gfx_arg_t null = {0};

    new_gfx(GFX_TYPE_RECTANGLE, x, y, width, height, rgb, null);
    return mp_const_none;
}
MP_DEFINE_CONST_FUN_OBJ_VAR_BETWEEN(display_vline_obj, 4, 4, display_vline);

STATIC const mp_rom_map_elem_t display_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__),    MP_ROM_QSTR(MP_QSTR_display) },
    { MP_ROM_QSTR(MP_QSTR___init__),    MP_ROM_PTR(&display___init___obj) },
    { MP_ROM_QSTR(MP_QSTR_fill),        MP_ROM_PTR(&display_fill_obj) },
    { MP_ROM_QSTR(MP_QSTR_line),        MP_ROM_PTR(&display_line_obj) },
    { MP_ROM_QSTR(MP_QSTR_text),        MP_ROM_PTR(&display_text_obj) },
    { MP_ROM_QSTR(MP_QSTR_hline),       MP_ROM_PTR(&display_hline_obj) },
    { MP_ROM_QSTR(MP_QSTR_vline),       MP_ROM_PTR(&display_vline_obj) },

    // methods
    { MP_ROM_QSTR(MP_QSTR_show),        MP_ROM_PTR(&display_show_obj) },
    { MP_ROM_QSTR(MP_QSTR_brightness),  MP_ROM_PTR(&display_brightness_obj) },
};
STATIC MP_DEFINE_CONST_DICT(display_module_globals, display_module_globals_table);

const mp_obj_module_t display_module = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t*)&display_module_globals,
};
MP_REGISTER_MODULE(MP_QSTR_display, display_module);
