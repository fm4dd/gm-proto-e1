module hexdigit(
  input wire [4:0] in,
  input wire dp,
  output reg [7:0] out
  );

// ---------- 7-seg assignment ----------
//                            a
//       d╶┐┌╴c              ────
//      e╶┐││┌╴b          f │    │
//     f╶┐││││┌╴a           │  g │ b
//    g╶┐││││││┌╴dp   ❯❯     ────
//   8'b00000000          e │    │
//                          │    │ c
//                           ────
//                             d   o dp
always @* begin
  out = 8'b11111111;
	 
  case(in)
    4'h0: begin // hex '0' SSD display pattern
      out[7] = 1'b1;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b0;
      out[0] = ~dp;
    end
	 
    4'h1: begin // hex '1' SSD display pattern
      out[7] = 1'b1;
      out[6] = 1'b1;
      out[5] = 1'b1;
      out[4] = 1'b1;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b1;
      out[0] = ~dp;
    end

    4'h2: begin // hex '2' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b1;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b1;
      out[2] = 1'b0;
      out[1] = 1'b0;
      out[0] = ~dp;
    end
	 
    4'h3: begin // hex '3' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b1;
      out[5] = 1'b1;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b0;
      out[0] = ~dp;
    end
 
     4'h4: begin // hex '4' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b1;
      out[4] = 1'b1;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b1;
      out[0] = ~dp;
    end
	 
    4'h5: begin // hex '5' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b1;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b1;
      out[1] = 1'b0;
      out[0] = ~dp;
    end
	 
    4'h6: begin // hex '6' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b1;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
	 
    4'h7: begin // hex '7' SSD display pattern
      out[7] = 1'b1;
      out[6] = 1'b1;
      out[5] = 1'b1;
      out[4] = 1'b1;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
	 
    4'h8: begin // hex '8' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
	 
    4'h9: begin // hex '9' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b1;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
	 
    4'ha: begin // hex 'a' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b1;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
	 
    4'hb: begin // hex 'b' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b1;
      out[1] = 1'b1;
      out[0] =  ~dp;
    end
	 
    4'hc: begin // hex 'c' SSD display pattern
      out[7] = 1'b1;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b1;
      out[2] = 1'b1;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
	 
    4'hd: begin // hex 'd' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b1;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b0;
      out[2] = 1'b0;
      out[1] = 1'b1;
      out[0] =  ~dp;
    end
	 
    4'he: begin // hex 'e' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b0;
      out[3] = 1'b1;
      out[2] = 1'b1;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
	 
    4'hf: begin // hex 'f' SSD display pattern
      out[7] = 1'b0;
      out[6] = 1'b0;
      out[5] = 1'b0;
      out[4] = 1'b1;
      out[3] = 1'b1;
      out[2] = 1'b1;
      out[1] = 1'b0;
      out[0] =  ~dp;
    end
    default: out = 8'b11111111;
  endcase
end
endmodule
