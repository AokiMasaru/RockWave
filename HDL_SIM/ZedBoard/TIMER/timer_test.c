/*
 * Filename: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/TIMER/timer_test.c
 * Path: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/TIMER
 * Created Date: Friday, October 27th 2023, 6:52:43 am
 * Author: Masaru Aoki
 * 
 * Copyright (c) 2023 Your Company
 */

// TIMER
volatile unsigned char      * const reg_msip      = ((unsigned long *)0x02000000U);
volatile unsigned long long * const reg_mtimecmp  = ((unsigned long *)0x02004000U);
volatile unsigned long long * const reg_mtime     = ((unsigned long *)0x0200BFF8U);

extern EnableTimer();
extern EnableInt();
extern StartTimer();

void main()
{
    *reg_msip      = 0xFF;
    *reg_msip      = 0x55;
    *reg_msip      = 0xAA;
    *reg_msip      = 0x00;



    *reg_mtimecmp  = 0xFFFFFFFFFFFFFFFF;
    *reg_mtimecmp  = 0x5555555555555555;
    *reg_mtimecmp  = 0xAAAAAAAAAAAAAAAA;
    *reg_mtimecmp  = 0x0000000000000000;

    *reg_mtimecmp  = 0x0000000000000A00;

    // Enable Timer
    StartTimer();

    while(*reg_mtime < *reg_mtimecmp);

    for(int i=0;i<10;i++);

    *reg_mtimecmp  = 0xFFFFFFFFFFFFFFFF;

    for(int i=0;i<10;i++);
}
