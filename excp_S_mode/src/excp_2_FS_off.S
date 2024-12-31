//
// The test will check that when an extension’s status is set to Off, any instruction 
// attempting to access the corresponding state in S-mode will raise an illegal instruction exception, 
// while with the status set to On, the instruction will execute normally. like FS bits (13 and 14) 
// in mstatus are 00 means off then will raise the illegal instruction when will try to access 

 #include "model_test.h"
#include "arch_test.h"
RVTEST_ISA("RV32IF_Zicsr,RV32IFD_Zicsr,RV64IF_Zicsr,RV64IFD_Zicsr,RV32EF_Zicsr,RV32EFD_Zicsr,RV64EF_Zicsr,RV64EFD_Zicsr")

.section .text.init
.globl rvtest_entry_point
rvtest_entry_point:
RVMODEL_BOOT
RVTEST_CODE_BEGIN

#ifdef TEST_CASE_1

RVTEST_CASE(0,"//check ISA:=regex(.*I.*F.*);def TEST_CASE_1=True;",fs_off)
 RVTEST_FP_ENABLE()
csrr t3, mstatus

RVTEST_VALBASEUPD(x3,test_dataset_0)
RVTEST_SIGBASE(x1,signature_x1_1)

nop
li t0,1
nop

 // RVTEST_GOTO_LOWER_MODE Smode
 

// inst_0:
// rs2 == rd != rs1 and rs2 == rd != rs3 and rs3 != rs1, rs1==f23, rs2==f16, rs3==f25, rd==f16,fs1 == 0 and fe1 == 0xf0 and fm1 == 0x59914d and fs2 == 1 and fe2 == 0x0d and fm2 == 0x169c55 and fs3 == 1 and fe3 == 0x5d and fm3 == 0x000000 and  fcsr == 0x0 and rm_val == 7   
/* opcode: fmadd.s ; op1:f23; op2:f16; op3:f25; dest:f16; op1val:0x7859914d; op2val:0x86969c55;
op3val:0xae800000; valaddr_reg:x3; val_offset:0*0 + 3*-1*FLEN/8; rmval:dyn;
testreg:x2; fcsr_val:0 */
TEST_FPR4_OP(fmadd.s, f16, f23, f16, f25, dyn, 0, 0, x3, 0*0 + 3*0*FLEN/8, x4, x1, x2)

csrr t3, mstatus
nop
nop
nop
nop
nop

	// Set FS bits to 00 (Disable FPU)
//	csrr t3, mstatus                     // Read mstatus
//	li t4, 0xFFFF9FFF                    // Mask to clear FS bits (FS = 00)
//	and t3, t3, t4                       // Clear FS bits
//	csrw mstatus, t3                     // Write back to mstatus


// RVTEST_FP_ENABLE()

 RVTEST_FP_DISABLE()


// rs1 == rs2 == rs3 == rd, rs1==f22, rs2==f22, rs3==f22, rd==f22,fs1 == 0 and fe1 == 0xf0 and fm1 == 0x59914d and fs2 == 1 and fe2 == 0x0d and fm2 == 0x169c55 and fs3 == 1 and fe3 == 0x5d and fm3 == 0x000001 and  fcsr == 0x0 and rm_val == 7   
/* opcode: fmadd.s ; op1:f22; op2:f22; op3:f22; dest:f22; op1val:0x7859914d; op2val:0x7859914d;
op3val:0x7859914d; valaddr_reg:x3; val_offset:3*0 + 3*0*FLEN/8; rmval:dyn;
testreg:x2; fcsr_val:0 */
// TEST_FPR4_OP(fmadd.s, f22, f22, f22, f22, dyn, 0, 0, x3, 3*0 + 3*1*FLEN/8, x4, x1, x2)
	nop
	nop
	nop
#endif


RVTEST_CODE_END
RVMODEL_HALT

RVTEST_DATA_BEGIN
.align 4
rvtest_data:
.word 0xbabecafe
.word 0xabecafeb
.word 0xbecafeba
.word 0xecafebab
test_dataset_0:
NAN_BOXED(2019135821,32,FLEN)

NAN_BOXED(0,32,FLEN)
NAN_BOXED(1,32,FLEN)
NAN_BOXED(2084295396,32,FLEN)


RVTEST_DATA_END

RVMODEL_DATA_BEGIN
rvtest_sig_begin:
sig_begin_canary:
CANARY;

signature_x1_1:
    .fill 256*((SIGALIGN)/4),4,0xdeadbeef

#ifdef rvtest_mtrap_routine

tsig_begin_canary:
CANARY;
tsig_begin_canary:
CANARY;
mtrap_sigptr:
    .fill 64*(XLEN/32),4,0xdeadbeef
tsig_end_canary:
CANARY;
tsig_end_canary:
CANARY;

#endif

#ifdef rvtest_gpr_save

gpr_save:
    .fill 32*XLEN/32,4,0xdeadbeef

#endif

sig_end_canary:
CANARY;
rvtest_sig_end:
RVMODEL_DATA_END
