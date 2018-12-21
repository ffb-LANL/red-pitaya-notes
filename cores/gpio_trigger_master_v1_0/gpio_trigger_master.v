
`timescale 1 ns / 1 ps

module axis_gpio_reader #
(
  parameter integer GPIO_DATA_WIDTH = 8,
  parameter integer GPIO_INPUT_WIDTH = 2,
  parameter integer GPIO_OUTPUT_WIDTH = 6
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
  reg  int_trig_reg, int_trig_reg_next;
  wire [GPIO_DATA_WIDTH-1:0] int_data_wire;
  wire [GPIO_OUTPUT_WIDTH-1:0] int_output;

  genvar j;

  // input pins
  generate
    for(j = 0; j < GPIO_INPUT_WIDTH; j = j + 1)
      begin : GPIO
        IOBUF gpio_iobuf (.O(int_data_wire[j]), .IO(gpio_data[j]), .I({(GPIO_INPUT_WIDTH){1'b0}}), .T(1'b1)); 
      end
  endgenerate


  // output pins
  generate
    for(j = GPIO_INPUT_WIDTH; j < GPIO_DATA_WIDTH; j = j + 1)
      begin : GPIO_OUT
        IOBUF gpio_iobuf (.O(int_data_wire[j]), .IO(gpio_data[j]), .I(int_output[j-GPIO_INPUT_WIDTH]), .T(1'b0)); 
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
  assign int_output = {{(GPIO_OUTPUT_WIDTH-2){1'b0}},aclk,trigger};

endmodule
