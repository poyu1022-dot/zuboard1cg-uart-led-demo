# ZUBoard 1CG — UART + LED 展示範例

在 Avnet **ZUBoard 1CG**(AMD Zynq UltraScale+ MPSoC, XCZU1CG)上執行的最小可行範例:

- 透過 **UART0**(J16 micro-USB)以 115200-8-N-1 持續送出一行文字訊息到電腦
- 透過 **PL(可程式邏輯)** 自製的計數器邏輯,交互閃爍 User RGB LED **D4 / D5**(約 1 秒切換一次),讓人一眼就能看出「燒錄前 / 燒錄後」的差異
- 附一頁**免安裝、雙擊即用**的 HTML 展示頁(`demo_kit/ZUBoard_Demo.html`),用 Windows 內建的 Edge 瀏覽器(Web Serial API)即時顯示 UART 輸出,並內嵌系統架構方塊圖與技術組成說明,適合業務/FAE 在客戶現場快速展示

## 硬體需求

- Avnet ZUBoard 1CG
- micro-USB 傳輸線(接 J16,兼具 JTAG 與 UART)
- USB-C 15V/3A 電源供應器(接 J15)
- Windows 電腦一台

## 快速開始(使用 `prebuilt/` 內已建置好的檔案,不需安裝 Vivado/Vitis)

1. **硬體準備**
   - BOOT MODE 撥動開關 **SW2** 設定為 JTAG 模式:`ON-ON-ON-ON`
   - micro-USB 接上 **J16**,USB-C 電源接上 **J15**
   - 按下電源鈕 **SW7** 開機(此時 D4、D5 應為熄滅)
2. 雙擊 `demo_kit/1_Program_And_Run.bat`
   - 內部呼叫 `scripts/program_and_run.tcl`,透過 JTAG 燒錄 `prebuilt/system_wrapper.bit` 並執行 `prebuilt/hello_avnet.elf`
   - 完成後終端機會顯示 `APP_RUNNING`,同時 D4、D5 立即開始交互閃爍
3. 雙擊 `demo_kit/ZUBoard_Demo.html`,以瀏覽器(建議 Edge / Chrome)開啟後,點擊「連線至 ZUBoard」並選擇對應的序列埠,即可即時看到 UART 輸出的文字

> 此流程完全不會更動板上 QSPI 原廠出貨的展示程式;展示結束後拔除 USB、把 SW2 撥回 QSPI 開機模式(`ON-OFF-ON-ON`)即可恢復原廠內容。

> `demo_kit/1_Program_And_Run.bat`、`demo_kit/2_Open_Block_Design.bat` 開頭各有一行 `set VITIS_BIN=...` / `set VIVADO_BIN=...`,若您的 AMD Vivado/Vitis 安裝路徑不同,請先修改該行。

## 若要修改設計並重新建置

需要安裝 **AMD Vivado Design Suite** 與 **AMD Vitis**(本範例使用 2026.1 版本開發)。

1. 硬體(FPGA)部分:
   ```
   vivado -mode batch -source hardware/01_create_project.tcl
   vivado -mode batch -source hardware/02_build_bitstream.tcl
   ```
   會在 `build/` 建立 Vivado 專案,並把新的 `.bit` / `.xsa` 輸出到 `prebuilt/`。

2. 軟體(應用程式)部分:
   ```
   vitis -s software/build_platform_and_app.py
   ```
   會依 `prebuilt/zuboard_uart_led.xsa` 建立 Standalone 平台,並編譯 `software/helloworld.c` 為 `software/vitis_ws/hello_avnet/build/hello_avnet.elf`。若想直接用於 `demo_kit`,建置完成後複製取代 `prebuilt/hello_avnet.elf` 即可。

3. 若修改了硬體(例如改變 LED 閃爍頻率的 Verilog 或接腳),記得重新產生 `psu_init.tcl`:重新執行步驟 2 的軟體建置一次,會在 `software/vitis_ws/zuboard_platform/export/zuboard_platform/hw/sdt/psu_init.tcl` 產生新版本,複製取代 `prebuilt/psu_init.tcl`。

## 修改印出的訊息

編輯 `software/helloworld.c` 裡的 `xil_printf(...)` 字串,重新執行上面的 Vitis 建置步驟即可。

