/*
*********************************************************************************************************
*                                            EXAMPLE CODE
*
*                          (c) Copyright 2009-2014; Micrium, Inc.; Weston, FL
*
*               All rights reserved.  Protected by international copyright laws.
*
*               Please feel free to use any application code labeled as 'EXAMPLE CODE' in
*               your application products.  Example code may be used as is, in whole or in
*               part, or may be used as a reference only.
*
*               Please help us continue to provide the Embedded community with the finest
*               software available.  Your honesty is greatly appreciated.
*
*               You can contact us at www.micrium.com.
*********************************************************************************************************
*/

/*
*********************************************************************************************************
*
*                                          APPLICATION CODE
*
*                                            CYCLONE V SOC
*
* Filename      : app.c
* Version       : V1.00
* Programmer(s) : JBL
* Modifications	: Nancy Minderman nancy.minderman@ualberta.ca, Brendan Bruner bbruner@ualberta.ca
* 				  Changes to this project include scatter file changes and BSP changes for port from
* 				  Cyclone V dev kit board to DE1-SoC
*********************************************************************************************************
* Note(s)       : none.
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                            INCLUDE FILES
*********************************************************************************************************
*/

#include  <app_cfg.h>
#include  <lib_mem.h>

#include  <bsp.h>
#include  <bsp_int.h>
#include  <bsp_os.h>
#include  <cpu_cache.h>

#include  <cpu.h>
#include  <cpu_core.h>

#include  <os.h>
#include  <hps.h>
#include  <socal.h>
#include  <hwlib.h>
#include <math.h>

#include "audio_cfg.h"
#include "audio.h"

// Compute absolute address of any slave component attached to lightweight bridge
// base is address of component in QSYS window
// This computation only works for slave components attached to the lightweight bridge
// base should be ranged checked from 0x0 - 0x1fffff

#define FPGA_TO_HPS_LW_ADDR(base)  ((void *) (((char *)  (ALT_LWFPGASLVS_ADDR))+ (base)))

#define APP_TASK_PRIO 5
#define AUDIO_TASK_PRIO 7
#define LCD_TASK_PRIO 6

#define TASK_STACK_SIZE 4096
#define LEDR_ADD 0x00000000
#define LEDR_BASE FPGA_TO_HPS_LW_ADDR(LEDR_ADD)
#define SYNTH0_ADD 0x1000
#define SYNTH0_BASE FPGA_TO_HPS_LW_ADDR(SYNTH0_ADD)
#define SYNTH1_ADD 0x1100
#define SYNTH1_BASE FPGA_TO_HPS_LW_ADDR(SYNTH1_ADD)
#define SYNTH2_ADD 0x1200
#define SYNTH2_BASE FPGA_TO_HPS_LW_ADDR(SYNTH2_ADD)
#define SYNTH3_ADD 0x1300
#define SYNTH3_BASE FPGA_TO_HPS_LW_ADDR(SYNTH3_ADD)
#define SYNTH4_ADD 0x1400
#define SYNTH4_BASE FPGA_TO_HPS_LW_ADDR(SYNTH4_ADD)
#define SYNTH5_ADD 0x1500
#define SYNTH5_BASE FPGA_TO_HPS_LW_ADDR(SYNTH5_ADD)
#define SYNTH6_ADD 0x1600
#define SYNTH6_BASE FPGA_TO_HPS_LW_ADDR(SYNTH6_ADD)
#define SYNTH7_ADD 0x1700
#define SYNTH7_BASE FPGA_TO_HPS_LW_ADDR(SYNTH7_ADD)

#define AUDIO_BUFFER_SIZE 128
#define M_PI 3.14159265358979323846
/*
*********************************************************************************************************
*                                       LOCAL GLOBAL VARIABLES
*********************************************************************************************************
*/

CPU_STK AppTaskStartStk[TASK_STACK_SIZE];
CPU_STK AudioTaskStartStk[TASK_STACK_SIZE];
CPU_STK LCDTaskStartStk[TASK_STACK_SIZE];

INT32S lbuffer[32000];
INT32S rbuffer[32000];
INT32S buffer[32000];

/*
*********************************************************************************************************
*                                      LOCAL FUNCTION PROTOTYPES
*********************************************************************************************************
*/

static  void  AppTaskStart              (void        *p_arg);
static  void  AudioTaskStart            (void        *p_arg);
static  void  LCDTaskStart              (void        *p_arg);


/*
*********************************************************************************************************
*                                               main()
*
* Description : Entry point for C code.
*
* Arguments   : none.
*
* Returns     : none.
*
* Note(s)     : (1) It is assumed that your code will call main() once you have performed all necessary
*                   initialisation.
*********************************************************************************************************
*/

