class master_agent extends uvm_agent;
`uvm_component_utils(master_agent)
m_config m_cfg;

master_driver drvh;
master_monitor monh;
master_sequencer seqrh;


function new(string name="master_agent",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(m_config)::get(this,"","m_config",m_cfg))
	`uvm_fatal(get_type_name(),"getting is failed")


monh = master_monitor:: type_id:: create("monh",this);
if(m_cfg.is_active== UVM_ACTIVE)
	begin
	drvh = master_driver :: type_id:: create("drvh",this);
	seqrh = master_sequencer :: type_id :: create("seqrh",this);
	end
endfunction

function void connect_phase(uvm_phase phase);
if(m_cfg.is_active== UVM_ACTIVE)
	drvh.seq_item_port.connect(seqrh.seq_item_export);
endfunction

endclass
