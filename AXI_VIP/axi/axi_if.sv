interface axi(input bit ACLK);


//write_address_channel
logic [3:0] AWID;
logic [31:0] AWADDR;
logic [3:0] AWLEN;
logic [2:0] AWSIZE;
logic [1:0] AWBURST;
logic AWVALID,AWREADY;

//write_data channel
logic [3:0] WID;
logic [31:0]WDATA;
logic [3:0]WSTRB;
logic WREADY,WLAST,WVALID;

//write_response channel

logic [3:0] BID;
logic [1:0] BRESP;
logic BVALID,BREADY;


//read_address_channel
logic [3:0] ARID;
logic [31:0] ARADDR;
logic [3:0] ARLEN;
logic [2:0] ARSIZE;
logic [1:0] ARBURST;
logic ARVALID,ARREADY;

//read_data/response channel
logic [3:0] RID;
logic [31:0]RDATA;
logic [1:0] RRESP;
logic RREADY,RLAST,RVALID;

//--------------------------------------------------------------------------------------------
clocking m_drv @(posedge ACLK);
default input #1 output #1;
 
//write_address_channel
output AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
input AWREADY;

//write_data channel
output WID,WDATA,WLAST,WVALID,WSTRB;
input WREADY;

//write_response channel
input BID,BRESP,BVALID;
output BREADY;
//read_address_channel
output ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
input ARREADY;

//read_data/response channel
input RID,RDATA,RRESP,RLAST,RVALID;
output RREADY;

endclocking
//---------------------------------------------------------------------------------------------

clocking m_mon @(posedge ACLK);
default input #1 output #1;

input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
input AWREADY;

//write_data channel
input WID,WDATA,WLAST,WVALID,WSTRB;
input WREADY;

//write_response channel
input BID,BRESP,BVALID;
input BREADY;
//read_address_channel
input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
input ARREADY;

//read_data/response channel
input RID,RDATA,RRESP,RLAST,RVALID;
input RREADY;

endclocking

//---------------------------------------------------------------------------------------------

clocking s_drv @(posedge ACLK);
default input #1 output #1;

//write_address_channel
input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
output AWREADY;

//write_data channel
input WID,WDATA,WSTRB,WLAST,WVALID;
output WREADY;

//write_response channel
output BID,BRESP,BVALID;
input BREADY;
//read_address_channel
input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
output ARREADY;

//read_data/response channel
output RID,RDATA,RRESP,RLAST,RVALID;
input RREADY;

endclocking

//---------------------------------------------------------------------------------------------

clocking s_mon @(posedge ACLK);
default input #1 output #1;
input AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID;
input AWREADY;

//write_data channel
input WID,WDATA,WLAST,WVALID,WSTRB;
input WREADY;

//write_response channel
input BID,BRESP,BVALID;
input BREADY;
//read_address_channel
input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
input ARREADY;

//read_data/response channel
input RID,RDATA,RRESP,RLAST,RVALID;
input RREADY;

endclocking

//---------------------------------------------------------------------------------------------


modport M_DRV(clocking m_drv);
modport M_MON(clocking m_mon);
modport S_DRV(clocking s_drv);
modport S_MON(clocking s_mon);


//----------------------------------------------------------------------------------------------
//------------------------ASSERTIONS------------------------------------------------------------
//----------------------------------------------------------------------------------------------
//___________________________________________________________________________________

property awready;
 @(posedge ACLK) AWVALID && ~AWREADY |=> ($stable(AWADDR) && $stable(AWLEN) && $stable(AWSIZE) && $stable(AWBURST) && $stable(AWVALID) && $stable(AWID)) until AWREADY[->1];
endproperty

property arready;
 @(posedge ACLK) ARVALID && ~ARREADY |=> ($stable(ARADDR) && $stable(ARLEN) && $stable(ARSIZE) && $stable(ARBURST) && $stable(ARVALID) &&  $stable(ARID)) until ARREADY[->1];
endproperty

property wready;
 @(posedge ACLK) WVALID && ~WREADY |=> ($stable(WDATA) && $stable(WLAST) && $stable(WSTRB) && $stable(WVALID) && $stable(WID)) until WREADY[->1];
endproperty

property rready;
 @(posedge ACLK) RVALID && ~RREADY |=> ($stable(RDATA) && $stable(RRESP) && $stable(RLAST) && $stable(RVALID) && $stable(RID)) until RREADY[->1];
endproperty

property bready;
 @(posedge ACLK) BVALID && ~BREADY |=> ($stable(BRESP) && $stable(BID) && $stable(BVALID)) until BREADY[->1];
endproperty

AwReady : cover property(awready);
ArReady : cover property(arready);
wReady : cover property(wready);
rReady : cover property(rready);
bReady : cover property(bready);

