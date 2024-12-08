; compile and run with
; nasm -i../nasm_utils/ -felf64 test_string.asm && ld test_string.o && ./a.out && rm test_string.o && rm a.out

%include "strings.asm"
%include "syscalls.asm"
%include "iostream.asm"

global    _start

section   .text

test_strlen:
    mov rax, msg_1
	call strlen	
	mov rax, msg_2
    ret


test_find_substr:
	; find_substr(rax = char* string, rdi = char* substr, rsi = int64 start_position, rdx = int64 end_position)
    push rax
	mov rax, msg_1
	call strlen
	mov rdx, rax
	pop rax
	mov rdi, substr_1
	mov rsi, 0
	call find_substr
	call print_int


_start:
    call test_find_substr
	call exit
     
        
section   .data
	info_msg db "String: ", 0h
	info_substr db "    substring: ", 0h
	info_result db "    result: ", 0h
	
	msg_1  db  "Hello there, My Name is Earl. Earl says Hello to you", 0h
	msg_2 db "The dog named Earl jumps over the lazy cat. The cat ran past the fox", 0h
	test_msg_description db "Test msg: ", 0h
	substr_1 db "Earl", 0h
	substr_2 db "the", 0h
	substr_3 db "cat", 0h

	str_int_1  db  "7", 0h
	str_int_2  db  "420123", 0h
	str_int_3  db  "-1389188", 0h
