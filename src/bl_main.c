/********************************************************************************************************
 *
 * bl_main.c      : The main file for the boot loader.
 * Author         : QJ Wang. qjwang@ti.com
 * Date           : 2-18-2016
 * 2022-08-26 Heimir Thor Sverrisson, w1ant, heimir.sverrisson@gmail.com
 *
 * Copyright (c) 2006-2011 Texas Instruments Incorporated.  All rights reserved.
 * Software License Agreement
 *
 * Texas Instruments (TI) is supplying this software for use solely and
 * exclusively on TI's microcontroller products. The software is owned by
 * TI and/or its suppliers, and is protected under applicable copyright
 * laws. You may not combine this software with "viral" open-source
 * software in order to form a larger program.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND WITH ALL FAULTS.
 * NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
 * NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. TI SHALL NOT, UNDER ANY
 * CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES, FOR ANY REASON WHATSOEVER.
 *
 * Author:  Qingjun Wang  (qjwang@ti.com)
 *---------------------------------------------------------------------------------------------------------------------
 * Revision History
 *---------------------------------------------------------------------------------------------------------------------
 * Version          Date        Author         Description
 *---------------------------------------------------------------------------------------------------------------------
 * 00.10.00       19/09/2012    QJ Wang        1. Initial Version
 * 00.10.01       10/01/2014    QJ Wang        1. Changes for Rev2.01.00 F021 Flash API
 * 00.10.02       11/12/2014    QJ Wang        1. Changes for Rev2.01.01 F021 Flash API
 * 00.20.00       18/02/2016    QJ Wang        1. Rewrote code for y-modem protocol, and CRC16
 *                                             2. Changes in bl_flash.c, bl_link.cmd
 *                                             3. Changed App start address to 0x10100, The 0x10000~0x10100 is left for
 *                                                application update status
 *                                             4. Added TMS570LS0714 devices
 ***********************************************************************************************************/

#include "bl_config.h"
#include "bl_uart.h"
#include "system.h"
#include "bl_check.h"
#include "sci_common.h"
#include "bl_led_demo.h"

/*****************************************************************************
 *
 * This holds the current remaining size in bytes to be downloaded.
 *
 ******************************************************************************/
uint32_t g_ulTransferSize;

/*****************************************************************************
 *
 * This holds the current address that is being written to during a download
 * command.
 *
 ******************************************************************************/
uint32_t g_ulTransferAddress;

/*****************************************************************************
 *
 * This is the data buffer used during transfers to the boot loader.
 *
 ******************************************************************************/
uint32_t g_pulDataBuffer[BUFFER_SIZE];

/*****************************************************************************
 *
 * This is the data buffer used for update status.
 *
 * g_pulUpdateSuccess[] are used to store application update status and application
 * image's version etc
 ******************************************************************************/

uint32_t g_pulUpdateSuccess[] =
		{ 0x5A5A5A5A, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
uint32_t g_ulUpdateStatusAddr = APP_STATUS_ADDRESS;

uint32_t g_ulUpdateBufferSize = 32; /*32 bytes or 8 32-bit words*/

#define E_PASS     		0
#define E_FAIL     		0x1U
#define E_TIMEOUT  		0x2U

/*****************************************************************************
 *
 * This is an specially aligned buffer pointer to g_pulDataBuffer to make
 * copying to the buffer simpler.  It must be offset to end on an address that
 * ends with 3.
 *
 ******************************************************************************/
uint8_t *g_pucDataBuffer;

/*****************************************************************************
 *
 * This holds the current address that is being written to during a download
 * command.
 *
 ******************************************************************************/
void delay(void) {
	static volatile uint32_t delayval;
	delayval = 10000;   // 100000 are about 10ms
	while (delayval--)
		;
}

void main(void) {
	/* Initialize SCI Routines to receive Command and transmit data */
	sciInit();

#ifdef DEBUG_MSG
	UART_putString(UART, "\r\nHercules MCU UART BootLoader\r\n");
	UART_putString(UART, "TI Safety MCU Application Team, qjwang@ti.com\r\n");
#endif

	// Bring GIO out of reset before the call to CheckForceUpdate() below
	CheckGPIOForceUpdate();

	if (!CheckForceUpdate()) {
#ifdef DEBUG_MSG
		UART_putString(UART, "Jump to application...\r\n");
#endif
		g_ulTransferAddress = (uint32_t) APP_START_ADDRESS;
		((void (*)(void)) g_ulTransferAddress)();
	}

	UpdaterUART();
}

