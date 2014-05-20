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

//  Copyright 2014 by Roger E Critchlow Jr, AD5DZ, Santa Fe, New Mexico, USA

//
// the transceiver module ties the parts together
//

// these axi registers are all memory mapped on the ARM,
// I'm not sure how they turn out on this side
// the caller of transceiver sure doesn't know them, either

module transceiver(GPIO_P, GPIO_N);
    inout [23:0] GPIO_P;
    inout [23:0] GPIO_N;
   // parameters
   parameter sample_clock = 73.728;
   parameter sample_clock_divider = 1;
   parameter fixed_rx_decimation = 64;

  // axi control registers		   
   reg        reset;
  // axi mode registers
   reg        tx_enable;
   reg 	      rx_enable;
   reg 	      loopback;
  // axi parameter registers
   reg [5:0]  rx_decimation;
   reg [31:0] tx_dphase;
   reg [31:0] rx_dphase;
  // axi stream interfaces
  // ...

   wire [11:0] rx_data;
   wire [11:0] tx_data;
   wire [5:0]  rx_pga;
   wire        rx_pga_enable;
   
   wire [5:0]  hw_rx_data;
   wire        hw_rx_enable;
   wire [5:0]  hw_tx_data;
   wire        hw_tx_enable;
   wire        hw_rx_gain;
   wire        hw_reset;
   wire        hw_rx_clock;
   wire        hw_tx_clock;
   
   wire        clock;		// hw_rx_clock / 2
        
   ad9866(reset,
	  clock,
	  rx_data, rx_enable,
	  tx_data, tx_enable,
	  pga_data, pga_enable,
	  loopback,
	  // pins to/from hardware device
	  hw_rx_port, hw_rx_enable,
	  hw_tx_port, hw_tx_enable,
	  hw_rx_gain,
	  hw_reset,
	  hw_rx_clock, hw_tx_clock);

   wire rx_out_strobe;
   wire [23:0] rx_out_data_I;
   wire [23:0] rx_out_data_Q;

   receiver(clock, rx_decimation, rx_dphase,
	    rx_out_strobe, rx_data,
	    rx_out_data_I, rx_out_data_Q);

   wire [23:0] tx_in_data_I;
   wire [23:0] tx_in_data_Q;
   wire [15:0] tx_out_data_I;
   wire [15:0] tx_out_data_Q;
   
   transmitter(clock, tx_dphase,
	       tx_in_data_I, tx_in_data_Q,
	       tx_out_data_I, tx_out_data_Q);
   
endmodule // transceiver


