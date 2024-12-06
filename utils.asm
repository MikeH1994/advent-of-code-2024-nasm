SYSCALL_READ      equ 0
SYSCALL_WRITE     equ 1
SYSCALL_OPEN      equ 2
SYSCALL_CLOSE     equ 3
SYSCALL_EXIT      equ 60

SYSCALL_STDIN     equ 0
SYSCALL_STDOUT    equ 1
SYSCALL_OPEN_R    equ 0
SYSCALL_OPEN_W    equ 1
SYSCALL_OPEN_RW   equ 2 

;----------------------------------------------------------
; void exit()
; Exits program
;----------------------------------------------------------
exit:
    mov rdi,0
    mov rax, SYSCALL_EXIT
    syscall
    ret

;----------------------------------------------------------
; int strlen(rax = char* message)
; String length calculation function
; returns:
;    rax = length of string
;----------------------------------------------------------
strlen:
    
    ;let rax point to the current element of the char buffer being checked
    ;let rdi point to the start of the char buffer
    push rdi
    mov rdi,rax        ;rdi and rax now both point to the start of the buffer
.nextchar:
    cmp byte[rax],0h   ;compare char at rax to null byte
    jz .finished       ;if [rax] == 0h, jump to .finished
    inc rax            ;else, increment the pointer and jump back to .nextchar
    jmp .nextchar    
.finished:
    sub rax,rdi
    pop rdi
    ret


;----------------------------------------------------------
; void print()
; print linefeed to stdout
;----------------------------------------------------------
print_LF:
    push rax
    push 0Ah         ;push a linefeed on to the stack (Don't need a null byte as next byte in rax is 0)
    
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the linefeed) in rax 
    call print_str
    
    pop rax         ;remove linefeed    
    pop rax         ;restore original value of rx
    ret

;----------------------------------------------------------
; void print_comma()
; print comma to stdout
;----------------------------------------------------------
print_comma:
    push rax
    push ","         ;push a comma on to the stack (Don't need a null byte as next byte in rax is 0)
    
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the linefeed) in rax 
    call print_str
    
    pop rax         ;remove linefeed    
    pop rax         ;restore original value of rx
    ret
	
;----------------------------------------------------------
; void print_lbracket()
; print left bracket to stdout
;----------------------------------------------------------
print_lbracket:
    push rax
    push "["         ;push a comma on to the stack (Don't need a null byte as next byte in rax is 0)
    
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the linefeed) in rax 
    call print_str
    
    pop rax         ;remove linefeed    
    pop rax         ;restore original value of rx
    ret
	
;----------------------------------------------------------
; void print_lbracket()
; print left bracket to stdout
;----------------------------------------------------------
print_rbracket:
    push rax
    push "]"         ;push a comma on to the stack (Don't need a null byte as next byte in rax is 0)
    
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the linefeed) in rax 
    call print_str
    
    pop rax         ;remove linefeed    
    pop rax         ;restore original value of rx
    ret

;----------------------------------------------------------
; void print(rax = char* message)
; print string to stdout (without a linefeed at end)
;----------------------------------------------------------
print_str:
    push rax
    push rdi
    push rsi
    push rdx
    
    ;for printing to stdout as syscall we want:
    ;rax = SYSCALL_WRITE, rdi = SYSCALL_STDOUT, rsi = message ptr, rdx = strlen
    
    mov rsi,rax        ;move the str ptr to rsi first
    call strlen        ;calculate the length of the string (strlen is now in rax)
    mov rdx,rax        ;move the string length to rdx
    mov rax, SYSCALL_WRITE
    mov rdi, SYSCALL_STDOUT
    syscall
    
    ;pop stack back in order then exit
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret
	
