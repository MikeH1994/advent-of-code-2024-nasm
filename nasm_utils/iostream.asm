%ifndef IOSTREAM_ASM
%define IOSTREAM_ASM

%include "syscalls.asm"
%include "strings.asm"

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
    push ","        ;push a comma on to the stack (Don't need a null byte as next byte in rax is 0)
    
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the linefeed) in rax 
    call print_str
    
    pop rax         ;remove comma    
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
; void print_LF(char* message)
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
; print an unsigned integer, followed by a line feed
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

%endif