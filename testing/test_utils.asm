; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 test_utils.asm && ld test_utils.o && ./a.out && rm test_utils.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "../utils.asm"

global    _start

section   .text


;----------------------------------------------------------
; void test_array_utils(r8 = int64* array, r9 = uint64 array_size)
;
;
;----------------------------------------------------------
test_array_utils:
	mov rax, msg_array
	call print_str
	mov rax, r8
	mov rdi, r9
	call print_int_array
	call print_LF
	mov rax, msg_is_sorted
	call print_str
	mov rax, r8
	mov rdi, r9
	call array_is_sorted
	call print_int_LF
	mov rax, msg_array_sorted
	call print_str
	mov rax, r8
	mov rdi, r9
	call sort_array
	call print_int_array
	call print_LF
	mov rax, msg_is_sorted
	call print_str
	mov rax, r8
	mov rdi, r9
	call array_is_sorted
	call print_int_LF
	call print_LF
	ret
	
_start:
	mov r8, array_1
	mov r9, 6
    call test_array_utils   
	mov r8, array_2
	mov r9, 9
	call test_array_utils 
	mov r8, array_3
	mov r9, 8
	call test_array_utils 
    call exit
    
section   .data
          msg_test_print_arrays  db  "Testing print array", 0h
		  msg_test_print_strings  db  "Testing print strings", 0h
		  msg_test_array_utils  db  "Testing array utils", 0h

		  msg_is_sorted db "    is sorted:     ", 0h
		  array_1 dq 108, 32, 9, 128, -100, -999
		  array_2 dq -10, -4, 32, 100, 102, 199, 302, 406, 8723
	      array_3 dq 39, 12, 18, 85, 72, 10, 2, 18

		  msg_array db  "Array:             ",0h
		  msg_array_sorted db  "    array sorted:  ",0h


		  