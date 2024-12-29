//
// If we try to access the non existinfg CSR and the instruction is csrr  
// 0xfff in S mode so it will cause the illegal instruction and will update the mcause 
// with the exception code 2, mepc will point to the address of the illegal 
// instruction, mtval will contain the binary representation of illegal instruction
// 

#include "model_test.h"

#include "arch_test.h"

RVTEST_ISA("RV32I_Zicsr")

# Test code region
.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT
RVTEST_CODE_BEGIN

#ifdef TEST_CASE_1
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def rvtest_strap_routine=True; def TEST_CASE_1=True; mac SV32_MACROS", mstatus_tvm)

RVTEST_SIGBASE( x13,signature_x13_1)

main:
#ifdef rvtest_mtrap_routine					                				// Verification of existance of rvtest_mtrap_routine
	LI a4, 0xceed
	RVTEST_SIGUPD(x13,a4)
#endif
#ifdef rvtest_strap_routine					                				// Verification of existance of rvtest_strap_routine
	LI a4, 0xbeed
	RVTEST_SIGUPD(x13,a4)
#endif
	
 	ALL_MEM_PMP          		  // set the PMP permissions for the whole memory
	csrw satp, zero  		  // write satp with all zeros (bare mode)

	csrr t3, mstatus           // read mstatus value 
	RVTEST_SIGUPD(x13,t3)

	// go to supervisor mode we can do it by hardcoding or using directly a macro 
	
	// csrr t2,mstatus
   	// li t1, ~(0x3 << 11)
  	// and t2,t2,t1
   
   	// li t1,0x0800
   	// or t2,t2,t1
   
   	// csrw mstatus, t2      
   	// la t1,switch_to_supervisor     // switch to S mode
   	// csrw mepc,t1
   	// mret
   
        // switch_to_supervisor:


	RVTEST_GOTO_LOWER_MODE Smode
	// supervisor ecall
	
	li t1,3
	li t1,0xdead
	csrw 0xFFF,t1
	
	// switching back to the M mode
	RVTEST_GOTO_MMODE

#endif
//---------------------------------------------------------------------------------------------------------------------------------
RVTEST_CODE_END
RVMODEL_HALT
RVTEST_DATA_BEGIN
.align 22

//---------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------

#ifdef rvtest_strap_routine
.align 12                       //complete the 4KB permission memory range
rvtest_slvl1_pg_tbl:
		RVTEST_PTE_IDENT_MAP(0,1,PTE_V | PTE_A | PTE_D | PTE_G)
#endif

RVTEST_DATA_END                
.align 12
RVMODEL_DATA_BEGIN
rvtest_sig_begin:
sig_begin_canary:
CANARY;

// test signatures initialization
signature_x13_1:
    .fill 64*(XLEN/32),4,0xcafebeef

// trap signatures initialization
#ifdef rvtest_mtrap_routine
mtrap_sigptr:
    .fill 64*(XLEN/32),4,0xdeadbeef
#endif

sig_end_canary:
CANARY;
rvtest_sig_end:
RVMODEL_DATA_END
