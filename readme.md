# FlashBootLoader_TI

This repo contains code for **flash loaders** that run on the Texas Instruments (TI)
TMS570 micro controllers. It is based on sample code supplied by TI and described
in the boot loader description found [here](docs/spna192.pdf).

In this context a **flash loader** is the code that runs on the micro controller
while a **host loader** is a program on an external computer communicating with it
to download new code into flash.

Only the serial version is present here, while TI also provides `spi` and `can bus`
versions.

When built and installed with TI's `Code Composer Studio` on a micro controller
it can be used to load a new application into flash memory over a serial port
using a **host loader** that can use the **ymodem protocol** to send and receive
files.