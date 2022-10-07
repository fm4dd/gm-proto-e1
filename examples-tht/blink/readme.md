## GM-PROTO-E1 Example "blink"

This Verilog example program validates the function of the four LED0..3. Using a clock divider for the 10MHz system clock, it alternates between LED0/2 and LED1/3 with a frequency of 2Hz.

### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-tht/blink$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/blink.v; synth_gatemate -top blink -vlog net/blink_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/blink_synth.v -o blink -ccf ../gm-proto-e1-tht.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag blink_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
