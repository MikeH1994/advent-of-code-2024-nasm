; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 day_01.asm && ld day_01.o && ./a.out && rm day_01.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "../utils.asm"

global    _start

section   .text

;----------------------------------------------------------
; int64 load_arrays(rax=char* fpath, rdi = char* charBuffer, rsi = int64 char_buffer_size, rdx = int64* int_buffer_0, 
;                   r8 = int64* int_buffer_1, r9 = int64* int_buffer_2)
;   load the text file in to array_0, then splits it in two array_1 and array_2
; returns:
;     rax = int64* int_array_1
;     rdi = int64* int_array_2
;     rsi = int64 array_length
;----------------------------------------------------------
; rax will store pointer to current int_array_0 element 
; rdi will store pointer to current int_array_1 element (for the left column)
; rsi will store pointer to current int_array_2 element (for the right column)
; rdx will be used to check remainder
; r8 will store the total number of element in array_0
; r9 will store the index we are at in int array_0
; r10 will be used for misc
load_arrays:
    ; store registers
    push rdx
    push r8
    push r9
    push r10
    push r8 ; storing another copy of array_1 so we can revert to starting position later
    push r9 ; storing another copy of array_2 so we can revert to starting position later

    
    ; load_int_array_from_txt(rax=char* fpath, rdi = char* buffer,rsi = uint64 bufferSize, rdx = int64* int_array)
    ; returns
    ;    rax = int64* array_0
    ;    rdi = int64 array_0_length
    ; loads array in to array_0
    call load_int_array_from_txt
    push rdi    ; store array_0 length
    mov rdi, r8 ; rdi = int64* array_1
    mov rsi, r9 ; rsi = int64* array_2
    pop r8      ; r8 = int64 array_0_length
    mov r9, 0   ; r9 = current index
.mainLoop:
    cmp r9, r8  ; compare current index to number of element in array_0 
    jge .finished
    push rax    ; store array_0 pointer
    mov rax, r9 ; rax = current_index
    mov rdx, 0  ; clear remaineder 
    mov r10, 2
    div r10     ; divide current index by 2- remainder now in rdx 
    cmp rdx, 0  ; check if remainder is 0 (i.e. current index is even)
    je .indexIsEven
    jmp .indexIsOdd        
.indexIsEven:
    mov rdx, rax ; store index/2 in rdx
    pop rax      ; rax = array_0 again
    mov r10, [rax] ; r10  = array_0[index]
    mov [rdi], r10; array_1[index_1] = array_0[index_0]
    inc r9
    add rdi, 8
    add rax, 8
    jmp .mainLoop
