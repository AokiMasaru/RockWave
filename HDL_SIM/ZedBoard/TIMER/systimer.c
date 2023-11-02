/*
 * *****************************************************************
 * File: systimer.c
 * Category: MaRTOS
 * File Created: 2023/08/26 08:44
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: Wed Nov 01 2023
 * Modified By: Masaru Aoki
 * *****
 * Copyright 2023 - 2023  Project MaRTOS
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/08/26	Masaru Aoki	First Version
 * *****************************************************************
 */

extern volatile unsigned long long * const reg_mtimecmp;
extern volatile unsigned long long * const reg_mtime;
extern void setTrapVector();
extern void trap_vectors();


void systimer(void)
{
    // 次回タイマ割り込み設定
    do{
        *reg_mtimecmp += 0x00000A00;
    } while ((long)(*reg_mtime - *reg_mtimecmp) >= 0);


}

void StartTimer(void)
{
    setTrapVector((unsigned long)trap_vectors + 0x00000001);
    *reg_mtimecmp = *reg_mtime + 0x00000A00;
    EnableTimer();
    EnableInt();
}
