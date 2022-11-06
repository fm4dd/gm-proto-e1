// -------------------------------------------------------
// sound.v    gm-proto-e1 demo program    @20221022 fm4dd
//
// Requires: buzzer, 2x hex digits, 4x LED, system clock
//           rst and 1x push button for start/stop
//
// Description:
// ------------
// This program plays "Rudolf the rednosed reindeer" on
// on the buzzer. Note data is displayed on the LEDs,
// and on the hex digits. Button PB0 starts and stops
// the song.
//
// This program needs 25Mhz from the GateMate PLL, and
// I needed to disable CC_MX8 in yosys with -nomx8 arg.
//
// Adapted from https://www.fpga4fun.com/MusicBox4.html
// (c) fpga4fun.com 2003-2015
// -------------------------------------------------------
module sound(
  input clk,
  input rst,
  input [1:0] prbtn,
  output [3:0] prled,
  output wire [7:0] prhex0,
  output wire [7:0] prhex1,
  output reg prbuz
);

wire clk270, clk180, clk90, clk0, usr_ref_out;
wire usr_pll_lock_stdy, usr_pll_lock;

// -------------------------------------------------------
// Module CC_PLL: get a PLL-derived user clock signal
// -------------------------------------------------------
CC_PLL #(
  .REF_CLK("10.0"),    // reference input in MHz
  .OUT_CLK("25.0"),    // pll output frequency in MHz
  .PERF_MD("ECONOMY"), // LOWPOWER, ECONOMY, SPEED
  .LOW_JITTER(1),      // 0: disable, 1: enable low jitter mode
  .CI_FILTER_CONST(2), // optional CI filter constant
  .CP_FILTER_CONST(4)  // optional CP filter constant
) pll_inst (
  .CLK_REF(clk), .CLK_FEEDBACK(1'b0), .USR_CLK_REF(1'b0),
  .USR_LOCKED_STDY_RST(1'b0), .USR_PLL_LOCKED_STDY(usr_pll_lock_stdy), .USR_PLL_LOCKED(usr_pll_lock),
  .CLK270(clk270), .CLK180(clk180), .CLK90(clk90), .CLK0(clk0), .CLK_REF_OUT(usr_ref_out)
);

// -------------------------------------------------------
// Module debounce: get a clean push-button state signal
// -------------------------------------------------------
reg btn0;
wire btn0_down, btn0_up;
debounce d0 (prbtn[0], clk0, btn0, btn0_down, btn0_up);

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
reg [4:0] data_0;
reg [4:0] data_1;
hexdigit h1 (data_0, 1'b0, prhex1);
hexdigit h0 (data_1, 1'b0, prhex0);

reg play;

assign prled[2:0] = play ?fullnote :4'd0;
assign prled[3] = play;

// -------------------------------------------------------
// use a counter to go through a ROM containing the notes
// of a tune
// -------------------------------------------------------
reg [30:0] tone;
wire [7:0] fullnote;
music_ROM get_fullnote(.clk0(clk0), .address(tone[29:22]), .note(fullnote));

// -------------------------------------------------------
// We divide the "fullnote" by 12. That gives us the octave
// (5 octaves fit into 3 bits) and 4-bit note (from 0 to 11)
// -------------------------------------------------------
wire [2:0] octave;
wire [3:0] note;
divide_by12 get_octave_and_note(.numerator(fullnote[5:0]), .quotient(octave), .remainder(note));

// -------------------------------------------------------
// To go from one note to the next, frequency is multiplied
// by "1.0594".  Below is the precaclulated lookup table.
// We divide the main clock by 512 for note A, by 483 for
// note A#, by 456 for note B...  Dividing by a lower value
// gives a higher frequency --> higher note.
// -------------------------------------------------------
reg [8:0] clkdivider;
always @*
case(note)
  // -------------------------------------------------------
  // we also display the note value on the 7-seg digits.
  // The # is shown as left-aligned ' after the note value
  // -------------------------------------------------------
  0: begin clkdivider = 9'd511; data_0 = 5'ha; data_1 = 5'd31; end // A
  1: begin clkdivider = 9'd482; data_0 = 5'ha; data_1 = 5'd24; end // A#/Bb
  2: begin clkdivider = 9'd455; data_0 = 5'hb; data_1 = 5'd31; end // B
  3: begin clkdivider = 9'd430; data_0 = 5'hc; data_1 = 5'd31; end // C
  4: begin clkdivider = 9'd405; data_0 = 5'hc; data_1 = 5'd24; end // C#/Db
  5: begin clkdivider = 9'd383; data_0 = 5'hd; data_1 = 5'd31; end // D
  6: begin clkdivider = 9'd361; data_0 = 5'hd; data_1 = 5'd24; end // D#/Eb
  7: begin clkdivider = 9'd341; data_0 = 5'he; data_1 = 5'd31; end // E
  8: begin clkdivider = 9'd322; data_0 = 5'hf; data_1 = 5'd31; end // F
  9: begin clkdivider = 9'd303; data_0 = 5'hf; data_1 = 5'd24; end // F#/Gb
 10: begin clkdivider = 9'd286; data_0 = 5'd20; data_1 = 5'd31; end // G
 11: begin clkdivider = 9'd270; data_0 = 5'd20; data_1 = 5'd24; end // G#/Ab
  default: clkdivider = 9'd0;
endcase

reg [8:0] counter_note;
reg [7:0] counter_octave;
always @(posedge clk0 or negedge rst)
begin
  if(!rst) play <= 1'b0;
  else
  begin
    if(btn0_down==1) play <= ~play;
    if(play==1) begin
      tone <= tone+31'd1;
      // -------------------------------------------------------
      // Create pause after the ROM ends: && tone[21:18]!=0
      // the "fullnote" of value 0 is a quiet note.
      // -------------------------------------------------------
      if(counter_note==0 && counter_octave==0 && fullnote!=0 && tone[21:18]!=0) prbuz <= ~prbuz;

      // -------------------------------------------------------
      // For the lowest octave, we divide "counter_note" by 256.
      // For octave 1, we divide by 128... and so on...
      // -------------------------------------------------------
      if(counter_note==0) counter_octave <= counter_octave==0 ? 8'd255 >> octave : counter_octave-8'd1;

      counter_note <= counter_note==0 ? clkdivider : counter_note-9'd1;
    end
    else tone = 31'd1; 
  end
end

endmodule

/////////////////////////////////////////////////////
// The "divide by 12" module takes 6-bit variable (numerator)
// and divides it by 12 (denominator). That gives a 3-bit quotient
// (0..5) and a 4 bits remainder (0..11). To divide by 12, it is
// easier to divide by 4 first, then by 3. Div by 4 is trivial:
// we remove 2 bits out of the numerator, and copy it to the
// remainder. So we are left with 6-2=4 bits to divide by the
// value "3", which we do with a lookup table.
/////////////////////////////////////////////////////
module divide_by12(
  input [5:0] numerator,  // value to be divided by 12
  output reg [2:0] quotient, 
  output [3:0] remainder
);

reg [1:0] remainder3to2;
always @(numerator[5:2])
case(numerator[5:2])
  0: begin quotient=0; remainder3to2=0; end
  1: begin quotient=0; remainder3to2=1; end
  2: begin quotient=0; remainder3to2=2; end
  3: begin quotient=1; remainder3to2=0; end
  4: begin quotient=1; remainder3to2=1; end
  5: begin quotient=1; remainder3to2=2; end
  6: begin quotient=2; remainder3to2=0; end
  7: begin quotient=2; remainder3to2=1; end
  8: begin quotient=2; remainder3to2=2; end
  9: begin quotient=3; remainder3to2=0; end
 10: begin quotient=3; remainder3to2=1; end
 11: begin quotient=3; remainder3to2=2; end
 12: begin quotient=4; remainder3to2=0; end
 13: begin quotient=4; remainder3to2=1; end
 14: begin quotient=4; remainder3to2=2; end
 15: begin quotient=5; remainder3to2=0; end
endcase

assign remainder[1:0] = numerator[1:0];  // the first 2 bits are copied through
assign remainder[3:2] = remainder3to2;  // and the last 2 bits come from the case statement
endmodule
/////////////////////////////////////////////////////


module music_ROM(
	input clk0,
	input [7:0] address,
	output reg [7:0] note
);

always @(posedge clk0)
case(address)
	  0: note<= 8'd25;
	  1: note<= 8'd27;
	  2: note<= 8'd27;
	  3: note<= 8'd25;
	  4: note<= 8'd22;
	  5: note<= 8'd22;
	  6: note<= 8'd30;
	  7: note<= 8'd30;
	  8: note<= 8'd27;
	  9: note<= 8'd27;
	 10: note<= 8'd25;
	 11: note<= 8'd25;
	 12: note<= 8'd25;
	 13: note<= 8'd25;
	 14: note<= 8'd25;
	 15: note<= 8'd25;
	 16: note<= 8'd25;
	 17: note<= 8'd27;
	 18: note<= 8'd25;
	 19: note<= 8'd27;
	 20: note<= 8'd25;
	 21: note<= 8'd25;
	 22: note<= 8'd30;
	 23: note<= 8'd30;
	 24: note<= 8'd29;
	 25: note<= 8'd29;
	 26: note<= 8'd29;
	 27: note<= 8'd29;
	 28: note<= 8'd29;
	 29: note<= 8'd29;
	 30: note<= 8'd29;
	 31: note<= 8'd29;
	 32: note<= 8'd23;
	 33: note<= 8'd25;
	 34: note<= 8'd25;
	 35: note<= 8'd23;
	 36: note<= 8'd20;
	 37: note<= 8'd20;
	 38: note<= 8'd29;
	 39: note<= 8'd29;
	 40: note<= 8'd27;
	 41: note<= 8'd27;
	 42: note<= 8'd25;
	 43: note<= 8'd25;
	 44: note<= 8'd25;
	 45: note<= 8'd25;
	 46: note<= 8'd25;
	 47: note<= 8'd25;
	 48: note<= 8'd25;
	 49: note<= 8'd27;
	 50: note<= 8'd25;
	 51: note<= 8'd27;
	 52: note<= 8'd25;
	 53: note<= 8'd25;
	 54: note<= 8'd27;
	 55: note<= 8'd27;
	 56: note<= 8'd22;
	 57: note<= 8'd22;
	 58: note<= 8'd22;
	 59: note<= 8'd22;
	 60: note<= 8'd22;
	 61: note<= 8'd22;
	 62: note<= 8'd22;
	 63: note<= 8'd22;
	 64: note<= 8'd25;
	 65: note<= 8'd27;
	 66: note<= 8'd27;
	 67: note<= 8'd25;
	 68: note<= 8'd22;
	 69: note<= 8'd22;
	 70: note<= 8'd30;
	 71: note<= 8'd30;
	 72: note<= 8'd27;
	 73: note<= 8'd27;
	 74: note<= 8'd25;
	 75: note<= 8'd25;
	 76: note<= 8'd25;
	 77: note<= 8'd25;
	 78: note<= 8'd25;
	 79: note<= 8'd25;
	 80: note<= 8'd25;
	 81: note<= 8'd27;
	 82: note<= 8'd25;
	 83: note<= 8'd27;
	 84: note<= 8'd25;
	 85: note<= 8'd25;
	 86: note<= 8'd30;
	 87: note<= 8'd30;
	 88: note<= 8'd29;
	 89: note<= 8'd29;
	 90: note<= 8'd29;
	 91: note<= 8'd29;
	 92: note<= 8'd29;
	 93: note<= 8'd29;
	 94: note<= 8'd29;
	 95: note<= 8'd29;
	 96: note<= 8'd23;
	 97: note<= 8'd25;
	 98: note<= 8'd25;
	 99: note<= 8'd23;
	100: note<= 8'd20;
	101: note<= 8'd20;
	102: note<= 8'd29;
	103: note<= 8'd29;
	104: note<= 8'd27;
	105: note<= 8'd27;
	106: note<= 8'd25;
	107: note<= 8'd25;
	108: note<= 8'd25;
	109: note<= 8'd25;
	110: note<= 8'd25;
	111: note<= 8'd25;
	112: note<= 8'd25;
	113: note<= 8'd27;
	114: note<= 8'd25;
	115: note<= 8'd27;
	116: note<= 8'd25;
	117: note<= 8'd25;
	118: note<= 8'd32;
	119: note<= 8'd32;
	120: note<= 8'd30;
	121: note<= 8'd30;
	122: note<= 8'd30;
	123: note<= 8'd30;
	124: note<= 8'd30;
	125: note<= 8'd30;
	126: note<= 8'd30;
	127: note<= 8'd30;
	128: note<= 8'd27;
	129: note<= 8'd27;
	130: note<= 8'd27;
	131: note<= 8'd27;
	132: note<= 8'd30;
	133: note<= 8'd30;
	134: note<= 8'd30;
	135: note<= 8'd27;
	136: note<= 8'd25;
	137: note<= 8'd25;
	138: note<= 8'd22;
	139: note<= 8'd22;
	140: note<= 8'd25;
	141: note<= 8'd25;
	142: note<= 8'd25;
	143: note<= 8'd25;
	144: note<= 8'd23;
	145: note<= 8'd23;
	146: note<= 8'd27;
	147: note<= 8'd27;
	148: note<= 8'd25;
	149: note<= 8'd25;
	150: note<= 8'd23;
	151: note<= 8'd23;
	152: note<= 8'd22;
	153: note<= 8'd22;
	154: note<= 8'd22;
	155: note<= 8'd22;
	156: note<= 8'd22;
	157: note<= 8'd22;
	158: note<= 8'd22;
	159: note<= 8'd22;
	160: note<= 8'd20;
	161: note<= 8'd20;
	162: note<= 8'd22;
	163: note<= 8'd22;
	164: note<= 8'd25;
	165: note<= 8'd25;
	166: note<= 8'd27;
	167: note<= 8'd27;
	168: note<= 8'd29;
	169: note<= 8'd29;
	170: note<= 8'd29;
	171: note<= 8'd29;
	172: note<= 8'd29;
	173: note<= 8'd29;
	174: note<= 8'd29;
	175: note<= 8'd29;
	176: note<= 8'd30;
	177: note<= 8'd30;
	178: note<= 8'd30;
	179: note<= 8'd30;
	180: note<= 8'd29;
	181: note<= 8'd29;
	182: note<= 8'd27;
	183: note<= 8'd27;
	184: note<= 8'd25;
	185: note<= 8'd25;
	186: note<= 8'd23;
	187: note<= 8'd20;
	188: note<= 8'd20;
	189: note<= 8'd20;
	190: note<= 8'd20;
	191: note<= 8'd20;
	192: note<= 8'd25;
	193: note<= 8'd27;
	194: note<= 8'd27;
	195: note<= 8'd25;
	196: note<= 8'd22;
	197: note<= 8'd22;
	198: note<= 8'd30;
	199: note<= 8'd30;
	200: note<= 8'd27;
	201: note<= 8'd27;
	202: note<= 8'd25;
	203: note<= 8'd25;
	204: note<= 8'd25;
	205: note<= 8'd25;
	206: note<= 8'd25;
	207: note<= 8'd25;
	208: note<= 8'd25;
	209: note<= 8'd27;
	210: note<= 8'd25;
	211: note<= 8'd27;
	212: note<= 8'd25;
	213: note<= 8'd25;
	214: note<= 8'd30;
	215: note<= 8'd30;
	216: note<= 8'd29;
	217: note<= 8'd29;
	218: note<= 8'd29;
	219: note<= 8'd29;
	220: note<= 8'd29;
	221: note<= 8'd29;
	222: note<= 8'd29;
	223: note<= 8'd29;
	224: note<= 8'd23;
	225: note<= 8'd25;
	226: note<= 8'd25;
	227: note<= 8'd23;
	228: note<= 8'd20;
	229: note<= 8'd20;
	230: note<= 8'd29;
	231: note<= 8'd29;
	232: note<= 8'd27;
	233: note<= 8'd27;
	234: note<= 8'd25;
	235: note<= 8'd25;
	236: note<= 8'd25;
	237: note<= 8'd25;
	238: note<= 8'd25;
	239: note<= 8'd25;
	240: note<= 8'd25;
	241: note<= 8'd0;
	242: note<= 8'd00;
	default: note <= 8'd0;
endcase
endmodule

/////////////////////////////////////////////////////
