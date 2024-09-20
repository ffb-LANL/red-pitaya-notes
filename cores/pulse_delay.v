`timescale 1 ns / 1 ps

module pulse_delay #
(
  parameter integer CNTR_WIDTH = 32
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire                        pulse,
  input  wire [CNTR_WIDTH-1:0]       delay,
  output wire                        delayed_pulse
);

  reg [CNTR_WIDTH-1:0] int_cntr_reg, int_cntr_next;
  reg int_enbl_reg, int_enbl_next,int_delayed_pulse,int_delayed_pulse_next;
  wire int_comp_wire, int_last_wire;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_cntr_reg <= {(CNTR_WIDTH){1'b0}};
      int_enbl_reg <= 1'b0;
      int_delayed_pulse <= 1'b0;
    end
    else
    begin
      int_cntr_reg <= int_cntr_next;
      int_enbl_reg <= int_enbl_next;
      int_delayed_pulse <= int_delayed_pulse_next;
    end
  end

  assign int_comp_wire = int_cntr_reg < delay;
  assign int_last_wire = ~int_comp_wire;

    always @*
      begin
        int_cntr_next = int_cntr_reg;
        int_enbl_next = int_enbl_reg;
	int_delayed_pulse_next = int_delayed_pulse;

        if(~int_enbl_reg & pulse)
        begin
          int_enbl_next = 1'b1;
        end

        if(int_enbl_reg & int_comp_wire)
        begin
          int_cntr_next = int_cntr_reg + 1'b1;
        end

        if(int_enbl_reg & int_last_wire)
        begin
          int_cntr_next = {(CNTR_WIDTH){1'b0}};
          int_enbl_next = 1'b0;
	  int_delayed_pulse_next = 1'b1;
        end

	if(int_delayed_pulse)
        begin
	  int_delayed_pulse_next = 1'b0;
        end		
      end

  assign delayed_pulse = int_delayed_pulse;

endmodule