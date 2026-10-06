`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.08.2026 17:26:58
// Design Name: 
// Module Name: dsp
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


module dsp(
    input mclk,
    input sclk,
    input [2:0] sel,
    input [1:0] vol_shift,
    input signed [23:0] audio_in,
    input data_recieved,
    output reg signed [23:0] audio_out = 0
    );
    
    reg signed [23:0] pos_clip = 24'sd3000000;
    reg signed [23:0] neg_clip = -24'sd3000000;
    
    //check for clipping after volume shift
     reg signed [23:0] max_vol = 24'sd8000000;
     reg signed [23:0] min_vol = -24'sd8000000;
    
    always @(posedge sclk) begin
        if(data_recieved) begin
            case(sel)
                3'b000: audio_out <= audio_in;                  //same
                3'b001: audio_out <= audio_in >>> vol_shift;    //decrease volume
                3'b010: begin 
                    audio_out <= audio_in <<< vol_shift;    //increase volume --- fix this later see this result first
                    if(audio_out > max_vol) audio_out <= max_vol;
                    else if(audio_out < min_vol) audio_out <= min_vol;
                    end
                3'b011: begin                                   //clip the audio
                    if(audio_in > pos_clip) audio_out <= pos_clip;
                    else if(audio_in < neg_clip) audio_out <= neg_clip;
                    else audio_out <= audio_in;
                    end
                3'b100: audio_out <= audio_in & 24'hFFFF00; //medium bit crushing
                3'b101: audio_out <= audio_in & 24'hFF0000; //hard bit crushing
                3'b110: audio_out <= audio_in;
                3'b111: audio_out <= audio_in;
                default: audio_out <= audio_in;
             endcase 
          end
     end

     
    
                               
                
endmodule
