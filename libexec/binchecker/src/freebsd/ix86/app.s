.text
.global _start
_start:
    push $0
    movl $1, %eax
    int $0x80
