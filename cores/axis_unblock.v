
`timescale 1 ns / 1 ps

module axis_unblock #
(
  parameter integer AXIS_TDATA_WIDTH = 16 
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

    // Slave side
  input wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input wire                        s_axis_tvalid,
  output wire                       s_axis_tready,
  
  
    // Master side
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,
  input wire                         m_axis_tready

);
 

  assign s_axis_tready = aresetn? m_axis_tready:1'b1; 
  assign m_axis_tvalid = aresetn? s_axis_tvalid:1'b0; 
  assign m_axis_tdata = s_axis_tdata;
endmodule
