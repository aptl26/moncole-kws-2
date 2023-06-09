#
# This file is part of the MicroPython for Monocle project:
#      https://github.com/brilliantlabsAR/monocle-micropython
#
# Authored by: Josuah Demangeon (me@josuah.net)
#              Raj Nakarja / Brilliant Labs Ltd. (raj@itsbrilliant.co)
#
# ISC Licence
#
# Copyright © 2023 Brilliant Labs Ltd.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

import _camera as __camera
import bluetooth as __bluetooth
import fpga as __fpga
import time as __time

RGB = "RGB"
YUV = "YUV"
JPEG = "JPEG"

__overlay_state = False


def capture(url):
    raise NotImplementedError


def overlay(enable=None):
    if enable == None:
        global __overlay_state
        return __overlay_state
    if enable == True:
        __fpga.write(0x4404, "")
        __time.sleep_ms(100)
        __camera.wake()
        __fpga.write(0x1005, "")
        __fpga.write(0x3005, "")
        __overlay_state = True
    else:
        __fpga.write(0x3004, "")
        __fpga.write(0x1004, "")
        __time.sleep_ms(100)
        __camera.sleep()
        __overlay_state = False


def output(x, y, format):
    raise NotImplementedError


def zoom(multiplier):
    __camera.wake()
    __time.sleep_ms(100)
    __camera.zoom(multiplier)
    if not overlay():
        __camera.sleep()


def record(enable):
    if enable:
        # Overlay seems to be required for recording.
        overlay(True)
        __fpga.write(0x1005, b"")  # record on
    else:
        # This pauses the image, ready for replaying
        __fpga.write(0x1004, b"")  # record off
        __camera.sleep()


def replay():
    # Stop recording to avoid output mixing live and recorded feeds
    record(False)

    # This will trigger one replay of the recorded feed
    __fpga.write(0x3007, b"")  # replay once
    __time.sleep(4)
