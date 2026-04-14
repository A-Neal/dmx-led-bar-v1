# FPGA DMX Decoder and PWM Driver Written in Verilog

This project directory is uploaded as-is, and doesn't contain a lot of polish.

I used Apio to build the Verilog into a configuration for the FPGA, and developed
on a Lattice iCE40UP5k. You can use the underlying toolchain if you'd prefer, but
I recommend Apio if you aren't looking to get into the weeds and just want to
modify little bits of the Verilog or build it for a different FPGA.

If you are building exactly according to what's in this repo, you don't need to
have Apio or build the configuration. **hardware.bin** is the file that is already
built and padded to fit into the 2Mbit flash on the PCB.

To flash, I used a generic CH341A USB SPI flasher with `flashrom` to flash the
hardware.bin file.

`$ flashrom -p ch341a_spi -w hardware.bin`

This repo includes the KiCAD project for the PCB, as well as just the gerber files
for have the PCB produced if you don't want to do any mods.

The BOM file is a list of everything that goes on the PCB and a link to the part
on Mouser. It's inside the KiCAD project directory.

The LED strips I used get a little too hot for the channels I used when everything
is turned up, so I'm not going to recommend them. But I will link them anyway
because they're excellent for other uses or if you're building a beefier fixture
than these plans are for.

LED Strip I Used: https://a.co/d/0fOELpNe

Less Powerful Equivalent LED Strip: https://a.co/d/0jd0L9jr

Aluminum Diffuser Channels: https://a.co/d/0e7rKbcg

24V Power Supply: https://a.co/d/09dPfuRe

Use any 12-24V LED strip and power supply that you want so long as the strip fits
in the channels, and the power supply can push enough power comfortably.

