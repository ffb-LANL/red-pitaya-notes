
`timescale 1 ns / 1 ps

module gpio_level_trigger #
(
  parameter integer GPIO_DATA_WIDTH = 16
  parameter integer AXIS_TDATA_WIDTH = 32,
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

  inout  wire [GPIO_DATA_WIDTH-1:0]  gpio_data,

  input  wire                        soft_trig,
  input  wire [31:0]                 delay,
  output wire                        trigger
);

  reg  [GPIO_DATA_WIDTH-1:0] int_data_reg [1:0];
  reg  triggered, int_trig_reg, int_trig_reg_next,out_trig, out_trig_next;
  reg  [31:0] counter, counter_next;
  wire [GPIO_DATA_WIDTH-1:0] int_data_wire;
  wire int_comp_wire;

  genvar j;

  generate
    for(j = 0; j < GPIO_DATA_WIDTH; j = j + 1)
      begin : GPIO
        IOBUF gpio_iobuf (.O(int_data_wire[j]), .IO(gpio_data[j]), .I({(GPIO_DATA_WIDTH){1'b0}}), .T(1'b1));
      end
  endgenerate
 
  assign int_comp_wire = counter < delay;
  always @(posedge aclk)
  begin
      int_data_reg[0] <= int_data_wire;
      int_data_reg[1] <= int_data_reg[0];
      if(~aresetn)
         begin
      	int_trig_reg <= 1'b0;
           out_trig <= 1'b0;
           counter <= 32'b0;
         end
      else
         begin
  	       int_trig_reg <= int_trig_reg_next;
            out_trig <= out_trig_next;
            counter <= counter_next;
         end
  end

  always @*
  begin 
      int_trig_reg_next = int_trig_reg;
      out_trig_next = out_trig;
      counter_next = counter;
      if(soft_trig | int_data_reg[1][0:0])
          int_trig_reg_next = 1'b1;
      if ( int_comp_wire & int_trig_reg)
           counter_next=counter  + 1'b1;
      if ( ~int_comp_wire)
          out_trig_next = 1'b1;
      end
    

  assign trigger  = out_trig;
  assign s_axis_tready = m_axis_tready;
  assign m_axis_tvalid = s_axis_tvalid;
  assign m_axis_tdata = s_axis_tdata;
  

endmodule
