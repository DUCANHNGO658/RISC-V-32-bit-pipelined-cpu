`timescale 1ns / 1ps

module top_module_tb();

    // --- 1. KHAI BÁO TÍN HIỆU ĐIỀU KHIỂN ---
    reg clk;
    reg rst;
    
    wire [31:0] next_pc;
    wire [31:0] cur_pc;

    // --- 2. GỌI KHỐI CPU ĐỂ KIỂM TRA (UUT) ---
    top_module #(
        .WIDTH(32)
    ) uut (
        .clk(clk),
        .rst(rst),
        .cur_pc(cur_pc)
    );

    // --- 3. BỘ TẠO XUNG CLOCK (Chu kỳ 10ns -> 100MHz) ---
    always begin
        #5 clk = ~clk;
    end

    // --- 4. KỊCH BẢN MÔ PHỎNG (STIMULUS) ---
    initial begin
        $display("==================================================================");
        $display("   TESTBENCH KHỞI CHẠY CHƯƠNG TRÌNH TÍNH TOÁN: (x10 + x11) - x13  ");
        $display("==================================================================");
        
        // Cấu hình ban đầu kích hoạt Reset
        clk = 0;
        rst = 1; 
        
        // Chờ 2 chu kỳ clock (20ns) rồi nhả reset để CPU bắt đầu chạy
        #20;
        rst = 0; 
        
        // Chờ 150ns để chuỗi lệnh nạp từ program.mem chạy trôi hết qua 5 tầng Pipeline
        #150; 
        
        // In kết quả chốt sau khi chạy xong chương trình
        $display("\n==================================================================");
        $display(" KẾT QUẢ KIỂM TRA TRẠNG THÁI CÁC THANH GHI CUỐI CÙNG:");
        $display(" Thanh ghi x10 (Chứa số 5)                = %d", uut.register_file.rf[10]); 
        $display(" Thanh ghi x11 (Chứa số 2)                = %d", uut.register_file.rf[11]);
        $display(" Thanh ghi x13 (Chứa số 1)                = %d", uut.register_file.rf[13]);
        $display(" -> KẾT QUẢ BIỂU THỨC x12 [(5 + 2) - 1]   = %d", uut.register_file.rf[12]);
        $display("==================================================================");
        
        $finish; // Dừng mô phỏng
    end
      
    // --- 5. THEO DÕI LOG CHẠY LIÊN TỤC TRÊN TCL CONSOLE ---
    initial begin
        $monitor("Time = %0dns | PC = 0x%h | x10 = %d | x11 = %d | x13 = %d | Kết quả x12 = %d", 
                 $time, 
                 cur_pc, 
                 uut.register_file.rf[10], 
                 uut.register_file.rf[11], 
                 uut.register_file.rf[13], 
                 uut.register_file.rf[12]);
    end

endmodule