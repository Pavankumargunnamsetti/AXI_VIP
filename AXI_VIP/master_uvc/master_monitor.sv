class master_monitor extends uvm_monitor;
`uvm_component_utils (master_monitor)
uvm_analysis_port #(axi_xtn) analysis_port;


virtual axi.M_MON vif;


m_config m_cfg;

function new(string name="master_monitor",uvm_component parent);
super.new(name,parent);
analysis_port = new("analysis_port",this);
endfunction

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(m_config)::get(this,"","m_config",m_cfg))
	`uvm_fatal(get_type_name(),"getting is failed")

endfunction

function void connect_phase(uvm_phase phase);
vif = m_cfg.vif;
endfunction 

task run_phase(uvm_phase phase);
forever
	monitor();
endtask

axi_xtn q1[$],q2[$],q3[$];
axi_xtn m_xtn,rxtn;
task monitor();
fork 
	begin
		sem_wac.get(1);
		write_addr();
		sem_wac.put(1);
		sem_wadc.put(1);
	end
	begin
		sem_wdc.get(1);
		sem_wadc.get(1);
		write_data(q1.pop_front());
		sem_wdc.put(1);
		sem_wdrc.put(1);
	end
	begin
		sem_wrc.get(1);
		sem_wdrc.get(1);
		write_response(q2.pop_front());
		sem_wrc.put(1);
	end


	begin
		sem_rac.get(1);
		read_addr();
		sem_rac.put(1);
		sem_radc.put(1);
	end
	begin
		sem_rdc.get(1);
		sem_radc.get(1);
		read_data(q3.pop_front());
		sem_rdc.put(1);
	end

join_any
endtask


semaphore sem_wac = new(1);
semaphore sem_wadc = new();
semaphore sem_wdc = new(1);
semaphore sem_wdrc = new();
semaphore sem_wrc = new(1);

semaphore sem_rac = new(1);
semaphore sem_radc = new();
semaphore sem_rdc = new(1);


task write_addr();
`uvm_info(get_type_name(),"start of write_addr channel",UVM_HIGH)

m_xtn = axi_xtn::type_id::create("m_xtn");

@(vif.m_mon);
while(vif.m_mon.AWVALID !==1 || vif.m_mon.AWREADY !==1)
@(vif.m_mon);

//wait(vif.m_mon.AWVALID & vif.m_mon.AWREADY);
m_xtn.AWVALID = vif.m_mon.AWVALID;
m_xtn.AWID = vif.m_mon.AWID;
m_xtn.AWLEN = vif.m_mon.AWLEN;
m_xtn.AWSIZE = vif.m_mon.AWSIZE;
m_xtn.AWBURST = vif.m_mon.AWBURST;
m_xtn.AWADDR = vif.m_mon.AWADDR;
m_xtn.AWREADY = vif.m_mon.AWREADY;

//$display("------------------mmon-------------");
//m_xtn.print();
q1.push_back(m_xtn);
`uvm_info(get_type_name(),"end of write_addr channel",UVM_HIGH)

endtask


task write_data(axi_xtn xtn);
`uvm_info(get_type_name(),"start of write_data channel",UVM_HIGH)

xtn.w_addr_calc();
xtn.WDATA = new[xtn.AWLEN+1];
xtn.WSTRB = new[xtn.AWLEN+1];

for(int i=0;i<=xtn.AWLEN;i++)
begin
		//wait(vif.m_mon.WVALID && vif.m_mon.WREADY);
		@(vif.m_mon);
		while(vif.m_mon.WVALID !==1 || vif.m_mon.WREADY !==1)
		@(vif.m_mon);
		xtn.WVALID = vif.m_mon.WVALID;
		xtn.WREADY = vif.m_mon.WREADY;
		xtn.WSTRB[i]=vif.m_mon.WSTRB;
		if(vif.m_mon.WSTRB==1111)
			xtn.WDATA[i] = vif.m_mon.WDATA;
		else if(vif.m_mon.WSTRB==1000)
			xtn.WDATA[i] = vif.m_mon.WDATA[31:24];
		else if(vif.m_mon.WSTRB==0100)
			xtn.WDATA[i] = vif.m_mon.WDATA[23:16];
		else if(vif.m_mon.WSTRB==0010)
			xtn.WDATA[i] = vif.m_mon.WDATA[15:8];
		else if(vif.m_mon.WSTRB==0001)
			xtn.WDATA[i] = vif.m_mon.WDATA[7:0];
		else if(vif.m_mon.WSTRB==0011)
			xtn.WDATA[i] = vif.m_mon.WDATA[15:0];
		else if(vif.m_mon.WSTRB==0110)
			xtn.WDATA[i] = vif.m_mon.WDATA[23:8];
		else if(vif.m_mon.WSTRB==1100)
			xtn.WDATA[i] = vif.m_mon.WDATA[31:16];
		else if(vif.m_mon.WSTRB==0111)
			xtn.WDATA[i] = vif.m_mon.WDATA[23:0];
		else if(vif.m_mon.WSTRB==1110)
			xtn.WDATA[i] = vif.m_mon.WDATA[31:8];
		if(i==xtn.AWLEN)

			xtn.WLAST = vif.m_mon.WLAST;
		
end
q2.push_back(xtn);
`uvm_info(get_type_name(),"end of write_data channel",UVM_HIGH)

