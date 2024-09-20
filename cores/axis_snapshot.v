
`timescale 1 ns / 1 ps

module axis_snapshot #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter         ALWAYS_READY = "TRUE" 
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,
  input  wire                        trig_flag,

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

always @*
  begin
   int_data_reg_next =  int_data_reg;
   int_enbl_next = int_enbl_reg;
   int_done_next = int_done;
   if(~int_enbl_reg & ~ int_done)
     begin
       int_enbl_next = 1'b1;
       int_done_next = 1'b0;
     end
	
   if(int_enbl_reg & s_axis_tvalid & trig_flag)
     begin
       int_data_reg_next = s_axis_tdata;
       int_done_next = 1'b1;
       int_enbl_next = 1'b0;
     end		
  end

  generate
    if(ALWAYS_READY == "TRUE")
    begin : READY
      assign s_axis_tready = 1'b1;
    end
    else
    begin : BLOCKING
      assign s_axis_tready = m_axis_tready; 
    end
  endgenerate

  assign data = int_data_reg; 
endmodule
