module sram_bayesian #(
    parameter WORD_SIZE = 8,
    parameter NUM_WORDS = 4
)(
    input wire clk,
    input wire rst_n,
    input wire [1:0] word_sel,
    output reg [WORD_SIZE-1:0] data_out
);
    reg [WORD_SIZE-1:0] memory [0:NUM_WORDS-1];
    initial begin
        memory[0] = 8'b10100101;
        memory[1] = 8'b11001100;
       
 memory[2] = 8'b01011010;
        memory[3] = 8'b11110000;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {WORD_SIZE{1'b0}};
        end else begin
            data_out <= memory[word_sel];
        end
    end
endmodule
