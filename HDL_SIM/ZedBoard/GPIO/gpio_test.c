/*
 * Filename: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/GPIO/gpio_test.c
 * Path: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/GPIO
 * Created Date: Wednesday, October 25th 2023, 5:35:09 am
 * Author: Masaru Aoki
 * 
 * Copyright (c) 2023 Your Company
 */

// GPIO
volatile unsigned char  * const reg_dflt_st    = ((unsigned long *)0x70000000U);
volatile unsigned char  * const reg_refclk_st  = ((unsigned long *)0x70000004U);
volatile unsigned short * const reg_input      = ((unsigned long *)0x70000010U);
volatile unsigned char  * const reg_output     = ((unsigned long *)0x70000020U);

void main()
{
    *reg_dflt_st    = 0x01;
    *reg_refclk_st  = 0x01;

    *reg_output = 0x55;
    *reg_output = 0xAA;
    *reg_output = 0xFF;
    *reg_output = 0x00;

    int inp = *reg_input;
    *reg_output = inp;

}
