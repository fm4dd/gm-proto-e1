// -------------------------------------------------------
// buzzer.v      gm-proto-e1 demo program  @20221001 fm4dd
//
// Requires: LEDs, buttons, 7-Segment modules, clk, buzzer
//
// Description:
// ------------
// This program takes button press of the two push buttons:
// each button outputs a different frequency to the buzzer
// each button lights up its equivalent LED light,
// and the button number is displayed on two seven segment
// digits as b0 or b1. 
// -------------------------------------------------------
module buzzer(
  input clk,
  input rst,
  input [1:0] prbtn,
  output reg [3:0] prled,
  output [7:0] prhex0,
  output [7:0] prhex1,
  output reg prbuz
);

// -------------------------------------------------------
//  REG/WIRE declarations
// -------------------------------------------------------
reg [4:0] data_0;   // 7-seg display data 1st digit
reg [4:0] data_1;   // 7-seg display data 2nd digit
reg [25:0] pulse;   // system clock 10 Mhz
reg [25:0] freqdiv; // frequency divider
reg clk_out;        // derived frquency for buzzer

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
//  Structural coding
// -------------------------------------------------------
always @(posedge clk_out) 
begin
  if((prbtn[0] == 1) && (prbtn[1] == 1))
  begin
    prled <= 4'd0;  // all led off
    data_0 = 5'd20;  // digit 0 off
    data_1 = 5'd20;  // digit 1 off
  end
  else
  begin
    if(prbtn[0] == 0)
    begin 
      freqdiv <= 26'd2499;
      prbuz <= ~prbuz;
      prled[0] <= 1'b1;
      data_1 = 5'd11;
      data_0 = 5'd0;
    end
    if(prbtn[1] == 0)
    begin
      freqdiv <= 26'd3199;
      prbuz <= ~prbuz;
      prled[1] <= 1'b1;
      data_1 = 5'd11;
      data_0 = 5'd1;
    end
  end
end

always @(posedge clk or negedge rst)
begin
  if (!rst) begin
    clk_out = 1'b1;
    pulse = 0;
  end
  else begin
    pulse <= pulse + 1;
    if(pulse == freqdiv)
    begin
      clk_out <= ~clk_out;
      pulse <= 0;
    end
  end
end

endmodule
