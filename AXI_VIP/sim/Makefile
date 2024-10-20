#Makefile for UVM Testbench - AXI VERIFICATION

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = VCS

FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64


RTL= ../axi/*
work= work #library name
SVTB1= ../top/top.sv
INC = +incdir+../tb +incdir+../test +incdir+../master_uvc +incdir+../slave_uvc
SVTB2 = ../test/axi_pkg.sv
VSIMOPT= -vopt -voptargs=+acc 
VSIMCOV= -coverage -sva 
VSIMBATCH1= -c -do  " log -r /* ;coverage save -onexit mem_cov1;run -all; exit"
VSIMBATCH2= -c -do  " log -r /* ;coverage save -onexit mem_cov2;run -all; exit"
VSIMBATCH3= -c -do  " log -r /* ;coverage save -onexit mem_cov3;run -all; exit"
VSIMBATCH4= -c -do  " log -r /* ;coverage save -onexit mem_cov4;run -all; exit"


help:
	@echo =============================================================================================================
	@echo "! USAGE   	--  make target                             										"
	@echo "! clean   	=>  clean the earlier log and intermediate files.       								"
	@echo "! sv_cmp    	=>  Create library and compile the code.                   								"
	@echo "! run_test	=>  clean, compile & run the simulation for inc_test in batch mode.		" 
	@echo "! run_test1	=>  clean, compile & run the simulation for fixed_test in batch mode.			" 
	@echo "! run_test2	=>  clean, compile & run the simulation for wrap_test in batch mode.			"
#	@echo "! run_test3	=>  clean, compile & run the simulation for corrupt_parity_test in batch mode.		" 
	@echo "! view_wave1 =>  To view the waveform of inc_test                                                    "
	@echo "! view_wave2 =>  To view the waveform of fixed_test                                                       " 
	@echo "! view_wave3 =>  To view the waveform of wrap_test                                                       " 
#	@echo "! view_wave4 =>  To view the waveform of corrupt_parity_test                                                      " 
	@echo "! regress    =>  clean, compile and run all testcases in batch mode.		    				!"
	@echo "! report     =>  To merge coverage reports for all testcases and  convert to html format.			!"
	@echo "! cov        =>  To open merged coverage report in html format.							!"
	@echo ====================================================================================================================

clean : clean_$(SIMULATOR)
sv_cmp : sv_cmp_$(SIMULATOR)
run_test : run_test_$(SIMULATOR)
run_test1 : run_test1_$(SIMULATOR)
run_test2 : run_test2_$(SIMULATOR)
#run_test3 : run_test3_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
#view_wave4 : view_wave4_$(SIMULATOR)
regress : regress_$(SIMULATOR)
report : report_$(SIMULATOR)
cov : cov_$(SIMULATOR)

# ----------------------------- Start of Definitions for Mentor's Questa Specific Targets -------------------------------#

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB2) $(SVTB1) 	
	
run_test_Questa: sv_cmp
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1)  -wlf inc_wave.wlf -l test1.log  -sv_seed random  work.top +UVM_TESTNAME=inc_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1
	
run_test1_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2)  -wlf fixed_wave.wlf -l test2.log  -sv_seed random  work.top +UVM_TESTNAME=fixed_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2
	
run_test2_Questa:
	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3)  -wlf wrap_wave.wlf -l test3.log  -sv_seed random  work.top +UVM_TESTNAME=wrap_test
	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov3
	
#run_test3_Questa:
#	vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4)  -wlf wave_file4.wlf -l test4.log  -sv_seed random  work.top +UVM_TESTNAME=corrupt_parity_test
#	vcover report  -cvg  -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov4
	
view_wave1_Questa:
	vsim -view inc_wave.wlf
	
view_wave2_Questa:
	vsim -view fixed_wave.wlf
	
view_wave3_Questa:
	vsim -view wrap_wave.wlf
	
#view_wave4_Questa:
#	vsim -view wave_file4.wlf

report_Questa:
	vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3 mem_cov4
	vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov

regress_Questa: clean_Questa run_test_Questa run_test1_Questa run_test2_Questa report_Questa cov_Questa #run_test3_Questa

cov_Questa:
	firefox covhtmlreport/index.html&
	
clean_Questa:
	rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear

# ----------------------------- End of Definitions for Mentor's Questa Specific Targets -------------------------------#

# ----------------------------- Start of Definitions for Synopsys's VCS Specific Targets -------------------------------#

sv_cmp_VCS:
	vcs -l vcs.log -timescale=1ns/1ps -sverilog -ntb_opts uvm -debug_access+all -full64 -kdb  -lca -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a $(RTL) $(INC) $(SVTB2) $(SVTB1) +define+UVM_REPORT_DISABLE_FILE_LINE 
		      
run_test_VCS:	clean  sv_cmp_VCS
	./simv -a vcs.log +fsdbfile+inc_wave.fsdb -cm_dir ./mem_cov1 +ntb_random_seed_automatic +UVM_TESTNAME=inc_test +UVM_VERBOSITY=UVM_LOW
	urg -dir mem_cov1.vdb -format both -report urgReport1
	
run_test1_VCS:	
	./simv -a vcs.log +fsdbfile+fixed_wave.fsdb -cm_dir ./mem_cov2 +ntb_random_seed_automatic +UVM_TESTNAME=fixed_test +UVM_VERBOSITY=UVM_LOW
	urg -dir mem_cov2.vdb -format both -report urgReport2
	
run_test2_VCS:	
	./simv -a vcs.log +fsdbfile+wrap_wave.fsdb -cm_dir ./mem_cov3 +ntb_random_seed_automatic +UVM_TESTNAME=wrap_test +UVM_VERBOSITY=UVM_LOW
	urg -dir mem_cov3.vdb -format both -report urgReport3
	
#run_test3_VCS:	
#	./simv -a vcs.log +fsdbfile+corrupt_parity.fsdb -cm_dir ./mem_cov4 +ntb_random_seed_automatic +UVM_TESTNAME=corrupt_parity_test 
#	urg -dir mem_cov4.vdb -format both -report urgReport4
	
view_wave1_VCS: 
	verdi -ssf inc_wave.fsdb
	
view_wave2_VCS: 
	verdi -ssf fixed_wave.fsdb

view_wave3_VCS: 
	verdi -ssf wrap_wave.fsdb

#view_wave4_VCS: 
#	verdi -ssf corrupt_parity.fsdb		
	
report_VCS:
	urg -dir mem_cov1.vdb mem_cov2.vdb mem_cov3.vdb -dbname merged_dir/merged_test -format both -report urgReport #mem_cov4.vdb

regress_VCS: clean_VCS sv_cmp_VCS run_test_VCS run_test1_VCS run_test2_VCS report_VCS #run_test3_VCS 
cov_VCS:
	verdi -cov -covdir merged_dir.vdb

clean_VCS:
	rm -rf simv* csrc* *.tmp *.vpd *.vdb *.key *.log *hdrs.h urgReport* *.fsdb novas* verdi*
	clear

# ----------------------------- END of Definitions for Synopsys's VCS Specific Targets -------------------------------#


