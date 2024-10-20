class base_test extends uvm_test;
`uvm_component_utils (base_test)

int no_of_masters=1;
int no_of_slaves=1;
int no_of_transactions = 15;
bit has_virtual_sequencer=1;
bit has_sb=1;
env envh;

a_config a_cfg;
m_config m_cfg[];
s_config s_cfg[];

function new(string name="base_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
a_cfg = a_config :: type_id :: create("a_cfg");

a_cfg.m_cfg=new[no_of_masters];
a_cfg.s_cfg=new[no_of_slaves];

m_cfg=new[no_of_masters];
s_cfg=new[no_of_slaves];

foreach(m_cfg[i])
	begin
	m_cfg[i] = m_config:: type_id :: create($sformatf("m_cfg[%0d]",i));
	m_cfg[i].is_active=UVM_ACTIVE;
	if(!uvm_config_db #(virtual axi)::get(this,"","axi",m_cfg[i].vif))
		`uvm_fatal(get_type_name(),"getting is failed")
	a_cfg.m_cfg[i] = m_cfg[i];
	end

foreach(s_cfg[i])
	begin
	s_cfg[i] = s_config:: type_id :: create($sformatf("s_cfg[%0d]",i));
	s_cfg[i].is_active=UVM_ACTIVE;
	if(!uvm_config_db #(virtual axi)::get(this,"","axi",s_cfg[i].vif))
		`uvm_fatal(get_type_name(),"getting is failed")
	a_cfg.s_cfg[i] = s_cfg[i];
	end

a_cfg.no_of_masters=no_of_masters;
a_cfg.no_of_slaves = no_of_slaves;
a_cfg.has_sb = has_sb;
a_cfg.has_virtual_sequencer=has_virtual_sequencer;
a_cfg.no_of_transactions = no_of_transactions;
uvm_config_db #(a_config):: set(this,"*","a_config",a_cfg);

envh= env::type_id :: create("envh",this);

endfunction
endclass


class inc_test extends base_test;
`uvm_component_utils (inc_test)
function new(string name="inc_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

inc_v_seq seq;

task run_phase(uvm_phase phase);
phase.raise_objection(this);
seq = inc_v_seq ::type_id::create("seq");
seq.start(envh.v_seqrh);
phase.drop_objection(this);
endtask
endclass


class fixed_test extends base_test;
`uvm_component_utils (fixed_test)
function new(string name="fixed_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

fixed_v_seq seq;

task run_phase(uvm_phase phase);
phase.raise_objection(this);
seq = fixed_v_seq::type_id::create("seq");
seq.start(envh.v_seqrh);
phase.drop_objection(this);
endtask
endclass



class wrap_test extends base_test;
`uvm_component_utils (wrap_test)
function new(string name="wrap_test",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction

wrap_v_seq seq;

task run_phase(uvm_phase phase);
phase.raise_objection(this);
seq = wrap_v_seq::type_id::create("seq");
seq.start(envh.v_seqrh);
phase.drop_objection(this);
endtask
endclass





	
