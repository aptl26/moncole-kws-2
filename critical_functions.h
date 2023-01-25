/*
 * This file is part of the MicroPython for Monocle project:
 *      https://github.com/brilliantlabsAR/monocle-micropython
 *
 * Authored by: Josuah Demangeon (me@josuah.net)
 *              Raj Nakarja / Brilliant Labs Inc (raj@itsbrilliant.co)
 *
 * ISC Licence
 *
 * Copyright © 2023 Brilliant Labs Inc.
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

#pragma once

#include <stdint.h>
#include <stdbool.h>
#include "nrfx_log.h"
#include "SEGGER_RTT.h"

/**
 * @brief I2C addresses.
 */
#define TOUCH_ADDRESS 0x44  // I2C address for the IQS620A touch controller
#define CAMERA_ADDRESS 0x3C // I2C address for the OV5640 camera module

/**
 * @brief Enumeration of both LEDs on the device. Pass one of these to
 *        pmic_set_led to set it.
 */
typedef enum led_t
{
    GREEN_LED,
    RED_LED
} led_t;

/**
 * @brief Sets the red or green LED connected to the PMIC.
 * @param led: Can be GREEN_LED or RED_LED.
 * @param enable: True = on. False = off
 */
void pmic_set_led(led_t led, bool enable);

/**
 * @brief Logging macro for SeggerRTT based logging. Use like printf.
 */
#define log(format, ...) SEGGER_RTT_printf(0, "\r\n" format, ##__VA_ARGS__)

/**
 * @brief Clears the log screen.
 */
#define log_clear() SEGGER_RTT_printf(0, RTT_CTRL_CLEAR "\r");

/**
 * @brief Error handling macro. Safely logs and restarts the device.
 */
#define app_err(eval)                                                          \
    do                                                                         \
    {                                                                          \
        nrfx_err_t err = (eval);                                               \
        if (0x0000FFFF & err)                                                  \
        {                                                                      \
            log("App error code: 0x%x at %s:%u\r\n", err, __FILE__, __LINE__); \
            if (CoreDebug->DHCSR & CoreDebug_DHCSR_C_DEBUGEN_Msk)              \
            {                                                                  \
                __BKPT();                                                      \
            }                                                                  \
            NVIC_SystemReset();                                                \
        }                                                                      \
    } while (0)

/**
 * @brief I2C response structure. Contains a value and failure flag. If fail is
 *        true, then value is not valid.
 */
typedef struct i2c_response_t
{
    bool fail;
    uint8_t value;
} i2c_response_t;

i2c_response_t i2c_read(uint8_t device_address_7bit,
                        uint8_t register_address,
                        uint8_t register_mask);

i2c_response_t i2c_write(uint8_t device_address_7bit,
                         uint8_t register_address,
                         uint8_t register_mask,
                         uint8_t set_value);

/**
 * @brief Bootloader entry function. Call this to enter DFU mode.
 */
void enter_bootloader(void);