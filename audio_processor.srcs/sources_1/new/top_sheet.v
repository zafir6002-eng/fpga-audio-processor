`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.09.2026 16:53:03
// Design Name: 
// Module Name: top_sheet
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_sheet(
        input clk_100mhz,       //takes in crystal oscillator from FPGA
        input reset,
        input [2:0] sel_switch, //switches for DSP effect
        input [1:0] vol_switch, //switches for volume shift
        
        input pmod_sd_in,       
        output pmod_sd_out,     
        
        output pmod_sclk,      
        output pmod_ws
        
    );
    
    wire mclk;
    wire sclk;
    wire ws;
    wire data_recieved;
    
    wire signed [23:0] audio_left_r;
    wire signed [23:0] audio_right_r;
    wire signed [23:0] audio_left_t;
    wire signed [23:0] audio_right_t;
    
    assign pmod_sclk = sclk;
    assign pmod_ws = ws;
    
    //using the standard vivado clocking protocol to generate mclk
    clk_wiz_0 clock (
        .clk_in1(clk_100mhz),
        .reset(reset),
        .clk_out1(mclk)
    );
    
    //generating the clocks ws and sclk and converting sd_in into i2s format
    i2s_architecture i2s_inst (
        .mclk(mclk),
        .reset(reset),
        .sd_in(pmod_sd_in),
        .sd_out(pmod_sd_out),
        .sclk(sclk),
        .ws(ws),
        .data_recieved(data_recieved),
        .data_left_r(audio_left_r),
        .data_right_r(audio_right_r),
        .data_left_t(audio_left_t),
        .data_right_t(audio_right_t)
    );
    
    //right channel DSP
    dsp dsp_right (
        .mclk(mclk),
        .sclk(sclk),
        .sel(sel_switch),
        .vol_shift(vol_switch),
        .audio_in(audio_right_r),
        .data_recieved(data_recieved),
        .audio_out(audio_right_t)
    );
    
    //left channel DSP
    dsp dsp_left (
        .mclk(mclk),
        .sclk(sclk),
        .sel (sel_switch),
        .vol_shift(vol_switch),
        .audio_in(audio_left_r),
        .data_recieved(data_recieved),
        .audio_out(audio_left_t)
    );
         
        
endmodule
