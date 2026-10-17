module tt_um_fifo (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,

    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;

    wire [3:0] peak_mark;
    wire [7:0] data_out;

    // FIFO instance
    FIFO_SYNCHRONOUS #(
        .DATAWIDTH(8),
        .DEPTH(8),
        .PTRSIZE(3),
        .ALMOST_FULL(6),
        .ALMOST_EMPTY(2)
    ) fifo_inst (
        .clock_i       (clk),
        .reset_i       (~rst_n),
        .flush_i       (uio_in[0] & ena),
        .write_en_i    (uio_in[1] & ena),
        .read_en_i     (uio_in[2] & ena),
        .datain_i      (ui_in),

        .full_o        (full),
        .empty_o       (empty),
        .almost_full_o (almost_full),
        .almost_empty_o(almost_empty),
        .peak_mark_o   (peak_mark),
        .dataout_o     (data_out)
    );

    // Select data output or status output.
    // uio_in[3] = 0: output FIFO data
    // uio_in[3] = 1: output FIFO status

    assign uo_out = uio_in[3]
                  ? {peak_mark,
                     almost_empty,
                     almost_full,
                     empty,
                     full}
                  : data_out;

    // All bidirectional pins are inputs in this design.
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
