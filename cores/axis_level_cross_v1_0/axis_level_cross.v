
`timescale 1 ns / 1 ps

module axis_level_cross #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer CROSS_MASK = 8192,
  parameter ALWAYS_READY = "TRUE"
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,
  input wire signed[AXIS_TDATA_WIDTH-1:0] level,
  input wire                        direction,                        

    // Slave side
  input  wire signed [AXIS_TDATA_WIDTH-1:0] s_axis_tdata, //Data (32 bit vector)
  input wire                        s_axis_tvalid, //Validity of Data (Don't take data if not true)  
  output wire                       s_axis_tready, //Ready to accept data 

    // Master side
  input  wire                        m_axis_tready,
  output  wire signed [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,

  output wire                        state_out
);
 


reg [1:0] int_cross_reg, int_cross_next; 
reg int_state_reg, int_state_next;
wire int_comp_wire; //1 bit wide (true/false) because length not declared  

assign int_comp_wire = direction?s_axis_tdata<level:s_axis_tdata>level; //Internal Comparison wire. direction = 1 then take <, direction = 0 take >. C selection statement  
  
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

//Monitors transition in level 
always @*
        begin
		int_cross_next = int_cross_reg;
		int_state_next = int_state_reg;
		if(s_axis_tvalid)
			begin
				//int_cross_next = {int_cross_reg[0:0],s_axis_tdata & CROSS_MASK? 1'b1:1'b0}; //Looks for change of sign in signal. Figure it out. 
				int_cross_next = {int_cross_reg[0:0],int_comp_wire}; //Concatenation. Changes either LSB or MSB I'm not sure.
			end
		if(int_cross_reg == 2'b10) //Looks for "pattern" in the signal 
			begin
				int_state_next = 1'b1; //Change state if "pattern" found 
			end

	end
		
 if(ALWAYS_READY == "TRUE")
  assign s_axis_tready = 1'b1;
 else
  assign s_axis_tready = m_axis_tready;
 
 

assign m_axis_tvalid = s_axis_tvalid;
assign m_axis_tdata = s_axis_tdata;
assign state_out = int_state_reg;

endmodule
