// -------------------------------------------------------
// switch.v    gm-proto-e1 demo program    @20220924 fm4dd
//
// Requires: 4x LEDs, 4x Slide Switches, 2x 7-Seg modules
//
// Description:
// ------------
// This program tests the slide switches turn on/off their
// respective LED's by simply wiring them without a clock.
// The switch number is shown on the 7-segment display.
// -------------------------------------------------------
module switch(
   input wire [3:0] prswi,
   output wire [3:0] prled,
   output [7:0] prhex0,
   output [7:0] prhex1
);

// -------------------------------------------------------
//  REG/WIRE declarations
// -------------------------------------------------------
reg [4:0] data_0;
reg [4:0] data_1;

// -------------------------------------------------------
//  Structural coding
// -------------------------------------------------------
assign prled = prswi;

// -------------------------------------------------------
//  Module hexdigit: Creates the LED pattern from 3 args:
// in:  0-15 displays the hex value from 0..F
//      16 = all_on
//      17 = - (show minus sign)
//      18 = _ (show underscore)
//      19 = S
//     >19 = all_off
// dp:  0 or 1, disables/enables the decimal point led
// out: bit pattern result driving the 7seg module leds
// -------------------------------------------------------
hexdigit h0 (data_0, 1'b0, prhex0);
hexdigit h1 (data_1, 1'b0, prhex1);

// -------------------------------------------------------
// Logic to display the switch number on the 7-seg modules
// as S0..S3, and if all switches are on, as SA.
// -------------------------------------------------------
always @( * )
   case (prswi)
      1 : begin data_0 = 5'd0; data_1 = 5'd19; end // SW0 = on
      2 : begin data_0 = 5'd1; data_1 = 5'd19; end // SW1 = on
      4 : begin data_0 = 5'd2; data_1 = 5'd19; end // SW2 = on
      8 : begin data_0 = 5'd3; data_1 = 5'd19; end // SW3 = on
     15 : begin data_0 = 5'ha; data_1 = 5'd19; end // All SW = on
     default : begin data_0 = 5'd20; data_1 = 5'd20; end
  endcase

endmodule
