## GM-PROTO-E1 Example "sound"

This Verilog example program validates the function of a buzzer sound module soldered into the prototyping area by playing a melody. The example has the buzzer + signal connected as "prbuz" to IO_EA_A6.
A press of push button PB0 starts or stops the song. The note values are displayed as binary on the LEDs, and with their value on the two 7-Segment digits. The song played is "Rudolf the rednosed reindeer", with the source code adapted from https://www.fpga4fun.com/MusicBox4.html.


### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-tht/sound$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/debounce.v src/hexdigit.v src/sound.v; synth_gatemate -top sound -nomx8 -vlog net/sound_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/sound_synth.v -o sound -ccf src/gm-proto-e1-tht.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag sound_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