endtask

task write_response(axi_xtn xtn);
`uvm_info(get_type_name(),"start of write_response channel",UVM_HIGH)

//wait(vif.m_mon.BVALID && vif.m_mon.BREADY);
@(vif.m_mon);
while(vif.m_mon.BVALID !==1 || vif.m_mon.BREADY !==1)
@(vif.m_mon);

xtn.BID = vif.m_mon.BID;
xtn.BVALID = vif.m_mon.BVALID;
xtn.BREADY = vif.m_mon.BREADY;
xtn.BRESP = vif.m_mon.BRESP;

analysis_port.write(xtn);
`uvm_info(get_type_name(),"end of write_response channel",UVM_HIGH)

endtask


task read_addr();
`uvm_info(get_type_name(),"start of read_addr channel",UVM_HIGH)

rxtn = axi_xtn::type_id::create("rxtn");

@(vif.m_mon);
while(vif.m_mon.AWVALID !==1 || vif.m_mon.AWREADY !==1)
@(vif.m_mon);

rxtn.ARVALID = vif.m_mon.ARVALID;
rxtn.ARID = vif.m_mon.ARID;
rxtn.ARLEN = vif.m_mon.ARLEN;
rxtn.ARSIZE = vif.m_mon.ARSIZE;
rxtn.ARBURST = vif.m_mon.ARBURST;
rxtn.ARADDR = vif.m_mon.ARADDR;
rxtn.ARREADY = vif.m_mon.ARREADY;

q3.push_back(rxtn);
`uvm_info(get_type_name(),"end of read_addr channel",UVM_HIGH)

endtask


task read_data(axi_xtn xtn);
`uvm_info(get_type_name(),"start of read_data channel",UVM_HIGH)

xtn.r_addr_calc();
xtn.r_strobe_calc();
xtn.RDATA = new[xtn.ARLEN+1];
//xtn.WSTRB = new[xtn.AWLEN+1];

for(int i=0;i<=xtn.ARLEN;i++)
begin
	//	wait(vif.m_mon.RVALID && vif.m_mon.RREADY);
		@(vif.m_mon);
		while((vif.m_mon.RVALID !==1)||(vif.m_mon.RREADY !==1))
		@(vif.m_mon);
		xtn.RVALID = vif.m_mon.RVALID;
		xtn.RREADY = vif.m_mon.RREADY;
		if(xtn.RSTRB[i]==1111)
		xtn.RDATA[i] = vif.m_mon.RDATA;
		else if(xtn.RSTRB[i]==1000)
			xtn.RDATA[i] = vif.m_mon.RDATA[31:24];
		else if(xtn.RSTRB[i]==0100)
			xtn.RDATA[i] = vif.m_mon.RDATA[23:16];
		else if(xtn.RSTRB[i]==0010)
			xtn.RDATA[i] = vif.m_mon.RDATA[15:8];
		else if(xtn.RSTRB[i]==0001)
			xtn.RDATA[i] = vif.m_mon.RDATA[7:0];
		else if(xtn.RSTRB[i]==0011)
			xtn.RDATA[i] = vif.m_mon.RDATA[15:0];
		else if(xtn.RSTRB[i]==0110)
			xtn.RDATA[i] = vif.m_mon.RDATA[23:8];
		else if(xtn.RSTRB[i]==1100)
			xtn.RDATA[i] = vif.m_mon.RDATA[31:16];
		else if(xtn.RSTRB[i]==1110)
			xtn.RDATA[i] = vif.m_mon.RDATA[31:8];
		if(i==xtn.ARLEN)
			xtn.RLAST = vif.m_mon.RLAST;
		
end
`uvm_info(get_type_name(),"end of read_data channel",UVM_HIGH)

analysis_port.write(xtn);
endtask

endclass
