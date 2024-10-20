class axi_xtn extends uvm_sequence_item;
`uvm_object_utils (axi_xtn)

function new (string name="axi_xtn");
super.new(name);
endfunction

//write_address_channel
rand bit [3:0] AWID;
rand bit [31:0] AWADDR;
rand bit [3:0] AWLEN;
rand bit [2:0] AWSIZE;
rand bit [1:0] AWBURST;
bit AWVALID,AWREADY;

//write_data channel
rand bit [3:0] WID;
rand bit [31:0]WDATA[];
rand bit [3:0] WSTRB[];
bit WREADY,WLAST,WVALID;

//write_response channel
rand bit [3:0] BID;
rand bit [1:0] BRESP;
bit BVALID,BREADY;

//read_address_channel
rand bit [3:0] ARID;
rand bit [31:0] ARADDR;
rand bit [3:0] ARLEN;
rand bit [2:0] ARSIZE;
rand bit [1:0] ARBURST;
bit ARVALID,ARREADY;

//read_data/response channel
rand bit [3:0] RID;
rand bit [31:0]RDATA[];
bit [3:0]RSTRB[];
rand bit [1:0] RRESP;
bit RREADY,RLAST,RVALID;


//write signals constraints

constraint SIZE_W{AWSIZE dist{0:=1,1:=1,2:=1};}
constraint BURST_W{AWBURST dist{0:=2,1:=2,2:=2};}
constraint ADDR_WA{AWBURST==2'b10 && AWSIZE==1 -> AWADDR%2==0;}
constraint ADDR_WB{AWBURST==2'b10 && AWSIZE==2 -> AWADDR%4==0;}
constraint ALEN{AWBURST==2 -> AWLEN inside{1,3,7,15};
		ARBURST==2 -> ARLEN inside{1,3,7,15};}
constraint WDATA_size{WDATA.size==AWLEN+1;}
constraint wstrb_size{WSTRB.size==WDATA.size;}
constraint ID_W{AWID==WID;WID==BID;}


//read_signals constraints
constraint SIZE_R{ARSIZE dist{0:=1,1:=1,2:=1};}
constraint BURST_R{ARBURST dist{0:=2,1:=2,2:=2};}
constraint ADDR_RA{ARBURST==2'b10 && ARSIZE==1 -> ARADDR %2 ==0;}
constraint ADDR_RB{ARBURST==2'b10 && ARSIZE==2 -> ARADDR %4 ==0;}
constraint len{RDATA.size==ARLEN+1;}
constraint ID_R{ARID==RID;}


//constraint ques{AWSIZE==1;AWLEN==4;AWADDR==5;}


function bit do_compare(uvm_object rhs,uvm_comparer comparer);
axi_xtn rhs_;
if(!$cast(rhs_,rhs))
		`uvm_fatal(get_type_name(),"casting is failed in do_compare")
for(int i=0;i<=this.AWLEN;i++)
	begin
	if(!(this.WDATA[i]==rhs_.WDATA[i])&&(this.WSTRB[i]==rhs_.WSTRB[i]))
	return 0;
	end
for(int i=0;i<=this.ARLEN;i++)
	begin
	if(!(this.RDATA[i]==rhs_.RDATA[i]))
	return 0;
	end

return this.AWLEN==rhs_.AWLEN &&
	this.AWSIZE==rhs_.AWSIZE &&
	this.AWBURST==rhs_.AWBURST &&
	this.ARLEN==rhs_.ARLEN &&
	this.ARSIZE==rhs_.ARSIZE &&
	this.ARBURST==rhs_.ARBURST;

endfunction



function void do_print(uvm_printer printer);
printer.print_field("AWADDR",this.AWADDR,32,UVM_DEC);
foreach(this.waddr[i])
printer.print_field($sformatf("waddr[%0d]",i),this.waddr[i],32,UVM_DEC);

printer.print_field("AWLEN",this.AWLEN,4,UVM_DEC);
printer.print_field("AWSIZE",this.AWSIZE,3,UVM_DEC);
printer.print_field("AWBURST",this.AWBURST,2,UVM_DEC);
foreach(this.WDATA[i])
printer.print_field($sformatf("WDATA[%0d]",i),this.WDATA[i],32,UVM_DEC);
foreach(this.WSTRB[i])
printer.print_field($sformatf("WSTRB[%0d]",i),this.WSTRB[i],4,UVM_BIN);
printer.print_field("BRESP",this.BRESP,2,UVM_DEC);
printer.print_field("ARADDR",this.ARADDR,32,UVM_DEC);
foreach(this.raddr[i])
printer.print_field($sformatf("raddr[%0d]",i),this.raddr[i],32,UVM_DEC);

printer.print_field("ARVALID",this.ARVALID,1,UVM_DEC);
printer.print_field("ARLEN",this.ARLEN,4,UVM_DEC);
printer.print_field("ARSIZE",this.ARSIZE,3,UVM_DEC);
printer.print_field("ARBURST",this.ARBURST,2,UVM_DEC);
foreach(this.RDATA[i])
printer.print_field($sformatf("RDATA[%0d]",i),this.RDATA[i],32,UVM_DEC);
printer.print_field("RRESP",this.RRESP,2,UVM_DEC);
endfunction



