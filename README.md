# FPGA

Project Description  
The user utilizes a joystick to create a box around any object in the video feed. Next, they press the red button and the real-time template-matching-based tracking begins. As the object moves in the video feed, the box moves with it. When the user presses the red button again, the box stops moving, and the user can move the box again to choose a new object to track.

Implementation Description  
Our project was implemented in SystemVerilog with some 3rd party VHDL code and ran on a Zynq-7000 Zedboard. This repo contains all necessary source files in the src directory and our Vivado project file, FPGA.xpr.
