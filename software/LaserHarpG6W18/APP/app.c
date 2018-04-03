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
*
* Additional Authors: Adam Narten, Oliver Rarog, Randi Derbyshire, Celeste Chiasson
* Edited on: January 2018
*
*********************************************************************************************************
* Note(s)       : none.
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*                                            INCLUDE FILES
*********************************************************************************************************
*/
#include <app_cfg.h>
#include <lib_mem.h>

#include <bsp.h>
#include <bsp_int.h>
#include <bsp_os.h>
#include <cpu_cache.h>

#include <cpu.h>
#include <cpu_core.h>

#include <os.h>
#include <hps.h>
#include <socal.h>
#include <hwlib.h>
#include <math.h>

#include "lcd.h"
#include "synthesizer.h"
#include "audio_cfg.h"
#include "audio.h"
#include "options.h"
#include "app.h"
#include "button.h"

/*
*********************************************************************************************************
*                                       LOCAL GLOBAL VARIABLES
*********************************************************************************************************
*/

CPU_STK AppTaskStk[TASK_STACK_SIZE];
CPU_STK AudioTaskStk[TASK_STACK_SIZE];

INT32S SYNTH_VALUES[NUM_STRINGS];
INT32S POLY_BUFFER[NUM_STRINGS];
float fractions[NUM_STRINGS];
int integers[NUM_STRINGS];
float fraction_accumulators[NUM_STRINGS];

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
*                   initialization.
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

    os_err = OSTaskCreateExt((void (*)(void *)) AppTask,   /* Create the start task.                               */
                             (void          * ) 0,
                             (OS_STK        * )&AppTaskStk[TASK_STACK_SIZE - 1],
                             (INT8U           ) APP_TASK_PRIO,
                             (INT16U          ) APP_TASK_PRIO,  // reuse prio for ID
                             (OS_STK        * )&AppTaskStk[0],
                             (INT32U          ) TASK_STACK_SIZE,
                             (void          * )0,
                             (INT16U          )(OS_TASK_OPT_STK_CLR | OS_TASK_OPT_STK_CHK));

    if (os_err != OS_ERR_NONE) {
        ; /* Handle error. */
    }

    os_err = OSTaskCreateExt((void (*)(void *)) AudioTask,   /* Create the audio task.                               */
							 (void          * ) 0,
							 (OS_STK        * )&AudioTaskStk[TASK_STACK_SIZE - 1],
							 (INT8U           ) AUDIO_TASK_PRIO,
							 (INT16U          ) AUDIO_TASK_PRIO,  // reuse prio for ID
							 (OS_STK        * )&AudioTaskStk[0],
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
*                                           AppTask()
*
* Description : Startup task example code.
*
* Arguments   : p_arg       Argument passed by 'OSTaskCreate()'.
*
* Returns     : none.
*
* Created by  : main().
*
* Notes       : (1) The ticker MUST be initialized AFTER multitasking has started.
*********************************************************************************************************
*/
static  void  AppTask (void *p_arg)
{

    BSP_OS_TmrTickInit(OS_TICKS_PER_SEC);                       /* Configure and enable OS tick interrupt.              */

	InitLCD();

	for(;;) {
        BSP_WatchDog_Reset();                                   /* Reset the watchdog.                                  */

        if (key_pressed()) {
        	if (key_3_pressed()) {
				change_key();
        	}
        	if (key_2_pressed()) {
				change_scale();
        	}
        	if (key_1_pressed()) {
				change_instrument();
        	}
        	if (key_0_pressed()) {
				change_octave();
        	}
			update_LCD_string();
        }

		OSTimeDlyHMSM(0,0,0,50);
    }
}

/*
*********************************************************************************************************
*                                           AudioTask()
*
* Description : Startup task example code.
*
* Arguments   : p_arg       Argument passed by 'OSTaskCreate()'.
*
* Returns     : none.
*
* Created by  : main().
*
* Notes       : (1) The ticker MUST be initialized AFTER multitasking has started.
*********************************************************************************************************
*/
static  void  AudioTask (void *p_arg)
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

	update_LCD_string();

	char *SYNTH_BASE[8] = {SYNTH0_BASE, SYNTH1_BASE, SYNTH2_BASE, SYNTH3_BASE, SYNTH4_BASE, SYNTH5_BASE, SYNTH6_BASE, SYNTH7_BASE};
	int DIODE_MASK[8] = {DIODE_0_MASK, DIODE_1_MASK, DIODE_2_MASK, DIODE_3_MASK, DIODE_4_MASK, DIODE_5_MASK, DIODE_6_MASK, DIODE_7_MASK};

	// TODO: This should be determined by the button options
	int instrument = 1;
	int extend[8] = {0, 0, 0, 0, 0, 0, 0};
	int extendConstant = 16;
	float envelope[8] = {0,0,0,0,0,0,0,0};

	int i;
    for(;;) {
        BSP_WatchDog_Reset();				/* Reset the watchdog.   */

        POLY_BUFFER[0] = 0;
        get_frequencies(integers, fractions);
        INT8U photodiodes = (INT8U) alt_read_byte(PHOTODIODE_BASE);

        for (i = 0; i < NUM_STRINGS; i++) {
        	writeFreqToSynthesizer(SYNTH_BASE[i], integers[i]);
            fraction_accumulators[i] = fraction_accumulators[i] + fractions[i];
            int enable = (photodiodes & DIODE_MASK[i]);
            if (fraction_accumulators[i] > 1) {
            	alt_write_word(SYNTH_BASE[i], 1);
            	fraction_accumulators[i] = fraction_accumulators[i] - 1;
            }
            if ((extend[i] % extendConstant) == 0) {
				envelope[i] = readFromEnvelope(ENVELOPE_BASE, i, (enable <= 0), instrument);
			}
			extend[i] = extend[i] + 1;
			INT32S read = readFromSythesizer(SYNTH_BASE[i], enable);
			POLY_BUFFER[0] += (INT32S) (read * envelope[i]);
        }
		write_audio_data(POLY_BUFFER, 1);
    }
}
