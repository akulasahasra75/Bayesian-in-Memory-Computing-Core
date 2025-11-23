module lfsr_random #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire enable,
    output wire [WIDTH-1:0] random_bits
);
    reg [WIDTH-1:0] lfsr_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_reg <= 8'b11011010;
        end else if (enable) begin
            lfsr_reg <= {lfsr_reg[6:0], lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3]};
        end
    end
    assign random_bits = lfsr_reg;
endmodule