;----------------------------------------------------------
; void print(rax = char* message, rdi = int64 str_len)
; print string to stdout (without a linefeed at end)
;----------------------------------------------------------
print_substr:
    push rax
    push rdi
    push rsi
    push rdx
    
    ;for printing to stdout as syscall we want:
    ;rax = SYSCALL_WRITE, rdi = SYSCALL_STDOUT, rsi = message ptr, rdx = strlen
    
    mov rsi,rax        ;move the str ptr to rsi first
    mov rdx,rdi        ;move the string length to rdx
    mov rax, SYSCALL_WRITE
    mov rdi, SYSCALL_STDOUT
    syscall
    
    ;pop stack back in order then exit
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

;----------------------------------------------------------
; void sprint_LF(char* message)
; print a string
;----------------------------------------------------------
print_str_LF:
    call print_str
    call print_LF
    ret
    
;----------------------------------------------------------
; void print_int_withSignCheck(int num, bool isSigned)
; print an integer, with checks to see if it is negative if isSigned is passed
;----------------------------------------------------------

print_int_withSignCheck:
    ;let rax be the current value
    ;let rdi be the number of characters to print
    ;let rsi be used to store the char representation of each digit
    ;rdx will store the remainder of the divides
    push rax
    push rdi
    push rsi
    push rdx
    cmp rdi,1        ;if flag is passed, rdi is signed
    mov rdi,0        ;set rdi to zero as we are now using it as a counter
    je .raxIsSigned  ;handle signed int
    jmp .divideLoop  ;else, ignore
.raxIsSigned:
    cmp rax,0        ;check if rax is negative
    jge .divideLoop  ;not negative, no need to handle this
    
    push rax        ;store rax
    push '-'        ;push a minus sign on to the stack (Don't need a null byte as next byte in rax is 0)
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the minus sign) in rax 
    call print_str
    pop rax         ;remove minus sign    
    pop rax         ;restore original value of rax
    
    mov  rsi, -1     ;move divisor
    imul rsi         ;times rax by -1 so we know it is now positive
    
    jmp .divideLoop  ;carry on as normal now
.divideLoop:
    inc rdi        ;increment the number of bytes counter
    mov rdx,0      ;clear rdx (where remainder will be stored)
    mov rsi,10     ;put the divisor in rsi
    div rsi        ;divide rax by 10
    add rdx,48     ;add 48 to the quotient (to get the corresponding ascii)
    push rdx       ;add this character to the stack
    cmp rax,0      ;if the quotient is zero, we don't need to go further 
    jnz .divideLoop
    jmp .printLoop
.printLoop:
    mov rax, rsp   ;move the pointer to top stack element to rax
    call print_str ;print this character
    pop rax        ;remove this character from stack
    dec rdi        ;decrement counter
    cmp rdi,0      ;check if we are done
    jnz .printLoop
    jmp .finishedPrinting
.finishedPrinting:   
    ;restore values 
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    ret
	
;----------------------------------------------------------
; void print_int(rax = num)
; print a signed integer
;----------------------------------------------------------
print_int:
    push rdi
    mov rdi,1
    call print_int_withSignCheck
    pop rdi
    ret
   
;----------------------------------------------------------
; void print_int_LF(rax = int num)
; print a signed integer plus linefeed
;----------------------------------------------------------
    
print_int_LF:
    call print_int
    call print_LF
    ret
    
;----------------------------------------------------------
; void print_int(rax = uint val)
; print an unsigned integer
;----------------------------------------------------------
print_uint:
    push rdi
    mov rdi,0
    call print_int_withSignCheck
    pop rdi
    ret
    
;----------------------------------------------------------
; void print_int(rax = uint val)
; print an unsigned integer
;----------------------------------------------------------
print_uint_LF:
    call print_uint
    call print_LF
    ret
	

;----------------------------------------------------------
; void print_int_array(rax = int64* buffer, rdi = int64 buffersize)
; print an unsigned integer
;----------------------------------------------------------
print_int_array:
	; rax will store the integer we are going to print next
     ; rdi will contain the buffer size
	; rsi will contain the buffer pointer
	; rdx will be the current index that we are going to print
	push rax
	push rsi
	push rdx
	mov rsi, rax
	mov rdx, 0
	call print_lbracket
