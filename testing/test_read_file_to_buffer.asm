; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 test_utils.asm && ld test_utils.o && ./a.out && rm test_utils.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "../utils.asm"

global    _start

section   .text


	
_start:
    mov rax, input_filepath
    mov rdi, charBuffer
    mov rsi, bufferSize
    call read_file_to_buffer
    call print_substr  
    call print_LF
    call exit
    
section   .data
	input_filepath  db  "test_array.txt",0h

	bufferSize equ 65536
	charBuffer  TIMES  bufferSize    DB  0          ;uint8_t[8192]

		  


		  