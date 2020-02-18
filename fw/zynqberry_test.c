#define VRAM        (0xA0200000)
#define GPIO_IN     (0x70000010)
#define GPIO_OUT    (0x70000020)
#define GPIO_DFLT   (0x70000000)
#define GPIO_REFCLK (0x70000004)

#define PIX_SIZE_X 320
#define PIX_SIZE_Y 180

void main()
{
	/*HDMIテスト ななめグラデーションを描画*/
    for(int y = 0; y < PIX_SIZE_Y; y++){
        for(int x = 0; x < PIX_SIZE_X; x++){
            *(volatile unsigned char *)(VRAM + y * PIX_SIZE_X + x) = (unsigned char)(x + y);
        }
    }

	/*Pushスイッチキー入力をそのまま出力*/
	*(volatile int *)(GPIO_DFLT) = 5;
    *(volatile int *)(GPIO_REFCLK) = 5;
    while (1){
		*(volatile int *)(GPIO_OUT) = *(volatile int *)(GPIO_IN);
	}


}
