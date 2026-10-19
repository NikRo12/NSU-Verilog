`timescale 1ns/1ps
module tb_lab2;
    localparam int W = 4;

    logic [W-1:0] d0, d1, y;
    logic         sel;
    logic [1:0]   code;
    logic         enable;
    logic [3:0]   onehot;

    mux2 #(.W(W)) u_mux (.d0(d0), .d1(d1), .sel(sel), .y(y));
    decoder2to4   u_dec (.code(code), .enable(enable), .onehot(onehot));

    integer errors = 0;

    logic [3:0] dec_tt [0:3];
    initial begin
        dec_tt[0] = 4'b0001;
        dec_tt[1] = 4'b0010;
        dec_tt[2] = 4'b0100;
        dec_tt[3] = 4'b1000;
    end

    logic [W-1:0] exp_y;
    logic [3:0]   exp_onehot;

    initial begin
        $dumpfile("wave2.vcd");
        $dumpvars(0, tb_lab2);

        // ---------- Часть A: полный перебор sel, d0, d1 (2*16*16 = 512) ----------
        for (int s = 0; s < 2; s++)
            for (int i = 0; i < 16; i++)
                for (int j = 0; j < 16; j++) begin
                    sel = s[0]; d0 = i[W-1:0]; d1 = j[W-1:0];
                    #1;
                    if (sel == 1'b0) exp_y = d0;
                    else             exp_y = d1;
                    if ($isunknown(y)) begin
                        errors++;
                        $display("ERROR mux: X/Z sel=%b d0=%b d1=%b y=%b", sel, d0, d1, y);
                    end else if (y !== exp_y) begin
                        errors++;
                        $display("ERROR mux: sel=%b d0=%b d1=%b expected=%b actual=%b",
                                 sel, d0, d1, exp_y, y);
                    end
                end

        // ---------- Часть B: все enable и code (2*4 = 8) ----------
        for (int e = 0; e < 2; e++)
            for (int c = 0; c < 4; c++) begin
                enable = e[0]; code = c[1:0];
                #1;
                exp_onehot = enable ? dec_tt[c] : 4'b0000;
                if ($isunknown(onehot)) begin
                    errors++;
                    $display("ERROR dec: X/Z enable=%b code=%b onehot=%b", enable, code, onehot);
                end else begin
                    if (onehot !== exp_onehot) begin
                        errors++;
                        $display("ERROR dec: enable=%b code=%b expected=%b actual=%b",
                                 enable, code, exp_onehot, onehot);
                    end
                    if (enable && !$onehot(onehot)) begin
                        errors++;
                        $display("ERROR dec: enable=1 code=%b onehot=%b is not one-hot", code, onehot);
                    end
                    if (!enable && onehot !== 4'b0000) begin
                        errors++;
                        $display("ERROR dec: enable=0 but onehot=%b", onehot);
                    end
                end
            end

        if (errors == 0) $display("PASS: lab 1.2, 0 errors");
        else             $display("FAIL: lab 1.2, %0d errors", errors);
        $finish;
    end
endmodule
