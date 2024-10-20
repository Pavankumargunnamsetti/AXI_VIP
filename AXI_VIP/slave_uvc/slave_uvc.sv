class slave_uvc extends uvm_agent;
`uvm_component_utils(slave_uvc)
a_config cfg;

slave_agent s_agent[];

function new(string name="slave_uvc",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(a_config) :: get(this,"","a_config",cfg))
	`uvm_fatal(get_type_name(),"getting is failed")

s_agent = new[cfg.no_of_slaves];

foreach(s_agent[i])
	begin
		s_agent[i]=slave_agent::type_id::create($sformatf("s_agent[%0d]",i),this);
		uvm_config_db #(s_config) :: set(this,$sformatf("s_agent[%0d]*",i),"s_config",cfg.s_cfg[i]);
	end

endfunction

endclass

