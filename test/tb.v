
`timescale 1ns/1ps

module tb;

    reg clk;
    reg rst_n;
    reg ena;

    reg  [7:0] ui_in;
    reg  [7:0] uio_in;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Instantiate your Tiny Tapeout top module
    tt_um_fifo dut (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk    = 0;
        rst_n  = 0;
        ena    = 1;
        ui_in  = 8'h00;
        uio_in = 8'h00;

        // Apply reset
        #20;
        rst_n = 1;
        #10;

        // Write 0xA5 into FIFO
        ui_in = 8'hA5;
        uio_in[1] = 1'b1;  // write enable
        #10;
        uio_in[1] = 1'b0;

        // Write 0x3C into FIFO
        ui_in = 8'h3C;
        uio_in[1] = 1'b1;
        #10;
        uio_in[1] = 1'b0;

        // Allow FIFO output logic to update
        #20;

        // Read enable
        uio_in[2] = 1'b1;
        #10;
        uio_in[2] = 1'b0;

        // Display data output
        uio_in[3] = 1'b0;  // select data output
        #10;
        $display("FIFO data output = %h", uo_out);

        // Select status output
        uio_in[3] = 1'b1;
        #10;
        $display("FIFO status output = %b", uo_out);

        // Finish simulation
        #20;
        $finish;
    end

    initial begin
        $monitor(
            "time=%0t rst_n=%b write=%b read=%b ui_in=%h uo_out=%h",
            $time, rst_n, uio_in[1], uio_in[2], ui_in, uo_out
        );
    end

endmodule

