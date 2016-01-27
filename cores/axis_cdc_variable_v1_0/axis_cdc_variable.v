
`timescale 1 ns / 1 ps

// Open-loop Multi-Cycle Path formulation for bus clock domain crossing. 
// Assumption that input data changes less often than m_aclk/3 and the AXIS recipient is non-blocking
// faster rate or blocking would require closed loop CDC

module axis_cdc_variable #
(
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // System signals
  input  wire                        in_clk,
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire [AXIS_TDATA_WIDTH-1:0] cfg_data,

  // Master side
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid
);

  reg [AXIS_TDATA_WIDTH-1:0] int_tdata_reg;
  reg int_tvalid_reg, int_tvalid_next;
  reg s_toggle;
  
  reg [2:0] m_sync;
  wire compare;  

  always @(posedge in_clk)
    s_toggle <= s_toggle ^ compare ; // latch an update request on change

  always @(posedge aclk)
    m_sync <= {m_sync[1:0],s_toggle};  // cross update pulse to new clock

  always @(posedge in_clk)
  begin
    if(~aresetn)
       int_tdata_reg <= {(AXIS_TDATA_WIDTH){1'b0}};
    else
       int_tdata_reg <= cfg_data;
  end

  always @(posedge aclk)
      int_tvalid_reg <= int_tvalid_next;


  always @*
  begin
    int_tvalid_next = int_tvalid_reg;

    if(m_sync[2] ^ m_sync[1] )
    begin
      int_tvalid_next = 1'b1;
    end

    if(m_axis_tready & int_tvalid_reg)
    begin
      int_tvalid_next = 1'b0;
    end
  end

  assign compare = int_tdata_reg != cfg_data;

  assign m_axis_tdata = int_tdata_reg;
  assign m_axis_tvalid = int_tvalid_reg;

endmodule
