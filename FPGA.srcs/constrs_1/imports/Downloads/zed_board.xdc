#set_property PACKAGE_PIN    Y9 [get_ports {   clk100 } ]
#set_property PACKAGE_PIN	Y21	[get_ports {	vga_blue[0]	}	]
#set_property PACKAGE_PIN	Y20	[get_ports {	vga_blue[1]	}	]
#set_property PACKAGE_PIN	AB20	[get_ports {	vga_blue[2]	}	]
#set_property PACKAGE_PIN	AB19	[get_ports {	vga_blue[3]	}	]
#set_property PACKAGE_PIN	AB22	[get_ports {	vga_green[0]	}	]
#set_property PACKAGE_PIN	AA22	[get_ports {	vga_green[1]	}	]
#set_property PACKAGE_PIN	AB21	[get_ports {	vga_green[2]	}	]
#set_property PACKAGE_PIN	AA21	[get_ports {	vga_green[3]	}	]
#set_property PACKAGE_PIN	V20	[get_ports {	vga_red[0]	}	]
#set_property PACKAGE_PIN	U20	[get_ports {	vga_red[1]	}	]
#set_property PACKAGE_PIN	V19	[get_ports {	vga_red[2]	}	]
#set_property PACKAGE_PIN	V18	[get_ports {	vga_red[3]	}	]
#set_property PACKAGE_PIN	AA19	[get_ports {	vga_hsync	}	]
#set_property PACKAGE_PIN	Y19	[get_ports {	vga_vsync	}	]
					
					
set_property PACKAGE_PIN	Y11	[get_ports {	OV7670_PWDN	}	]
set_property PACKAGE_PIN	AB11	[get_ports {	OV7670_RESET	}	]
set_property PACKAGE_PIN	AA11	[get_ports {	OV7670_D[0]	}	]
set_property PACKAGE_PIN	AB10	[get_ports {	OV7670_D[1]	}	]
set_property PACKAGE_PIN	Y10	[get_ports {	OV7670_D[2]	}	]
set_property PACKAGE_PIN	AB9	[get_ports {	OV7670_D[3]	}	]
set_property PACKAGE_PIN	AA9	[get_ports {	OV7670_D[4]	}	]
set_property PACKAGE_PIN	AA8	[get_ports {	OV7670_D[5]	}	]
					
set_property PACKAGE_PIN	W12	[get_ports {	OV7670_D[6]	}	]
set_property PACKAGE_PIN	V12	[get_ports {	OV7670_D[7]	}	]
set_property PACKAGE_PIN	W11	[get_ports {	OV7670_XCLK	}	]
set_property PACKAGE_PIN	W10	[get_ports {	OV7670_PCLK	}	]
set_property PACKAGE_PIN	V10	[get_ports {	OV7670_HREF	}	]
set_property PACKAGE_PIN	V9	[get_ports {	OV7670_VSYNC	}	]
set_property PACKAGE_PIN	W8	[get_ports {	OV7670_SIOD	}	]
set_property PACKAGE_PIN	V8	[get_ports {	OV7670_SIOC	}	]
set_property PACKAGE_PIN	V12	[get_ports {	OV7670_PCLK	}	]
					
set_property PACKAGE_PIN	T22	[get_ports {	LD0	}	]
set_property PACKAGE_PIN	T21	[get_ports {	LD1	}	]
set_property PACKAGE_PIN	U22	[get_ports {	LD2	}	]
set_property PACKAGE_PIN	U21	[get_ports {	LD3	}	]
set_property PACKAGE_PIN	V22	[get_ports {	LD4	}	]
set_property PACKAGE_PIN	W22	[get_ports {	LD5	}	]
set_property PACKAGE_PIN	U19	[get_ports {	LD6	}	]
set_property PACKAGE_PIN	U14	[get_ports {	LD7	}	]
					
set_property PACKAGE_PIN	T18	[get_ports {	btn	}	]


# Voltage levels
#set_property IOSTANDARD LVTTL [get_ports btn]
#set_property IOSTANDARD LVTTL [get_ports {LED[*]}]

#set_property IOSTANDARD LVTTL [get_ports OV7670_PCLK]
#set_property IOSTANDARD LVTTL [get_ports OV7670_SIOC]
#set_property IOSTANDARD LVTTL [get_ports OV7670_VSYNC]
#set_property IOSTANDARD LVTTL [get_ports OV7670_RESET]
#set_property IOSTANDARD LVTTL [get_ports OV7670_PWDN]
#set_property IOSTANDARD LVTTL [get_ports OV7670_HREF]
#set_property IOSTANDARD LVTTL [get_ports OV7670_XCLK]
#set_property IOSTANDARD LVTTL [get_ports OV7670_SIOD]
#set_property IOSTANDARD LVTTL [get_ports {OV7670_D[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
#set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]
#set_property IOSTANDARD LVCMOS33 [get_ports clk100]

#Switches
set_property PACKAGE_PIN F22 [get_ports SW0]
set_property PACKAGE_PIN G22 [get_ports SW1]
set_property PACKAGE_PIN H22 [get_ports SW2]
set_property PACKAGE_PIN F21 [get_ports SW3]
set_property PACKAGE_PIN H19 [get_ports SW4]
set_property PACKAGE_PIN H18 [get_ports SW5]
set_property PACKAGE_PIN H17 [get_ports SW6]
set_property PACKAGE_PIN M15 [get_ports SW7]


#VGA
set_property PACKAGE_PIN Y21 [get_ports VGA_B1]
set_property PACKAGE_PIN Y20 [get_ports VGA_B2]
set_property PACKAGE_PIN AB20 [get_ports VGA_B3]
set_property PACKAGE_PIN AB19 [get_ports VGA_B4]
set_property PACKAGE_PIN AB22 [get_ports VGA_G1]
set_property PACKAGE_PIN AA22 [get_ports VGA_G2]
set_property PACKAGE_PIN AB21 [get_ports VGA_G3]
set_property PACKAGE_PIN AA21 [get_ports VGA_G4]
set_property PACKAGE_PIN AA19 [get_ports VGA_HS]
set_property PACKAGE_PIN V20 [get_ports VGA_R1]
set_property PACKAGE_PIN U20 [get_ports VGA_R2]
set_property PACKAGE_PIN V19 [get_ports VGA_R3]
set_property PACKAGE_PIN V18 [get_ports VGA_R4]
set_property PACKAGE_PIN Y19 [get_ports VGA_VS]

#GCLK
set_property PACKAGE_PIN Y9 [get_ports GCLK]

#Buttons
set_property PACKAGE_PIN T18 [get_ports BTNU]
set_property PACKAGE_PIN P16 [get_ports BTNC]
set_property PACKAGE_PIN R16 [get_ports BTND]
set_property PACKAGE_PIN N15 [get_ports BTNL]
set_property PACKAGE_PIN R18 [get_ports BTNR]

#Push Buttons
#set_property PACKAGE_PIN D13 [get_ports PB1]
#set_property PACKAGE_PIN C10 [get_ports PB2]



# Magic
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets OV7670_PCLK_IBUF]


# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]]

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]]

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]]
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]]