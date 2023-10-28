/*
 * Filename: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/TIMER/timer_test.c
 * Path: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/TIMER
 * Created Date: Friday, October 27th 2023, 6:52:43 am
 * Author: Masaru Aoki
 * 
 * Copyright (c) 2023 Your Company
 */

// TIMER
volatile unsigned long      * const reg_vga_en    = ((unsigned long *)0x02000000U);
volatile unsigned long long * const reg_mtimecmp  = ((unsigned long *)0x02004000U);
volatile unsigned long long * const reg_mtime     = ((unsigned long *)0x0200BFF8U);

void main()
{
    *reg_msip      = 0xFFFFFFFF;
    *reg_msip      = 0x55555555;
    *reg_msip      = 0xAAAAAAAA;
    *reg_msip      = 0x00000000;



    *reg_mtimecmp  = 0xFFFFFFFFFFFFFFFF;
    *reg_mtimecmp  = 0x5555555555555555;
    *reg_mtimecmp  = 0xAAAAAAAAAAAAAAAA;
    *reg_mtimecmp  = 0x0000000000000000;

    for(int i=0;i<10;i++){
        int inp = *reg_mtime;
        *reg_mtimecmp = inp;
    }
}
