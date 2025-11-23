module weight_perturb #(
    parameter WORD_SIZE = 8
)(
    input wire [WORD_SIZE-1:0] base_weight,
    input wire [WORD_SIZE-1:0] confidence,
    input wire [WORD_SIZE-1:0] random_mask,
    output wire [WORD_SIZE-1:0] perturbed_weight
);
    genvar i;
    generate
        for (i = 0; i < WORD_SIZE; i = i + 1) begin : bit_perturbation
         assign perturbed_weight[i] = confidence[i] ? base_weight[i] : (random_mask[i] ? base_weight[i] : ~base_weight[i]);
        end
    endgenerate
endmodule
