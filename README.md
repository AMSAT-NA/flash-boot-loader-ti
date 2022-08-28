# FlashBootLoaderTI

This repo contains code for **flash loaders** that run on the Texas Instruments (TI)
TMS570 micro controllers. It is based on sample code supplied by TI and described
in the boot loader description found [here](docs/spna192.pdf).

In this context a **flash loader** is the code that runs on the micro controller
while a **host loader** is a program on an external computer, communicating with it
to download new code into flash.

Only the serial version is present here, while TI also provides `spi` and `can bus`
versions.

When built and installed with TI's `Code Composer Studio` on a micro controller
it can be used to load a new application into flash memory over a serial port
using a **host loader** that can use the **ymodem protocol** to send and receive
files.

## Memory structure

The flash loader itself lives at the bottom of the flash memory starting with
`0x20` (8x32 bits) for interrupt vectors followed by the boot loader code. The
application area starts at flash address `0x10000` (64k) with 256 bytes (`0x100`) of
book keeping data followed by the application itself in address `0x10100`. A dump
of application memory is shown below:

![Application memory map](img/BootloaderMemoryMap.png)

If an application has been loaded without and error the flash loader will write
the pattern `0x5a5a5a5a` at the start of the area, followed by the start address
of the application (`0x10100` here), followed by the size of the application in
bytes. The proper application code starts at address `0x10100` with 32 bytes containing
eight interrupt vectors of the application.