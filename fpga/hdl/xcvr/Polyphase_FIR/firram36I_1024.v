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

//
// this is originally an Altera specific module altered to switch between
// Altera and Xilinx conditionally
//
module firram36I_1024 (
   clock,
   data,
   rdaddress,
   wraddress,
   wren,
   q);

   input	  clock;
   input [35:0]   data;
   input [6:0] 	  rdaddress;
   input [6:0] 	  wraddress;
   input	  wren;
   output [35:0]  q;

`ifdef XILINX_IMPLEMENTATION
   // uh, this is only firram36I_128, not 1024,
   // someone must have cut and pasted blindly
   xfirram36I_128(clock, wren, wraddress, data, rdaddress, q);
`endif //  `ifdef XILINX_IMPLEMENTATION

`ifdef ALTERA_IMPLEMENTATION
   afirram36I_1024(clock, data, rdaddress, wraddress, wren, q);
`endif

endmodule // firram36I_1024



