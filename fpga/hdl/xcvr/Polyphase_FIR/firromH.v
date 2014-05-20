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
module firromH (
	address,
	clock,
	q);

	parameter MifFile = "missing_file.mif";

	input	[7:0]  address;
	input	  clock;
	output	[17:0]  q;
`ifdef XILINX_IMPLEMENTATION
       xfirromH #(.MifFile(MifFile)) (clock, address, q);
`endif //  `ifdef XILINX_IMPLEMENTATION

`ifdef ALTERA_IMPLEMENTATION
       afirromH #(.MifFile(MifFile)) (address, clock, q);
`endif //  `ifdef XILINX_IMPLEMENTATION

endmodule
