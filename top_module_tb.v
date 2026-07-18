`timescale 1ns / 1ps

module top_module_tb();

    reg clk;
    reg rst;
    wire [31:0] cur_pc;

    // Instantiate CPU Under Test
    top_module #(
        .WIDTH(32)
    ) uut (
        .clk(clk),
        .rst(rst),
        .cur_pc(cur_pc)
    );

    // Clock generator (10ns period -> 100MHz)
    always begin
        #5 clk = ~clk;
    end

    // Simulation Stimulus
    initial begin
        $display("==================================================================");
        $display("     COMPREHENSIVE PIPELINE VERIFICATION TESTBENCH LAUNCHED       ");
        $display("==================================================================");
        
        // Setup Waveform Dumps for GTKWave / Vivado
        $dumpfile("cpu_waves.vcd");
        $dumpvars(0, top_module_tb);

        // Initial Reset
        clk = 0;
        rst = 1; 
        #20;
        rst = 0; 
        
        // Wait 350ns for the pipeline to finish all 18 instructions 
        // and process the stalls, flushes, and writebacks.
        #350; 
        
        // --- AUTOMATIC SELF-CHECKING ASSERTIONS ---
        $display("\n==================================================================");
        $display(" VERIFYING REGISTER FILE AND DATA MEMORY STATES...");
        $display("==================================================================");

        if (uut.register_file.rf[1] == 32'd60 &&  // JAL Return PC (56+4)
            uut.register_file.rf[2] == 32'd20 &&  // addi x2
            uut.register_file.rf[3] == 32'd20 &&  // lw x3
            uut.register_file.rf[4] == 32'd30 &&  // add x4 (RAW Hazard Check)
            uut.register_file.rf[5] == 32'd30 &&  // addi x5
            uut.register_file.rf[6] == 32'd0  &&  // Should be 0 (flushed instruction)
            uut.register_file.rf[7] == 32'd0  &&  // Should be 0 (flushed instruction)
            uut.register_file.rf[8] == 32'd0  &&  // Should be 0 (flushed instruction)
            uut.register_file.rf[9] == 32'd0  &&  // Should be 0 (flushed instruction)
            uut.register_file.rf[10] == 32'd60 && // addi x10, x1 (JAL Link address RAW Forwarding)
            uut.data_mem.mem[1] == 32'd20 &&      // RAM[4] = 20
            uut.data_mem.mem[2] == 32'd60)        // RAM[8] = 60
        begin
            $display(" >>> [TEST STATUS]: SUCCESS! CPU PASSED ALL VERIFICATION CHECKS. <<<");
            $display("   - Test Data Forwarding (MEM/WB -> EX): PASS");
            $display("   - Test Load-Use Stall (ID bubble): PASS");
            $display("   - Test Branch BEQ/BNE Taken & Flush: PASS");
            $display("   - Test Jump JAL Taken & Link address Forwarding: PASS");
            $display("   - Test Memory SW/LW: PASS");
        end
        else begin
            $display(" >>> [TEST STATUS]: FAILED! MISMATCH IN REGISTER FILE OR MEMORY STATE. <<<");
            $display(" Actual Register State:");
            $display("   x1 (ra)   = %d (Expected: 60)", uut.register_file.rf[1]);
            $display("   x2        = %d (Expected: 20)", uut.register_file.rf[2]);
            $display("   x3        = %d (Expected: 20)", uut.register_file.rf[3]);
            $display("   x4 (RAW)  = %d (Expected: 30)", uut.register_file.rf[4]);
            $display("   x5        = %d (Expected: 30)", uut.register_file.rf[5]);
            $display("   x6 (Flush)= %d (Expected: 0)",  uut.register_file.rf[6]);
            $display("   x7 (Flush)= %d (Expected: 0)",  uut.register_file.rf[7]);
            $display("   x8 (Flush)= %d (Expected: 0)",  uut.register_file.rf[8]);
            $display("   x9 (Flush)= %d (Expected: 0)",  uut.register_file.rf[9]);
            $display("   x10 (Link)= %d (Expected: 60)", uut.register_file.rf[10]);
            $display("   RAM[4]    = %d (Expected: 20)", uut.data_mem.mem[1]);
            $display("   RAM[8]    = %d (Expected: 60)", uut.data_mem.mem[2]);
        end
        $display("==================================================================");
        
        $finish;
    end
      
    // Simulation monitor trace
    initial begin
        $monitor("Time = %0dns | PC = 0x%h | x1 (ra) = %d | x4 = %d | x10 = %d", 
                 $time, 
                 cur_pc, 
                 uut.register_file.rf[1], 
                 uut.register_file.rf[4], 
                 uut.register_file.rf[10]);
    end

endmodule