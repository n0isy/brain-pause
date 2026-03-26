.intel_syntax noprefix

.equ SYS_rt_sigprocmask, 14
.equ SYS_rt_sigtimedwait, 128
.equ SYS_exit_group,     231

.equ SIG_BLOCK, 0
.equ SIGINT,    2
.equ SIGTERM,   15

.equ KERNEL_SIGSET_SIZE, 8

.section .rodata,"a",@progbits
sigset:
    .quad (1 << (SIGINT - 1)) | (1 << (SIGTERM - 1))

.section .text,"ax",@progbits
.global _start
.type _start, @function

_start:
    # rt_sigprocmask(SIG_BLOCK, &sigset, NULL, 8)
    mov eax, SYS_rt_sigprocmask
    mov edi, SIG_BLOCK
    lea rsi, [rip + sigset]
    xor edx, edx
    mov r10d, KERNEL_SIGSET_SIZE
    syscall

    test rax, rax
    js fatal

wait_signal:
    # rt_sigtimedwait(&sigset, NULL, NULL, 8)
    mov eax, SYS_rt_sigtimedwait
    lea rdi, [rip + sigset]
    xor esi, esi
    xor edx, edx
    mov r10d, KERNEL_SIGSET_SIZE
    syscall

    # success => rax = signal number
    cmp eax, SIGINT
    je clean_exit
    cmp eax, SIGTERM
    je clean_exit

    # error => negative errno
    test rax, rax
    js fatal

    jmp wait_signal

clean_exit:
    mov eax, SYS_exit_group
    xor edi, edi
    syscall

fatal:
    mov eax, SYS_exit_group
    mov edi, 1
    syscall
