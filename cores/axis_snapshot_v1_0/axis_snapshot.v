
`timescale 1 ns / 1 ps

module axis_snapshot #
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
  
  
    // Master side
  input wire m_axis_tready,

  output wire [AXIS_TDATA_WIDTH-1:0] data 

 

);
 
reg [AXIS_TDATA_WIDTH-1:0] int_data_reg,int_data_reg_next;
reg int_enbl_reg, int_enbl_next, int_done, int_done_next;

wire int_tvalid_wire;


always @(posedge aclk)
 begin
   if(~aresetn)
    begin
      int_data_reg <= {(AXIS_TDATA_WIDTH-1){1'b0}};
      int_enbl_reg <= 1'b0;
      int_done <= 1'b0;
    end
   else
    begin
      int_enbl_reg <= int_enbl_next;
      int_data_reg <= int_data_reg_next;
      int_done <= int_done_next;
    end		
 end

assign int_tvalid_wire = m_axis_tready & s_axis_tvalid;

always @*
  begin
   int_data_reg_next =  int_data_reg;
   int_enbl_next = int_enbl_reg;
   int_done_next = int_done;
   if(~int_enbl_reg & ~ int_done)
     begin
       int_enbl_next = 1'b1;
     end
   if(int_enbl_reg & int_tvalid_wire)
     begin
       int_data_reg_next = s_axis_tdata;
       int_done_next = 1'b1;
       int_enbl_next = 1'b0;
     end		
  end

  assign s_axis_tready = m_axis_tready; 
  assign data = int_data_reg; 
endmodule
