; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 test_utils.asm && ld test_utils.o && ./a.out && rm test_utils.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "../utils.asm"

global    _start

section   .text


	
_start:
    ; load_int_array_from_txt(rax=char* fpath, rdi = char* buffer,rsi = uint64 bufferSize, rdx = int64* int_array)
    mov rax, input_filepath
    mov rdi, charBuffer
    mov rsi, bufferSize
    mov rdx, array_1
    call load_int_array_from_txt
    call print_int_array  
    call print_LF   
    call exit
    
section   .data
	input_filepath  db  "test_array.txt",0h

	bufferSize equ 65536
	charBuffer  TIMES  bufferSize    DB  0          ;uint8_t[bufferSize]
	array_1     TIMES  bufferSize    DQ  0          ;uint64_t[bufferSize]

		  


		  