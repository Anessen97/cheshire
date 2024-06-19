// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>
// Yann Picod <ypicod@ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`include "cheshire/typedef.svh"

// TODO: Expose more IO: unused SPI CS, Serial Link, etc.

module cheshire_top_chip (
  input  logic  clk_i,
  input  logic  rst_ni,
);

  ///////////////////////
  //  Cheshire Config  //
  ///////////////////////

  import cheshire_pkg::*;

  // Use default config as far as possible
  function automatic cheshire_cfg_t gen_cheshire_chip_cfg();
    cheshire_cfg_t ret  = DefaultCfg;
    ret.Vga = 0;
    ret.AxiDataWidth = 32;
    ret.AddrWidth = 32;
    ret.LlcOutRegionEnd = 'hFFFF_FFFF;
    ret.SerialLink      = 0;
    return ret;
  endfunction

  // Configure cheshire for FPGA mapping
  localparam cheshire_cfg_t ChipCfg = gen_cheshire_chip_cfg();
  `CHESHIRE_TYPEDEF_ALL(, ChipCfg)
  
  //////////////////
  // Cheshire SoC //
  //////////////////

  cheshire_soc #(
    .Cfg                ( ChipCfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
    .reg_ext_req_t      ( reg_req_t ),
    .reg_ext_rsp_t      ( reg_req_t )
  ) i_cheshire_soc (
    .clk_i              ( clk_i ),
    .rst_ni             ( rst_ni   )
  );

endmodule
