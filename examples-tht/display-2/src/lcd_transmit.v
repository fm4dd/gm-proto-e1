// -------------------------------------------------------
// This module implements the logic to send a single data
// instruction to an HD44780 character LCD. Input is an
// 8-bit 'data' value, together with the cmd or display
// flag 'cd' (0=control-command, 1=display).
// Output are the 8 datalines and two control lines EN/RS,
// and the completion flag 'done_tick' that confirms the
// data transmission.
//
// data:      lcd input
// clk:       clock (expected clock rate is 10MHz)
// rst:       reset signal
// start:     start transmission process
// cd:        0=LCD Command, 1=LCD Char value
// rs:        LCD register select
// en:        LCD enable signal
// done_tick: Process completed clock tick
// -------------------------------------------------------
module lcd_transmit (
  input [7:0] data,			
  input clk, rst, start, cd,	
  output reg [7:0] lcd_data,
  output rs, en, 
  output reg done_tick
);

localparam [2:0] idle  = 3'b000,
                 load  = 3'b001,
                 wait1 = 3'b010, //   1ms wait
                 wait2 = 3'b011, // 0.5ms wait
                 done  = 3'b100;

reg [2:0] state_reg,state_next;
reg [15:0] count_reg;
wire [15:0] count_next;
reg [7:0] lcd_data_reg; 
reg [7:0] lcd_data_next;
reg rs_reg, rs_next, en_reg, en_next, c_load_reg, c_load_next;
wire c_1ms, c_h1ms;

always @(posedge clk or negedge rst)
begin
  if(!rst) begin
    state_reg    <= idle;
    c_load_reg   <= 0;
    en_reg       <= 0;
    rs_reg       <= 0;
    lcd_data_reg <= 0;
    count_reg    <= 0;
  end
  else begin
       state_reg <= state_next;
      c_load_reg <= c_load_next;
          en_reg <= en_next;
          rs_reg <= rs_next;
    lcd_data_reg <= lcd_data_next;
       count_reg <= count_next;
  end
end

assign count_next = (c_load_reg)?(count_reg + 1'b1):16'd0;
// -------------------------------------------------------
// adjust here for different clock rates
// -------------------------------------------------------
assign c_1ms = (count_reg == 16'd2500); // 1.0ms from 10MHz
assign c_h1ms = (count_reg == 16'd1250); // 0.5ms from 10MHz

always @*
begin
  state_next    = state_reg;
  rs_next       = rs_reg;
  en_next       = en_reg;
  lcd_data_next = lcd_data_reg;
  done_tick     = 0;
  c_load_next   = c_load_reg;
  
  case(state_reg)
    idle:
    begin
      if(start) state_next = load;
    end
	 
    load:                  // From input load data byte
    begin                  // and set the cmd/display mode
      state_next    = wait1;
      lcd_data_next = data;
      rs_next       = cd;
    end
	 
    wait1:                 // toggle EN signal on, wait 1ms 
    begin                  // and then toggle EN back to '0'
      c_load_next   = 1;   // start delay counter
      en_next = 1;
      if(c_1ms) begin
        state_next  = wait2;
        en_next     = 0;
        c_load_next = 0;  // reset delay counter
      end
    end

    wait2:                  // create 0.5ms delay so the
    begin                   // display has time to read data
      c_load_next   = 1;    // start delay counter
      if(c_h1ms) begin
        state_next  = done;
        c_load_next = 0;   // reset delay counter
      end
    end

    done:                   // set the cmd complete flag
    begin                   // and go back to 'idle' state
      done_tick    = 1;
      state_next   = idle;
    end
  endcase
  lcd_data = lcd_data_reg;	 
end
assign en = en_reg;
assign rs = rs_reg;

endmodule
