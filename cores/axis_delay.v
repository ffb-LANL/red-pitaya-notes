
`timescale 1 ns / 1 ps

module axis_delay #
(
  parameter integer AXIS_TDATA_WIDTH = 32,
  parameter integer CNTR_WIDTH = 32
)

(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire [CNTR_WIDTH-1:0]       cfg_data,
  input  wire [CNTR_WIDTH-1:0]       axis_data_count,  

  // Slave side
  output wire                        s_axis_tready,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,



  // Master side
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid,

  // Slave side
  output wire                        s_axis_fifo_tready,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_fifo_tdata,
  input  wire                        s_axis_fifo_tvalid,

  // Master side
  input  wire                        m_axis_fifo_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_fifo_tdata,
  output wire                        m_axis_fifo_tvalid
);

  reg int_enbl_reg, int_enbl_next;
  wire int_comp_wire;

  assign int_comp_wire = axis_data_count > cfg_data;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_enbl_reg <= 1'b0;
    end
    else
    begin
      int_enbl_reg <= int_enbl_next;
    end
  end

 
  always @*
  begin
    int_enbl_next = int_enbl_reg;
    if( ~int_enbl_reg & int_comp_wire)
    begin
       int_enbl_next = 1'b1;
    end
  end

  assign m_axis_fifo_tvalid = s_axis_tvalid;
  assign s_axis_tready = m_axis_fifo_tready;
  assign m_axis_tvalid = int_enbl_reg ? s_axis_fifo_tvalid : s_axis_tvalid;
  assign s_axis_fifo_tready = int_enbl_reg ? m_axis_tready : 1'b0;
  assign m_axis_fifo_tdata=s_axis_tdata;
  assign m_axis_tdata=s_axis_fifo_tdata;

endmodule
