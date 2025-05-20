#set page(fill: rgb("444352"))
#set text(fill: rgb("fdfdfd"))
#set line(stroke: (paint: rgb("fdfdfd")))
#set table(fill: rgb("444352"), stroke: rgb("fdfdfd"))
#set figure(placement: none)

= ECE345 Final Project Report

#figure(
image("DLL.png"),
caption: "Overall architecture of the DLL"
)

#pagebreak()

== VerilogA Code
#line(length: 100%)

```veriloga
// VerilogA for DLL, Charge_Pump, veriloga

`include "constants.vams"
`include "disciplines.vams"

module Charge_Pump(OUT, UP, DOWN, UP_NOT, DOWN_NOT, VDD, GND, IREF_1, IREF_2);

output OUT;
input UP, DOWN;
input UP_NOT, DOWN_NOT;
input VDD, GND;
input IREF_1, IREF_2;

parameter real iamp = 50e-6;
parameter real tdel = 0;
parameter real trise = 10e-12;
parameter real tfall = 10e-12;

electrical OUT, UP, DOWN;
real iout;

analog begin
	if ((V(UP)==1)&&(V(DOWN)==0))
		iout = -iamp;
	if ((V(UP)==0)&&(V(DOWN)==1))
		iout = iamp;
	if ((V(UP)==0)&&(V(DOWN)==0))
		iout = 0;
	if ((V(UP)==1)&&(V(DOWN)==1))
		iout = 0;

	I(OUT) <+ transition(iout, tdel, tfall, trise);
end

endmodule
```

#line(length: 100%)
#pagebreak()

#line(length: 100%)

```veriloga
// VerilogA for DLL, PFD, veriloga

`include "constants.vams"
`include "disciplines.vams"

module PFD(up_out, down_out, up_not, down_not, ref_clk, delayed_clk, VDD, GND);

input ref_clk, delayed_clk;
input VDD, GND;
output up_out, down_out;
output up_not, down_not;
electrical up_out, down_out, ref_clk, delayed_clk;
electrical rst;

parameter real vh = 1.0, vl = 0.0, vth = 0.5;//VDD = 1.0V, GND = 0, Vth = VDD/2 = 0.5V;
parameter real ttol = 5p from [0:inf);//tolerance
parameter real td = 0 from [0:inf); //delay of PFD output
parameter real tt = 10p from [0:inf);//rise and fall time
integer state_up;
integer state_dn;
integer init;

analog begin
   @(initial_step) begin
		state_up = 0;
		state_dn = 0;
		init = 0;
	end
   @(cross((V(ref_clk)-vth), +1, ttol)) begin
	  if (init == 0) begin
		init = 1;
		state_up = 0;
	  end
	  else
      	state_up = 1;
   end

   @(cross((V(delayed_clk)-vth), +1, ttol)) begin
      state_dn = 1;
   end
	
	@(cross((V(rst)-vh), +1, ttol)) begin
		state_up = 0;
		state_dn = 0;
	end
   V(down_out) <+ transition((state_dn == 1) ? vh:vl, td, tt);
   V(up_out) <+ transition((state_up == 1) ? vh:vl, td, tt);
   V(rst) <+ transition((V(up_out)&&V(down_out)) ? vh:vl, {10e-12}, tt);
end

endmodule
```

#line(length: 100%)
#pagebreak()

#line(length: 100%)

```veriloga
// VerilogA for DLL, VCDL, veriloga

`include "constants.vams"
`include "disciplines.vams"

module VCDL(Vin, Vctrl, Vout, VDD, GND);

input Vin;
input Vctrl;
input VDD, GND;
output Vout;

electrical Vin, Vctrl, Vout;
electrical VDD, GND;

parameter real max_delay = 1e-9;
parameter real ttol = 5p from [0:inf);
real total_delay;
real vout;

analog begin
	@(cross(V(Vin)-0.5, +1, ttol)) begin
		total_delay = 700*(1e-12)-(500*1e-12)*V(Vctrl);
		vout = 1.0;
	end
	@(cross(V(Vin)-0.5, -1, ttol)) begin
		total_delay = 700*(1e-12)-(500*1e-12)*V(Vctrl);
		vout = 0.0;
	end
	V(Vout) <+ transition(vout, total_delay, {10e-12});
end

endmodule
```

