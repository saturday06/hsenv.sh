.text
.global start
start:
    movq $0x2000001, %rax
    movq $0, %rdi
    syscall