.mainLoop:
	cmp rdx, rdi               ; if i >= buffer_size
	jge .finished              ; jump to .finished
	mov rax, [rsi + 8*rdx] 
	call print_int
	inc rdx
	cmp rdx, rdi               ; if i >= buffer_size
	jge .finished              ; jump to .finished (this check here is to prevent a comma on last elem)
	call print_comma
	jmp .mainLoop
.finished:
	call print_rbracket
	pop rdx
	pop rsi
	pop rax
	ret

;----------------------------------------------------------
; int64 string_to_int(rax=char* buffer, rdi = int64 length)
; 	converts a string to an integer, and returns as rax
;----------------------------------------------------------
; rax will store the current value
; rdi will store the current index we are at
; rsi will store the pointer to the buffer
; rdx will store the length of the substring
; r8 will store the value of the current digit
; r9 will store the value 10 for imul
; r10 will store if the first digit was '-'
string_to_int:
	push rdi
	push rsi
	push rdx
	push r8
	push r9
	push r10
	mov rsi, rax    ; rsi = buffer pointer
	mov rdx, rdi    ; rdx = length
	mov rdi, 0      ; rdi = current index
	mov rax, 0      ; rax = current value
	mov r9, 10      ; used for imul
	mov r10, 0      ; used to store whether we need to multiply by -1 at the end
	cmp byte[rsi], "+"
	je .firstCharIsPlus
	cmp byte[rsi], "-"
	je .firstCharIsMinus
	jmp .mainLoop
.mainLoop:
	cmp rdi, rdx             ; if i >= array_len
	jge .flipSignIfNeeded
	
	push rdx                 ; storing value of rdx as it is destroyed by imul
	imul r9
	pop rdx
	mov r8, 0
	mov r8b, byte[rsi + rdi]
	sub r8, 48               ; numbers in ascii start at 48 (e.g. 0 is 48, 1 is 49 etc)- subtract 48 from the ascii value to get int
	add rax, r8
	inc rdi
	jmp .mainLoop
.firstCharIsPlus:
	call print_rbracket
	inc rdi
	jmp .mainLoop
.firstCharIsMinus:
	inc rdi
	mov r10, 1
	jmp .mainLoop
.flipSignIfNeeded:
	cmp r10, 0
	je .finished   ; if r10 == 0, no negative sign and we can exit
	mov r9, -1
	imul r9		   ; rax *= -1
	jmp .finished  
.finished:
	pop r10
	pop r9
	pop r8
	pop rdx
	pop rsi
	pop rdi	
	ret


;----------------------------------------------------------
; read_file_to_buffer(rax=char* fpath, rdi = char* buffer,rsi = uint64 bufferSize)
;    read file to buffer pointer given in rdi.
;    returns:
;        rax = char* buffer
;        rdi = int64 string_length
;----------------------------------------------------------

read_file_to_buffer:  
    push rdx ; store rdx for later
    push rsi ; store rsi for later
          
    ;syscall 'open'-
    ;int open(const char *pathname, int flags);
    push rdi                ;store char buffer ptr for read call
    push rsi                ;store buffer size for read call
    mov rdi,rax             ;rdi = fpath
    mov rax,SYSCALL_OPEN    ;set rax for syscall
    mov rsi,SYSCALL_OPEN_R  ;set read only option
    syscall                 ;rax now contains file descriptor
    
    ;syscall 'read'-
    ;void read(rdi = uint file_descriptor, rsi = char* buffer, rdx = uint buffer_size)
    pop rdx                 ;store buffer size in rdx 
    pop rsi                 ;store char buffer ptr in rsi
    mov rdi,rax             ;store fd in rdi
    mov rax,SYSCALL_READ     
    syscall
    
    ;syscall 'close'
    ;void close(rdi = uint fd)
    mov rax,SYSCALL_CLOSE   ;file descriptor already in rdi 
    syscall
    
    mov rax, rsi            ; move stack pointer to rax
    push rax                ; store pointer on stack
    call strlen             ; rax = length of string loaded
    mov rdi, rax            ; rdi = length of string loaded
    pop rax                 ; rax = buffer pointer
    pop rsi                 ; restore rsi to initial value
    pop rdx
    ret
	

