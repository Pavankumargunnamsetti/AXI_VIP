class env extends uvm_env;

`uvm_component_utils(env)
a_config cfg;

master_uvc m_uvc;
slave_uvc s_uvc;
score_board sb;
virtual_sequencer v_seqrh;


function new(string name="env",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(a_config)::get(this,"","a_config",cfg))
	`uvm_fatal(get_type_name(),"getting is failed")

m_uvc = master_uvc::type_id::create("m_uvc",this);
s_uvc = slave_uvc :: type_id :: create("s_uvc",this);

if(cfg.has_sb)
	sb=score_board::type_id::create("sb",this);

if(cfg.has_virtual_sequencer)
	v_seqrh=virtual_sequencer::type_id::create("v_seqrh",this);

endfunction

function void connect_phase(uvm_phase phase);
if(cfg.has_sb)
	begin
		for(int i=0;i<cfg.no_of_masters;i++)
		m_uvc.m_agent[i].monh.analysis_port.connect(sb.m_fifo[i].analysis_export);
		for(int i=0;i<cfg.no_of_slaves;i++)
		s_uvc.s_agent[i].monh.analysis_port.connect(sb.s_fifo[i].analysis_export);
	end

if(cfg.has_virtual_sequencer)
	begin
		for(int i=0;i<cfg.no_of_masters;i++)
		v_seqrh.m_seqrh[i] = m_uvc.m_agent[i].seqrh;
		for(int i=0;i<cfg.no_of_slaves;i++)
		v_seqrh.s_seqrh[i] = s_uvc.s_agent[i].seqrh;
	end
endfunction		

		
endclass



