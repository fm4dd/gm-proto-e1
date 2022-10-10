## GM-PROTO-E1 Example "display"

This Verilog example program validates the function of an HD44780-compatible character LCD display.
The display connects to a 7x2 pin socket, wired on the prototype area with following schematic:

<img src=./charlcd-schematic.png width="640px">

I am using a 3.3V display model Sunlike SC2004CSLB-XA-LB-G(4x20 chars).
The 2.5V logic level is directly connected to the LCD IO lines.

**Note:**
The Verilog code operates the display in 4-bit mode, which leaves wires DB0..3 (blue color) unused.
In this demo, the hardware constraints file is located inside the "src" folder.

### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-tht/display$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/display.v; synth_gatemate -top display -vlog net/display_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/display_synth.v -o display -ccf src/gm-proto-e1-charlcd.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag display_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```


<img src=./charlcd-demo.png width="640px">
