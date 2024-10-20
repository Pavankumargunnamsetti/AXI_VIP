

class base_sequence extends uvm_sequence #(axi_xtn);
`uvm_object_utils (base_sequence)
a_config cfg;
function new(string name="base_sequence");
super.new(name);
endfunction

task body();
if(!uvm_config_db #(a_config) :: get(null,get_full_name(),"a_config",cfg))
	`uvm_fatal(get_full_name(),"getting is failed")
endtask

endclass

class fixed_sequence extends base_sequence;
`uvm_object_utils (fixed_sequence)

function new(string name="fixed_sequence");
super.new(name);
endfunction

task body();
//bit[1:0] i;
super.body();
repeat(cfg.no_of_transactions)
begin
	req = axi_xtn :: type_id :: create("req");
	start_item(req);
	assert(req.randomize() with {AWBURST==0;ARBURST==0;});//AWSIZE==i;ARSIZE==i;});
	finish_item(req);
//	i=$urandom_range(0,2);
end
endtask
endclass


class inc_sequence extends base_sequence;
`uvm_object_utils (inc_sequence)

function new(string name="inc_sequence");
super.new(name);
endfunction

task body();
//bit [1:0] i;
super.body();
repeat(cfg.no_of_transactions)
begin
	req = axi_xtn :: type_id :: create("req");
	start_item(req);
	assert(req.randomize() with {AWBURST==1;ARBURST==1;});//AWSIZE==i;ARSIZE==i;});
	finish_item(req);
//	if(i==2)
//		i=0;
//	else
//		i++;
end
endtask
endclass

class wrap_sequence extends base_sequence;
`uvm_object_utils (wrap_sequence)

function new(string name="wrap_sequence");
super.new(name);
endfunction

task body();
//bit [1:0] i;
super.body();
repeat(cfg.no_of_transactions)
begin
	req = axi_xtn :: type_id :: create("req");
	start_item(req);
	assert(req.randomize() with {AWBURST==2;ARBURST==2;});//AWSIZE==i;ARSIZE==i;});
	finish_item(req);
//	if(i==2)
//		i=0;
//	else
//		i++;
end
endtask
endclass






