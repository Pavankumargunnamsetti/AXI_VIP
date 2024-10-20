class trans;


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
rand bit[3:0] WSTRB[];
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
rand bit [1:0] RRESP;
bit RREADY,RLAST,RVALID;


//write signals constraints

constraint SIZE_W{AWSIZE inside{[0:2]};}
constraint BURST_W{AWBURST inside{[0:2]};}
constraint SIZE{AWSIZE dist{0,1,2};}
constraint ADDR_WA{AWBURST==2'b10 && AWSIZE==1 -> AWADDR%2==0;}
constraint ADDR_WB{AWBURST==2'b10 && AWSIZE==2 -> AWADDR%4==0;}
constraint WDATA_size{WDATA.size==AWLEN+1;}
constraint wstrb_size{WSTRB.size==WDATA.size;}
constraint ID_W{AWID==WID;WID==BID;}


//read_signals constraints
constraint SIZE_R{ARSIZE inside{[0:2]};}
constraint BURST_R{ARBURST inside{[0:2]};}
constraint SIZE_RD{ARSIZE dist{0,1,2};}
constraint ADDR_RA{ARBURST==2'b10 && ARSIZE==1 -> ARADDR %2 ==0;}
constraint ADDR_RB{ARBURST==2'b10 && ARSIZE==2 -> ARADDR %4 ==0;}
constraint len{RDATA.size==ARLEN+1;}
constraint ID_R{ARID==RID;}



constraint c1{AWADDR==5;AWSIZE==1;AWLEN==4;AWBURST==0;}


int unsigned start_address;
int unsigned number_bytes;
int unsigned burst_length;
int unsigned aligned_address;
int unsigned waddr[];

function void post_randomize();
start_address=AWADDR;
number_bytes = 2**AWSIZE;
burst_length = AWLEN+1;
aligned_address = (int'(start_address/number_bytes))*number_bytes;

addr_calc();
strobe_calc();

endfunction



function void addr_calc();
int unsigned wrap_boundary=(int'(start_address/(number_bytes*burst_length)))*(number_bytes*burst_length);
bit wrapped;

waddr = new[burst_length+1];
waddr[1]=start_address;

if(AWBURST==0)
	for(int i=2;i<=burst_length;i++)
		waddr[i] = start_address;
		
if(AWBURST==1) //INC
	for(int i=2;i<=burst_length;i++)
		waddr[i] = aligned_address +((i-1)*number_bytes);
		
if(AWBURST==2) //WRAP
begin
for(int i=2; i<=burst_length;i++)
	begin
		if(!wrapped)
			begin
				waddr[i] =  aligned_address+((i-1)*number_bytes);

				if(waddr[i]==wrap_boundary+(number_bytes*burst_length))
					begin
		 				waddr[i]=wrap_boundary;
						wrapped++;
					end
			end

		else
		waddr[i]=start_address+((i-1)*number_bytes)-(number_bytes*burst_length);
	end
end			 
endfunction




function void strobe_calc();
int unsigned data_bus_bytes = 4;
int unsigned lower_byte_lane;
int unsigned upper_byte_lane;

int unsigned lower_byte_lane_0 = start_address-(int'(start_address/data_bus_bytes))*data_bus_bytes;
int unsigned upper_byte_lane_0 = aligned_address + (number_bytes-1)-(int'(start_address/data_bus_bytes))*(data_bus_bytes);


for(int i=0;i<burst_length;i++)
	for(int j=0;j<4;j++)
		WSTRB[i][j]=0;


for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
WSTRB[0][j]=1;

for(int N=1;N<burst_length;N++)
begin
lower_byte_lane= waddr[N+1]-(int'(waddr[N+1]/data_bus_bytes))*data_bus_bytes;
upper_byte_lane = lower_byte_lane+number_bytes-1;
for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
WSTRB[N][j] = 1;
end

endfunction	


/*
function void addr_calc();
int unsigned wrap_boundary=(int'(start_address/(number_bytes*burst_length)))*(number_bytes*burst_length);
bit wrapped;

waddr = new[burst_length];

waddr[0]=start_address;
if(AWBURST==1)
	for(int i=0;i<burst_length;i++)
		waddr[i] = aligned_address +((i)*number_bytes);
		
if(AWBURST==2)
begin
for(int i=1; i<burst_length;i++)
	begin
		if(!wrapped)
			begin
				waddr[i] =  aligned_address+((i)*number_bytes);

				if(waddr[i]==wrap_boundary+(number_bytes*burst_length))
					begin
		 				waddr[i]=wrap_boundary;
						wrapped++;
					end
			end

		else
		waddr[i]=start_address+((i)*number_bytes)-(number_bytes*burst_length);
	end
end			 
endfunction
*/

endclass



module top();
trans h;

initial
begin
h=new;
assert(h.randomize);
for(int i=1;i<= h.burst_length;i++)
	$display("%0d - %4b",h.waddr[i],h.WSTRB[i-1]);

end
	
endmodule



