; compile and run with
; nasm -i../nasm_utils -felf64 test_printing.asm && ld test_printing.o && ./a.out && rm test_printing.o && rm a.out

%include "iostream.asm"

global    _start

section   .text

test_print_ints:
    mov rax, -3281
    call print_int_LF
    mov rax, 3281
    call print_uint_LF
    ret

test_print_string:
    call print_lbracket
    call print_rbracket
    call print_comma
    call print_LF
	mov rax, test_string
	call print_str_LF
    ret
	
test_print_array:
	mov rax, array_1
	mov rdi, 6
	call print_int_array
	ret 

_start:
    call test_print_ints
    call test_print_string
	call test_print_array
	call exit
    
    
section   .data
	test_string  db  "This is a test string",0Ah,"Foofoofoo",0h
	array_1 dq 108, 32, 9, -128, 422, 999