int main ()
{
    INT8U os_err;

    BSP_WatchDog_Reset();                                       /* Reset the watchdog as soon as possible.              */

                                                                /* Scatter loading is complete. Now the caches can be activated.*/
    BSP_BranchPredictorEn();                                    /* Enable branch prediction.                            */
    BSP_L2C310Config();                                         /* Configure the L2 cache controller.                   */
    BSP_CachesEn();                                             /* Enable L1 I&D caches + L2 unified cache.             */


    CPU_Init();

    Mem_Init();

    BSP_Init();


    OSInit();


    os_err = OSTaskCreateExt((void (*)(void *)) AppTaskStart,   /* Create the start task.                               */
                             (void          * ) 0,
                             (OS_STK        * )&AppTaskStartStk[TASK_STACK_SIZE - 1],
                             (INT8U           ) APP_TASK_PRIO,
                             (INT16U          ) APP_TASK_PRIO,  // reuse prio for ID
                             (OS_STK        * )&AppTaskStartStk[0],
                             (INT32U          ) TASK_STACK_SIZE,
                             (void          * )0,
                             (INT16U          )(OS_TASK_OPT_STK_CLR | OS_TASK_OPT_STK_CHK));

    if (os_err != OS_ERR_NONE) {
        ; /* Handle error. */
    }

    os_err = OSTaskCreateExt((void (*)(void *)) AudioTaskStart,   /* Create the audio task.                               */
							 (void          * ) 0,
							 (OS_STK        * )&AudioTaskStartStk[TASK_STACK_SIZE - 1],
							 (INT8U           ) AUDIO_TASK_PRIO,
							 (INT16U          ) AUDIO_TASK_PRIO,  // reuse prio for ID
							 (OS_STK        * )&AudioTaskStartStk[0],
							 (INT32U          ) TASK_STACK_SIZE,
							 (void          * )0,
							 (INT16U          )(OS_TASK_OPT_STK_CLR | OS_TASK_OPT_STK_CHK));

	if (os_err != OS_ERR_NONE) {
		; /* Handle error. */
	}

	os_err = OSTaskCreateExt((void (*)(void *)) LCDTaskStart,   /* Create the start task.                               */
							 (void          * ) 0,
							 (OS_STK        * )&LCDTaskStartStk[TASK_STACK_SIZE - 1],
							 (INT8U           ) LCD_TASK_PRIO,
							 (INT16U          ) LCD_TASK_PRIO,  // reuse prio for ID
							 (OS_STK        * )&LCDTaskStartStk[0],
							 (INT32U          ) TASK_STACK_SIZE,
							 (void          * )0,
							 (INT16U          )(OS_TASK_OPT_STK_CLR | OS_TASK_OPT_STK_CHK));

	if (os_err != OS_ERR_NONE) {
		; /* Handle error. */
	}

    CPU_IntEn();

    OSStart();

}


/*
*********************************************************************************************************
*                                           App_TaskStart()
*
* Description : Startup task example code.
*
* Arguments   : p_arg       Argument passed by 'OSTaskCreate()'.
*
* Returns     : none.
*
* Created by  : main().
*
* Notes       : (1) The ticker MUST be initialised AFTER multitasking has started.
*********************************************************************************************************
*/
static  void  AppTaskStart (void *p_arg)
{

    BSP_OS_TmrTickInit(OS_TICKS_PER_SEC);                       /* Configure and enable OS tick interrupt.              */


    for(;;) {
        BSP_WatchDog_Reset();                                   /* Reset the watchdog.                                  */

		OSTimeDlyHMSM(0, 0, 0, 500);

		BSP_LED_On();

		alt_write_word(LEDR_BASE, 0x00);

		OSTimeDlyHMSM(0, 0, 0, 500);

		BSP_LED_Off();

		alt_write_word(LEDR_BASE, 0x3ff);
    }
}

/*
*********************************************************************************************************
*                                           AudioTaskStart()
*
* Description : Startup task example code.
*
* Arguments   : p_arg       Argument passed by 'OSTaskCreate()'.
*
* Returns     : none.
*
* Created by  : main().
*
* Notes       : (1) The ticker MUST be initialised AFTER multitasking has started.
*********************************************************************************************************
*/
static  void  AudioTaskStart (void *p_arg)
{
    // Configure audio device
    // See WM8731 datasheet Register Map
    write_audio_cfg_register(0x0, 0x17);
    write_audio_cfg_register(0x1, 0x17);
    write_audio_cfg_register(0x2, 0x7F);
    write_audio_cfg_register(0x3, 0x7F);
    write_audio_cfg_register(0x4, 0x15); // bits 3, 4, and 5 corresponding to selecting LINE IN BYPASS, DAC output, and MIC BYPASS respectively
    write_audio_cfg_register(0x5, 0x06);
    write_audio_cfg_register(0x6, 0x00);
    write_audio_cfg_register(0x7, 0x4D);
    write_audio_cfg_register(0x8, 0x20); // bits 5:2 config based on sampling rate. Use 0x18 for 32kHz and 0x20 for 44.1kHz
    write_audio_cfg_register(0x9, 0x01);


    for(;;) {
        BSP_WatchDog_Reset();                                   /* Reset the watchdog.                                  */
        alt_write_word(SYNTH0_BASE, 40);
        alt_write_word(SYNTH1_BASE, 47);
        alt_write_word(SYNTH2_BASE, 60);
		buffer[0] = alt_read_word(SYNTH0_BASE) + alt_read_word(SYNTH1_BASE) + alt_read_word(SYNTH2_BASE);
        write_audio_data(buffer, 1);

    }

}

/*
*********************************************************************************************************
*                                           LCDTaskStart()
*
* Description : Startup task example code.
*
* Arguments   : p_arg       Argument passed by 'OSTaskCreate()'.
*
* Returns     : none.
*
* Created by  : main().
*
* Notes       : (1) The ticker MUST be initialised AFTER multitasking has started.
*********************************************************************************************************
*/
static  void  LCDTaskStart (void *p_arg)
{

//	InitLCD();
//	HomeLCD();
//	PrintStringLCD("Hello World\n");

	for(;;) {
        BSP_WatchDog_Reset();                                   /* Reset the watchdog.                                  */

        OSTimeDlyHMSM(0,1,0,0);
	}
}