int unsigned waddr[];
int unsigned raddr[];

function void post_randomize();
w_addr_calc();
r_addr_calc();
strobe_calc();
endfunction



function void w_addr_calc();
int unsigned start_address=AWADDR;
int unsigned number_bytes=2**AWSIZE;
int unsigned burst_length=AWLEN+1;
int unsigned aligned_address = (int'(start_address/number_bytes))*number_bytes;
int unsigned wrap_boundary=(int'(start_address/(number_bytes*burst_length)))*(number_bytes*burst_length);
bit wrapped;

waddr = new[burst_length];
waddr[0]=start_address;

if(AWBURST==0) //fixed burst
		for(int i=2;i<=burst_length;i++)
		waddr[i-1] = start_address;
if(AWBURST==1) //INC burst
	for(int i=2;i<=burst_length;i++)
		waddr[i-1] = aligned_address +((i-1)*number_bytes);
		
if(AWBURST==2) //WRAP burst
begin
for(int i=2; i<= burst_length;i++)
	begin
		if(!wrapped)
			begin
				waddr[i-1] =  aligned_address+((i-1)*number_bytes);

				if(waddr[i-1]==wrap_boundary+(number_bytes*burst_length))
					begin
		 				waddr[i-1]=wrap_boundary;
						wrapped++;
					end
			end

		else
		waddr[i-1]=start_address+((i-1)*number_bytes)-(number_bytes*burst_length);
	end
end			 
endfunction

function void r_addr_calc();
int unsigned start_address=ARADDR;
int unsigned number_bytes=2**ARSIZE;
int unsigned burst_length=ARLEN+1;
int unsigned aligned_address = (int'(start_address/number_bytes))*number_bytes;
int unsigned wrap_boundary=(int'(start_address/(number_bytes*burst_length)))*(number_bytes*burst_length);
bit wrapped;


raddr = new[burst_length];
raddr[0]=start_address;

if(ARBURST==0) //fixed burst
		for(int i=2;i<=burst_length;i++)
		raddr[i-1] = start_address;
if(ARBURST==1) //INC burst
	for(int i=2;i<=burst_length;i++)
		raddr[i-1] = aligned_address +((i-1)*number_bytes);
		
if(ARBURST==2) //WRAP burst
begin
for(int i=2; i<= burst_length;i++)
	begin
		if(!wrapped)
			begin
				raddr[i-1] =  aligned_address+((i-1)*number_bytes);

				if(raddr[i-1]==wrap_boundary+(number_bytes*burst_length))
					begin
		 				raddr[i]=wrap_boundary;
						wrapped++;
					end
			end

		else
		raddr[i-1]=start_address+((i-1)*number_bytes)-(number_bytes*burst_length);
	end
end			 
endfunction



function void strobe_calc();
int unsigned start_address=AWADDR;
int unsigned number_bytes=2**AWSIZE;
int unsigned burst_length=AWLEN+1;
int unsigned aligned_address = (int'(start_address/number_bytes))*number_bytes;

int unsigned data_bus_bytes = 4;
int unsigned lower_byte_lane;
int unsigned upper_byte_lane;

int unsigned lower_byte_lane_0 = start_address-(int'(start_address/data_bus_bytes))*data_bus_bytes;
int unsigned upper_byte_lane_0 = aligned_address + (number_bytes-1)-(int'(start_address/data_bus_bytes))*data_bus_bytes;


for(int i=0;i<burst_length;i++)
	for(int j=0;j<4;j++)
		WSTRB[i][j]=0;


for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
WSTRB[0][j]=1;

for(int N=1;N<burst_length;N++)
begin
lower_byte_lane= waddr[N]-(int'(waddr[N]/data_bus_bytes))*data_bus_bytes;
upper_byte_lane = lower_byte_lane+number_bytes-1;
for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
WSTRB[N][j] = 1;
end

endfunction	


//---------------------------------READ STROBE_________________________________
function void r_strobe_calc();
int unsigned start_address=ARADDR;
int unsigned number_bytes=2**ARSIZE;
int unsigned burst_length=ARLEN+1;
int unsigned aligned_address = (int'(start_address/number_bytes))*number_bytes;

int unsigned data_bus_bytes = 4;
int unsigned lower_byte_lane;
int unsigned upper_byte_lane;

int unsigned lower_byte_lane_0 = start_address-(int'(start_address/data_bus_bytes))*data_bus_bytes;
int unsigned upper_byte_lane_0 = aligned_address + (number_bytes-1)-(int'(start_address/data_bus_bytes))*data_bus_bytes;

RSTRB = new[ARLEN+1];

for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
RSTRB[0][j]=1;

for(int N=1;N<burst_length;N++)
begin
lower_byte_lane= raddr[N]-(int'(raddr[N]/data_bus_bytes))*data_bus_bytes;
upper_byte_lane = lower_byte_lane+number_bytes-1;
for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
RSTRB[N][j] = 1;
end

endfunction	

endclass
