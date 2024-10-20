class score_board extends uvm_scoreboard;
`uvm_component_utils (score_board)
uvm_tlm_analysis_fifo #(axi_xtn) m_fifo[];
uvm_tlm_analysis_fifo #(axi_xtn) s_fifo[];
a_config cfg;
 int master_transactions,slave_transactions;

covergroup wa_cov;
//WLEN : coverpoint m_xtn.AWLEN{bins len[]={0,1,2};}
WSIZE : coverpoint m_xtn.AWSIZE{bins siz[]={0,1,2};}
WBURST : coverpoint m_xtn.AWBURST{bins burst[]={0,1,2};
				illegal_bins ILLB={3};
				}
WADDR : coverpoint m_xtn.AWADDR{bins addr = {['h0:'hffffffff]};}
WLEN : coverpoint m_xtn.AWLEN{bins len = {[0:15]};}
W_SxBxL : cross WSIZE,WBURST,WLEN;
endgroup

covergroup ra_cov;
//WLEN : coverpoint m_xtn.AWLEN{bins len[]={0,1,2};}
RSIZE : coverpoint m_xtn.ARSIZE{bins siz[]={0,1,2};}
RBURST : coverpoint m_xtn.ARBURST{bins burst[]={0,1,2};
				illegal_bins ILLB={3};
				}
RADDR : coverpoint m_xtn.ARADDR{bins addr = {['h0:'hffffffff]};}
RLEN : coverpoint m_xtn.ARLEN{bins len = {[0:15]};}
R_SxBxL : cross RSIZE,RBURST,RLEN;
endgroup

covergroup wd_cov with function sample(int i);
WDATA: coverpoint m_xtn.WDATA[i]{bins wdata={['h0:'hffffffff]};}
WSTRB: coverpoint m_xtn.WSTRB[i]{bins wstrb[]={4'b1111,4'b0001,4'b0010,4'b0100,4'b1000,4'b1100,4'b0110,4'b0011};}
endgroup

covergroup rd_cov with function sample(int i);
RDATA: coverpoint m_xtn.RDATA[i]{bins wdata={['h0:'hffffffff]};}
endgroup


function new(string name="score_board",uvm_component parent);
super.new(name,parent);
ra_cov = new;
wa_cov = new;
wd_cov = new;
rd_cov = new;
endfunction

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(a_config)::get(this,"","a_config",cfg))
	`uvm_fatal(get_type_name(),"getting is failed")

m_fifo = new[cfg.no_of_masters];
foreach(m_fifo[i])
	m_fifo[i] = new($sformatf("m_fifo[%0d]",i),this);

s_fifo = new[cfg.no_of_slaves];
foreach(s_fifo[i])
	s_fifo[i] = new($sformatf("s_fifo[%0d]",i),this);

endfunction


task run_phase(uvm_phase phase);
phase.raise_objection(this);	
repeat(cfg.no_of_transactions*2)
	begin
		m_fifo[0].get(m_xtn);
		master_transactions++;
		s_fifo[0].get(s_xtn);	
		slave_transactions++;
		compare_data(m_xtn,s_xtn);	
	end
phase.drop_objection(this);
endtask

axi_xtn m_xtn,s_xtn;

int mismatched_data, matched_data;
task compare_data(axi_xtn m_xtn, axi_xtn s_xtn);
`uvm_info(get_type_name(),$sformatf("master_monitor %s slave_monitor %s ",m_xtn.sprint(),s_xtn.sprint()),UVM_LOW)
if(!m_xtn.compare(s_xtn))
		begin
			`uvm_error(get_type_name(),"master and slave data mismatched")
			mismatched_data++;
		end
else
		begin
			`uvm_info(get_type_name(),"master and slave data matched",UVM_LOW)
			matched_data++;
			wa_cov.sample();
			ra_cov.sample();
			foreach(m_xtn.WDATA[i])
				wd_cov.sample(i);
			foreach(m_xtn.RDATA[i])
				rd_cov.sample(i);
		end
endtask

function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(),$sformatf("\n\n------------------------------------------------------------------\n\n master_transactions -> %0d\n slave_transactions  -> %0d\n matched_data        -> %0d\n mismatched_data     -> %0d\n\n ------------------------------------------------------------------",master_transactions,slave_transactions,matched_data,mismatched_data),UVM_LOW)
endfunction

endclass
