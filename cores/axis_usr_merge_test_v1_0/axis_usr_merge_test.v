
`timescale 1 ns / 1 ps

module axis_usr_merge_test #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer AXIS_TUSER_WIDTH = 32
)
(
  // User signals
  input  wire [0:0] user_data,

  // System signals
  input  wire                        aclk,

  // Slave side
  output wire                        s_axis_tready,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,

  // Master side
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  output wire [AXIS_TUSER_WIDTH-1:0] m_axis_tuser
);

  assign s_axis_tready =  m_axis_tready;
  assign m_axis_tdata = s_axis_tdata;
  assign m_axis_tvalid = s_axis_tvalid;
  assign m_axis_tuser = {user_data,s_axis_tdata[15:0]};
endmodule
