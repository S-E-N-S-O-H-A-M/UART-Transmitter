// Description : Design of UARRT Transmitter
// Owner : Soham Sen
// Date : 25/04/2026


module uart_tx #(parameter CLK_FREQ = 50_000_000,
                 parameter BAUD_RATE = 115_200)
  (
  	input wire clk,
    input wire rst_n,
    input wire [7:0] tx_data,
    input wire tx_valid,
    output reg tx_out,
    output reg tx_busy
  );
  
  
  localparam integer CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
  
  
  // FSM States
  localparam [2:0] S_IDLE  =3'd0;
  localparam [2:0] S_START =3'd1;
  localparam [2:0] S_DATA  =3'd2;
  localparam [2:0] S_STOP  =3'd3;
  
  reg [2:0] state;
  reg [2:0] bit_idx;
  reg [15:0] clk_cnt;
  reg [7:0] tx_shift;
  
  
  always@(posedge clk)
    begin
      if(!rst_n) begin
        state<=S_IDLE;
        tx_out=1'b1;
        tx_busy<=1'b0;
        clk_cnt<=16'd0;
        bit_idx<=3'd0;
        tx_shift<=8'd0;
      end
      else begin
        case(state)        
       		S_IDLE : begin
              tx_out<=1'b1;
              tx_busy<=0;
              clk_cnt<=16'd0;
              bit_idx<=3'd0;
              if(tx_valid) begin
                tx_shift<=tx_data;
                tx_busy<=1'b1;
                state<=S_START;
              end
            end
            S_START : begin
              tx_out<=1'b0;
              if(clk_cnt<CLK_PER_BIT-1) begin
                clk_cnt<=clk_cnt+1'b1;
              end
              else begin
                clk_cnt<=16'd0;
                state<=S_DATA;
              end
            end
            S_DATA : begin
              tx_out<= tx_shift[bit_idx];
              if(clk_cnt<CLK_PER_BIT-1) begin
                clk_cnt<=clk_cnt+1'b1;
              end
              else begin
                clk_cnt<=16'd0;
                if(bit_idx==3'd7) begin
                  bit_idx<=3'd0;
                  state<=S_STOP;
                end
                else begin
                  bit_idx<=bit_idx+1'b1;
                end
              end
            end
          	S_STOP : begin
              tx_out<=1'b1;
              if(clk_cnt<CLK_PER_BIT-1) begin
                clk_cnt<=clk_cnt+1'b1;
              end
              else begin
                clk_cnt<=16'd0;
                tx_busy<=1'b0;
                state<=S_IDLE;
              end
            end
            default : begin
              state<=S_IDLE;
            end
        endcase
      end
    end
  
endmodule
