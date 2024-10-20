class master_uvc extends uvm_agent;
`uvm_component_utils(master_uvc)
a_config cfg;

master_agent m_agent[];

function new(string name="master_uvc",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(a_config) :: get(this,"","a_config",cfg))
	`uvm_fatal(get_type_name(),"getting is failed")

m_agent = new[cfg.no_of_masters];

foreach(m_agent[i])
	begin
		m_agent[i]=master_agent::type_id::create($sformatf("m_agent[%0d]",i),this);
		uvm_config_db #(m_config) :: set(this,$sformatf("m_agent[%0d]*",i),"m_config",cfg.m_cfg[i]);
	end

endfunction

endclass

