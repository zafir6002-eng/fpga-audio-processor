`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.08.2026 15:11:53
// Design Name: 
// Module Name: i2s_architecture
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



module i2s_architecture(
    input mclk, //12.288 MHz
    input reset,
    input sd_in,
    input [23:0] data_left_t,
    input [23:0] data_right_t,
    output reg [23:0] data_left_r,
    output reg [23:0] data_right_r,
    output reg sd_out,
    output sclk, //3.072 MHz
    output ws, //48kHz
    output reg data_recieved

    );
    
    //counter increments every mclk tick
    reg [7:0] clk_ctr;
    always @(posedge mclk or posedge reset) begin
        if (reset) begin
            clk_ctr <= 8'b0;
        end else begin
            clk_ctr <= clk_ctr + 1'b1;
        end
     end
     
     assign sclk = clk_ctr[1]; //1 whole cycle is 4 cycles of mclk 
     assign ws = clk_ctr[7]; //1 whole cycle is 256 cycles of mclk
     reg [5:0] bit_ctr;
     reg [23:0] data_tmp;
     
     //recieving/deserialize data
     always @(posedge sclk or posedge reset) begin
        if(reset) begin
            data_tmp <= 24'b0;
            data_left_r <= 24'b0;
            data_right_r <= 24'b0;
            data_recieved <= 1'b0;
        end else begin
            data_recieved <= 1'b0;
            
            
            //1 clock delay so we need the shifting to start when bit counter is one
            if(bit_ctr >= 1 && bit_ctr <= 24) begin
                data_tmp <= {data_tmp[22:0], sd_in}; //recieving the approaching bit
                
                //if bit ctr is at 24, write the data into the output register
                if(bit_ctr == 24) begin
                    if(~ws) begin
                        data_left_r <= {data_tmp[22:0], sd_in};
                    end else begin
                        data_right_r <= {data_tmp[22:0], sd_in};
                        data_recieved <= 1'b1;
                    end
                end
            end
          end
       end
       
       reg [23:0] data_tmp2;
       
       //transmitting/serialize data
       always @(negedge sclk or posedge reset) begin
            if(reset) begin
                bit_ctr <= 6'b0;
                sd_out <= 1'b0;
                data_tmp2 <= 24'b0;
             end else begin
                //match bit_ctr to edges of word select (ws)
                if(clk_ctr[6:1] == 6'b0) begin //comparing bits clk_ctr[6:1] because one full sclk cycle happens depending on bit clk_ctr[1]
                    bit_ctr <= 6'b0;
                end else begin
                    bit_ctr <= bit_ctr + 1;
                end 
             if(bit_ctr == 6'b0) begin
                if(ws) begin
                    data_tmp2 <= data_right_t;
                    sd_out <= data_right_t[23];
                end else begin
                    data_tmp2 <= data_left_t;
                    sd_out <= data_left_t[23];
                end
             end else if(bit_ctr >= 1 && bit_ctr <= 23) begin  
                    data_tmp2 <= {data_tmp2[22:0], 1'b0};
                    sd_out <= data_tmp2[22];
             end else begin
                    sd_out <= 1'b0;
                end 
             end 
         end
                  
endmodule
