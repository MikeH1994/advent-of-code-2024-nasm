%ifndef SYSCALLS_ASM
%define SYSCALLS_ASM

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

%endif
