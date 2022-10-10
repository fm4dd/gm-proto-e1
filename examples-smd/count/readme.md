## GM-PROTO-E1 Example "count"

This Verilog example program is a binary counter, displayed in binary on the LED's, and in hexadecimal on the two 7-Segment digits.  The hex digits can be enabled or disabled by slide switches SW0 and SW1. The counter runs at 1Hz, and the 7-segment decimal points pulse the counter clock. The counter clock is derived from the 10MHz system clock of the evaluation board.

### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-smd/count$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/count.v src/hexdigit.v; synth_gatemate -top count -vlog net/count_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/count_synth.v -o count -ccf ../gm-proto-e1-smd.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag count_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```

Running "count" example on the gm-proto-e1 module
<img src=count.jpg width="640px">