;----------------------------------------------------------
; load_int_array_from_txt(rax=char* fpath, rdi = char* buffer,rsi = uint64 bufferSize, rdx = int64* int_array)
;    loads a text file in to the char buffer given in rdi, then converts this to an array of ints
;    returns:
;        rax = int64* array
;        rdi = int64 array_length
;----------------------------------------------------------
; rax will store the char buffer (the array containing the text file we loaded)
; rdi will store the length of the buffer loaded (ignoring any folllowing bytes unused)
; rsi will store the int array we are writing to
; rdx will store the index we are at in the char buffer
; r8 will store the length of the substring we are searching over
; r9 will store the current length of the loaded array
; r10 will be used for misc arithmetic

load_int_array_from_txt:
	; load buffer in to memory and determine how long the loaded string is
     ; read_file_to_buffer(rax = char* fpath, rdi = char* buffer, rsi = int64 buffer_size)   
	call read_file_to_buffer  ; rax, rdi, and rsi already correspond to the correct arguments for read_file_to_buffer
    ; now, rax = char* buffer, rdi = length of string loaded
     
    ; store current values so we can preserve the other registers upon return 
    push rsi
    push rdx
    push r8
    push r9
    push r10

    ; initialise registers
    mov rsi, rdx ; rsi = int64* array
    mov rdx, 0   ; rdx = int64 index
    mov r8, 0    ; r8  = int64 substr_len
    mov r9, 0    ; r9  = int64 array_len
    mov r10, 0   ; r10 = misc 

.mainLoop:
    cmp rdx, rdi              ; compare the current index (rdx) to the length of the string (rdi)
    jge .finished               ; if i >= buffer_length, exit
    mov r8, 0				    ; set the length of the current substring to zero
    jmp .substringSearchLoop    ; 
.substringSearchLoop:
    ; check if we have reached the end of the string 
    push rdx                  ; store the starting position of the string
    add rdx, r8               ; rdx = starting index of substring + length of substring (i.e. the end position of the substring)
    cmp rdx, rdi              ; compare the end position of the substring to the length of the loaded string
    pop rdx                   ; restore starting position of string
    jge .endOfSubstring       ; if end of substring >= length of string, jump to end of substring
    jmp .checkCharacter
.checkCharacter:
    push rax                        ; store pointer position
    add rax, rdx                    ;
    add rax, r8                     ; rax now points to char_buffer[i + substr_len]
    mov r10, 0                      ; clear r10
    mov r10b, byte[rax]             ; r10 now equals char_buffer[i + substr_len]
    pop rax                         ; rax points to start of buffer again
    cmp r10b, "+"                   ; check if plus
    je .validCharacterFound         ; plus is accepted
    cmp r10b, "-"                   ; check if minus
    je .validCharacterFound         ; minus is accepted
    cmp r10, 48                     ; numbers in ascii are only between 48 and 57 inclusive- anything else is invalid
    jl .invalidCharacterFound       ;
    cmp r10, 57                     ; 
    jg .invalidCharacterFound       ;
    jmp .validCharacterFound
.validCharacterFound:
    inc r8                    ; increase the substring length by 1
    jmp .substringSearchLoop
.invalidCharacterFound:
    jmp .endOfSubstring
.endOfSubstring:
    cmp r8, 0                 ; check the length of the current substring
    je .emptySubstringFound   ; if substr_len == 0
    jmp .validSubstringFound  ; otherwise, substring valid
.emptySubstringFound:   
    inc rdx                   ; increment where we are starting the string from
    jmp .mainLoop
