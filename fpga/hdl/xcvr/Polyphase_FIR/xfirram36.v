//
//  HPSDR - High Performance Software Defined Radio
//
//  Hermes code. 
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

module xfirram36(
		      clk,
		      wea,
		      addra,
		      dina,
		      addrb,
		      doutb
		      );
   
   input clk;
   input [0 : 0] wea;
   input [6 : 0] addra;
   input [35 : 0] dina;
   input [6 : 0]  addrb;
   output reg [35 : 0] doutb;

   (* RAM_STYLE="BLOCK_POWER2" *)

   reg [35:0] ram [127:0];

   always @(posedge clk) begin
      if (wea)
        ram[addra] <= dina;
      doutb <= ram[addrb];
   end

endmodule
