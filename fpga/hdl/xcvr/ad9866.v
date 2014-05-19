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

module ad9866(
   input 	 reset,		   // reset
   output 	 clock,		   // sample clock from ad9866
   output [11:0] rx_data,	   // receive sample
   input 	 rx_enable,	   // receive enabled
   input [11:0]  tx_data,	   // transmit sample
   input 	 tx_enable,	   // transmit enable
   input [5:0] 	 rx_pga,	   // receive gain
   input 	 rx_pga_enable,	   // receive gain enabled
   input 	 loopback,	   // digital loopbck

   // AD9866 ports
   input [5:0] 	 hw_rx_data,	   // ADC input nibble
   input 	 hw_rx_sync,	   // input enabled, aka hw_rx_enable
   output [5:0]  hw_tx_data,	   // DAC output nibble
   output 	 hw_tx_sync,	   // output enabled, aka hw_tx_enable
   output 	 hw_rx_gain,	   // pga gain setting enable
   output 	 hw_reset,	   // hardware reset
   input 	 hw_rx_clock,	   // nibble clock
   output 	 hw_tx_not_quiet); // transmit enable, aka hw_tx_clock

   reg [11:0] 	 rx_data;
   reg [5:0] 	 hw_tx_data;
   
   assign hw_reset = reset;
   assign clock = hw_rx_sync;		// rx_sync once per sample
   assign hw_tx_not_quiet = tx_enable;
   assign hw_rx_gain = rx_enable && rx_pga_enable && ! tx_enable;
   assign hw_tx_sync = hw_rx_sync && tx_enable;

   always @(negedge hw_rx_clock) begin
      if  (reset != 0) begin
	 if (rx_enable) begin
	    if (hw_rx_sync != 0)
	      rx_data[5:0] <= hw_rx_data;
	    else
	      rx_data[11:6] <= hw_rx_data;
	 end
	 if (tx_enable)
	   hw_tx_data <= hw_rx_sync ? tx_data[5:0] : tx_data[11:6];
	 else
	   hw_tx_data <= hw_rx_gain ? rx_pga : 6'b0;
      end
   end

endmodule // ad9866


