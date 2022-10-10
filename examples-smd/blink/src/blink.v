// -------------------------------------------------------
// blink.v    gm-proto-e1 demo program    @20220924 fm4dd
//
// Requires: 8x LEDs, system clock
//
// Description:
// ------------
// This program blinks alternately LED0-LED2 / LED1-LED3.
// A 2Hz blink pulse derived from the 10MHz signal SB_A8:
// 10MHz clock needs breakpoint at 23'd4999999 (gatemate)
// -------------------------------------------------------

module blink(
  input wire clk,
  input wire rst,
  output wire [7:0] prled
);

  reg clk_1hz;
  reg [22:0] count;

  assign {prled[0], prled[2], prled[4], prled[6]} = clk_1hz;
  assign {prled[1], prled[3], prled[5], prled[7]} = ~clk_1hz;

  always @(posedge clk or negedge rst)
  begin
    if (!rst) begin
      clk_1hz = 1'b1;
      count = 0;
    end
    else begin 
      count   <= count + 1;
      if(count == 23'd4999999) begin
        count   <= 0;
        clk_1hz <= ~clk_1hz;
      end
    end
  end

endmodule