#line(length: 100%)
#pagebreak()

== DLL Testbench using Verilog

#figure(
image("tb_DLL.png"),
caption: "Testbench Schematic for the DLL"
)

#pagebreak()
#figure(
image("tb_ DLL_verilog_full_0.png"),
caption: "Verilog testbench result: DLL full operation (Inital Value of Vctrl = 0V)"
)

#figure(
image("tb_ DLL_verilog_start_0.png"),
caption: "Verilog testbench result: DLL at start state (Inital Value of Vctrl = 0V)"
)

#figure(
image("tb_ DLL_verilog_end_0.png"),
caption: "Verilog testbench result: DLL at end state (Inital Value of Vctrl = 0V)"
)

#figure(
image("tb_ DLL_verilog_full_1.png"),
caption: "Verilog testbench result: DLL full operation (Inital Value of Vctrl = 1V)"
)

#figure(
image("tb_ DLL_verilog_start_1.png"),
caption: "Verilog testbench result: DLL at start state (Inital Value of Vctrl = 1V)"
)

#figure(
image("tb_ DLL_verilog_end_1.png"),
caption: "Verilog testbench result: DLL at end state (Inital Value of Vctrl = 1V)"
)

#pagebreak()
== Main Cells

#figure(
image("VCDL.png"),
caption: "Complete schematic of the VCDL"
)

#figure(
image("VCDL_stage.png"),
caption: "Single stage of the VCDL"
)

#figure(
image("PFD.png"),
caption: "Schematic of the PFD"
)

#figure(
image("Charge_Pump.png"),
caption: "Schematic of the charge pump"
)

== Supplementary Cells

#figure(
image("inverter.png"),
caption: "Schematic of the inverter"
)

#figure(
image("D_Flip_Flop.png"),
caption: "Schematic of the D Flip-Flop"
)

#figure(
image("NAND.png"),
caption: "Schematic of the NAND gate"
)

== DLL Testbench using Schematics

#figure(
image("tb_DLL_trace_full_0.png"),
caption: "Simulation trace of DLL full operation (Inital Value of Vctrl = 0V)"
)

#figure(
image("tb_DLL_trace_start_0.png"),
caption: "Simulation trace of DLL at start (Inital Value of Vctrl = 0V)"
)

#figure(
image("tb_DLL_trace_end_0.png"),
caption: "Simulation trace of DLL at end (Inital Value of Vctrl = 0V)"
)

#figure(
image("tb_DLL_trace_full_1.png"),
caption: "Simulation trace of DLL full operation (Inital Value of Vctrl = 1V)"
)

#figure(
image("tb_DLL_trace_start_1.png"),
caption: "Simulation trace of DLL at start state (Inital Value of Vctrl = 1V)"
)

#figure(
image("tb_DLL_trace_end_1.png"),
caption: "Simulation trace of DLL at end state (Inital Value of Vctrl = 1V)"
)

== Main Cell Testbenches

#figure(
image("tb_VCDL.png"),
caption: "Testbench Schematic for the VCDL"
)

#pagebreak()
#figure(
image("tb_VCDL_trace_0.png"),
caption: "Simulation trace of the VCDL testbench (Vctrl = 0V)"
)

#figure(
image("tb_VCDL_trace_1.png"),
caption: "Simulation trace of the VCDL testbench (Vctrl = 1V)"
)

#figure(
image("tb_PFD.png"),
caption: "Testbench schematic for the PFD"
)

#figure(
image("tb_PFD_trace.png"),
caption: "Simulation trace of the PFD testbench"
)
