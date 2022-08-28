//*****************************************************************************
//
// bl_link.cmd: command file
// Date        : 9-19-2012
//
// Copyright (c) 2006-2011 Texas Instruments Incorporated.  All rights reserved.
// Software License Agreement
//
// Texas Instruments (TI) is supplying this software for use solely and
// exclusively on TI's microcontroller products. The software is owned by
// TI and/or its suppliers, and is protected under applicable copyright
// laws. You may not combine this software with "viral" open-source
// software in order to form a larger program.
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND WITH ALL FAULTS.
// NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
// NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. TI SHALL NOT, UNDER ANY
// CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
// DAMAGES, FOR ANY REASON WHATSOEVER.
//
//*****************************************************************************

--retain="*(.intvecs)"


MEMORY
{
    VECTORS    (X)   : origin=0x00000000 length=0x00000020
    FLASH_API  (RX)  : origin=0x00000020 length=0x000014E0
    FLASH0     (RX)  : origin=0x00001500 length=0x002FEB00
    SRAM       (RW)  : origin=0x08002000 length=0x0002D000
    STACK      (RW)  : origin=0x08000000 length=0x00002000
}
SECTIONS
{
   .intvecs : {} > VECTORS
   flashAPI :
   {
     Fapi_UserDefinedFunctions.obj (.text)
     bl_flash.obj (.text)

     --library = ../../../lib/F021_API_CortexR4_BE.lib (.text)
   } load = FLASH_API, run = SRAM, LOAD_START(api_load), RUN_START(api_run), SIZE(api_size)

   .text  > FLASH0
   .const > FLASH0
   .cinit > FLASH0
   .pinit > FLASH0
   .data  > SRAM
   .bss   > SRAM
}
