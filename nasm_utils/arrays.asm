%ifndef ARRAYS_ASM
%define ARRAYS_ASM

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

%endif