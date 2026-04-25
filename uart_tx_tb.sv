// Description : Verification of a UARRT Transmitter
// Owner : Soham Sen
// Date : 25/04/2026

 module uart_tx_tb;

    parameter CLK_FREQ  = 1_000_000;
    parameter BAUD_RATE = 100_000;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_CLK = 500;

    reg        clk;
    reg        rst_n;
    reg  [7:0] tx_data;
    reg        tx_valid;
    wire       tx_out;
    wire       tx_busy;

    uart_tx #(.CLK_FREQ(CLK_FREQ), 
              .BAUD_RATE(BAUD_RATE)) dut (.clk(clk), 
      									  .rst_n(rst_n), 
      									  .tx_data(tx_data),
                                          .tx_valid(tx_valid), 
                                          .tx_out(tx_out), 
                                          .tx_busy(tx_busy));

   	// Clock Generation
    initial clk = 0;
    always #(HALF_CLK) clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task automatic send_and_check;
        input [7:0] data;
        integer i;
        reg sampled_bit;
        begin
            @(posedge clk);
            tx_data = data;  tx_valid = 1'b1;
            @(posedge clk);  tx_valid = 1'b0;

            // Middle of START bit
            repeat (CLKS_PER_BIT / 2) @(posedge clk);
            if (tx_out !== 1'b0) fail_count = fail_count + 1;
            else                 pass_count = pass_count + 1;

            // 8 DATA bits
            for (i = 0; i < 8; i = i + 1) begin
                repeat (CLKS_PER_BIT) @(posedge clk);
                if (tx_out !== data[i]) fail_count = fail_count + 1;
                else                    pass_count = pass_count + 1;
            end

            // STOP bit
            repeat (CLKS_PER_BIT) @(posedge clk);
            if (tx_out !== 1'b1) fail_count = fail_count + 1;
            else                 pass_count = pass_count + 1;

            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    initial begin
        rst_n = 0; tx_data = 0; tx_valid = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (3) @(posedge clk);

        send_and_check(8'h55);
        send_and_check(8'hA3);
        send_and_check(8'h00);
        send_and_check(8'hFF);
        send_and_check(8'h42);
        send_and_check(8'hDE);
        send_and_check(8'hAD);

        $display("PASSED=%0d  FAILED=%0d", pass_count, fail_count);
        $finish;
    end
   
   	initial begin
      $dumpfile("dump.vcd");
      $dumpvars;	
    end
   
endmodule
