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

module transceiver(
    GPIO_N,
    GPIO_P,
    SPI0_SCLK,
    SPI0_MOSI,
    SPI0_MISO,
    SPI0_SS
    );
    inout [23:0] GPIO_N;
    inout [23:0] GPIO_P;
    inout SPI0_SCLK;
    inout SPI0_MOSI;
    inout SPI0_MISO;
    inout SPI0_SS;
    
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
   
   wire        hw_clkout2;
   wire [5:0]  hw_rx_data;
   wire        hw_rx_enable;
   wire [5:0]  hw_tx_data;
   wire        hw_tx_enable;
   wire        hw_pga_enable;
   wire        hw_reset;
   wire        hw_rx_clock;
   wire        hw_tx_clock;

   assign hw_clkout2 = GPIO_P[1];       // gpio_1_p from ad9866, clkout2
   assign hw_not_reset = GPIO_N[3];     // gpio_3_n to ad9866, /reset
   assign hw_pga_enable = GPIO_P[3];    // gpio_3_p to ad9866, pga_strobe
   assign hw_tx_data = {GPIO_N[5], GPIO_P[5], GPIO_N[7], GPIO_P[7], GPIO_N[9], GPIO_P[9]};        // gpio_[5,7,9]_[n,p] to ad9866, txio
   assign hw_rx_data = {GPIO_N[11], GPIO_P[11], GPIO_N[13], GPIO_P[13], GPIO_N[15], GPIO_P[15]};  // gpio_[11,13,15]_[n,p] from ad9866, rxio
   assign hw_rx_enable = GPIO_N[17];    // gpio_17_n to ad9866, rxen
   assign hw_tx_enable = GPIO_P[17];    // gpio_17_p to ad9866, txen
   assign hw_tx_clock = GPIO_N[19];     // gpio_19_n from ad9866, rxclk
   assign hw_rx_clock = GPIO_P[19];     // gpio_19_p from ad9866, txclk

   // assign the SPI0 EMIO straight through to GPIO connector
   //assign SPI0_MOSI = GPIO_N[21];    // gpio_21_n to/from ad9866, spi mosi
   //assign SPI0_MISO = GPIO_P[21];    // gpio_21_p from ad9866, spi miso
   //assign SPI0_SCLK = GPIO_N[23];    // gpio_23_n to ad9866, spi clock
   //assign SPI0_SS = GPIO_P[23];      // gpio_23_p to ad9866, spi ~serial enable

   wire        clock;		// hw_rx_clock / 2
        
   ad9866 modem(
		reset,
		clock,
		rx_data,
		rx_enable,
		tx_data,
		tx_enable,
		pga_data,
		pga_enable,
		loopback,
		// pins to/from hardware device
		hw_rx_data,
		hw_rx_enable,
		hw_tx_data,
		hw_tx_enable,
		hw_pga_enable,
		hw_not_reset,
		hw_rx_clock,
		hw_tx_clock
		);

   wire rx_out_strobe;
   wire [23:0] rx_out_data_I;
   wire [23:0] rx_out_data_Q;

   receiver rcvr(clock, rx_decimation, rx_dphase,
	    rx_out_strobe, {rx_data,2'b000},
	    rx_out_data_I, rx_out_data_Q);

   wire [23:0] tx_in_data_I;
   wire [23:0] tx_in_data_Q;
   wire [15:0] tx_out_data_I;
   wire [15:0] tx_out_data_Q;
   
   transmitter xmtr(clock, tx_dphase,
	       tx_in_data_I, tx_in_data_Q,
	       tx_out_data_I, tx_out_data_Q);
   
endmodule // transceiver


