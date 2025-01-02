//
// In M- mode execute the ecall instruction,  MXLEN-1 bit of mcause will become zero and the 
// the exception code will be 11(b) for the environment call from M mode, mepc register will 
// get the address of the ecall instruction verify by checking both registers values
//
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
    RVTEST_CASE(1,"//check ISA:=regex(.*32.*); check ISA:=regex(.*I.*Zicsr.*); def rvtest_mtrap_routine=True; def TEST_CASE_1=True; mac SV32_MACROS",m_ecall)

RVTEST_SIGBASE( x13,signature_x13_1)

main:
#ifdef rvtest_mtrap_routine					             // Verification of existance of rvtest_mtrap_routine
	LI a4, 0xceed
	RVTEST_SIGUPD(x13,a4)
#endif

	
	ALL_MEM_PMP          		  // set the PMP permissions for the whole memory
	csrw satp, zero  		  // write satp with all zeros (bare mode)

	csrr t3, mstatus                  // read mstatus value 
	RVTEST_SIGUPD(x13,t3)

	// machine ecall  
	ecall
	nop
	
	RVTEST_GOTO_MMODE
	nop
	
	csrr a4,mcause
	RVTEST_SIGUPD(x13,a4)
	
	LI a4, 0xffff
	RVTEST_SIGUPD(x13,a4)
	
			                

#endif
//---------------------------------------------------------------------------------------------------------------------------------
RVTEST_CODE_END
RVMODEL_HALT
RVTEST_DATA_BEGIN
.align 22
// ----------------------------------------------


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
