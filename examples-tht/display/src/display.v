// -------------------------------------------------------
// display.v    gm-proto-e1 demo program   @20221010 fm4dd
//
// Requires: 4x20 character LCD (3.3V) via prototyping area
//
// Description:
// ------------
// This program tests writing to a character LCD display
// in 4-bit mode (data/command pins (DB4-DB7). 
// -------------------------------------------------------
module display(
  input clk, 	
  input rst, 	
  output reg lcd_rs, lcd_en, lcd_rw,                               
  output reg [7:4] lcd_db
);

parameter Length  = 86;           // the memory block length we send to the LCD
reg [14:0]counter;                // clock delay counter register
integer pointer;                  // memory location pointer (0..Length)
reg lsbflag;                      // count=0 sends 1st nibble, otherwise 2nd                    
wire [9:0]memory[0:Length-1];     // display data memory, 10 bits x Length

assign	 memory[0]={2'b00,8'h28}; // Function Set: 4-bit, 2 Line, 5x7 Dots.            
assign	 memory[2]={2'b00,8'h0E}; // Entry Mode.     
assign	 memory[1]={2'b00,8'h06}; // Display on Cursor on.   
assign	 memory[3]={2'b00,8'h01}; // Clear Display (also clear DDRAM content).
assign	 memory[4]={10'd0};       // The memory location in middle are
assign	 memory[5]={10'd0};       // kept empty so that the LCD is
assign	 memory[6]={10'd0};       // properly initialized and is ready
assign	 memory[7]={10'd0};       // to expect display data 
assign	 memory[8]={10'd0};
assign	 memory[9]={10'd0};
assign	 memory[10]={10'd0};
assign	 memory[11]={10'd0};
assign	 memory[12]={10'd0};
assign	 memory[13]={10'd0};
assign	 memory[14]={10'd0};
assign	 memory[15]={10'd0};
assign	 memory[16]={10'd0};
assign	 memory[17]={10'd0};
assign	 memory[18]={2'b10," "};   // CMD Space that should appear on LCD.
assign	 memory[19]={2'b00,8'h1C}; // CMD Shift the display right.
assign	 memory[20]={2'b10,"W"};   // Character that should be displayed.
assign	 memory[21]={2'b10,"E"};
assign	 memory[22]={2'b10,"L"};
assign	 memory[23]={2'b10,"C"};
assign	 memory[24]={2'b10,"O"};
assign	 memory[25]={2'b10,"M"};
assign	 memory[26]={2'b10,"E"};
assign	 memory[27]={2'b10," "};
assign	 memory[28]={2'b10,"T"};
assign	 memory[29]={2'b10,"O"};
assign	 memory[30]={2'b10,":"};
assign	 memory[31]={2'b00,8'hC0}; // Shift to second Line of LCD    
assign	 memory[32]={2'b10," "};   // Space that should appear on LCD.
assign	 memory[33]={2'b00,8'h1C}; // Shift the display right.
assign	 memory[34]={2'b10,"G"};   // Character that should be displayed. 
assign	 memory[35]={2'b10,"a"};
assign	 memory[36]={2'b10,"t"};
assign	 memory[37]={2'b10,"e"};
assign	 memory[38]={2'b10,"M"};
assign	 memory[39]={2'b10,"a"};
assign	 memory[40]={2'b10,"t"};
assign	 memory[41]={2'b10,"e"};
assign	 memory[42]={2'b10," "};
assign	 memory[43]={2'b10,"E"};
assign	 memory[44]={2'b10,"1"};
assign	 memory[45]={2'b00,8'h90}; // Shift to third Line of LCD    
assign	 memory[46]={2'b10," "};   // Space that should appear on LCD.
assign	 memory[47]={2'b00,8'h1C}; // Shift the display right.
assign	 memory[48]={2'b10,"-"};
assign	 memory[49]={2'b10,"-"};
assign	 memory[50]={2'b10,"-"};
assign	 memory[51]={2'b10,"-"};
assign	 memory[52]={2'b10,"-"};
assign	 memory[53]={2'b10,"-"};
assign	 memory[54]={2'b10,"-"};
assign	 memory[55]={2'b10,"-"};
assign	 memory[56]={2'b10,"-"};
assign	 memory[57]={2'b10,"-"};
assign	 memory[58]={2'b10,"-"};
assign	 memory[59]={2'b10,"-"};
assign	 memory[60]={2'b10,"-"};
assign	 memory[61]={2'b10,"-"};
assign	 memory[62]={2'b10,"-"};
assign	 memory[63]={2'b10,"-"};
assign	 memory[64]={2'b10,"-"};
assign	 memory[65]={2'b10,"-"};
assign	 memory[66]={2'b10,"-"};
assign	 memory[67]={2'b10,"-"};
assign	 memory[68]={2'b00,8'hD1}; // Shift to fourth Line of LCD    
assign	 memory[69]={2'b10,"g"};
assign	 memory[70]={2'b10,"m"};
assign	 memory[71]={2'b10,"-"};
assign	 memory[72]={2'b10,"p"};
assign	 memory[73]={2'b10,"r"};
assign	 memory[74]={2'b10,"o"};
assign	 memory[75]={2'b10,"t"};
assign	 memory[76]={2'b10,"o"};
assign	 memory[77]={2'b10,"-"};
assign	 memory[78]={2'b10,"e"};
assign	 memory[79]={2'b10,"1"};
assign	 memory[80]={2'b10," "};
assign	 memory[81]={2'b10,"b"};
assign	 memory[82]={2'b10,"o"};
assign	 memory[83]={2'b10,"a"};
assign	 memory[84]={2'b10,"r"};
assign	 memory[85]={2'b10,"d"};

always @(posedge clk or negedge rst)
begin
  if (!rst) begin
    counter='d0;
    lcd_en='b0;
  end
  else begin
    counter=counter+1'b1;        // increment delay counter
    if(pointer==Length+1)        // are we at the end of memory?                             
      lcd_en='b0;                // stop sending data to display
    else lcd_en = counter[14];
  end
end

always @(negedge lcd_en)         // on falling edge of en, send commands or data to the LCD
begin
  lcd_rs=memory[pointer][9];     // First two bits (MSB bits) have rs and rw signal data
  lcd_rw=1'b0;                   // We only write to the LCD, therefore set rw = '0'.
  if (!lsbflag)  
  begin
    lcd_db=memory[pointer][7:4]; // First send the upper 4 bits data/command
    lsbflag=1'b1;                // msb nibble complete, set lsbflag = 1
  end
  else
  begin
    lcd_db=memory[pointer][3:0]; // Next send the lower 4 bits data/command
    pointer=pointer+1;           // increment memory pointer
    lsbflag=1'b0;                // lsb nibble complete, reset lsbflag = 0
  end
end
endmodule                                                
