`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2025 16:45:23
// Design Name: 
// Module Name: popcount
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


module popcount #(
    parameter INPUT_WIDTH = 8
)(
    input wire [INPUT_WIDTH-1:0] data_in,
    output wire [3:0] count_out
);
    wire [1:0] count_2bit [0:3];
    genvar i;
    generate
        for (i = 0; i < INPUT_WIDTH; i = i + 2) begin : count_2bit_gen
            if (i+1 < INPUT_WIDTH) begin : gen_has_pair
                assign count_2bit[i/2] = data_in[i] + data_in[i+1];
            end else begin : gen_single
                assign count_2bit[i/2] = data_in[i];
            end
        end
    endgenerate
    wire [2:0] sum_stage1 = count_2bit[0] + count_2bit[1];
    wire [2:0] sum_stage2 = count_2bit[2] + count_2bit[3];
    wire [3:0] final_sum = sum_stage1 + sum_stage2;
    assign count_out = final_sum;
endmodule

