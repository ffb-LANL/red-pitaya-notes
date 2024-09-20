`timescale 1 ns / 1 ps

module axis_trig_sync #
(
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        aresetn,

  input  wire                        pulse,
  input  wire                        sync,
  output wire                        delayed_pulse
);

  reg int_enbl_reg, int_enbl_next,int_delayed_pulse,int_delayed_pulse_next;

  always @(posedge aclk)
  begin
    if(~aresetn)
    begin
      int_enbl_reg <= 1'b0;
      int_delayed_pulse <= 1'b0;
    end
    else
    begin
      int_enbl_reg <= int_enbl_next;
      int_delayed_pulse <= int_delayed_pulse_next;
    end
  end

  always @*
  begin
    int_enbl_next = int_enbl_reg;
    int_delayed_pulse_next = int_delayed_pulse;

    if(~int_enbl_reg & pulse)
    begin
      int_enbl_next = 1'b1;
    end

    if(int_enbl_reg & sync)
    begin
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