# SDR parallella-hw

This repository is a fork of https://github.com/parallella/parallella-hw.
It contains the FPGA HDL and EDK sources for a software defined radio
transceiver daughterboard for the parallella.  The hardware and software
for the transceiver is based on the Hermes-Lite project, 
https://github.com/softerhardware/Hermes-Lite.

This project modifies fpga/projects/parallella_7020_headless,
modifies fpga/edk/parallella_7020_headless,
and adds fpga/hdl/xcvr.  Generating a bitstream will overwrite the corresponding
.bit.bin file in fpga/bitstreams.

## Directory Structure

```
boards/         -  Board design files, all projects
    archive/        - Older boards no longer supported,
        proto/          - Zedboard based prototype (Jan 2013)
        gen0/           - First Parallella board, too hot (Apr 2013)
        gen1.0/         - Solid board, but hdmi wiring bug (Oct 2013)
        gen1.1/         - Fully working board (Dec 2013)
    libraries/      - Shared schematic and PCB tools libraries
    parallella-I/   - Current Parallella-I board schematic and PCB source
        constraints/    - Constraints files for board-specific pin locations
        docs/           - Docs specific to each board
        firmware/       - Low-level firmware (fsbl, u-boot, etc.)
        mfg/            - Manufacturing files: Fab Gerbers, Assembly docs

fpga/           -  FPGA design files and projects
    bitstreams/     - Latest generated bitstreams
    edk/            - EDK sources
        parallella_7010_headless/ - EDK for headless 7010-based Parallella
        parallella_7020_headless/ - EDK for headless 7020-based Parallella
    externals/      - Container for external repositories used by our projects
    hdl/            - Verilog source files
        axi/            - General AXI interface modules
        clocks/         - Clock generation
        common/         - General-purpose synchronizers/muxs/debouncers/etc.
        elink/          - eLink modules
        fifos/          - technology-independent FIFO modules
        gpio/           - modules for GPIO pins
        parallella-I/   - Modules specific to the Parallella
        xcvr            - SDR transceiver modules
    ip/             - Tool-specific IP generation (CoreGen) sources
    projects/       - One folder for each project
        parallella_7020_headless/
        parallella_7010_headless/
        parallella_64_7020_headless/
```

## FPGA Project Build instructions

See README files in the individual project directories.

## License

COPYING         -  GNU GENERAL PUBLIC LICENSE file


