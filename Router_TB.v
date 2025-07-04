module router_tb;

    reg clk, rst;
    reg [7:0] data_in_local;
    reg valid_in_local;
    wire ready_out_local;

    // Outputs
    wire [7:0] data_out_east;
    wire valid_out_east;
    reg ready_in_east;

    // Other ports not driven in this simple test
    wire [7:0] dummy_data;
    wire dummy_valid;
    reg dummy_ready = 1;

    // Instantiate router
    router uut (
        .clk(clk), .rst(rst),

        .data_in_local(data_in_local),
        .valid_in_local(valid_in_local),
        .ready_out_local(ready_out_local),

        .data_in_north(8'b0), .valid_in_north(1'b0), .ready_out_north(),
        .data_in_south(8'b0), .valid_in_south(1'b0), .ready_out_south(),
        .data_in_east(8'b0),  .valid_in_east(1'b0),  .ready_out_east(),
        .data_in_west(8'b0),  .valid_in_west(1'b0),  .ready_out_west(),

        .data_out_local(), .valid_out_local(), .ready_in_local(1'b1),
        .data_out_north(), .valid_out_north(), .ready_in_north(1'b1),
        .data_out_south(), .valid_out_south(), .ready_in_south(1'b1),
        .data_out_east(data_out_east), .valid_out_east(valid_out_east), .ready_in_east(ready_in_east),
        .data_out_west(), .valid_out_west(), .ready_in_west(1'b1)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Running NoC Router Testbench");
        clk = 0; rst = 1;
        data_in_local = 0;
        valid_in_local = 0;
        ready_in_east = 1;

        #15;
        rst = 0;

        // Inject packet from Local destined for East (dest_x = 2'b10 > 2'b01)
        #10;
        data_in_local = 8'b10_01_1111; // dest_x = 2, dest_y = 1, payload = 4'b1111
        valid_in_local = 1;

        #10;
        valid_in_local = 0;

        #50;
        $finish;
    end
endmodule
