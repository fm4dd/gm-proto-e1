// -------------------------------------------------------
// This module debounces an asynchronous input push button
// input btn: the glitchy unsynced button going active low
// input clk: the systenm clock, 10MHz for GateMate A1
// output btn_state: stays 1 while button is pushed (low)
// output btn_down: 1 for one clk cycle when button pushed
// output btn_up: 1 for one clk cycle when button released
//
// code copyright https://www.fpga4fun.com/Debouncer1.html
// -------------------------------------------------------
module debounce(
  input btn,
  input clk,
  output reg btn_state,
  output btn_down,
  output btn_up
);

// -------------------------------------------------------
// First, two flip-flops synchronize the btn signal to the
// "clk" clock domain
// -------------------------------------------------------
reg btn_sync_0;
always @(posedge clk) btn_sync_0 <= ~btn;  // invert btn to make btn_sync_0 active high
reg btn_sync_1;
always @(posedge clk) btn_sync_1 <= btn_sync_0;

// -------------------------------------------------------
// 16bit counter creates 1.5ms on a 10MHz clock
// adjust counter size for different clocks and timings
// -------------------------------------------------------
reg [15:0] btn_cnt;

// -------------------------------------------------------
// When button is pushed or released, increment counter
// The counter has to be maxed out before we decide that
// the push-button state has changed.
// -------------------------------------------------------
wire btn_idle = (btn_state==btn_sync_1);
wire btn_cnt_max = &btn_cnt;	           // true when all bits of btn_cnt are 1's

always @(posedge clk)
if(btn_idle) btn_cnt <= 0;                 // no button press
else
begin
  btn_cnt <= btn_cnt + 16'd1;              // something's going on, increment the counter
  if(btn_cnt_max) btn_state <= ~btn_state; // if the counter is maxed out, btn changed!
end

assign btn_down = ~btn_idle & btn_cnt_max & ~btn_state;
assign btn_up   = ~btn_idle & btn_cnt_max &  btn_state;
endmodule
