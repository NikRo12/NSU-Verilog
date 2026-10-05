`timescale 1ns/1ps
module tb_lab1;
        logic a, b;
        logic not_a, and_y, or_y, xor_y, nand_y, nor_y, xnor_y;

        basic_gates dut (.*);

    // порядок битов: {not_a, and, or, xor, nand, nor, xnor}
    logic [6:0] actual, expected;
    integer errors = 0;
    logic [6:0] tt [0:3];
    initial begin
        tt[0] = 7'b1000111; // a=0 b=0
        tt[1] = 7'b1011100; // a=0 b=1
        tt[2] = 7'b0011100; // a=1 b=0
        tt[3] = 7'b0110001; // a=1 b=1
    end

    initial begin
        $dumpfile("wave1.vcd");
        $dumpvars(0, tb_lab1);

        for (int i = 0; i < 4; i++) begin
            a = i[1];
            b = i[0];
            #10;
            actual   = {not_a, and_y, or_y, xor_y, nand_y, nor_y, xnor_y};
            expected = tt[i];

            if ($isunknown(actual)) begin
                errors++;
                $display("ERROR: X/Z at a=%b b=%b actual=%b", a, b, actual);
            end else if (actual !== expected) begin
                errors++;
                $display("ERROR: a=%b b=%b expected=%b actual=%b", a, b, expected, actual);
            end
        end

        if (errors == 0) $display("PASS: lab 1.1, 0 errors");
        else             $display("FAIL: lab 1.1, %0d errors", errors);
        $finish;
    end
endmodule
