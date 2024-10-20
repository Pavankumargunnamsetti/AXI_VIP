package Axi_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "axi_xtn.sv"
`include "master_config.sv"
`include "slave_config.sv"
`include "tb_config.sv"
`include "master_driver.sv"
`include "master_monitor.sv"
`include "master_sequencer.sv"

`include "slave_driver.sv"
`include "slave_monitor.sv"
`include "slave_sequencer.sv"

`include "master_agent.sv"
`include "slave_agent.sv"

`include "master_uvc.sv"
`include "slave_uvc.sv"

`include "score_board.sv"
`include "virtual_sequencer.sv"

`include "env.sv"
`include "master_sequence.sv"

`include "virtual_sequence.sv"
`include "test.sv"
endpackage

