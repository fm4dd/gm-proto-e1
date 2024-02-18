// -------------------------------------------------------
// display.v Gatemate character LCD demo   @20240218 fm4dd
//
// Requires: character LCD installed on GM-PROTO-E1 board
//           2x7 header: 20x4 LCD 3.3V SC2004CSWB-XA-LB
//
// Description:
// ------------
// This program tests output to 20x4 character LCD display
// -------------------------------------------------------
module display(
  input clk,
  input rst, 
  input [1:0] prbtn,
  output lcd_rs,
  output lcd_en,
  output  lcd_rw,
  output [7:0] lcd_d,
  output [3:0] prled,
  output [7:0] e1led
);

// -------------------------------------------------------
// First define a pushbutton handling for display control:
// The 'PB0' button cylces between 2 states that are
// used to switch between displaying text, and sending CLS
// The pushbutton state is displayed on LEDs LED0 and LED1
// -------------------------------------------------------
parameter BTNSTATE1 = 2'b01,
          BTNSTATE2 = 2'b10;

reg [1:0] btnstate;
reg [1:0] btnnext;

initial btnstate = BTNSTATE1;
initial btnnext = BTNSTATE1;

assign e1led[7:6] = 2'b11;    // turn 2 LED off
assign prled[3:2] = 2'b00;    // turn 2 LED off
assign prled[1:0] = btnstate; // show btn0 state on LED0/1
assign lcd_rw = 1'b0;         // RW signal unused, pull-down

// -------------------------------------------------------
// Module debounce gets a clean push-button state signal
// -------------------------------------------------------
reg btn0;
wire btn0_down;
wire btn0_up;

debounce d0 (prbtn[0], clk, btn0, btn0_down, btn0_up);

always@(posedge clk) btnstate <= btnnext;

always @(*)
   case (btnstate)
      BTNSTATE1: begin
         if(btn0_down) btnnext=BTNSTATE2;
            else btnnext=BTNSTATE1;
      end
      BTNSTATE2: begin
         if(btn0_down) btnnext=BTNSTATE1;
         else btnnext=BTNSTATE2;
      end
   endcase

// -------------------------------------------------------
// End of the rst/SW3 button handling. Start LCD control:
// -------------------------------------------------------

reg [7:0] data_reg, data_next;
reg [2:0] state_reg, state_next;
reg [7:0] count_reg, count_next;
reg cd_next, cd_reg;
reg d_start_reg, d_start_next;
wire done_tick;
reg lcd_busy;

reg [5:0] lcdled;
assign e1led[5:0] = lcdled;

localparam [2:0] INIT   = 3'b000, // state machine
		 IDLE 	= 3'b001,
		 SEND	= 3'b010,
		 FIN 	= 3'b011,
		 CLS 	= 3'b100;

initial begin
   state_reg   <= INIT;
   count_reg   <= 0;
   data_reg    <= 0;
   cd_reg      <= 0;
   d_start_reg <= 0;
   lcd_busy    <= 0;
end

wire [7:0] initm[0:3];
assign initm[0] = 8'h38;  // LCD_mode 8-bit
assign initm[1] = 8'h06;  // Entry mode
assign initm[2] = 8'h0E;  // Curson on
assign initm[3] = 8'h01;  // Clear Display
 
// -------------------------------------------------------
// Set LCD display ASCII data for a 20x4 display (83 chars)
// -------------------------------------------------------
localparam charlen = 8'd83;
reg [0:charlen*8-1] line1 = { "HELLO WORLD FPGA!   ", 8'hC0,
                              "Gatemate - CharLCD  ", 8'h94,
                              "--------------------", 8'hD4,
                              "8-bit mode LCD ready" };

// -------------------------------------------------------
// Module lcd_transmit: sends a single byte to display
// -------------------------------------------------------
lcd_transmit t1(data_reg, clk, rst, d_start_reg, cd_reg, lcd_d, lcd_rs, lcd_en, done_tick);

