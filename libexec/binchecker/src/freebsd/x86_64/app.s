.text
.global main
main:
    movq $1, %rax
    movq $0, %rdi
    int $0x80
