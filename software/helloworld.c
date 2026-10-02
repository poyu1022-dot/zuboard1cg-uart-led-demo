#include "xparameters.h"
#include "xuartps.h"
#include "xil_printf.h"
#include "sleep.h"

int main()
{
    XUartPs Uart_Ps;
    XUartPs_Config *Config = XUartPs_LookupConfig(XPAR_XUARTPS_0_BASEADDR);
    XUartPs_CfgInitialize(&Uart_Ps, Config, Config->BaseAddress);
    XUartPs_SetBaudRate(&Uart_Ps, 115200);

    while (1) {
        xil_printf("Hi AMD Ross, what a wonderful world!\r\n");
        sleep(1);
    }
    return 0;
}
