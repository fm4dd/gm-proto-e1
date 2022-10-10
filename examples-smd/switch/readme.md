## GM-PROTO-E1 Example "switch"

This Verilog example program validates the function of the eight DIP switches. This program works without a clock. Turning a slide switch "on" enables the respective board LED0..7. If only a single switch is on, and remaining switches are "off", the switch number gets shown on the 7-segment display modules as S0..S7, or as SA if all switches are on.

### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-smd/switch$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/hexdigit.v src/switch.v; synth_gatemate -top switch -vlog net/switch_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/switch_synth.v -o switch -ccf ../gm-proto-e1-smd.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag switch_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
