;-------------------------------------------------------------------------------
;  sys_core.asm
;
;  Author      : QJ Wang. qjwang@ti.com
;  Date        : 9-19-2012
;
;  Copyright (c) 2008-2011 Texas Instruments Incorporated.  All rights reserved.
;  Software License Agreement
;
;  Texas Instruments (TI) is supplying this software for use solely and
;  exclusively on TI's microcontroller products. The software is owned by
;  TI and/or its suppliers, and is protected under applicable copyright
;  laws. You may not combine this software with "viral" open-source
;  software in order to form a larger program.
;
;  THIS SOFTWARE IS PROVIDED "AS IS" AND WITH ALL FAULTS.
;  NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
;  NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;  A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. TI SHALL NOT, UNDER ANY
;  CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
;  DAMAGES, FOR ANY REASON WHATSOEVER.
;
; *****************************************************************************

    .text
    .arm

;-------------------------------------------------------------------------------
; Initialize CPU Registers

	.def     _coreInitRegisters_
    .asmfunc
    

_coreInitRegisters_


	; After reset, the CPU is in the Supervisor mode (M = 10011)
	    mov r0, lr
	    mov r1, #0x0000
	    mov r2, #0x0000
	    mov r3, #0x0000
	    mov r4, #0x0000
	    mov r5, #0x0000
	    mov r6, #0x0000
	    mov r7, #0x0000
	    mov r8, #0x0000
	    mov r9, #0x0000
	    mov r10, #0x0000
	    mov r11, #0x0000
	    mov r12, #0x0000
	    mov r13, #0x0000
	    mrs r1, cpsr
	    msr spsr_cxsf, r1 
	    ; Switch to FIQ mode (M = 10001)
	    cps #17
	    mov lr, r0
	    mov r8, #0x0000
	    mov r9, #0x0000
	    mov r10, #0x0000
	    mov r11, #0x0000
	    mov r12, #0x0000
	    mrs r1, cpsr
	    msr spsr_cxsf, r1 
	    ; Switch to IRQ mode (M = 10010)
	    cps #18
	    mov lr, r0
	    mrs r1,cpsr
	    msr spsr_cxsf, r1 	    
	    ; Switch to Abort mode (M = 10111)
	    cps #23
	    mov lr, r0
	    mrs r1,cpsr
	    msr spsr_cxsf, r1 	    
	    ; Switch to Undefined Instruction Mode (M = 11011)
	    cps #27
	    mov lr, r0
	    mrs r1,cpsr
	    msr spsr_cxsf, r1 	    
	    ; Switch back to Supervisor Mode (M = 10011)
	    cps #19

   .if __TI_VFPV3D16_SUPPORT__ = 1
        mrc   p15,     #0x00,      r2,       c1, c0, #0x02
        orr   r2,      r2,         #0xF00000
        mcr   p15,     #0x00,      r2,       c1, c0, #0x02
        mov   r2,      #0x40000000
        fmxr  fpexc,   r2

		fmdrr d0,         r1,     r1
        fmdrr d1,         r1,     r1
        fmdrr d2,         r1,     r1
        fmdrr d3,         r1,     r1
        fmdrr d4,         r1,     r1
        fmdrr d5,         r1,     r1
        fmdrr d6,         r1,     r1
        fmdrr d7,         r1,     r1
        fmdrr d8,         r1,     r1
        fmdrr d9,         r1,     r1
        fmdrr d10,        r1,     r1
        fmdrr d11,        r1,     r1
        fmdrr d12,        r1,     r1
        fmdrr d13,        r1,     r1
        fmdrr d14,        r1,     r1
        fmdrr d15,        r1,     r1
    .endif
        bl    next1
next1
        bl    next2
next2
        bl    next3
next3
        bl    next4
next4
        bx    r0

    .endasmfunc

;-------------------------------------------------------------------------------
;
; Copy the Flash API from flash to SRAM.
;

    .def     _copyAPI2RAM_
    .asmfunc

_copyAPI2RAM_

   .ref    api_load
flash_load   .word api_load
   .ref    api_run
flash_run   .word api_run
    .ref    api_size
flash_size  .word api_size

     ldr    r0, flash_load
     ldr    r1, flash_run
     ldr    r2, flash_size
     add    r2, r1, r2
copy_loop1:
     ldr     r3, [r0], #4
     str     r3, [r1], #4
     cmp     r1, r2
     blt     copy_loop1
      bx     lr

    .endasmfunc


