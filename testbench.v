`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2025 17:03:52
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

module tb_bayesian_imc; 
    reg clk; 
    reg rst_n; 
    reg start; 
    reg [7:0] input_data; 
    reg [1:0] weight_select; 
    reg [7:0] confidence_pattern; 
    wire [3:0] mean_result; 
    wire [3:0] confidence_level; 
    wire done; 
    wire [2:0] current_state; 
 
    integer test_count; 
    integer pass_count; 
 
    reg [79:0] state_names [0:7]; 
    initial begin 
        state_names[0] = "IDLE"; 
        state_names[1] = "INIT_SAMPLE"; 
        state_names[2] = "READ_MEMORY"; 
        state_names[3] = "PERTURB"; 
        state_names[4] = "PROCESS"; 
        state_names[5] = "ACCUMULATE"; 
        state_names[6] = "ANALYZE"; 
        state_names[7] = "DONE"; 
    end 
 
    bayesian_imc_core dut ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start), 
        .input_data(input_data), 
        .weight_select(weight_select), 
        .confidence_pattern(confidence_pattern), 
        .mean_result(mean_result), 
        .confidence_level(confidence_level), 
        .done(done), 
        .current_state_out(current_state) 
    ); 
 
    always #5 clk = ~clk; 
 
    initial begin 
        test_count = 0; 
        pass_count = 0; 
        clk = 0; 
        rst_n = 0; 
        start = 0; 
        input_data = 8'b0; 
        weight_select = 2'b0; 
        confidence_pattern = 8'b0; 
        $display("=== BAYESIAN IMC VERIFICATION ==="); 
        $display("Starting simulation..."); 
        #20; 
        rst_n = 1; 
        #20; 
        $display("\n--- Test 1: High Confidence Pattern ---"); 
        run_bayesian_test(8'b10101010, 2'b00, 8'b11111111, "High Confidence Test"); 
        #100; 
        $display("\n--- Test 2: Medium Confidence Pattern ---"); 
        run_bayesian_test(8'b10101010, 2'b00, 8'b10101010, "Medium Confidence Test"); 
        #100; 
        $display("\n--- Test 3: Low Confidence Pattern ---"); 
        run_bayesian_test(8'b10101010, 2'b00, 8'b00010001, "Low Confidence Test"); 
        #100; 
        $display("\n--- Test 4: Different Weight Pattern ---"); 
        run_bayesian_test(8'b11110000, 2'b01, 8'b11111111, "Different Weight Test"); 
        #50; 
        $display("\n=== SIMULATION SUMMARY ==="); 
        $display("Total Tests: %0d", test_count); 
        $display("Tests Passed: %0d", pass_count); 
        $display("Success Rate: %0.1f%%", (pass_count * 100.0) / test_count); 
        if (pass_count == test_count) 
            $display("*** ALL TESTS PASSED ***"); 
        else 
            $display("*** SOME TESTS FAILED ***"); 
        #100; 
        $finish; 
    end 
 
    task run_bayesian_test; 
        input [7:0] test_input; 
        input [1:0] test_weight_sel; 
        input [7:0] test_confidence; 
        input [80:0] test_name; 
        begin 
            test_count = test_count + 1; 
            $display("Running: %s", test_name); 
            $display("  Input: %b, Weight: %b, Confidence: %b", 
                     test_input, test_weight_sel, test_confidence); 
            input_data = test_input; 
            weight_select = test_weight_sel; 
            confidence_pattern = test_confidence; 
            wait_for_state(3'b000); 
        #10; 
            start = 1; 
            #10; 
            start = 0; 
            wait(done == 1); 
            #20; 
            $display("  Results: Mean = %0d, Confidence = %0d", 
                     mean_result, confidence_level); 
            if (mean_result <= 8 && confidence_level <= 15) begin 
                $display("  PASS: TEST PASSED"); 
                pass_count = pass_count + 1; 
            end else begin 
                $display("  FAIL: TEST FAILED - Invalid results"); 
            end 
            #30; 
        end 
    endtask 
 
    task wait_for_state; 
        input [2:0] target_state; 
        begin 
            while (current_state !== target_state) #10; 
        end 
    endtask 
    always @(current_state) begin 
        $display("  FSM State: %s", state_names[current_state]); 
    end 
 
    initial begin 
        $dumpfile("bayesian_imc.vcd"); 
        $dumpvars(0, tb_bayesian_imc); 
    end 
endmodule
