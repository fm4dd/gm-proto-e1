## Gatemate E1 Character LCD Example "display-2"

This Verilog example program validates the function of an HD44780-compatible character LCD display in 8-bit mode. I am using a 3.3V display model Sunlike SC2004CSLB-XA-LB-G(4x20 chars). The FPGA 2.5V logic level is directly connected to the LCD IO lines via the 2x7 pin socket soldered to the GM-PROTO-E1 interface board from https://github.com/fm4dd/gm-proto-e1

The LCD interface is wired to the FPGA IO banks EB and EA per below schematic:
<img src=../display/charlcd-schematic.png width="800px">

The hardware definition file for this setup is in [src/gm-proto-e1.ccf](src/gm-proto-e1.ccf)

The GM-PROTO-E1 pushbutton PB0 is used to toggle the display message on, and off (CLS). The LCD control line status is shown on the E1 onboard LEDs D1..D6, while the GM-PROTO-E1 LED0 and LED1 show the PB0 toggle state.

### Usage

```
fm@nuc7fpga:/mnt/hgfs/fpga/hardware/gm-proto-e1/examples-tht/display-2$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/debounce.v src/display.v src/lcd_transmit.v; synth_gatemate -top display -nomx8 -vlog net/display_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/display_synth.v -o display -ccf src/gm-proto-e1.ccf > log/impl.log
/usr/bin/openFPGALoader  -b gatemate_evb_jtag display_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```

The example will look like this:
<img src=./charlcd-demo.jpg width="640px">
