;
; nasm -felf64 solution.asm && ld -oout solution.o && ./out input
;
; input has to have an empty line at the end of file
;

GLOBAL _start

SECTION .text


;in
;       rdi - start address
;out
;       rdi - next newline char address
linelen:
        dec     rdi
.loop:
        inc     rdi
        movzx   eax, BYTE [rdi]
        cmp     eax, 10
        jne     .loop

        ret


;in
;       rdi - address from where to search
;out
;       rdi - address of the next digit char
locate_digit:
        dec     rdi
.loop:
        inc     rdi
        movzx   eax, BYTE [rdi]
        sub     eax, '0'
        cmp     eax, 9
        ja      .loop

        ret


;in
;       rdi - address of the first digit
;out
;       rax - result number
;       rdi - next non digit
atoi:
        xor     rax, rax

        call    _atoi

        ret


;in
;       rax
;       rdi - address of the first digit
;out
;       rax - concact old rax and result
;       rdi - next non digit
_atoi:
        dec     rdi
        jmp     .loop

.next_digit:
        lea     rax, [rax + rax * 4]
        lea     rax, [rcx + rax * 2]

.loop:
        inc     rdi
        movzx   ecx, BYTE [rdi]
        sub     ecx, '0'
        cmp     ecx, 9
        jbe     .next_digit

        ret


;in
;       rdi - string start
;out
;       rax - result number
;       rdi - next newline char
atoi_but_stupid:
        push    r12
        push    r13

        mov     r13, rdi
        call    linelen
        mov     r12, rdi
        mov     rdi, r13


        call    locate_digit

        xor     rax, rax
.loop:
        call    _atoi
        mov     r13, rax
        call    locate_digit
        mov     rax, r13
        cmp     rdi, r12
        jb      .loop

        pop     r13
        pop     r12
        ret


;       positive number itoa written to buff 
;       terminated with newline char
;in
;       rax - number
;out
;       rdi - length
;       buff[0:rdi] contains the number as string ending with newline
itoa2buff:
        push    rbx
        mov     rbx, 10

        mov     BYTE [itoa_buff], 10
        xor     edi, edi
        inc     edi
.loop:
        cmp     rax, 0
        jz      .reverse

        xor     edx, edx
        div     ebx
        add     dl, '0'
        mov     BYTE [itoa_buff + edi], dl
        inc     edi
        jmp     .loop

.reverse:
        xor     eax, eax
        mov     ecx, edi
        dec     ecx

.reverse_loop:
        cmp     eax, ecx
        jae     .return

        mov     dl, BYTE [itoa_buff + eax]
        mov     bl, BYTE [itoa_buff + ecx]
        mov     BYTE [itoa_buff + eax], bl
        mov     BYTE [itoa_buff + ecx], dl
        inc     eax
        dec     ecx
        jmp     .reverse_loop

.return:
        pop     rbx
        ret


;       binary search the left root of
;       x^2 - b * x + c
;in
;       rdi - b
;       rsi - c
;out
;       rax - left root
find_root:
        push    r12
        push    rbx

        mov     rbx, 0
        mov     rcx, rdi

.loop:
        mov     rax, rdi
        sub     rax, rbx
        mul     rbx
        sub     rax, rsi

        mov     r12, rcx
        and     r12, 1
        shr     rcx, 1
        cmp     rcx, 0
        jz      .return
        add     rcx, r12

        cmp     rax, 0
        jle     .move_r
        jmp     .move_l

.move_l:
        sub     rbx, rcx
        jmp     .loop

.move_r:
        add     rbx, rcx
        jmp     .loop
        
.return:
        cmp     rax, 0
        jle     .all_good
        dec     rbx

.all_good:
        mov     rax, rbx

        pop     rbx
        pop     r12
        ret


_start:
        pop     r8              ; argc
        dec     r8              ;
        pop     rsi             ; program name

        cmp     r8, 0
        jz      .no_args

        pop     rsi             ; first arg

        mov     rax, sys_open   ;
        mov     rdi, rsi        ; open filepath from the first arg
        mov     rsi, sys_rdonly ;
        syscall                 ; rax = file handle
        mov     rdi, rax        ;

        mov     rax, sys_read   ; read file contents into buff 
        mov     rsi, buff       ; up to 1024 bytes
        mov     rdx, buff_size  ;
        syscall                 ; rax = n bytes read

        mov     rax, sys_close  ; just assume we read everything
        syscall                 ; and close the file


        ; Process read buff for pt.1
        mov     rdi, buff       
        call    linelen
        mov     rbx, rdi

        xor     r12, r12
        mov     rdi, buff

.read_next_time:
        call    locate_digit
        call    atoi
        mov     [times_arr + r12 * 4], eax
        inc     r12
        cmp     rdi, rbx
        jb      .read_next_time


        inc     rdi
        mov     r12, rdi
        call    linelen
        mov     rbx, rdi
        mov     rdi, r12
        xor     r12, r12

.read_next_dist:
        call    locate_digit
        call    atoi
        mov     [dists_arr + r12 * 4], eax
        inc     r12
        cmp     rdi, rbx
        jb      .read_next_dist


        xor     rbx, rbx
        mov     r13, 1

;       Part 1 solution
.solve_next:
        mov     edi, [times_arr + rbx * 4]
        mov     esi, [dists_arr + rbx * 4]

        call    find_root

        sub     edi, eax
        sub     edi, eax
        dec     edi
        mov     eax, edi
        mul     r13
        mov     r13, rax

        inc     rbx
        cmp     rbx, r12
        jne     .solve_next

        mov     rax, sys_write
        mov     rdi, sys_stdout
        mov     rsi, msg1
        mov     rdx, msg_size
        syscall

        mov     rax, r13
        call    itoa2buff
        mov     rdx, rdi
        mov     rax, sys_write
        mov     rdi, sys_stdout
        mov     rsi, itoa_buff
        syscall

;       Part 2 solution
        mov     rdi, buff
        call    atoi_but_stupid
        mov     r14, rax
        call    atoi_but_stupid
        mov     rsi, rax
        mov     rdi, r14
        call    find_root

        sub     r14, rax
        sub     r14, rax
        dec     r14

        mov     rax, sys_write
        mov     rdi, sys_stdout
        mov     rsi, msg2
        mov     rdx, msg_size
        syscall

        mov     rax, r14
        call    itoa2buff
        mov     rdx, rdi
        mov     rax, sys_write
        mov     rdi, sys_stdout
        mov     rsi, itoa_buff
        syscall


.exit_ok:
        mov     rax, sys_exit
        mov     rdi, 0
        syscall

.no_args:
        mov     rax, sys_write
        mov     rdi, sys_stdout
        mov     rsi, badargs
        mov     rdx, badargs_size
        syscall

        mov     rax, sys_exit
        mov     rdi, 1
        syscall


SECTION .bss
buff_size       equ     256
buff            resb    buff_size

times_arr       resb    16
dists_arr       resb    16

itoa_buff       resb    16


SECTION .data

msg1            db      'Result 1: '
msg2            db      'Result 2: '
msg_size        equ     $ - msg2
badargs         db      'Expected input file path',10
badargs_size    equ     $ - badargs

sys_rdonly      equ     0

sys_stdout      equ     1

sys_read        equ     0
sys_write       equ     1
sys_open        equ     2
sys_close       equ     3
sys_exit        equ     60

; vim: ft=nasm ts=8 sts=8 sw=8