## 修改 LED 閃爍頻率

編輯 `hardware/led_blink.v` 中 `CLK_FREQ_HZ` 參數(目前對應 pl_clk0 = 100MHz,計數到位即切換一次,約為 1 秒),重新執行 Vivado 建置步驟即可。

## 專案結構

```
├── hardware/                Vivado 專案來源(Tcl 腳本 + Verilog + 接腳限制)
│   ├── 01_create_project.tcl   建立專案與 Block Design(PS + UART0 + LED PL 邏輯)
│   ├── 02_build_bitstream.tcl  合成 / 實作 / 產生位元流 / 匯出硬體平台(.xsa)
│   ├── led_blink.v             D4/D5 交互閃爍邏輯(以 pl_clk0 分頻計數)
│   └── led_constraints.xdc     D4(Bank 44)、D5(Bank 65/66)接腳與電氣特性限制
├── software/                Vitis 應用程式來源
│   ├── helloworld.c            主程式:設定 UART0 為 115200 並持續印出訊息
│   └── build_platform_and_app.py  建立 Standalone 平台 + 應用程式(Vitis Python API)
├── scripts/
│   ├── program_and_run.tcl     透過 JTAG(XSDB)燒錄並執行
│   ├── capture_serial.ps1      擷取指定秒數的序列埠輸出(驗證用)
│   └── serial_monitor.ps1      持續監看序列埠輸出(Ctrl+C 結束)
├── demo_kit/                 客戶現場展示用套件(雙擊即用)
│   ├── 1_Program_And_Run.bat
│   ├── 2_Open_Block_Design.bat / open_block_design.tcl
│   └── ZUBoard_Demo.html       操作步驟 + 即時 UART 顯示 + 架構圖 + 技術組成說明
└── prebuilt/                 已建置完成的成品,供直接展示使用
    ├── system_wrapper.bit
    ├── hello_avnet.elf
    ├── zuboard_uart_led.xsa
    └── psu_init.tcl
```

## 技術組成

| 項目 | 內容 |
|---|---|
| 目標晶片 | AMD Zynq UltraScale+ MPSoC — XCZU1CG(Arm Cortex-A53 處理系統 PS + FPGA 可程式邏輯 PL) |
| 硬體設計工具 | AMD Vivado Design Suite 2026.1 — IP Integrator 建立 PS 方塊設計,並以 Verilog 撰寫 LED 邏輯後整合進同一顆晶片 |
| 軟體開發工具 | AMD Vitis Unified IDE 2026.1(Python API)— 由硬體匯出檔(.xsa)建立 Standalone 平台與應用程式專案 |
| 執行環境 | Standalone(裸機,無作業系統),執行於 Cortex-A53 #0 |
| 程式語言 | C(應用程式邏輯)、Verilog(PL LED 閃爍模組)、Tcl / Python(建置與燒錄自動化腳本) |
| 關鍵函式庫 / 驅動 | xuartps(UART 驅動)、xil_printf(標準輸出)、FSBL 與 PMUFW(由 Vitis 平台自動產生的開機元件) |
| 燒錄 / 除錯介面 | JTAG,透過板載 FTDI FT2232H 晶片,以 XSDB(Xilinx System Debugger)+ hw_server 執行下載與啟動 |
| 展示網頁技術 | 純 HTML5 + CSS3 + JavaScript(Web Serial API)— 不需安裝、不需伺服器,雙擊即可用 Edge / Chrome 開啟 |

## 疑難排解

- **`xsdb` 找不到 target / 燒錄失敗**:通常是板子的 USB 連線斷開了。檢查 micro-USB 是否確實插著、板子是否通電,必要時拔插重試。
- **瀏覽器頁面按下連線後跳出的序列埠清單是空的**:確認 SW2 已切到 JTAG 模式且已完成步驟 2(燒錄程式),Windows 才會列出對應的 USB 序列埠。
- **瀏覽器不支援 Web Serial API**:改用 Microsoft Edge 或 Google Chrome(Windows 內建 Edge 即符合需求),Firefox / Safari 目前不支援此 API。

## 參考文件

- ZUBoard 1CG Getting Started Guide(Avnet)
- ZUBoard 1CG Hardware User's Guide(Avnet)— UART0 / MIO 腳位、User RGB LED 腳位定義來源
