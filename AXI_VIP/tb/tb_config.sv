class a_config extends uvm_object;
`uvm_object_utils (a_config)
int no_of_masters;
int no_of_slaves;
int no_of_transactions=1;
bit has_virtual_sequencer;
bit has_sb;
m_config m_cfg[];
s_config s_cfg[];



function new(string name="a_config");
super.new(name);
endfunction
endclass
