
`timescale 1 ns / 1 ps

module axis_delay #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer DEPTH = 32
)

(
  // System signals
  input  wire                        aclk,

  // Slave side
  output wire                        s_axis_tready,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,



  // Master side
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid

);


  reg [AXIS_TDATA_WIDTH-1:0] shift_reg[DEPTH-1:0];
  integer i;
  
  always @(posedge aclk)
  begin
    if(s_axis_tvalid)
    	begin
    	    for (i = 0; i < DEPTH-1; i = i+1)
      		    shift_reg[i+1] <= shift_reg[i];
      		shift_reg[0] <= s_axis_tdata;
    	end
  end

  assign s_axis_tready = m_axis_tready;
  assign m_axis_tvalid = s_axis_tvalid;
  assign m_axis_tdata = shift_reg[DEPTH-1];

endmodule
