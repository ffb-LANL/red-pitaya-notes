
`timescale 1 ns / 1 ps

module axis_gpio_reader_writer #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer GPIO_IN_DATA_WIDTH = 8,
  parameter integer GPIO_OUT_DATA_WIDTH = 8
)
(
  // System signals
  input  wire                        aclk,

  inout  wire [GPIO_IN_DATA_WIDTH-1:0] gpio_data_in,
  inout  wire [GPIO_OUT_DATA_WIDTH-1:0] gpio_data_out,
  input  wire [GPIO_OUT_DATA_WIDTH-1:0] data,

  // Master side
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid
);

  reg  [AXIS_TDATA_WIDTH-1:0] int_data_reg [1:0];
  wire [AXIS_TDATA_WIDTH-1:0] int_data_wire;

  genvar j;

  generate
  for(j = 0; j < GPIO_IN_DATA_WIDTH ; j = j + 1)
  begin : GPIO_IN
    IOBUF gpio_iobuf (.O(int_data_wire[j]), .IO(gpio_data_in[j]), .I(1'b0), .T(1'b1));
  end
  endgenerate

  generate
  for(j = 0; j < GPIO_OUT_DATA_WIDTH ; j = j + 1)
  begin : GPIO_OUT
    IOBUF gpio_iobuf (.O(int_data_wire[j+GPIO_IN_DATA_WIDTH]), .IO(gpio_data_out[j]), .I(data[j]), .T(1'b0));
  end
  endgenerate

  always @(posedge aclk)
  begin
    int_data_reg[0] <= int_data_wire;
    int_data_reg[1] <= int_data_reg[0];
  end

  assign m_axis_tdata = int_data_reg[1];
  assign m_axis_tvalid = 1'b1;

endmodule
