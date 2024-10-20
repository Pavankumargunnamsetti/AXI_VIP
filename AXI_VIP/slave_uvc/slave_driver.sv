class slave_driver extends uvm_driver #(axi_xtn);
`uvm_component_utils (slave_driver)

virtual axi.S_DRV vif;

s_config s_cfg;

function new(string name="slave_driver",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
if(!uvm_config_db #(s_config)::get(this,"","s_config",s_cfg))
	`uvm_fatal(get_type_name(),"getting is failed")

endfunction

function void connect_phase(uvm_phase phase);
vif = s_cfg.vif;
endfunction 


task run_phase(uvm_phase phase);
forever send_to_dut();
endtask

semaphore sem_wac = new(1);
semaphore sem_wadc = new();
semaphore sem_wdc = new(1);
semaphore sem_wdrc = new();
semaphore sem_wrc = new(1);


semaphore sem_rac = new(1);
semaphore sem_radc = new();
semaphore sem_rdc = new(1);

int smem[int];
axi_xtn q1[$],q2[$],q3[$];
axi_xtn wxtn,rxtn;

task send_to_dut();
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


task write_addr();
`uvm_info(get_type_name(),"start of write_addr channel",UVM_HIGH)
wxtn = axi_xtn::type_id::create("wxtn");
@(vif.s_drv);
while(vif.s_drv.AWVALID !==1)
@(vif.s_drv);

wxtn.AWID = vif.s_drv.AWID;
wxtn.AWLEN = vif.s_drv.AWLEN;
wxtn.AWSIZE = vif.s_drv.AWSIZE;
wxtn.AWBURST = vif.s_drv.AWBURST;
wxtn.AWADDR = vif.s_drv.AWADDR;

@(vif.s_drv);
vif.s_drv.AWREADY <=1;
@(vif.s_drv);
vif.s_drv.AWREADY <=0;

q1.push_back(wxtn);
q2.push_back(wxtn);

`uvm_info(get_type_name(),"end of write_addr channel",UVM_HIGH)
repeat($urandom_range(1,5)) @(vif.s_drv);
endtask


task write_data(axi_xtn xtn);
xtn.w_addr_calc();
//while(vif.s_drv.WLAST!==1)
for(int i=0;i<=xtn.AWLEN;i++)
begin
		@(vif.s_drv);
		while(vif.s_drv.WVALID !==1)
		@(vif.s_drv);

		
		if(vif.s_drv.WSTRB==1111)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA;
		else if(vif.s_drv.WSTRB==1000)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[31:24];
		else if(vif.s_drv.WSTRB==0100)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[23:16];
		else if(vif.s_drv.WSTRB==0010)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[15:8];
		else if(vif.s_drv.WSTRB==0001)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[7:0];
		else if(vif.s_drv.WSTRB==0011)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[15:0];
		else if(vif.s_drv.WSTRB==0110)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[23:8];
		else if(vif.s_drv.WSTRB==1100)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[31:16];
		else if(vif.s_drv.WSTRB==0111)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[23:0];
		else if(vif.s_drv.WSTRB==1110)
			smem[xtn.waddr[i]] = vif.s_drv.WDATA[31:8];
	
		vif.s_drv.WREADY <=1;
		@(vif.s_drv);
		vif.s_drv.WREADY <=0;

	repeat($urandom_range(1,5)) @(vif.s_drv);
	
end
endtask

task write_response(axi_xtn xtn);
@(vif.s_drv);
	vif.s_drv.BID <=xtn.AWID;
	vif.s_drv.BVALID<=1;
	vif.s_drv.BRESP <=0;
	@(vif.s_drv);
	while(vif.s_drv.BREADY !==1)
	@(vif.s_drv);
//	@(vif.s_drv);
	vif.s_drv.BVALID <=0;
	vif.s_drv.BRESP <=2'bx;
	vif.s_drv.BID <=4'bx;

	
endtask

task read_addr();
rxtn = axi_xtn::type_id::create("rxtn");
@(vif.s_drv);
while(vif.s_drv.ARVALID !==1)
@(vif.s_drv);

repeat($urandom_range(1,5)) @(vif.s_drv);

rxtn.ARID = vif.s_drv.ARID;
rxtn.ARLEN = vif.s_drv.ARLEN;
rxtn.ARSIZE = vif.s_drv.ARSIZE;
rxtn.ARBURST = vif.s_drv.ARBURST;
rxtn.ARADDR = vif.s_drv.ARADDR;

q3.push_back(rxtn);

vif.s_drv.ARREADY <=1;
@(vif.s_drv);
vif.s_drv.ARREADY <=0;
repeat($urandom_range(1,5)) @(vif.s_drv);


endtask

task read_data(axi_xtn xtn);	
for(int i=0;i<=xtn.ARLEN;i++)
	begin
		@(vif.s_drv);
		vif.s_drv.RID <= xtn.ARID;
		vif.s_drv.RVALID <= 1;
		vif.s_drv.RDATA <= {$random};
		vif.s_drv.RRESP <= 0;
		if(i==xtn.ARLEN)
			vif.s_drv.RLAST <=1;
		else
			vif.s_drv.RLAST <=0;
		@(vif.s_drv);
		while(vif.s_drv.RREADY !==1)
		@(vif.s_drv);
		vif.s_drv.RVALID <=0;
		vif.s_drv.RRESP <= 1'bx;
		vif.s_drv.RLAST <=0;
		vif.s_drv.RDATA <= 'bx;
		repeat($urandom_range(1,5)) @(vif.s_drv);
	end		

endtask


endclass