;-------------------------------------------------------------------------------
; Initialize Stack Pointers

    .def     _coreInitStackPointer_
    .asmfunc

_coreInitStackPointer_

        cps   #17
        ldr   sp,       fiqSp
        cps   #18
        ldr   sp,       irqSp
        cps   #23
        ldr   sp,       abortSp
        cps   #27
        ldr   sp,       undefSp
        cps   #31
        ldr   sp,       userSp
        cps   #19
        ldr   sp,       svcSp
        bx    lr

userSp  .word 0x08000000+0x00000200
svcSp   .word 0x08000000+0x00000200+0x00001500
fiqSp   .word 0x08000000+0x00000200+0x00001500+0x00000100
irqSp   .word 0x08000000+0x00000200+0x00001500+0x00000100+0x00000200
abortSp .word 0x08000000+0x00000200+0x00001500+0x00000100+0x00000200+0x00000100
undefSp .word 0x08000000+0x00000200+0x00001500+0x00000100+0x00000200+0x00000100+0x00000100

    .endasmfunc

;-------------------------------------------------------------------------------
; Enable VFP Unit

    .def     _coreEnableVfp_
    .asmfunc

_coreEnableVfp_
   .if __TI_VFPV3D16_SUPPORT__ = 1
        mrc   p15,     #0x00,      r0,       c1, c0, #0x02
        orr   r0,      r0,         #0xF00000
        mcr   p15,     #0x00,      r0,       c1, c0, #0x02
        mov   r0,      #0x40000000
        fmxr  fpexc,   r0
    .endif
        bx    lr

    .endasmfunc

;-------------------------------------------------------------------------------
; Enable Event Bus Export

    .def     _coreEnableEventBusExport_
    .asmfunc

_coreEnableEventBusExport_

        stmfd sp!, {r0}
        mrc   p15, #0x00, r0,         c9, c12, #0x00
        orr   r0,  r0,    #0x10
        mcr   p15, #0x00, r0,         c9, c12, #0x00
        ldmfd sp!, {r0}
        bx    lr

    .endasmfunc


;-------------------------------------------------------------------------------
; Disable Event Bus Export

    .def     _coreDisableEventBusExport_
    .asmfunc

_coreDisableEventBusExport_

        stmfd sp!, {r0}
        mrc   p15, #0x00, r0,         c9, c12, #0x00
        bic   r0,  r0,    #0x10
        mcr   p15, #0x00, r0,         c9, c12, #0x00
        ldmfd sp!, {r0}		
        bx    lr

    .endasmfunc


;-------------------------------------------------------------------------------
; Enable RAM ECC Support

    .def     _coreEnableRamEcc_
    .asmfunc

_coreEnableRamEcc_

        stmfd sp!, {r0}
        mrc   p15, #0x00, r0,         c1, c0,  #0x01
        orr   r0,  r0,    #0x0C000000
        mcr   p15, #0x00, r0,         c1, c0,  #0x01
        ldmfd sp!, {r0}		
        bx    lr

    .endasmfunc


;-------------------------------------------------------------------------------
; Disable RAM ECC Support

    .def     _coreDisableRamEcc_
    .asmfunc

_coreDisableRamEcc_

        stmfd sp!, {r0}
        mrc   p15, #0x00, r0,         c1, c0,  #0x01
        bic   r0,  r0,    #0x0C000000
        mcr   p15, #0x00, r0,         c1, c0,  #0x01
        ldmfd sp!, {r0}		
        bx    lr

    .endasmfunc


;-------------------------------------------------------------------------------
; Enable Flash ECC Support

    .def     _coreEnableFlashEcc_
    .asmfunc

_coreEnableFlashEcc_

        stmfd sp!, {r0}
        mrc   p15, #0x00, r0,         c1, c0,  #0x01
        orr   r0,  r0,    #0x02000000
        dmb
        mcr   p15, #0x00, r0,         c1, c0,  #0x01
        ldmfd sp!, {r0}		
        bx    lr

    .endasmfunc


;-------------------------------------------------------------------------------
; Disable Flash ECC Support

    .def     _coreDisableFlashEcc_
    .asmfunc

_coreDisableFlashEcc_

        stmfd sp!, {r0}
        mrc   p15, #0x00, r0,         c1, c0,  #0x01
        bic   r0,  r0,    #0x02000000
        mcr   p15, #0x00, r0,         c1, c0,  #0x01
        ldmfd sp!, {r0}		
        bx    lr

    .endasmfunc


