`timescale 10 ns / 10 ns

module tb;

reg clk;
reg rst;
wire [7:0] led;

initial begin
`ifdef CCSDF
  $sdf_annotate("blink_00.sdf", dut);
`endif
  $dumpfile("sim/blink_tb.vcd");
  $dumpvars(0, tb);
  clk = 0;
  rst = 0;
end

always clk = #5 ~clk;

blink dut (
  .clk(clk),
  .rst(rst),
  .prled(led)
);

initial begin
  #20;
  rst = 1;
  #10000000;
  $finish;
end

blink b(clk, rst, led);

endmodule
