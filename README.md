#FPGA I2S Audio Processor


# This design includes three source modules: dsp.v, i2s_architecture.v, top_sheet.v
# Find these files through audio_processor.srcs/sources_1/new/...

# There is also a a simulation file found at:
# audio_processor.srcs/sim_1/new/testbench.v

# This project is a transceiver which utilises the I2S protocol to transmit audio and applies some digital signal processing effects to the audio
# It was made and tested using the Vivado software and it built such that it would work on a Basys 3 AMD Artix 7 FPGA board, however it was on simulated and tested using Vivado's simulation software, not the actual board
