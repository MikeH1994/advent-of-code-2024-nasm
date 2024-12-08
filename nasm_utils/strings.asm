%ifndef STRINGS_ASM
%define STRINGS_ASM

;----------------------------------------------------------
; int strlen(rax = char* string)
; String length calculation function
; returns:
;    rax = length of string
;----------------------------------------------------------
;let rax point to the current element of the char buffer being checked
;let rdi point to the start of the char buffer

strlen:    
    push rdi           ; preserve rdi
    mov rdi,rax        ; rdi and rax now both point to the start of the buffer
.nextchar:
    cmp byte[rax],0h   ;compare char at rax to null byte
    jz .finished       ;if [rax] == 0h, jump to .finished
    inc rax            ;else, increment the pointer and jump back to .nextchar
    jmp .nextchar    
.finished:
    sub rax,rdi        ; length = ptr of null byte - ptr of start
    pop rdi
    ret

;----------------------------------------------------------
; int64 find_substr(rax = char* string, rdi = char* substr, rsi = int64 start_position, rdx = int64 end_position)
;		rax = char* string - the string to be searched 
;       rdi = char* substring 
;		rsi = start_position - the index of the char we are starting at (e.g. 0 for the first char)
;		rdx = end_position - the end position of the string we are searching over, non-inclusive (e.g. 3 for a string of length 3)
; Searches for the provided substring. Returns -1 if not found
; returns:
;    rax = length of string
;
; pseudocode:
;	
; int find_substr(string, substring, start_pos, end_pos):
;     for i in range(start_pos, end_pos):
;         substring_found = True
;         for j in range(len(substring)):
;             if i + j >= end_pos:
;                 return -1
;		      char_a = string[i + j]
;			  char_b = substring[j]		 			
;             if char_a != char_b:
;                 substring_found = False
;                  break
;         if substring_found:
;             return i
;     return -1 
;
;
;----------------------------------------------------------
; rax will be used to store the pointer to the string to search over
; rdi will be used to store the substring we are trying to find
; rsi will be used to store the current start position in the string
; rdx will be used to store the end position of the search region in rax
; r8 will be used to store the length of the substring
; r9 will be used to store the position in the substring we are iterating over
; r10 will be used to store the char in rax to check
; r11 will be used to store the char in rdx to check
find_substr:
	; store the values of any registers we are modifying
	push rsi
	push r8
	push r9
	push r10
	push r11
	
	; find the length of the substring
	push rax
	mov rax, rdi ; rax = substring
	call strlen  ; rax = substring length
	mov r8, rax  ; r8  = substring length
	pop rax      ; rax = string
.mainLoop:
	cmp  rsi, rdx             		; if i >= end_index, exit loop 
	jge .searchFailed
	mov r9, 0                 		; j = 0 (the index in the substring)
	jmp .iterateOverSubstring
.iterateOverSubstring:        		; compare string[i + j] to substring[j]
	; check if  j >= len(substring)
	cmp r9, r8                		; compare j to len(substring)
	jge .searchSucceeded    		; if  j >= len(substring), exit loop as all characters have matched
	; check if i + j >= len(string)
	mov r10, r9
	add r10, rsi                    ; r10 = i + j
	cmp r10, rdx                    ; 
	jge .searchFailed               ; if i + j >= len(string), we've reached the end of the string and failed to find substr
	; clear r10 and r11
	mov r10, 0
	mov r11, 0	
	; move the pointer rax to string[i+j] then move the byte at that position to r10
	push rax
	add rax, rsi  ; add i
	add rax, r9   ; add j
	mov r10b, byte[rax]  ; r10 = string[i + j]
	pop rax
	; move the pointer rdi to substring[j] then move the byte at that position to r11
	push rdi
	add rdi, r9
	mov r11b, byte[rdi]
	pop rdi	
	; check if characters are equal
	cmp r10b, r11b					; compare string[i + j] to substring[j]
	jne .substringNotFound			; if they are not equal, substring has not been found- jump back to main loop go to next character
	; characters match- increase j
	inc r9
	jmp .iterateOverSubstring
.substringNotFound:
	inc rsi                   ; i += 1
	jmp .mainLoop             ; 
.searchSucceeded:
	mov rax, rsi              ; rsi = i (the index the found substring starts at)- this is the value we are returning
	jmp .finished             ;  
.searchFailed:
	mov rax, -1               ; return -1 if search failed
	jmp .finished
.finished:
	; restore registers
	pop r11
	pop r10
	pop r9
	pop r8
	pop rsi
	ret
	
%endif