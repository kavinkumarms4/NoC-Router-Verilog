module router #(parameter WIDTH = 8, DEPTH = 4)(
    input clk,
    input rst,
    input [WIDTH-1:0] data_in_local,
    input valid_in_local,
    output wire ready_out_local,

    input [WIDTH-1:0] data_in_north,
    input valid_in_north,
    output wire ready_out_north,

    input [WIDTH-1:0] data_in_south,
    input valid_in_south,
    output wire ready_out_south,

    input [WIDTH-1:0] data_in_east,
    input valid_in_east,
    output wire ready_out_east,

    input [WIDTH-1:0] data_in_west,
    input valid_in_west,
    output wire ready_out_west,

    // Output data and control
    output reg [WIDTH-1:0] data_out_local,
    output reg valid_out_local,
    input ready_in_local,

    output reg [WIDTH-1:0] data_out_north,
    output reg valid_out_north,
    input ready_in_north,

    output reg [WIDTH-1:0] data_out_south,
    output reg valid_out_south,
    input ready_in_south,

    output reg [WIDTH-1:0] data_out_east,
    output reg valid_out_east,
    input ready_in_east,

    output reg [WIDTH-1:0] data_out_west,
    output reg valid_out_west,
    input ready_in_west
);

    // Current router coordinates (hardcoded for now)
    localparam CUR_X = 2'b01;
    localparam CUR_Y = 2'b01;

    // Wires for FIFO outputs
    wire [WIDTH-1:0] fifo_out_local, fifo_out_north, fifo_out_south, fifo_out_east, fifo_out_west;
    wire fifo_valid_local, fifo_valid_north, fifo_valid_south, fifo_valid_east, fifo_valid_west;


    // FIFOs for Input Buffers

    fifo #(WIDTH, DEPTH) fifo_local (
        .clk(clk), .rst(rst),
        .data_in(data_in_local), .write_en(valid_in_local),
        .data_out(fifo_out_local), .read_en(ready_out_local),
        .valid(fifo_valid_local), .ready(ready_out_local)
    );

    fifo #(WIDTH, DEPTH) fifo_north (
        .clk(clk), .rst(rst),
        .data_in(data_in_north), .write_en(valid_in_north),
        .data_out(fifo_out_north), .read_en(ready_out_north),
        .valid(fifo_valid_north), .ready(ready_out_north)
    );

    fifo #(WIDTH, DEPTH) fifo_south (
        .clk(clk), .rst(rst),
        .data_in(data_in_south), .write_en(valid_in_south),
        .data_out(fifo_out_south), .read_en(ready_out_south),
        .valid(fifo_valid_south), .ready(ready_out_south)
    );

    fifo #(WIDTH, DEPTH) fifo_east (
        .clk(clk), .rst(rst),
        .data_in(data_in_east), .write_en(valid_in_east),
        .data_out(fifo_out_east), .read_en(ready_out_east),
        .valid(fifo_valid_east), .ready(ready_out_east)
    );

    fifo #(WIDTH, DEPTH) fifo_west (
        .clk(clk), .rst(rst),
        .data_in(data_in_west), .write_en(valid_in_west),
        .data_out(fifo_out_west), .read_en(ready_out_west),
        .valid(fifo_valid_west), .ready(ready_out_west)
    );

    // XY Routing Logic (Local Input Only for Now)


    wire [1:0] dest_x = fifo_out_local[7:6];
    wire [1:0] dest_y = fifo_out_local[5:4];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out_local <= 0; valid_out_local <= 0;
            data_out_north <= 0; valid_out_north <= 0;
            data_out_south <= 0; valid_out_south <= 0;
            data_out_east  <= 0; valid_out_east  <= 0;
            data_out_west  <= 0; valid_out_west  <= 0;
        end else begin
            valid_out_local <= 0;
            valid_out_north <= 0;
            valid_out_south <= 0;
            valid_out_east  <= 0;
            valid_out_west  <= 0;

            if (fifo_valid_local) begin
                if (dest_x > CUR_X && ready_in_east) begin
                    data_out_east  <= fifo_out_local;
                    valid_out_east <= 1;
                end else if (dest_x < CUR_X && ready_in_west) begin
                    data_out_west  <= fifo_out_local;
                    valid_out_west <= 1;
                end else if (dest_y > CUR_Y && ready_in_south) begin
                    data_out_south <= fifo_out_local;
                    valid_out_south <= 1;
                end else if (dest_y < CUR_Y && ready_in_north) begin
                    data_out_north <= fifo_out_local;
                    valid_out_north <= 1;
                end else if (dest_x == CUR_X && dest_y == CUR_Y && ready_in_local) begin
                    data_out_local <= fifo_out_local;
                    valid_out_local <= 1;
                end
            end
        end
    end
endmodule

// FIFO Module

module fifo #(parameter WIDTH = 8, DEPTH = 4)(
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    input write_en,
    output [WIDTH-1:0] data_out,
    input read_en,
    output reg valid,
    output reg ready
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH):0] wr_ptr, rd_ptr;
    reg [$clog2(DEPTH+1):0] count;

    assign data_out = mem[rd_ptr];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            valid  <= 0;
            ready  <= 1;
        end else begin
            if (write_en && (count < DEPTH)) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end

            if (read_en && (count > 0)) begin
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end

            valid <= (count > 0);
            ready <= (count < DEPTH);
        end
    end
endmodule
