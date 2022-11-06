## GM-PROTO-E1 Example "buzzer"

This Verilog example program validates the function of a buzzer sound module soldered into the prototyping area. The example has the buzzer + signal connected as "prbuz" to IO_EA_A6. A press on each of the two push buttons creates a different frequency, which outputs a different tone on the buzzer. Each button lights up its equivalent LED, and the button number is displayed on two of the six 7-segment display modules as b0 or b1.


### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-tht/buzzer$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/buzzer.v src/hexdigit.v; synth_gatemate -top buzzer -nomx8 -vlog net/buzzer_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/buzzer_synth.v -o buzzer -ccf ../gm-proto-e1-tht.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag buzzer_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
