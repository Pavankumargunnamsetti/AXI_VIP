module top;
import uvm_pkg::*;
import Axi_pkg::*;

bit clock;

always #5 clock = ~clock;

axi in0(clock);

initial 
begin
`ifdef VCS
$fsdbDumpvars(0,top);
`endif

uvm_config_db #(virtual axi) :: set(null,"*","axi",in0);
uvm_top.enable_print_topology = 1;
run_test();
end
endmodule
