
`timescale 1 ns / 1 ps

module axis_red_pitaya_adc_4ch #
(
)
(

// ADC
  input  logic [ 27:0] adc_dat_i,  // ADC data
  input  logic aclk,  // ADC A clock 
  input  logic adc_clk_23,  // ADC B clock
  input  logic aresetn,


  // input logic adc_clk_p_i,
  // input logic adc_clk_n_i,
  // input logic adc_clk_p_i2,
  // input logic adc_clk_n_i2,

  input logic adc_buf_clk01,
  input logic adc_buf_clk23,
  input logic idelay_ctrl_clk,
  input logic idelay_ctrl_rst,
  output logic idelay_ctrl_rdy,

  // output logic adc_clk_buf,
  // output logic adc_clk_buf2,


  // Master side
  output wire        m_axis_tvalid,
  output wire [63:0] m_axis_tdata
);
  

logic [3:0][6:0] adc_dat_internal;

assign adc_dat_internal[0] = adc_dat_i[6:0];
assign adc_dat_internal[1] = adc_dat_i[13:7];
assign adc_dat_internal[2] = adc_dat_i[20:14];
assign adc_dat_internal[3] = adc_dat_i[27:21];

wire [2-1:0] adc_clks;
assign adc_clks = {adc_clk_23, aclk};
logic [  2-1: 0]      adc_clk_in;
assign adc_clk_in = {adc_buf_clk23,adc_buf_clk01};

logic signed [3:0][13:0]     adc_dat, adc_dat_r;

// DDR inputs
// falling edge: odd bits    rising edge: even bits   
// 0: CH1 falling edge data  1: CH1 rising edge data
// 2: CH2 falling edge data  3: CH2 rising edge data
// 4: CH3 falling edge data  5: CH3 rising edge data
// 6: CH4 falling edge data  7: CH4 rising edge data

logic idly_rdy;
assign idelay_ctrl_rdy = idly_rdy;

// delay input ADC signals
logic [4*7-1:0] idly_rst ;
logic [4*7-1:0] idly_ce  ;
logic [4*7-1:0] idly_inc ;
logic [4*7-1:0] [5-1:0] idly_cnt ;
logic [4-1:0] [14-1:0] adc_dat_raw;


// diferential clock input
// IBUFDS i_clk_01 (.I (adc_clk_p_i), .IB (adc_clk_n_i), .O (adc_clk_in[0]));  // differential clock input
// IBUFDS i_clk_23 (.I (adc_clk_p_i2), .IB (adc_clk_n_i2), .O (adc_clk_in[1]));  // differential clock input

// assign adc_clk_buf = adc_clk_in[0];
// assign adc_clk_buf2 = adc_clk_in[1];


//(* IODELAY_GROUP = "adc_inputs" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
IDELAYCTRL i_idelayctrl (
  .RDY(idly_rdy),   // 1-bit output: Ready output
  .REFCLK(idelay_ctrl_clk), // 1-bit input: Reference clock input
  .RST(idelay_ctrl_rst)   // 1-bit input: Active high reset input
);

genvar GV;
genvar GVC;
genvar GVD;

generate
for (GVC = 0; GVC < 4; GVC = GVC + 1) begin : channels
  for (GV = 0; GV < 7; GV = GV + 1) begin : adc_decode
    logic           adc_dat_idly;
    logic [ 2-1:0] adc_dat_ddr;


   //(* IODELAY_GROUP = "adc_inputs" *)
   IDELAYE2 #(
      .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
//      .IDELAY_TYPE("VARIABLE"),        // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_TYPE("FIXED"),        // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE(4),                // Input delay tap setting (0-31)
      .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
   )
   i_dly (
      .CNTVALUEOUT  ( idly_cnt[GV+GVC*7]    ),  // 5-bit output: Counter value output
      .DATAOUT      ( adc_dat_idly          ),  // 1-bit output: Delayed data output
      .C            ( adc_clk_in[GVC/2]     ),  // 1-bit input: Clock input
      .CE           ( idly_ce[GV+GVC*7]     ),  // 1-bit input: Active high enable increment/decrement input
      .CINVCTRL     ( 1'b0                  ),  // 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN   ( 5'h0                  ),  // 5-bit input: Counter value input
      .DATAIN       ( 1'b0                  ),  // 1-bit input: Internal delay data input
      .IDATAIN      ( adc_dat_internal[GVC][GV]    ),  // 1-bit input: Data input from the I/O
      .INC          ( idly_inc[GV+GVC*7]    ),  // 1-bit input: Increment / Decrement tap delay input
      .LD           ( idly_rst[GV+GVC*7]    ),  // 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN     ( 1'b0                  ),  // 1-bit input: Enable PIPELINE register to load data input
      .REGRST       ( 1'b0                  )   // 1-bit input: Active-high reset tap-delay input
   );
  
    IDDR #(.DDR_CLK_EDGE("SAME_EDGE")) iddr_adc_dat_0 (.D(adc_dat_idly), .Q1({adc_dat_ddr[1]}), .Q2({adc_dat_ddr[0]}), .C(adc_clks[GVC/2]), .CE(1'b1), .R(1'b0), .S(1'b0));
    assign adc_dat_raw[GVC][2*GV  ] = adc_dat_ddr[0];
    assign adc_dat_raw[GVC][2*GV+1] = adc_dat_ddr[1];
  end 
end
endgenerate

always @(posedge aclk) begin
  adc_dat_r[0] <= {adc_dat_raw[0][14-1], ~adc_dat_raw[0][14-2:0]};
  adc_dat_r[1] <= {adc_dat_raw[1][14-1], ~adc_dat_raw[1][14-2:0]};

  adc_dat  [0] <= adc_dat_r[0];
  adc_dat  [1] <= adc_dat_r[1];
end

always @(posedge aclk) begin
  adc_dat_r[2] <= {adc_dat_raw[2][14-1], ~adc_dat_raw[2][14-2:0]};
  adc_dat_r[3] <= {adc_dat_raw[3][14-1], ~adc_dat_raw[3][14-2:0]};

  adc_dat  [2] <= adc_dat_r[2];
  adc_dat  [3] <= adc_dat_r[3];
end

  assign adc_csn = 1'b1;

  assign m_axis_tvalid = 1'b1;

  assign m_axis_tdata = {
    {(3){adc_dat[3][13]}}, adc_dat[3][12:0],
    {(3){adc_dat[2][13]}}, adc_dat[2][12:0],
    {(3){adc_dat[1][13]}}, adc_dat[1][12:0],
    {(3){adc_dat[0][13]}}, adc_dat[0][12:0]};

endmodule
