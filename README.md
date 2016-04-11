# ECE532 Project
## src: Contains modules for the main project
## Audio experiments are not integrated in the main project. The audio experiment designs, codes and ips can be found at this link https://drive.google.com/open?id=0B08YFqs5JPMJbmd3UXlYeHBfQW8

ECE532 Digital Systems Design


Project name: Duck Hunt Simulation Game


Project Description

Our project is a recreation of the classical duck hunt game.

The game uses camera inputs to capture movements which are then used to control the marker on screen.

Targets are generated at random positions on the screen and will change direction of movement randomly.

When the marker overlaps with the target, a hit is then registered.

Score counters are incremented and decremented depending on a hit or miss.

The game ends when the score falls below 0 or exceeds 15.


How to use

-Create a new Vivado project for the Nexys 4 DDR FPGA Board.

-Add the source code and constraint files.

-Add existing Block Memory and Clock Wizard IP files.

-Upgrade the IPs if neccessary.

-Run synthesis, implementation, and bitstream generation.

-Connect the Nexys 4 DDR FPGA Board and program the board.

-Choose a marker of choice, ideally one that has a uniform colour with a high contrast to the background colours.

-Move marker around until it falls within the central black square on the displayed camera feed.

-Press BTNU for around 0.2 seconds to capture the marker.

-Repeat pressing BTNU until the game background appears and a red marker is hovering around the screen and responding to user movements.

-Press BTND to start the game.

-Once the game ends, press BTND to restart and pres CPU_RESET to return to the camera feed and recalibrate markers.


Repository structure

src/ contrains the source code, constraints, and generated IP files for the project

dfsdfs