/*
 * Filename: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/VGA/vga_test.c
 * Path: /home/aokim/Company/RISCV/RockWave/HDL_SIM/ZedBoard/VGA
 * Created Date: Friday, October 27th 2023, 12:08:47 pm
 * Author: Masaru Aoki
 * 
 * Copyright (c) 2023 Your Company
 */

// VGA
volatile unsigned char      * const reg_vga_en    = ((unsigned long *)0x60000000U);
volatile unsigned char      * const reg_vsync     = ((unsigned long *)0x60000004U);

void main()
{
    *reg_vga_en      = 0x01;
    *reg_vga_en      = 0x00;
    *reg_vga_en     = 0x01;


    while(*reg_vsync != 0x00);

    for(int i=0;i<100000;i++);

    while(*reg_vsync != 0x00);

    while(*reg_vsync != 0x00);

    while(*reg_vsync != 0x00);
    *reg_vga_en      = 0x00;

}
