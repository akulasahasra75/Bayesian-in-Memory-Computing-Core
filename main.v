module bayesian_imc_core #( 
    parameter WORD_SIZE = 8, 
    parameter NUM_SAMPLES = 8, 
    parameter NUM_WORDS = 4 
)( 
    input wire clk, 
    input wire rst_n, 
    input wire start, 
    input wire [WORD_SIZE-1:0] input_data, 
    input wire [1:0] weight_select, 
    input wire [WORD_SIZE-1:0] confidence_pattern, 
    output reg [3:0] mean_result, 
    output reg [3:0] confidence_level, 
    output reg done, 
    output reg [2:0] current_state_out 
); 
    localparam [2:0] IDLE        = 3'b000; 
    localparam [2:0] INIT_SAMPLE = 3'b001; 
    localparam [2:0] READ_MEMORY = 3'b010; 
    localparam [2:0] PERTURB     = 3'b011; 
    localparam [2:0] PROCESS     = 3'b100; 
    localparam [2:0] ACCUMULATE  = 3'b101; 
    localparam [2:0] ANALYZE     = 3'b110; 
    localparam [2:0] DONE_STATE  = 3'b111; 
 
    reg [2:0] current_state, next_state; 
    reg [3:0] sample_count; 
    wire [WORD_SIZE-1:0] memory_out; 
    reg [3:0] sample_results [0:7]; 
    reg [6:0] result_sum; 
 
    wire [WORD_SIZE-1:0] perturbed_weight; 
    wire [WORD_SIZE-1:0] random_bits; 
    wire [3:0] popcount_result; 
 
    sram_bayesian sram_array ( 
        .clk(clk), .rst_n(rst_n), .word_sel(weight_select), 
        .data_out(memory_out) 
    ); 
 
    lfsr_random random_gen ( 
        .clk(clk), .rst_n(rst_n), .enable(current_state == PERTURB), 
        .random_bits(random_bits) 
    ); 
 
    weight_perturb weight_pert ( 
        .base_weight(memory_out), 
        .confidence(confidence_pattern), 
        .random_mask(random_bits), 
 
        .perturbed_weight(perturbed_weight) 
    ); 
 
    kogge_stone_popcount popcount ( 
        .data_in(input_data ~^ perturbed_weight), 
        .count_out(popcount_result) 
    ); 
 
    integer i; 
    reg [5:0] variance_sum; 
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            current_state <= IDLE; 
            sample_count <= 0; 
            result_sum <= 0; 
            done <= 0; 
            current_state_out <= IDLE; 
            mean_result <= 0; 
            confidence_level <= 0; 
        end else begin 
            current_state <= next_state; 
            current_state_out <= current_state; 
            case (current_state) 
                IDLE: begin 
                    sample_count <= 0; 
                    result_sum <= 0; 
                    done <= 0; 
                end 
                ACCUMULATE: begin 
                    sample_results[sample_count] <= popcount_result; 
                    result_sum <= result_sum + popcount_result; 
                    sample_count <= sample_count + 1; 
                end 
                ANALYZE: begin 
                    mean_result <= result_sum >> 3; 
                    variance_sum = 0; 
                    for (i = 0; i < 8; i = i + 1) begin 
                        if (sample_results[i] > mean_result) 
                            variance_sum = variance_sum + (sample_results[i] - mean_result); 
                        else 
                            variance_sum = variance_sum + (mean_result - sample_results[i]); 
                    end 
                    if (variance_sum < 4)      confidence_level <= 15; 
                    else if (variance_sum < 8) confidence_level <= 12; 
                    else if (variance_sum < 12)confidence_level <= 8; 
                    else if (variance_sum < 16)confidence_level <= 4; 
                    else                       confidence_level <= 1; 
                    done <= 1; 
                end 
                DONE_STATE: begin 
 
                    done <= 0; 
                end 
            endcase 
        end 
    end 
 
    always @(*) begin 
        case (current_state) 
            IDLE:        next_state = start ? INIT_SAMPLE : IDLE; 
            INIT_SAMPLE: next_state = READ_MEMORY; 
            READ_MEMORY: next_state = PERTURB; 
            PERTURB:     next_state = PROCESS; 
            PROCESS:     next_state = ACCUMULATE; 
            ACCUMULATE:  next_state = (sample_count == NUM_SAMPLES-1) ? 
ANALYZE: INIT_SAMPLE; 
            ANALYZE:     next_state = DONE_STATE; 
            DONE_STATE:  next_state = IDLE; 
            default:     next_state = IDLE; 
        endcase 
    end 
endmodule