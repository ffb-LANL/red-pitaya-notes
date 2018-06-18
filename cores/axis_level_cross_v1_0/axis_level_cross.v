
`timescale 1 ns / 1 ps

module axis_level_cross #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer CROSS_MASK = 8192
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
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,

  output wire                        state_out
);
 


reg [1:0] int_cross_reg, int_cross_next;
reg int_state_reg, int_state_next;
  
always @(posedge aclk)
	begin
		if(~aresetn)
      			begin
        			int_state_reg <= 0;
      			end
    		else
    			begin
 				int_state_reg <= int_state_next; 
			end
	end

always @(posedge aclk)
	begin
		int_cross_reg <= int_cross_next; 
  	end

always @*
        begin
		int_cross_next = int_cross_reg;
		int_state_next = int_state_reg;
		if(s_axis_tvalid)
			begin
				int_cross_next = {int_cross_reg[0:0],s_axis_tdata & CROSS_MASK? 1'b1:1'b0};
			end
		if(int_cross_reg == 2'b10)
			begin
				int_state_next = 1'b1;
			end

	end
		

assign s_axis_tready = m_axis_tready;
assign m_axis_tvalid = s_axis_tvalid;
assign m_axis_tdata = s_axis_tdata;
assign state_out = int_state_reg;

endmodule