//___________________________________________________________________________________
property size_1(x,y,z);
	@(posedge ACLK) (x==1) && (y==2) |-> z%2==0;
endproperty
property size_1(x,y,z);
	@(posedge ACLK) (x==2) && (y==2) |-> z%4==0;
endproperty

ASIZE_1: assert property(size_1(AWSIZE,AWBURST,AWADDR));
ASIZE_2: assert property(size_2(AWSIZE,AWBURST,AWADDR));
RSIZE_1: assert property(size_1(ARSIZE,ARBURST,ARADDR));
RSIZE_2: assert property(size_2(ARSIZE,ARBURST,ARADDR));
//___________________________________________________________________________________

/*
property a_size_1;
	@(posedge ACLK) (AWSIZE==1) && (AWBURST==2) |-> AWADDR%2==0;
endproperty
property a_size_2;
	@(posedge ACLK) (AWSIZE==2) && (AWBURST==2) |-> AWADDR%4==0;
endproperty
property r_size_1;
	@(posedge ACLK) (ARSIZE==1) && (ARBURST==2) |-> ARADDR%2==0;
endproperty
property r_size_2;
	@(posedge ACLK) (ARSIZE==1) && (ARBURST==2) |-> ARADDR%4==0;
endproperty
ASIZE_0: assert property(a_size_1);
ASIZE_1: assert property(a_size_2);
RSIZE_0: assert property(r_size_1);
RSIZE_1: assert property(r_size_2);
*/
//___________________________________________________________________________________

property a_len;
	@(posedge ACLK) $rose(AWVALID) && AWBURST==2 |-> AWLEN inside{1,3,7,15};
endproperty
property r_len;
	@(posedge ACLK) $rose(ARVALID) && ARBURST==2 |-> ARLEN inside{1,3,7,15};
endproperty

ALEN : cover property(a_len);
RLEN : cover property(r_len); 


//___________________________________________________________________________________

property a_size;
@(posedge ACLK) $rose(AWVALID) |-> AWSIZE inside{0,1,2};
endproperty
property r_size;
@(posedge ACLK) $rose(ARVALID) |-> ARSIZE inside{0,1,2};
endproperty

ASIZE : cover property(a_size);
RSIZE : cover property(r_size);

//___________________________________________________________________________________

property a_burst;
@(posedge ACLK) $rose(AWVALID) |-> AWBURST!==3;
endproperty

property r_burst;
@(posedge ACLK) $rose(ARVALID) |-> ARBURST!==3;
endproperty

ABURST: cover property(a_burst);
RBURST: cover property(r_burst);
//___________________________________________________________________________________
  



/*
property awvalid;
@(posedge ACLK) AWVALID |-> if(AWREADY)
					(##1 ~AWVALID || AWVALID)
				else
					(##1 $stable(AWVALID));
endproperty
property wvalid;
@(posedge ACLK) WVALID |-> if(WREADY)
					(##1 ~WVALID || WVALID)
				else
					(##1 $stable(WVALID));
endproperty
property arvalid;
@(posedge ACLK) ARVALID |-> if(ARREADY)
					(##1 ~ARVALID || ARVALID)
				else
					(##1 $stable(ARVALID));

endproperty
property rvalid;
@(posedge ACLK) RVALID |-> if(RREADY)
					(##1 ~RVALID || RVALID)
				else
					(##1 $stable(RVALID));
endproperty
property bvalid;
@(posedge ACLK) BVALID |-> if(BREADY)
					(##1 BVALID || !BVALID)	  
				else
				(##1 $stable(BVALID));
endproperty

Awvalid : assert property(awvalid);
Wvalid : assert property(wvalid);
Arvalid : assert property(arvalid);
Rvalid : assert property(rvalid);
Bvalid : assert property(bvalid);
*/
/*property awvalid;
@(posedge ACLK) AWVALID && ~AWREADY |=> $stable(AWVALID) intersect ~AWREADY;
endproperty
property wvalid;
@(posedge ACLK) WVALID && ~WREADY |=> $stable(WVALID) intersect ~WREADY;
endproperty
property arvalid;
@(posedge ACLK) ARVALID && ~ARREADY |=> $stable(ARVALID) intersect ~ARREADY;
endproperty
property rvalid;
@(posedge ACLK) RVALID && ~RREADY |=> $stable(RVALID) intersect ~RREADY;
endproperty
property bvalid;
@(posedge ACLK) BVALID && ~BREADY |=> $stable(BVALID) intersect ~BREADY;
endproperty

Awvalid : cover property(awvalid);
Wvalid : cover property(wvalid);
Arvalid : cover property(arvalid);
Rvalid : cover property(rvalid);
Bvalid : cover property(bvalid);
*/
endinterface
