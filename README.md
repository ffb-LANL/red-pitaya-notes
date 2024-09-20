# Red Pitaya Notes

Notes on the Red Pitaya Open Source Instrument:  https://pavel-demin.github.io/red-pitaya-notes/

A pre-built SD card image can be downloaded from this link: https://www.dropbox.com/scl/fi/fcwo3403nsagdbowcq6t8/red-pitaya-debian-12.1-armhf-20231004.zip?rlkey=2d3wpvkv39ih6693yqt3p8h62&dl=1  

Typical framework consist of FPGA bit file, with runs on Red Pitaya programmable logic, a server app which runs on Red Pitaya processing system (CPU), and a client app with runs on a host  

Bitfile creation example: https://pavel-demin.github.io/red-pitaya-notes/led-blinker/  

# A simple RP 122-16 ADC recorder example located in ..\projects\adc_recorder_test_122  

On the development machine: 
Command to create the bitfile: make NAME=adc_recorder_test_122 PART=xc7z020clg400-1 bit 
Command to compile the ADC recorder clien app: arm-linux-gnueabihf-gcc -O3 -march=armv7-a -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard -o adc-recorder-test adc-recorder-test.c  

On Red Pitaya:
Command to program FPPA with bitfile: cat adc_recorder_test_122.bit > /dev/xdevcfg 
Command to record ADC waveform into a file: adc-recorder-test > data.txt 

cd /opt/tmp
cat /opt/adc_recorder_test_122.bit > /dev/xdevcfg 
/opt/tmp/adc-recorder-test > data.txt 








