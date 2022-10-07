## GM-PROTO-E1 Example "button"

This Verilog example program validates the function of the two push buttons PB0 and PB1. Push buttons are a bit tricky for the need of clock synchronisation and debounce. In this program, a running light moves over the four LEDs. Push button PB0 controls the speed in 4 levels (1,2,4,8Hz), while push button PB1 controls the direction of the movement. The current state is displayed on the two 7-Segment modules: HEX0 displays the speed level 0..3, and HEX1 shows the direction F (forward) or b (backward).

### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-tht/button$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/button.v src/debounce.v src/hexdigit.v; synth_gatemate -top button -vlog net/button_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/button_synth.v -o button -ccf ../gm-proto-e1-tht.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag button_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
