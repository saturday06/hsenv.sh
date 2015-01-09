.text
.global main
main:
    push $0
    push $0
    movl $1, %eax
    int $0x80
