// Authors: Matej Oblak, Iztok Jeras
// (c) Red Pitaya  http://www.redpitaya.com
////////////////////////////////////////////////////////////////////////////////



//--------------------------------------------------------------------------
// SPI confing for 4ADC

`timescale 1 ns / 1 ps

module spi_cfg_4adc #(
   parameter TIMING = 16'b1101,
   parameter FORMAT = 16'b0

)(
  // system signals
  input                aclk      ,  // clock
  input                aresetn     ,  // reset - active low

  
  // SPI master interface

  output  wire          spi_start_o,
  output  reg [16-1:0]  spi_adr,  
  output  reg [16-1:0]  spi_dat,    
  output  wire          spi_rw,     
  output  wire          spi_cs_sel, 
  output  wire [ 5-1:0] spi_h_lng , 
  output  wire [ 5-1:0] spi_l_lng  ,
  output  wire [ 8-1:0] spi_clk_pre ,
  output  wire          spi_wr_edg  ,
  output  wire          spi_rd_edg  ,
  output  wire          spi_clk_idle,
  input   wire          spi_busy ,


  output reg           spi_done_o,  
  output wire [ 3-1:0] spi_state_o

);


reg           spi_start;
assign spi_rw       = 1'h0;  // no read from ADC
assign spi_cs_sel   = 1'h1;  // only one device
assign spi_h_lng    = 5'h8;  // 8+8 bits
assign spi_l_lng    = 5'h8;
assign spi_clk_pre  = 8'd10; // 12.5 MHz
assign spi_wr_edg   = 1'h1;  // change on falling edge
assign spi_rd_edg   = 1'h1;  // change on falling edge
assign spi_clk_idle = 1'h1;  // idle on HI level
assign spi_start_o = spi_start;



localparam PDWN_ADR = 16'h1;
localparam TIM_ADR  = 16'h2;
localparam MODE_ADR = 16'h3;
localparam FORM_ADR = 16'h4;

localparam PDWN_DAT = 16'h0; // write mode, normal operation
localparam TIM_DAT  = TIMING; // write mode, normal clock polarity, CLKOUT delayed by 270 degrees, clock duty cycle stabilizer ON
localparam MODE_DAT = 16'h2; // write mode, default LVDS config, no LVDS termination, digital out enabled, DDR CMOS output mode
localparam FORM_DAT = FORMAT; // write mode, Checkerboard Output Patterns

`ifdef SIMULATION
localparam ONE_SECOND = 12500; // 100 us
`else 
localparam ONE_SECOND = 12500000; //100 ms 
`endif
localparam  RESET = 3'h0, INIT_PDWN = 3'h1, INIT_TIM=3'h2, INIT_MODE=3'h3, INIT_FORM=3'h4, SPI_END=3'h5;

//              ____________________________________________________________
// data format: |ADR MSB | MSB-1 | ... | LSB | DAT MSB | MSB-1 | ... | LSB |

reg [32-1:0] spi_wait_cnt;
reg [ 3-1:0] spi_state;
assign spi_state_o = spi_state;

always @(posedge aclk) begin
  if (~aresetn)
    spi_wait_cnt <= 'h0;
  else if (spi_wait_cnt < ONE_SECOND)
    spi_wait_cnt <= spi_wait_cnt + 'h1;
end 

always @(posedge aclk      ) begin
  if (~aresetn)
    spi_state <= RESET;

  case (spi_state)
    RESET: begin
      spi_done_o <= 'h0;
      spi_start <= (spi_wait_cnt >= ONE_SECOND) & ~spi_busy;
      if (spi_wait_cnt >= ONE_SECOND & ~spi_busy & ~spi_start) begin
        spi_state <= INIT_PDWN;
        spi_adr   <= PDWN_ADR;
        spi_dat   <= PDWN_DAT;
      end
    end

    INIT_PDWN: begin
      spi_start <= ~spi_busy;
      if (~spi_busy & ~spi_start) begin
        spi_state <= INIT_TIM;
        spi_adr   <= TIM_ADR;
        spi_dat   <= TIM_DAT;
      end
    end

    INIT_TIM: begin
      spi_start <= ~spi_busy;
      if (~spi_busy & ~spi_start) begin
        spi_state <= INIT_MODE;
        spi_adr   <= MODE_ADR;
        spi_dat   <= MODE_DAT;
      end
    end

    INIT_MODE: begin
      spi_start <= ~spi_busy;
      if (~spi_busy & ~spi_start) begin
        spi_state <= INIT_FORM;
        spi_adr   <= FORM_ADR;
        spi_dat   <= FORM_DAT;
      end
    end

    INIT_FORM: begin
      spi_start <= 'h0;
      if (~spi_busy & ~spi_start) begin
        spi_state <= SPI_END;
      end
    end

    default: begin
 //     spi_start <= ~spi_busy && adc_reg_commv;
 //     spi_adr   <= adc_reg_comm[31:16];
 //     spi_dat   <= adc_reg_comm[15:0];
      spi_done_o <= 'h1;
    end
  endcase
end 


endmodule
