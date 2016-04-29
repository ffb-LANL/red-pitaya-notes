
`timescale 1 ns / 1 ps

module axis_measure_pulse #
(
  parameter integer CNTR_WIDTH = 64
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire                        run_flag,
  input  wire                        cfg_flag,
  input  wire [CNTR_WIDTH-1:0]       cfg_data,

  output wire                        trg_flag,
  output wire [CNTR_WIDTH-1:0]       sts_data,

  // Slave side
  output wire                        s_axis_tready,
  input  wire                        s_axis_tvalid
);