// -------------------------------------------------------
// count.v         FPGA demo program       @20220924 fm4dd
//
// Requires: LEDs, Slide Switches, 7-Segment modules, clk
//
// Description:
// ------------
// This program is a binary counter, displayed as binary
// on LED's, and in hexadecimal on the 7-Segment digits.
// The hex digits are enabled/disabled by slide switches.
// The 7-segment decimal points pulse the counter clock.
//
// The count pulse is 1Hz, derived from the system clock:
// 10MHz clock: set breakpoint at 23'd4999999 (gatemate)
// 12MHz clock: set breakpoint at 23'd5999999 (icebreaker)
// 50MHz clock: set breakpoint at 25'd24999999 (de10-lite)
// -------------------------------------------------------

module count(
  input clk,
  input rst,
  input [7:0] prswi,
  output [7:0] prled,
  output [7:0] prhex0,
  output [7:0] prhex1
);

parameter pulsebreak = 23'd4999999; // for 10MHz clock
//parameter pulsebreak = 25'd24999999; // for 50MHz clock

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg clk_1hz;
reg [15:0] count;
reg [24:0] pulse;
wire [4:0] data_0;
wire [4:0] data_1;
assign prled = count;

//=======================================================
//  Module hexdigit: Creates the LED pattern from 3 args:
// in:  0-16 sets the hex value led segments, >16 disables
// dp:  0 or 1, disables/enables the decimal point led
// out: this is the bit pattern for the 7seg module leds 
//=======================================================
hexdigit h0 (data_0, clk_1hz, prhex0);
hexdigit h1 (data_1, clk_1hz, prhex1);

//=======================================================
// Construct hex digit number from the counter or disable
// the hex module if the corresponding switch # is "off"
//=======================================================

assign data_0 = prswi[0] ?count[3:0]   :20; 
assign data_1 = prswi[1] ?count[7:4]   :20;

always @(posedge clk_1hz or negedge rst)
begin
  if (!rst) count = 0;
  else count <= count + 1;
end

always @(posedge clk or negedge rst)
begin
  if (!rst) begin
    clk_1hz = 1'b1;
    pulse = 0;
  end
  else begin 
    pulse <= pulse + 1;
    if(pulse == pulsebreak) begin
      pulse <= 0;
      clk_1hz <= ~clk_1hz;
    end
  end
end

endmodule
