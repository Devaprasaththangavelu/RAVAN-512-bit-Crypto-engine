//asynv_fifo.v
module async_fifo #(
    parameter DSIZE = 32,
    parameter ASIZE = 5
)(
    input  wire wclk, wrst_n, winc,
    input  wire [DSIZE-1:0] wdata,
    output wire wfull,
    
    input  wire rclk, rrst_n, rinc,
    output wire [DSIZE-1:0] rdata,
    output wire rempty
);
    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

    // Synchronize Read Pointer to Write Domain
    sync #(.ADDRSIZE(ASIZE)) sync_r2w (
        .clk(wclk), .rst_n(wrst_n), .ptr_in(rptr), .ptr_out(wq2_rptr)
    );

    // Synchronize Write Pointer to Read Domain
    sync #(.ADDRSIZE(ASIZE)) sync_w2r (
        .clk(rclk), .rst_n(rrst_n), .ptr_in(wptr), .ptr_out(rq2_wptr)
    );

    // Write Controller
    wptr_full #(.ADDRSIZE(ASIZE)) wptr_handler (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .wq2_rptr(wq2_rptr),
        .wfull(wfull), .waddr(waddr), .wptr(wptr)
    );

    // Read Controller
    rptr_empty #(.ADDRSIZE(ASIZE)) rptr_handler (
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .rq2_wptr(rq2_wptr),
        .rempty(rempty), .raddr(raddr), .rptr(rptr)
    );

    // Shared Memory
    fifomem #(.DATASIZE(DSIZE), .ADDRSIZE(ASIZE)) fifo_ram (
        .wclk(wclk), .wclken(winc & ~wfull),
        .waddr(waddr), .raddr(raddr),
        .wdata(wdata), .rdata(rdata)
    );
endmodule