.indexIsOdd:
    mov rdx, rax ; store index/2 in rdx
    pop rax      ; rax = array_0 again
    mov r10, [rax] ; r10  = array_0[index]
    mov [rsi], r10 ; array_2[index//2] = array_0[index]
    inc r9
    add rsi, 8
    add rax, 8
    jmp .mainLoop    
.finished:
    ; calculate the number of elements from array_0_len / 2
    mov rax, r9 ; rax = number of elements in array_0
    mov rdx, 0  ; clear rdx
    mov r10, 2
    div r10     ; rax = array_1_length (= length of array_2)
    mov rsi, rax    ; rsi = array_1_length
    ; retrieve the pointers to the start of array_1 and array_2
    pop  rdi; rdi = int64* array_2 (this is the extra copy of array_2 from r9 at the start of the function)
    pop  rax ; rax = int64* array_1 (this is the extra copy of array_1 from r8 at the start of the function)
    
    ; sort array 1
    mov rdx, rdi ; store array_2 in rdx
    mov rdi, rsi ; rdi = array_1_length
    call sort_array ; array_1 sorted
    ; sort array 2
    push rax ; store array_1 in stack
    mov rax, rdx ; rax = array_2
    call sort_array ; array_2 sorted
    pop rax      ; rax = array_1 again
    mov rdi, rdx ; rdi = array_2
                 ; rsi still = array_length   
    
    
    ; restore registers
    pop r10
    pop r9
    pop r8
    pop rdx
    
    ret

;----------------------------------------------------------
; int calculate_distance(rax=int64* array_1, rdi = int64* array_2, rsi = int64* n)
;   calculates the sum of the distance for each element
;----------------------------------------------------------
;   rax will store pointer to array_1
;   rdi will store pointer to array_2
;   rsi will store length of arrays
;   rdx will store current index
;   r8 will store current sum
;   r9 for misc maths
calculate_distance:
    ; store registers
    push rdx
    push r8
    push r9
    ; initialise values
    mov rdx, 0  ; rdx = current index
    mov r8, 0   ; r8 = sum
.mainLoop:
    cmp rdx, rsi ; compare current index to array length
    jge .finished ; if current index >= array length, jump
    mov r9, [rax + 8*rdx]  ; r9 = array_1[index]
    sub r9, [rdi + 8*rdx] ;  r9 = array_1[index] - array_2[index]   
    ; take abs(x)
    push rax
    mov rax, r9
    call int_abs
    mov r9, rax ; r9 = abs(array_1[index] - array_2[index])
    pop rax
    add r8, r9
    inc rdx
    jmp .mainLoop
.finished:
    mov rax, r8
    pop r9
    pop r8
    pop rdx
    ret
   
;----------------------------------------------------------
; int64 number_of_occurances_in_array(rax = int64* array, rdi = int64 array_length, rsi = int64 x)
;     rax = n_occurances
;----------------------------------------------------------
; rax will store the array we are checking
; rdi will store the length of the array
; rsi will store the value we are looking for in the array
; rdx will store the index we are at
; r8 will store the number of times we have foud this value
number_of_occurances_in_array:
    push rdx
    push r8
    push r9

    mov rdx, 0 ; rdx = current_index
    mov r8, 0  ; r8 = number of occurances found
.mainLoop:
    cmp rdx, rdi
    jge .finished  ; if current index >= array length, got to exit
    mov r9, [rax]  ; r9 = array[index]
    cmp rsi, r9    ; compare value in array to the value we are looking for
    jne .valuesNotEqual  ; if array[index] != x, jump
    inc rdx        ; increment index
    add rax, 8     ; move buffer pointer to next int
    inc r8         ; value found, increase the counter by 1
    jmp .mainLoop
.valuesNotEqual:
    inc rdx        ; increment index and move buffer pointer
    add rax, 8     ; 
    jmp .mainLoop
.finished:   
    mov rax, r8    ; rax = number of occurances found
    pop r9
    pop r8
    pop rdx  
    ret

;----------------------------------------------------------
; int calculate_distance(rax=int64* array_1, rdi = int64* array_2, rsi = int64* n)
;   calculates the sum of the distance for each element times the number of times it appears in array_2
;----------------------------------------------------------
;   rax will store pointer to array_1
;   rdi will store pointer to array_2
;   rsi will store length of arrays
;   rdx will store current index
;   r8 will store current sum
;   r9 for misc maths
calculate_distance_2:
    ; store registers
    push rdx
    push r8
    push r9
    ; initialise values
    mov rdx, 0  ; rdx = current index
    mov r8, 0   ; r8 = sum
.mainLoop:
    cmp rdx, rsi ; compare current index to array length
    jge .finished ; if current index >= array length, jump
    
    push rax ; store current register values
    push rdi
    push rsi
    push rdx
    
    mov r9, [rax + 8*rdx]  ; r9 = array_1[index]
    
    ; calculate the number of occurances of array_1[index] in array_2
    ; rax = number_of_occurances_in_array(rax = int64* array, rdi = int64 array_length, rsi = int64 x)

    mov rax, rdi ; rax = array_2
    mov rdi, rsi ; rdi = length of array
    mov rsi, r9  ; rsi = array_1[index]
    call number_of_occurances_in_array ; rax = n_occurances
    
    imul r9       ; rax = n_occurances*array_1[index]
    add r8, rax   ; add n_occurances*array_1[index] to current sum (r8)
    
    ; restore registers
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    inc rdx
    jmp .mainLoop
.finished:
    mov rax, r8
    pop r9
    pop r8
    pop rdx
    ret
                
;----------------------------------------------------------
; void run(rax=char* fpath)
;   runs day 1 for the given file
;----------------------------------------------------------
run:
    ; print info text first
    push rax
    mov rax, msg_part_1
    call print_str
    pop rax
    call print_str
    call print_LF
    
    ;load_arrays(rax=char* fpath, rdi = char* charBuffer, rsi = int64 char_buffer_size, rdx = int64* int_buffer_0, 
    ;                   r8 = int64* int_buffer_1, r9 = int64* int_buffer_2)
    ; load arrays
    mov rdi, char_buffer
    mov rsi, buffer_size
    mov rdx, array_0
    mov r8, array_1
    mov r9, array_2
    call load_arrays
    
    ; new register values:
    ; rax = int64* array_1
    ; rdi = int64* array_2
    ; rsi = int64 array_length	
    
    ; print the array length
    push rax
    mov rax, msg_array_len
    call print_str
    mov rax, rsi
    call print_int_LF
    pop rax

    ; calculate distance (for part 1)
    call calculate_distance
    push rax
    mov rax, msg_distance_1
    call print_str
    pop rax ; rax = distance
    call print_int_LF
    
    ; calculate distance_2 (for part 2)
    mov rax, array_1
    call calculate_distance_2
    push rax
    mov rax, msg_distance_2
    call print_str
    pop rax
    call print_int_LF

    ret
	
_start:
    mov rax, test_filepath
    call run
    mov rax, input_filepath
    call run
    call exit
    
section   .data
	input_filepath  db  "input_file.txt",0h
	test_filepath  db  "test_file.txt",0h

     msg_part_1  db "Day 01: Running file ", 0h
     msg_array_len db "    Array length: ", 0h
	msg_array_1 db "    Array 1: ", 0h
	msg_array_2 db "    Array 2: ", 0h
	msg_distance_1 db "    Distance (1): ", 0h
	msg_distance_2 db "    Distance (2): ", 0h

	buffer_size equ 65536
	char_buffer  TIMES  buffer_size    DB  0          ;uint8_t[8192]
	array_0     TIMES  buffer_size    DQ  0          ;uint64_t[8192]
     array_1     TIMES  buffer_size    DQ  0          ;uint64_t[8192]
	array_2     TIMES  buffer_size    DQ  0          ;uint64_t[8192]
