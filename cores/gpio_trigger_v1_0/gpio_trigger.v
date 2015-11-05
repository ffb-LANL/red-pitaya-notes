
`timescale 1 ns / 1 ps

module axis_gpio_reader #
(
  parameter integer GPIO_DATA_WIDTH = 16
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

  inout  wire [GPIO_DATA_WIDTH-1:0]  gpio_data,

  input  wire                        soft_trig,

  output wire                        trigger
);

  reg  [GPIO_DATA_WIDTH-1:0] int_data_reg [1:0];
  reg  triggered, int_trig_reg, int_trig_reg_next;
  wire [GPIO_DATA_WIDTH-1:0] int_data_wire;

  genvar j;

  generate
    for(j = 0; j < GPIO_DATA_WIDTH; j = j + 1)
      begin : GPIO
        IOBUF gpio_iobuf (.O(int_data_wire[j]), .IO(gpio_data[j]), .I({(GPIO_DATA_WIDTH){1'b0}}), .T(1'b1));
      end
  endgenerate

  always @(posedge aclk)
  begin
      int_data_reg[0] <= int_data_wire;
      int_data_reg[1] <= int_data_reg[0];
      if(~aresetn)
      	int_trig_reg <= 1'b0;
      else
	int_trig_reg <= int_trig_reg_next;
  end

  always @*
  begin 
      int_trig_reg_next = int_trig_reg;
      if(soft_trig | int_data_reg[1][0:0])
          int_trig_reg_next = 1'b1;
  end
    

  assign trigger  = int_trig_reg;

endmodule
