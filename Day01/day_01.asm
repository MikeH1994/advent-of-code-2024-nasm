; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 day_01.asm && ld day_01.o && ./a.out && rm day_01.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "../utils.asm"

global    _start

section   .text

;----------------------------------------------------------
; int64 load_arrays(rax=char* fpath, rdi = char* charBuffer, rsi = int64 char_buffer_size, rdx = int64* int_buffer_1, 
;                    r8 = int64* int_buffer_2)
;     loads the text file (containing two columns of numbers) and stores each row in the supplied int buffers
; returns:
;     rax = number of ints loaded in to each buffer
;	  all other registers preserved 	
;----------------------------------------------------------
; rax will store the char buffer (the array containing the text file we loaded)
; rdi will store the length of the string loaded
; rsi will store int buffer 1    (where we will store the integers in the left hand column)
; rdx will store int buffer 2    (where we will store the integers in the right hand column)
; r8 will store the index we are at in the char buffer
; r9 will store the length of the substring we are searching over
; r10 will store if this is the left or right hand column
; r11 will store the number of ints loaded into each array
; r12 will be used for misc arithmetic
load_arrays:
	push rdi
	push rsi
	push rdx
	push r8
	push r9
	push r10
	push r11
	push r12
	
	; load buffer in to memory and determine how long the loaded string is
     ; read_file_to_buffer(rax = char* fpath, rdi = char* buffer, rsi = int64 buffer_size)   
	call read_file_to_buffer  ; rax, rdi, and rsi already correspond to the correct arguments for read_file_to_buffer
     ; now, rax = char* buffer, rdi = length of string loaded
     
     call print_substr
     
     mov rsi, rdx              ; rsi is equal to buffer_1 pointer
     mov rdx, r8               ; rdx is equal to buffer_2 pointer  
     
	mov r8, 0                 ; r8 is equal to starting index of substring
	mov r9, 0                 ; r9 is equal to the length of the substring
	mov r10,0                 ; r10 is equal to the current column (0=left, 1=right)
	mov r11,0                 ; r11 is equal to the number of elements we have loaded in to each array 
     
.mainLoop:
	call print_substr
     call print_LF
     call print_LF

     cmp r8, rdi               ; compare the current index (r8) to the length of the string (rdi)
 	jge .finished             ; if i >= str_length, exit
	mov r9, 0				  ; set the length of the current substring to zero
     jmp .substringSearchLoop
.substringSearchLoop:
	; check if we have reached the end of the string 
	mov r12, r8
	add r12, r9               ; r12 = starting index of substring + length of substring (i.e. the end position of the substring)
	cmp r12, rdi              ; compare the end position of the string to the length of the string
	jge .endOfSubstring       ; if end of substring >= length of string, jump to end of substring
	mov r12, 0                ; clear r12
	mov r12, [rax + rdi] ; r12 now equals char_buffer[i]
	cmp r12, 48               ; numbers in ascii are only between 48 and 57 inclusive- anything else is invalid
	jl .endOfSubstring
	cmp r12, 57
	jg .endOfSubstring
	inc r9
	jmp .substringSearchLoop
	
.endOfSubstring:
	cmp r9, 0                 ; if the length of the substring found is zero, (e.g. the first char in the substring is non numeric)
	je .invalidSubstringFound ; then jump to .invalidSubstringFound
	; convert substring to int
	push rax                  ; store the buffer
	push rdi                  ; store the length of the string
	add rax, r8               ; rax now points to the start of the string in the buffer
	mov rdi, r9		       ; rdi now contains the length of the substring
	call string_to_int        ; rax now contains the integer generated from the substring
	mov r12, rax			  ; r12 now contains the next integer to add to the specified array
	; restore rax and rdi registers
     pop rdi                   ; rdi stores the length of the string again
     pop rax                   ; rax stores pointer to buffer again
     add r8, r9		       ; update the current index we are at in the string
	mov r9, 0                 ; set the current substring length to zero
	cmp r10,0                 ; if r10 == 0, this element belongs to the left hand column   
	je .addLeftColumn
	jmp .addRightColumm
.invalidSubstringFound:
	inc r8
	jmp .mainLoop
.addLeftColumn:
	call print_lbracket
	push rax
	mov rax, r12
	call print_int_LF
	pop rax
	
	mov [rsi + r11*8], r12    ; move the new integer to the array
	mov r10, 1                ; the next element is the right hand array now
	jmp .mainLoop
.addRightColumm:
	call print_rbracket

	push rax
	mov rax, r12
	call print_int_LF
	pop rax

	mov [rdx + r11*8], r12    ; move the new integer to the array
	mov r10, 0                ; the next element is the left hand array now
	inc r11					  ; increase the number of elements added to array by 1
	jmp .mainLoop
.finished:
	mov rax, r11			  ; move the number of ints added to rax
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rdx
	pop rdi
	pop rsi
	ret
	
part_1_test:
	mov rax, msg_test
	call print_str_LF
	
	mov rax, test_filepath
	mov rdi, charBuffer
	mov rsi, bufferSize
	mov rdx, array_1
	mov r8, array_2
	call load_arrays ; rax now equals number of elements loaded to each array
	;push rax
	;mov rax, msg_array_1
	;call print_str
	;mov rax, array_1
	;pop rdi ; rdi = length of array
	;call print_int_array
	;call print_LF
	;mov rax, msg_array_2
	;call print_str
	;mov rax, array_2
	;call print_int_array
	;call print_LF
	ret
	
_start:
	call part_1_test
    call exit
    
section   .data
	input_filepath  db  "input_file.txt",0h
	test_filepath  db  "test_file.txt",0h

    msg_test    db "Test file: ", 0h
	msg_input   db "Input file: ", 0h
	msg_n_elems db "    Number of elements: ", 0h
	msg_str_len db "    String length: ", 0h
	msg_array_1 db "    Array 1: ", 0h
	msg_array_2 db "    Array 2: ", 0h
	

	bufferSize equ 65536
	charBuffer  TIMES  bufferSize    DB  0          ;uint8_t[8192]
	array_1     TIMES  bufferSize    DQ  0          ;uint64_t[8192]
	array_2     TIMES  bufferSize    DQ  0          ;uint64_t[8192]

		  