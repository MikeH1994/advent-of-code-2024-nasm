; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 test_string.asm && ld test_string.o && ./a.out && rm test_string.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "../utils.asm"

global    _start

section   .text

	
test_strings:
	push rax
	call strlen
	mov rdi, rax
	pop rax
	call string_to_int
	call print_int_LF
	ret
	

_start:
	mov rax, str_int_1
	mov rdi, 1
	call test_strings
	
	mov rax, str_int_1
	mov rdi, 1
	call test_strings
	
	mov rax, str_int_2
	mov rdi, 2
	call test_strings
	
	mov rax, str_int_2
	mov rdi, 2
	call test_strings
	
	mov rax, str_int_3
	mov rdi, 4
	call test_strings
	
	mov rax, str_int_3
	mov rdi, 4
	call test_strings
	
    call exit
    
section   .data
          msg_test_print_arrays  db  "Testing print array", 0h
		  str_int_1  db  "7", 0h
		  str_int_2  db  "420123", 0h
		  str_int_3  db  "-1389188", 0h
		  
		  

		  