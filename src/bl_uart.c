//*****************************************************************************
//
// bl_uart.c : Functions to transfer data via the UART port.
// Author    : QJ Wang. qjwang@ti.com
// Date      : 9-19-2012
//
// 2022-08-28, Heimir Thor Sverrisson, w1ant, heimir.sverrisson@gmail.com
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
#include "bl_config.h"

#include "hw_sci.h"
#include "bl_uart.h"
#include "sci_common.h"
#include "bl_ymodem.h"
#include "sys_common.h"
#include "bl_led_demo.h"

uint32_t JumpAddress;
void get_software_Version(void);
void get_hardware_Info(void);
static void checkUpdate(void);
uint32_t CheckForceUpdate(void);

extern uint32_t g_pulUpdateSuccess[8];
extern uint32_t g_ulUpdateStatusAddr;
extern uint32_t g_ulUpdateBufferSize;  //32 bytes or 8 32-bit words
extern char fileName[FILENAME_LEN];
char tab_1024[1024] = { 0 };

void UART_Download() {
#ifdef DEBUG_MSG
	char Number[10] = "          ";
#endif
	int Size = 0;

	Size = Ymodem_Receive(UART, &tab_1024[0]);
	UART_putString(UART, CRLF);
	if (Size > 0) {
#ifdef DEBUG_MSG
		UART_putString(UART, "The application image has been programmed successfully");
		UART_putString(UART, CRLF);
		UART_putString(UART, "---------------------------");
		UART_putString(UART, CRLF);
		UART_putString(UART, "Name: ");
		UART_putString(UART, fileName);
		UART_putString(UART, CRLF);
		Int2Str(Number, Size);
		UART_putString(UART, "Size:     ");
		UART_putString(UART, Number);
		UART_putString(UART, "  Bytes");
		UART_putString(UART, CRLF);
		UART_putString(UART, "---------------------------");
		UART_putString(UART, CRLF);
#endif
		UART_putString(UART, "0");
	} else {
		UART_putString(UART, "1");
	}
}

/**
 * @brief  Upload a file via serial port.
 * @param  None
 * @retval None
 */
void UART_Upload(void) {
	uint32_t status = 0;
	uint32_t *updateInfo;
	uint32_t imageSize;
	uint32_t imageAddress;

	updateInfo = (uint32_t*) g_ulUpdateStatusAddr;

	imageAddress = updateInfo[1];
	imageSize = updateInfo[2];

	if (UART_getKey(UART) == CRC) {
		/* Transmit the flash image through ymodem protocol */
		status = Ymodem_Transmit(UART, (uint8_t*) imageAddress,
				(char*) "UploadedApplicationImage.bin", imageSize);

		UART_putString(UART, CRLF);
		if (status != 0) {
			UART_putString(UART, "1");
		} else {
			UART_putString(UART, "0");
		}
	} else {
		UART_putString(UART, "1");
	}
}

static void showMainMenu(){
	UART_putString(UART, CRLF);
	UART_putString(UART,
			"================== Main Menu ==========================");
	UART_putString(UART, CRLF);
	UART_putString(UART,
			"  1. Download Application Image To the Internal Flash");
	UART_putString(UART, CRLF);
	UART_putString(UART,
			"  2. Upload The Application Image From the Internal Flash");
	UART_putString(UART, CRLF);
	UART_putString(UART, "  3. Execute The Application Code");
	UART_putString(UART, CRLF);
	UART_putString(UART, "  4. Get Flash Loader Version");
	UART_putString(UART, CRLF);
	UART_putString(UART, "  5. Get Device Information");
	UART_putString(UART, CRLF);
	UART_putString(UART, "  6. Check if update is needed");
	UART_putString(UART, CRLF);
	UART_putString(UART, "  ?. Show this menu");
	UART_putString(UART, CRLF);
	UART_putString(UART,
			"=======================================================");
}

//*****************************************************************************
//
//! This function performs the update on the selected port.
//!
//! This function is called directly by the boot loader or it is called as a
//! result of an update request from the application.
//!
//! \return Never returns.
//
//*****************************************************************************
void UpdaterUART(void) {
	char key = 0;

	while (1) {
		LITE_TOPRIGHT_LED;

#ifdef DEBUG_MSG
		showMainMenu();
#endif
		UART_putString(UART, CRLF);
		UART_putString(UART, "$ ");
		key = UART_getKey(UART);

		if (key == 0x31) {
			/* Download user application in the Flash */
			UART_Download();
		} else if (key == 0x32) {
			/* Upload user application from the Flash */
			UART_Upload();
		} else if (key == 0x33) {
			JumpAddress = (uint32_t) APP_START_ADDRESS;
			if(!CheckForceUpdate()){ // Only jump if application is loaded (0x5a5a5a5a pattern written)
				((void (*)(void)) JumpAddress)();
			}
		} else if (key == 0x34) {
			get_software_Version();
		} else if (key == 0x35) {
			get_hardware_Info();
		} else if (key == 0x36) {
			checkUpdate();
		} else if (key == '?') {
			showMainMenu();
		} else {
			UART_putString(UART, "?");
		}
	}
}

static void checkUpdate(){
	UART_putString(UART, CRLF);
	if(CheckForceUpdate()){
		UART_putString(UART, "1");
	} else {
		UART_putString(UART, "0");
	}
}
