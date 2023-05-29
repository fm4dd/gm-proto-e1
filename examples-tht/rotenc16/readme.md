## GM-PROTO-E1 Example "rotenc16"

<img src="https://media.digikey.com/photos/Omron%20Elect%20Photos/A6R-162RS.jpg" width="120px">

This Verilog example program validates the function of a single 16-position rotary encoder, soldered into the prototyping area of the GM-Proto-E1 board. I am using model ERD216RSZ from vendor Excel Cell Electronics (ECE). 16-position rotary encoders are convenient as data input. With two encoders it is possble to quickly set the hex value of one byte.

### Schematic

<img src=./schematic.jpg width="640px">

### Verilog Code

Verilog code is likewise very simple. The encoder input signal pins can be assigned directly as bit values of one nibble (half-byte). On the GM-Proto-E1 board, we can map the encoder signal bit range straight to the 4 output LED's, and to one of the 7-segment LED displays to show the value in hex.

```
// -------------------------------------------------------
// rotenc16.v   gm-proto-e1 demo program   @20230528 fm4dd
//
// Requires: 4x LEDs, 16-pos rotary encoder, 1x 7-Seg LED
//
// Description:
// ------------
// This program shows the rotary encoder signal on LED0-3,
// and the corresponding hex code on 7-seg display prhex0.
// -------------------------------------------------------
module rotenc16(
  input wire [3:0] prrot,
  output wire [3:0] prled,
  output [7:0] prhex0
);

// -------------------------------------------------------
//  Module hexdigit: Creates the LED pattern from 3 args:
// in:  0-16 sets hex value of led segments, >16 is extra
// dp:  0 or 1, disables/enables the decimal point led
// out: this is the bit pattern for the 7seg module led's
//
// Note: Because 'in' is 5-bit wide to display extra chars
// we set the unused highest bit in[4] to 0, and assign
// the prrot signal to the remaining bits at in[3:0].
// -------------------------------------------------------
  hexdigit h0 ({1'b0, prrot}, 1'b0, prhex0);
  assign prled = prrot;
endmodule
```

### Pin assignment

added in src/gm-proto-e1.ccf:
```
## #######################################################
## gm-proto-e1 proto area 16-pos rotary encoder connection
## #######################################################
Pin_in "prrot[0]"    Loc = "IO_SB_B0" | PULLDOWN=true;
Pin_in "prrot[1]"    Loc = "IO_SB_B1" | PULLDOWN=true;
Pin_in "prrot[2]"    Loc = "IO_SB_B2" | PULLDOWN=true;
Pin_in "prrot[3]"    Loc = "IO_SB_B3" | PULLDOWN=true;

```

### Usage

```
fm@nuc7vm2204:~/fpga/hardware/gm-proto-e1/examples-tht/rotenc16$ make all
/home/fm/cc-toolchain-linux/bin/yosys/yosys -ql log/synth.log -p 'read -sv src/hexdigit.v src/rotenc16.v; synth_gatemate -top rotenc16 -nomx8 -vlog net/rotenc16_synth.v'
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i net/rotenc16_synth.v -o rotenc16 -ccf src/gm-proto-e1-tht.ccf > log/impl.log
/usr/local/bin/openFPGALoader  -b gatemate_evb_jtag rotenc16_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
Load SRAM via JTAG: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```

<img src=./demo.jpg width="640px">
