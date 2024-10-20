class master_driver extends uvm_driver #(axi_xtn);
`uvm_component_utils (master_driver)


virtual axi.M_DRV vif;
m_config m_cfg;

axi_xtn q1[$],q2[$],q3[$],q4[$],q5[$];

function new(string name="master_driver",uvm_component parent);
super.new(name,parent);
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
begin
	seq_item_port.get_next_item(req);
	//req.print();
	send_to_dut(req);
	seq_item_port.item_done();
end
endtask

task send_to_dut(axi_xtn xtn);
q1.push_back(xtn);
q2.push_back(xtn);
q3.push_back(xtn);
q4.push_back(xtn);
q5.push_back(xtn);

fork 
	begin
		sem_wac.get(1);
		write_addr(q1.pop_front());
		sem_wac.put(1);
		sem_wadc.put(1);
	end
	begin
		sem_wdc.get(1);
		sem_wadc.get(1);
		write_data(q2.pop_front());
		sem_wdc.put(1);
		sem_wdrc.put(1);
	end
	begin
		sem_wrc.get(1);
		sem_wdrc.get(1);
		write_response(q3.pop_front());
		sem_wrc.put(1);
	end


	begin
		sem_rac.get(1);
		read_addr(q4.pop_front());
		sem_rac.put(1);
		sem_radc.put(1);
	end
	begin
		sem_rdc.get(1);
		sem_radc.get(1);
		read_data(q5.pop_front());
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




task write_addr(axi_xtn xtn);
`uvm_info(get_type_name(),"start of write_addr channel",UVM_HIGH)
	@(vif.m_drv);
	vif.m_drv.AWVALID <= 1;
	vif.m_drv.AWADDR <= xtn.AWADDR;
	vif.m_drv.AWID <= xtn.AWID;
	vif.m_drv.AWBURST <= xtn.AWBURST;
	vif.m_drv.AWLEN <= xtn.AWLEN;
	vif.m_drv.AWSIZE <= xtn.AWSIZE;

	@(vif.m_drv);
	while(vif.m_drv.AWREADY !==1)
		@(vif.m_drv);
	
	vif.m_drv.AWVALID <=0;
	vif.m_drv.AWADDR <= 'bx;
	vif.m_drv.AWID <= 4'bx;
	vif.m_drv.AWBURST <= 2'bx;
	vif.m_drv.AWLEN <= 4'bx;
	vif.m_drv.AWSIZE <= 3'bx;

repeat($urandom_range(1,5)) @(vif.m_drv);
`uvm_info(get_type_name(),"end of write_addr channel",UVM_HIGH)
endtask

task write_data(axi_xtn xtn);
`uvm_info(get_type_name(),"start of write_data channel",UVM_HIGH)
	
	for(int i=0;i<=xtn.AWLEN;i++)
	begin
		@(vif.m_drv);
		vif.m_drv.WID <= xtn.AWID;
		vif.m_drv.WVALID <= 1;
		vif.m_drv.WDATA <= xtn.WDATA[i];
		vif.m_drv.WSTRB <= xtn.WSTRB[i];
		if(i==xtn.AWLEN)
			vif.m_drv.WLAST <=1;
		else
			vif.m_drv.WLAST <=0;
		@(vif.m_drv);
		while(vif.m_drv.WREADY !==1)
		@(vif.m_drv);
		
		vif.m_drv.WVALID <=0;
		vif.m_drv.WLAST <=0;
		vif.m_drv.WDATA <= 'bx;
		vif.m_drv.WSTRB <= 4'bx;
		repeat($urandom_range(1,5)) @(vif.m_drv);
	end
`uvm_info(get_type_name(),"end of write_data channel",UVM_HIGH)
			
endtask

task write_response(axi_xtn xtn);
`uvm_info(get_type_name(),"start of write_response channel",UVM_HIGH)

@(vif.m_drv);
while(vif.m_drv.BVALID !==1)
	@(vif.m_drv);
repeat($urandom_range(0,5)) @(vif.m_drv);
vif.m_drv.BREADY <=1;
@(vif.m_drv);
vif.m_drv.BREADY <=0;
`uvm_info(get_type_name(),"end of write_response channel",UVM_HIGH)

endtask

task read_addr(axi_xtn xtn);
`uvm_info(get_type_name(),"start of read_addr channel",UVM_HIGH)

@(vif.m_drv);
	vif.m_drv.ARVALID <= 1;
	vif.m_drv.ARADDR <= xtn.ARADDR;
	vif.m_drv.ARID <= xtn.ARID;
	vif.m_drv.ARBURST <= xtn.ARBURST;
	vif.m_drv.ARLEN <= xtn.ARLEN;
	vif.m_drv.ARSIZE <= xtn.ARSIZE;

@(vif.m_drv);

	while(vif.m_drv.ARREADY !==1)
		@(vif.m_drv);
	
	vif.m_drv.ARVALID <=0;
	vif.m_drv.ARADDR <= 'bx;
	vif.m_drv.ARID <= 4'bx;
	vif.m_drv.ARBURST <= 2'bx;
	vif.m_drv.ARLEN <= 4'bx;
	vif.m_drv.ARSIZE <= 3'bx;

repeat($urandom_range(1,5)) @(vif.m_drv);

`uvm_info(get_type_name(),"end of read_addr channel",UVM_HIGH)

endtask

int m_mem[int];

task read_data(axi_xtn xtn);

xtn.r_addr_calc();
xtn.r_strobe_calc();
//while(vif.m_drv.WLAST!==1)
for(int i=0;i<=xtn.ARLEN;i++)
begin
		@(vif.m_drv);
		while(vif.m_drv.RVALID !==1)
		@(vif.m_drv);

		if(xtn.RSTRB[i]==1111)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA;
		else if(xtn.RSTRB[i]==1000)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[31:24];
		else if(xtn.RSTRB[i]==0100)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[23:16];
		else if(xtn.RSTRB[i]==0010)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[15:8];
		else if(xtn.RSTRB[i]==0001)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[7:0];
		else if(xtn.RSTRB[i]==0011)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[15:0];
		else if(xtn.RSTRB[i]==0110)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[23:8];
		else if(xtn.RSTRB[i]==1100)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[31:16];
		else if(xtn.RSTRB[i]==0111)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[23:0];
		else if(xtn.RSTRB[i]==1110)
			m_mem[xtn.raddr[i]] = vif.m_drv.RDATA[31:8];
	
		vif.m_drv.RREADY <=1;
		@(vif.m_drv);
		vif.m_drv.RREADY <=0;

		repeat($urandom_range(0,5)) @(vif.m_drv);

end
endtask


endclass