.validSubstringFound:
    push rax                  ; store the buffer pointer 
    push rdi                  ; store the buffer length
    add rax, rdx              ; rax = pointer to the character we are starting at
    mov rdi, r8               ; rdi = length of substring
    call string_to_int        ; rax = integer
    mov [rsi + 8*r9], rax     ; move the new integer to the next spot in the array
    inc r9                    ; increase the array length counter
    pop rdi                   ; restore the buffer length
    pop rax                   ; restore the buffer pointer
    add rdx, r8               ; move the start point of the new string forwards
    jmp .mainLoop
.finished:
    mov rax, rsi              ; rax = int64* int_array
    mov rdi, r9               ; rdi = int64 array_length
    
    ; restore registers
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rsi
    
    ret


;----------------------------------------------------------
; bool array_is_sorted(rax = int64* array, rdi = uint64 array_size)
;     returns true in rax if the array is sorted from smallest to largest
;     
;     rax will contain the array
;     rdi will contain the array size - 2
;     rsi will contain the current index
;     rdx will be used to store rax[i]
;     r8 will be used to store rax[i+1]
;----------------------------------------------------------
array_is_sorted:
	push rdi
	push rsi
	push rdx
	push r8
	dec rdi ; rdi = array_size - 1
.mainLoop:
	cmp rsi, rdi 
	jge .success                             ; if current_index >= array_length - 2, exit loop
	mov rdx, [rax + 8*rsi]
	mov r8, [rax + 8*rsi + 8]
	cmp rdx, r8 
	jg .failed                               ; if rax[i] > rax[i + 1], array is not ordered- got to .failed
	inc rsi
	jmp .mainLoop
.failed:
	mov rax, 0
	jmp .finished
.success:
	mov rax, 1
	jmp .finished
.finished:
	pop r8
	pop rdx
	pop rsi
	pop rdi
	ret



;----------------------------------------------------------
; void sort_array(rax = int64* array, rdi = int64 array_size)
;     sorts the given array in place. All registers preserved
;     
;     rax will contain the pointer to the array
;     rdi will contain the array length
;     rsi will contain the current index
;     rdx will be used to store rax[i]
;     r8 will be used to store rax[i+1]
;     r9 will be used to store array length - 1
;     r10 will be used to store if a value has been swapped in a run
;----------------------------------------------------------
sort_array:
	push rsi
	push rdx
	push r8
	push r9
	push r10
	mov r9, rdi ; r9 = array_size
	dec r9      ; r9 = array_size - 1
	mov r10, 1  ; stores whether a value has been changed in a run
.mainLoop:
	cmp r10, 0           ; if we have completed a run with no changes, array is sorted
	je .finished
	mov rsi, 0	         ; set the index we are looping through to 
	mov r10, 0           ; reset the flag to indicate if any changes have been made
	jmp .sortLoop
.sortLoop:	
	cmp rsi, r9                ; compare current index to array_length - 1
	jge .mainLoop              ; we have looped through the entire array, go back to main loop now and check if it is now sorted
	mov rdx, [rax + 8*rsi]     ; rdx = rax[i] 
	mov r8, [rax + 8*rsi + 8]  ; r8 = rax[i+1]
	cmp rdx, r8
	jg .swapValues             ; if rax[i] > rax[i+1], jump to .swapValues
	inc rsi
	jmp .sortLoop
.swapValues:
	mov r10, 1
	mov [rax + 8*rsi], r8      ; rax[i] = r8 (=rax[i+1])
	mov [rax + 8*rsi + 8], rdx ; rax[i+1] = rdx (=rax[i])
	jmp .sortLoop
.finished:
	pop r10
	pop r9
	pop r8
	pop rdx
	pop rsi
	ret

;----------------------------------------------------------
; int64 int_abs(rax = int64 x)
;     returns the absolute value of x
;----------------------------------------------------------
int_abs:
    push rdx
    push rdi
    cmp rax, 0
    jge .finished
    mov rdi, -1
    imul rdi
    jmp .finished
.finished:  
    pop rdi
    pop rdx    
    ret

