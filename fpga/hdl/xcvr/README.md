# Radio Transceiver Sources

## Sources
   xcvr.v
    receiver.v
     cordic.v
     cic.v
     varcic.v
      cic_comb.v
      cic_integrator.v
     Polyphase_FIR/firfilt.v     
    transmitter.v

## AD9866 lines, directions from FPGA, and GPIO assignments

   GPIO1_N -> CLK_IN - output, clock from FPGA
   GPIO1_P <- CLOCK_OUT2 - input, raw clock from AD9866
   GPIO3_N -> /RESET - output, reset line for AD9866

   GPIO[579]_[NP] -> ADIO[11:6] - inputs, nibble to TX data or RX gain update
   GPIO[111315]_[NP] <- ADIO[5:0] - outputs, nibble to RX data

   GPIO17_N -> RXEN - output, receive enable
   GPIO17_P -> TXEN - output, transmit enable
   GPIO19_N <- TXCLK - input, transmit clock
   GPIO19_P <- RXCLK - input, receive clock

   GPIO21_N -> SDIO - output, SPI data out from ARM master
   GPIO21_P <- SDO - input, SPI data input to ARM master
   GPIO23_N -> SCLK - output, SPI clock from ARM master
   GPIO23_P -> /SEN - ouput, SPI enable from ARM master   

## ARM lines, directions from FPGA

   AXI DMA connection for data in/out

   RXEN - receive enable - 1 bit
   TXEN - transmit enable - 1 bit
   FDX - full duplex - 1 bit
   LOOP - digital loopback - 1 bit
   RESET - reset - 1 bit

   RXPH0 - receive initial phase angle - 20 bits
   RXDPH - receive phase angle update / clock - 20 bits

   TXPH0 - transmit initial phase angle - 20 bits
   TXDPH - transmit phase angle update / clock - 20 bits

   SDIO - EMIO mapped SPI interface
   SDO  - EMIO mapped SPI interface
   SCLK - EMIO mapped SPI interface
   /SEN - EMIO mapped SPI interface
