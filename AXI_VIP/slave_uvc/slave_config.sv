class s_config extends uvm_object;
`uvm_object_utils (s_config)

virtual axi vif;
uvm_active_passive_enum is_active;

function new(string name="s_config");
super.new(name);
endfunction
endclass
