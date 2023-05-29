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
