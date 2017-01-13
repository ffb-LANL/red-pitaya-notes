@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xsim testbench_iv_behav -key {Behavioral:sim_1:Functional:testbench_iv} -tclbatch testbench_iv.tcl -view C:/github/fp/Simulation2016/I-V/testbench_iv_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
