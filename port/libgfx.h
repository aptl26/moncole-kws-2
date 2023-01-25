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

typedef enum
{
    GFX_TYPE_NULL,      // skip this object
    GFX_TYPE_RECTANGLE, // filled
    GFX_TYPE_LINE,      // diagonal line
    GFX_TYPE_ELLIPSIS,  // diagonal line
    GFX_TYPE_TEXT,      // a single line of text truncated at the end
} gfx_type_t;

typedef struct
{
    uint8_t *buf;
    size_t len;
    int16_t y;
} gfx_row_t;

typedef union
{
    void const *ptr;
    uint32_t u32;
} gfx_arg_t;

typedef struct
{
    int16_t x, y, width, height;
    uint8_t yuv444[3];
    uint8_t type;
    gfx_arg_t arg;
} gfx_obj_t;

#define GFX_RGB_TO_YUV444(r, g, b) { \
    128.0 + 0.29900 * (r) + 0.58700 * (g) + 0.11400 * (b) - 128.0, \
    128.0 - 0.16874 * (r) - 0.33126 * (g) + 0.50000 * (b), \
    128.0 + 0.50000 * (r) - 0.41869 * (g) - 0.08131 * (b) \
}

#define GFX_YUV422_BLACK    { 0x80, 0x00 }

void gfx_set_color(gfx_obj_t *gfx, int16_t line_num, gfx_obj_t *obj_list, size_t obj_num);
bool gfx_render_row(gfx_row_t row, gfx_obj_t *obj_list, size_t obj_num);
void gfx_fill_black(gfx_row_t row);
int16_t gfx_get_text_width(char const *s, size_t len);
int16_t gfx_get_text_height(void);
