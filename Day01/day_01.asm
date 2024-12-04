; rax rdi rsi rdx r8 r9
; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 day_01.asm && ld day_01.o && ./a.out && rm day_01.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "../utils.asm"

global    _start

section   .text

;----------------------------------------------------------
; int64* load_arrays(rax=char* fpath, rdi = int64* buffer_1, rsi = int64* buffer_2)
;     loads the text file (containing two columns of numbers) and stores each row in the supplied buffers
;----------------------------------------------------------

load_arrays:
	ret

	
_start:
    call exit
    
section   .data
	filepath  db  "data.txt",0h
    msg_test_print_arrays  db  "Testing print array", 0h
	msg_test_print_strings  db  "Testing print strings", 0h
	msg_test_array_utils  db  "Testing array utils", 0h



		  