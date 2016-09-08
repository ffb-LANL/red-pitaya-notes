
`timescale 1 ns / 1 ps

module axis_value #
(
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

    // Slave side
  input wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input wire                        s_axis_tvalid,
  output wire                       s_axis_tready,


  output wire [AXIS_TDATA_WIDTH-1:0] data

);
 
reg [AXIS_TDATA_WIDTH-1:0] int_data_reg,int_data_reg_next;

always @(posedge aclk)
  begin
    if(~aresetn)
      begin
         int_data_reg <= {(AXIS_TDATA_WIDTH){1'b0}};
      end
    else
    begin
         int_data_reg <=  int_data_reg_next;
    end
  end

  always @*
    begin
         int_data_reg_next =  int_data_reg;
	 if(s_axis_tvalid)
	   begin
		int_data_reg_next = s_axis_tdata;
           end		
     end

  assign s_axis_tready = 1'b1; 
  assign data = int_data_reg; 
endmodule
