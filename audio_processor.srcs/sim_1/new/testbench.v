`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2026 17:02:34
// Design Name: 
// Module Name: testbench
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


module testbench ();
    //declaring inputs as reg as i am driving the inputs
    reg clk_100mhz;
    reg reset;
    reg [2:0] sel_switch;
    reg [1:0] vol_switch;
    reg pmod_sd_in;
    
    //declaring outputs as wires to recieve connection from instatiated modules
    wire pmod_sd_out;
    wire pmod_sclk;
    wire pmod_ws;
    
    top_sheet test (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .sel_switch(sel_switch),
        .vol_switch(vol_switch),
        .pmod_sd_in(pmod_sd_in),
        .pmod_sd_out(pmod_sd_out),
        .pmod_sclk(pmod_sclk),
        .pmod_ws(pmod_ws) 
    );
    
    //generating the 100MHz clock that would come from the board
    always #5 clk_100mhz = ~clk_100mhz;
    
    //testing
    initial begin
        clk_100mhz = 0;
        reset = 1;
        sel_switch = 3'b000;    //intially start testing on pass no effect mode
        vol_switch = 2'b00;
        
        
        #300;        //delay the rest so clocking wizard has time to complete
        reset = 0;
        
        #3000;      //delay to observe the sclk and ws signals
        
        sel_switch = 3'b000;    //switch to decrease volume mode
        vol_switch = 2'b01;     //shift by 1
        
        #2000000;      //delay to observe signals change
        
        $finish; 
        
    end
    

    reg signed [23:0] test_wave = 0;
    reg [5:0] sclk_count = 0;
    reg prev_ws = 0;

    //creating saw tooth audio for left channel
    always @(negedge pmod_ws) begin
        test_wave <= test_wave + 24'd150000;
    end
    
    //serialise data with the 1 clock delay and add zeros to make to whole audio frame 32 bits
    always @(negedge pmod_sclk) begin
        prev_ws <= pmod_ws;
        
        if(prev_ws != pmod_ws) begin //if ws toggles to other channel
            sclk_count <= 0;
            pmod_sd_in <= 0;
        end else begin
            sclk_count <= sclk_count + 1;
            
            if(sclk_count < 24) begin
                pmod_sd_in <= test_wave[23 - sclk_count];
            end else begin
                //adding zeros to last 8 bits
                pmod_sd_in <= 0;
            end
        end
    end

endmodule
