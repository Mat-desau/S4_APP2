// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Tue Jan 16 12:00:21 2024
// Host        : gegi-3014-bmwin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/rosj2103/Downloads/pb_logique_seq/pb_logique_seq.gen/sources_1/bd/design_1/ip/design_1_calcul_param_2_0_0/design_1_calcul_param_2_0_0_stub.v
// Design      : design_1_calcul_param_2_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "calcul_param_2,Vivado 2020.2" *)
module design_1_calcul_param_2_0_0(i_bclk, i_reset, i_en, i_ech, o_param)
/* synthesis syn_black_box black_box_pad_pin="i_bclk,i_reset,i_en,i_ech[23:0],o_param[7:0]" */;
  input i_bclk;
  input i_reset;
  input i_en;
  input [23:0]i_ech;
  output [7:0]o_param;
endmodule
