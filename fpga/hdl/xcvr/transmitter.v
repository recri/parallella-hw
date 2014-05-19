//
//  Hermes Lite
// 
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

// (C) Phil Harman VK6APH, Kirk Weedman KD7IRS  2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014 
// (C) Steve Haynal KF7O 2014


// This is a port of the Hermes project from www.openhpsdr.org to work with
// the Hermes-Lite hardware described at http://github.com/softerhardware/Hermes-Lite.
// It was forked from Hermes V2.5.

module transmitter(
   input clock,		   	// sample clock
   input [31:0] frequency,	// dphase/dclock for cordic
   input [23:0] in_data_I,
   input [23:0] in_data_Q,
   output [15:0] out_data_I,
   output [15:0] out_data_Q		   
   );
   
   //---------------------------------------------------------
   //                 Transmitter code 
   //---------------------------------------------------------	

   /* 
	The gain distribution of the transmitter code is as follows.
	Since the CIC interpolating filters do not interpolate by 2^n they have an overall loss.
	
	The overall gain in the interpolating filter is ((RM)^N)/R.  So in this case its 2560^4.
	This is normalised by dividing by ceil(log2(2560^4)).
	
	In which case the normalized gain would be (2560^4)/(2^46) = .6103515625
	
	The CORDIC has an overall gain of 1.647.
	
	Since the CORDIC takes 16 bit I & Q inputs but output needs to be truncated to 14 bits, in order to
	interface to the DAC, the gain is reduced by 1/4 to 0.41175
	
	We need to be able to drive to DAC to its full range in order to maximise the S/N ratio and 
	minimise the amount of PA gain.  We can increase the output of the CORDIC by multiplying it by 4.
	This is simply achieved by setting the CORDIC output width to 16 bits and assigning bits [13:0] to the DAC.
	
	The gain distripution is now:
	
	0.61 * 0.41174 * 4 = 1.00467 
	
	This means that the DAC output will wrap if a full range 16 bit I/Q signal is received. 
	This can be prevented by reducing the output of the CIC filter.
	
	If we subtract 1/128 of the CIC output from itself the level becomes
	
	1 - 1/128 = 0.9921875
	
	Hence the overall gain is now 
	
	0.61 * 0.9921875 * 0.41174 * 4 = 0.996798

    */	

   reg signed [15:0] fir_i;
   reg signed [15:0] fir_q;

   // latch I&Q data on strobe from FirInterp8_1024
   // in_data_* is updated at 48kHz
   always @ (posedge clock)
     begin 
	if (req1) begin 
		fir_i = in_data_I[23:8];
		fir_q = in_data_Q[23:8];	
	end 
     end 


   // Interpolate I/Q samples from 48 kHz to the clock frequency

   wire req1, req2;
   wire [19:0] y1_r, y1_i; 
   wire [15:0] y2_r, y2_i;

   FirInterp8_1024 fi (clock, req2, req1, fir_i, fir_q, y1_r, y1_i);  // req2 enables an output sample, req1 requests next input sample.

   // GBITS reduced to 31
   CicInterpM5 #(.RRRR(192), .IBITS(20), .OBITS(16), .GBITS(31)) in2 ( clock, 1'd1, req2, y1_r, y1_i, y2_r, y2_i);

   //---------------------------------------------------------
   //    CORDIC NCO 
   //---------------------------------------------------------

   // Code rotates input IQ at set frequency and produces I & Q 

   cpl_cordic cordic_inst (.clock(clock), .frequency(frequency), .in_data_I(y2_i),			
					     .in_data_Q(y2_r), .out_data_I(out_data_I), .out_data_Q(out_data_Q));		
			 	 
   /* 
    We can use either the I or Q output from the CORDIC directly to drive the DAC.

    exp(jw) = cos(w) + j sin(w)

    When multplying two complex sinusoids f1 and f2, you get only f1 + f2, no
    difference frequency.

    Z = exp(j*f1) * exp(j*f2) = exp(j*(f1+f2))
    = cos(f1 + f2) + j sin(f1 + f2)
    */

   // the CORDIC output is stable on the negative edge of the clock

   reg [13:0] 	      DACD;

   always @ (negedge clock)
     DACD <= out_data_I[13:0];   //gain of 4
   
   //`endif
endmodule