;-------------------------------------------------------------------------------
; Enable Offset via Vic controller

    .def     _coreEnableIrqVicOffset_
    .asmfunc

_coreEnableIrqVicOffset_

        stmfd sp!, {r0}
        mrc   p15, #0, r0,         c1, c0,  #0
        orr   r0,  r0,    #0x01000000
        mcr   p15, #0, r0,         c1, c0,  #0
        ldmfd sp!, {r0}		
        bx    lr

    .endasmfunc

;-------------------------------------------------------------------------------
; Disable interrupts - R4 IRQ & FIQ

        .def _disable_interrupt_
        .asmfunc
		
_disable_interrupt_

        cpsid if
        bx    lr
		
        .endasmfunc

;-------------------------------------------------------------------------------
; Disable FIQ interrupt

        .def _disable_FIQ_interrupt_
        .asmfunc
		
_disable_FIQ_interrupt_

        cpsid f
        bx    lr
		
        .endasmfunc

;-------------------------------------------------------------------------------
; Disable FIQ interrupt

        .def _disable_IRQ_interrupt_    
        .asmfunc
		
_disable_IRQ_interrupt_

        cpsid i
        bx    lr
		
        .endasmfunc
		
;-------------------------------------------------------------------------------
; Enable interrupts - R4 IRQ & FIQ

       .def _enable_interrupt_
       .asmfunc

_enable_interrupt_

        cpsie if
        bx    lr
		
        .endasmfunc

		
;-------------------------------------------------------------------------------
; Clear ESM CCM errorss

       .def _esmCcmErrorsClear_
       .asmfunc

_esmCcmErrorsClear_

        stmfd sp!, {r0-r2}		
        ldr   r0, ESMSR1_REG	; load the ESMSR1 status register address
        ldr   r2, ESMSR1_ERR_CLR
        str   r2, [r0]	 	; clear the ESMSR1 register

        ldr   r0, ESMSR2_REG	; load the ESMSR2 status register address
        ldr   r2, ESMSR2_ERR_CLR
        str   r2, [r0]	 	; clear the ESMSR2 register

        ldr   r0, ESMSSR2_REG	; load the ESMSSR2 status register address
        ldr   r2, ESMSSR2_ERR_CLR
        str   r2, [r0]	 	    ; clear the ESMSSR2 register

        ldr   r0, ESMKEY_REG	; load the ESMKEY register address
        mov   r2, #0x5             ; load R2 with 0x5
        str   r2, [r0]	 	    ; clear the ESMKEY register

        ldr   r0, VIM_INTREQ	; load the INTREQ register address
        ldr   r2, VIM_INT_CLR
        str   r2, [r0]	 	; clear the INTREQ register
        ldr   r0, CCMR4_STAT_REG	; load the CCMR4 status register address
        ldr   r2, CCMR4_ERR_CLR
        str   r2, [r0]	 	; clear the CCMR4 status register
        ldmfd sp!, {r0-r2}        
        bx    lr

ESMSR1_REG        .word 0xFFFFF518
ESMSR2_REG        .word 0xFFFFF51C
ESMSR3_REG        .word 0xFFFFF520
ESMKEY_REG        .word 0xFFFFF538
ESMSSR2_REG       .word 0xFFFFF53C
CCMR4_STAT_REG    .word 0xFFFFF600
ERR_CLR_WRD       .word 0xFFFFFFFF
CCMR4_ERR_CLR     .word 0x00010000
ESMSR1_ERR_CLR    .word 0x80000000
ESMSR2_ERR_CLR    .word 0x00000004
ESMSSR2_ERR_CLR   .word 0x00000004
VIM_INT_CLR       .word 0x00000001
VIM_INTREQ        .word 0xFFFFFE20

        .endasmfunc	
		

;-------------------------------------------------------------------------------
; C++ construct table pointers

    .def    __TI_PINIT_Base, __TI_PINIT_Limit
    .weak   SHT$$INIT_ARRAY$$Base, SHT$$INIT_ARRAY$$Limit

__TI_PINIT_Base  .long SHT$$INIT_ARRAY$$Base
__TI_PINIT_Limit .long SHT$$INIT_ARRAY$$Limit

    

;-------------------------------------------------------------------------------

