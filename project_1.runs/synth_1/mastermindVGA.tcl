# 
# Synthesis run script generated by Vivado
# 

debug::add_scope template.lib 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z020clg484-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir /afs/ece.cmu.edu/usr/jacobwei/Public/project_1/project_1.cache/wt [current_project]
set_property parent.project_path /afs/ece.cmu.edu/usr/jacobwei/Public/project_1/project_1.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
read_verilog -library xil_defaultlib -sv /afs/ece.cmu.edu/usr/jacobwei/Public/project_1/vga.sv
read_xdc /afs/ece.cmu.edu/usr/jacobwei/Public/project_1/zedboard_master_XDC_RevC_D_v3.xdc
set_property used_in_implementation false [get_files /afs/ece.cmu.edu/usr/jacobwei/Public/project_1/zedboard_master_XDC_RevC_D_v3.xdc]

synth_design -top mastermindVGA -part xc7z020clg484-1
write_checkpoint -noxdef mastermindVGA.dcp
catch { report_utilization -file mastermindVGA_utilization_synth.rpt -pb mastermindVGA_utilization_synth.pb }