always @(posedge clk or negedge rst)
begin
  if(!rst)
  begin
    state_reg   <= INIT;
    count_reg   <= 0;
    data_reg    <= 0;
    cd_reg      <= 0;
    d_start_reg <= 0;
    lcd_busy    <= 0;
  end
  else
  begin
    state_reg   <= state_next;
    count_reg   <= count_next;
    data_reg    <= data_next;
    cd_reg      <= cd_next;
    d_start_reg <= d_start_next;
  end
end

always @(*)
begin
  state_next = state_reg;
  count_next = count_reg;
  cd_next = cd_reg;
  d_start_next = d_start_reg;

  case(state_reg)
    INIT:                            // State INIT: Initialize the LCD
    begin                            // ------------------------------------
      lcdled[5:0] = 6'b000001;       // light up state led1
      data_next = initm[count_reg];  // Load 1st data set from initm[0]
      d_start_next = 1'b1;           // set d_start_next flag=1
      cd_next = 0;                   // set cd_next = 0 (Command)
      if(done_tick) begin            // transmission of one cmd complete
        d_start_next = 0;            // set d_start_next flag=0
        count_next = count_reg+1'b1; // increment counter
        if(count_reg > 8'd4)         // if counter is at position 4
          state_next = FIN;          // Init completed, ready for data
      end
    end
	 
    IDLE:                            // State IDLE: LCD waiting to send data
    begin                            // ------------------------------------
      count_next = 0;                // reset counter
      d_start_next = 1'b0;           // dont sent anything
      lcdled[5:0] = 6'b000010;       // Light up board led2 to indicate IDLE
      if(btnstate == BTNSTATE1)
         state_next = CLS;           // if PB1 is pressed clear display
      if(btnstate == BTNSTATE2)
         state_next = SEND;          // if PB0 is pressed send text to display
    end
	 
	 
    SEND:                            // State SEND: transmit LCD characters
    begin                            // ------------------------------------
      lcdled[5:0] = 6'b000100;       // Light up board led3 to indicate SEND
      data_next = line1[count_reg*8+7:count_reg*8];  // get next byte from line1
      case (data_next)               // Check if data is a cursor command
         8'h80: cd_next = 0;         // 0x80 = cursor to line-1 pos-0
         8'hC0: cd_next = 0;         // 0xc0 = cursor to line-2 pos-0
         8'h94: cd_next = 0;         // 0x94 = cursor to line-3 pos-0
         8'hD4: cd_next = 0;         // 0xd4 = cursor to line-4 pos-0
         default: cd_next = 1;       // data is ASCII, set cd_next = 1
      endcase
      d_start_next = 1'b1;           // set d_start_next flag=1 to transmit
      if(done_tick) begin            // done_tick is the execution of one cmd
        count_next = count_reg+1'b1; // increment memory counter
        d_start_next = 0;            // set d_start_next=0 (ready for next char)
        if(count_next == charlen)    // if counter is at end of line1
          state_next = FIN;          // Data display completed, move to FIN
      end
    end
	 
    FIN:                             // State FIN: Reset markers, return to IDLE
    begin                            // ------------------------------------
      lcdled[5:0]    = 6'b001000;    // Light up board led4 to indicate FIN
      data_next = 8'h80;             // set "display position line1-pos0" command
      cd_next = 0;                   // set cd_next = 0 (Command)
      d_start_next = 1;              // set d_start_next flag=1
      if(done_tick) begin            // done_tick is the execution of one cmd
        d_start_next = 0;            // set d_start_next=0 (ready for next char)
        data_next    <= 0;
    //    cd_next      <= 0;
        state_next = IDLE;           // return to state "IDLE"
      end
    end

    CLS:                             // State CLS: send display clear CMD
    begin                            // ------------------------------------
      lcdled[5:0] = 6'b010000;       // Light up board led5 to indicate CLR
      data_next = 8'h01;             // set "display clear" command
      cd_next = 0;                   // set cd_next = 0 (Command)
      d_start_next = 1;              // set d_start_next flag=1
      if(done_tick) begin            // done_tick is the execution of one cmd
        d_start_next = 0;            // set d_start_next=0 (ready for next char)
        state_next = IDLE;           // return to state "IDLE"
      end
    end
  endcase
end

endmodule
