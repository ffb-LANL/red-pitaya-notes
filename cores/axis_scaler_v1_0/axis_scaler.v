
`timescale 1 ns / 1 ps

module axis_scaler #
(
  parameter integer AXIS_TDATA_WIDTH = 14
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire signed  [AXIS_TDATA_WIDTH-1:0]   cfg_data,

    // Slave side
  input wire signed [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input wire                        s_axis_tvalid,
  output wire                       s_axis_tready,

    // Master side
  input  wire                        m_axis_tready,
  output wire signed [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid

);
 

reg signed [AXIS_TDATA_WIDTH-1:0] s_axis_tdata_reg,s_axis_tdata_next;

reg [AXIS_TDATA_WIDTH*2-1:0] int_data_reg, int_data_next;


wire multiply = s_axis_tvalid & m_axis_tready;

always @(posedge aclk)
	begin
		if(~aresetn)
      			begin
				s_axis_tdata_reg <= 0;
				s_axis_tdata_next <= 0;
        			int_data_reg <= 0;
        			int_data_next <= 0;
      			end
    		else
    			begin
     				if(multiply)
					begin
						s_axis_tdata_reg <= s_axis_tdata;
						s_axis_tdata_next <= s_axis_tdata_reg;
 						int_data_reg <= s_axis_tdata_next*cfg_data;
        					int_data_next <= int_data_reg; 
    					end
			end
	end
assign s_axis_tready = m_axis_tready;
assign m_axis_tvalid = s_axis_tvalid;

//scales down relative to 2^(AXIS_TDATA_WIDTH-2), e.g. cfg=4096  for 14 bit equals scale of 1

assign m_axis_tdata = int_data_next[AXIS_TDATA_WIDTH*2-3:AXIS_TDATA_WIDTH-2];

endmodule
