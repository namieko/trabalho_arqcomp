; Trabalho de Arq Comp – Versão final com correção na função is_prime
; Assemble com: nasm -felf64 trabalho.asm -o trabalho.o 
; Link com: ld trabalho.o -o trabalho

section .data
    prompt_msg       db "Digite 10 numeros inteiros, um por linha:", 0xA
    prompt_msg_len   equ $ - prompt_msg
    initial_msg      db 0xA, "Array fornecido:", 0xA
    initial_msg_len  equ $ - initial_msg
    sorted_all_msg   db "Array ordenado (completo):", 0xA
    sorted_all_msg_len equ $ - sorted_all_msg
    sorted_msg       db 0xA, "Numeros primos (ordenados):", 0xA
    sorted_msg_len   equ $ - sorted_msg
    n                equ 10
    newline          db 0xA
    space            db ' '

section .bss
    array            resd n
    input_buffer     resb 16
    numbuf           resb 21

section .text
    global _start

;---------------------------------------------------------------
; Função para converter uma string (texto) em um inteiro.
;---------------------------------------------------------------
string_to_int:
    xor rax, rax
.s2i_loop:
    movzx rdx, byte [rsi]
    cmp dl, '0'
    jl .s2i_done
    cmp dl, '9'
    jg .s2i_done
    sub dl, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp .s2i_loop
.s2i_done:
    ret

;---------------------------------------------------------------
; Função insertion_sort
;---------------------------------------------------------------
insertion_sort:
    mov ecx, 1
.sort_outer_loop:
    cmp ecx, n
    jge .sort_end
    mov eax, [array + ecx*4]
    mov ebx, ecx
    dec ebx
.sort_inner_loop:
    cmp ebx, 0
    jl .sort_insert_key
    mov edx, [array + ebx*4]
    cmp edx, eax
    jle .sort_insert_key
    mov edx, [array + ebx*4]
    mov [array + ebx*4 + 4], edx
    dec ebx
    jmp .sort_inner_loop
.sort_insert_key:
    inc ebx
    mov [array + ebx*4], eax
    inc ecx
    jmp .sort_outer_loop
.sort_end:
    ret

;---------------------------------------------------------------
; ፤ CORREÇÃO: Função is_prime com rótulos globais para evitar erros de símbolo.
;---------------------------------------------------------------
is_prime:
    push rcx
    push rdx
    push rsi

    mov esi, eax
    cmp esi, 2
    jl is_prime_not_prime   ; Se for menor que 2, não é primo
    cmp esi, 2
    je is_prime_is_prime    ; Se for 2, é primo

    mov ecx, 2
is_prime_check_loop:
    mov eax, ecx
    imul eax, ecx           ; eax = ecx * ecx
    cmp eax, esi
    ja is_prime_is_prime    ; Se ecx^2 > n, então é primo

    mov eax, esi
    xor edx, edx
    div ecx                 ; Divide n por ecx
    cmp edx, 0
    je is_prime_not_prime   ; Se o resto é 0, é divisível, não é primo

    inc ecx
    jmp is_prime_check_loop

is_prime_is_prime:
    mov eax, 1              ; Retorna 1 (verdadeiro)
    jmp is_prime_done
is_prime_not_prime:
    mov eax, 0              ; Retorna 0 (falso)
is_prime_done:
    pop rsi
    pop rdx
    pop rcx
    ret

;---------------------------------------------------------------
; Função print_number
;---------------------------------------------------------------
print_number:
    push rbx
    mov rbx, numbuf
    add rbx, 20
    mov rcx, 0
    cmp rax, 0
    jne .print_number_loop
    dec rbx
    mov byte [rbx], '0'
    mov rcx, 1
    jmp .print_number_output
.print_number_loop:
    xor rdx, rdx
    mov r8, 10
    div r8
    add rdx, '0'
    dec rbx
    mov [rbx], dl
    inc rcx
    cmp rax, 0
    jne .print_number_loop
.print_number_output:
    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, rcx
    syscall
    pop rbx
    ret

;---------------------------------------------------------------
; Função print_array_full
;---------------------------------------------------------------
print_array_full:
    mov ecx, 0
.loop:
    cmp ecx, n
    jge .end
    push rcx
    mov eax, [array + ecx*4]
    call print_number
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    pop rcx
    inc ecx
    jmp .loop
.end:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
    
;---------------------------------------------------------------
; _start: Ponto de entrada do programa
;---------------------------------------------------------------
_start:
    ; 1. Pede para o usuário digitar os números
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_msg
    mov rdx, prompt_msg_len
    syscall

    ; 2. Loop para ler os 10 números
    mov ecx, 0
.read_loop:
    cmp ecx, n
    jge .reading_done
    push rcx
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    mov rsi, input_buffer
    call string_to_int
    pop rcx
    mov [array + rcx*4], eax
    inc ecx
    jmp .read_loop

.reading_done:
    ; 3. Imprime o array fornecido
    mov rax, 1
    mov rdi, 1
    mov rsi, initial_msg
    mov rdx, initial_msg_len
    syscall
    call print_array_full

    ; 4. Ordena o array
    call insertion_sort

    ; 5. Imprime o array completo ordenado
    mov rax, 1
    mov rdi, 1
    mov rsi, sorted_all_msg
    mov rdx, sorted_all_msg_len
    syscall
    call print_array_full

    ; 6. Imprime a mensagem para os números primos
    mov rax, 1
    mov rdi, 1
    mov rsi, sorted_msg
    mov rdx, sorted_msg_len
    syscall

    ; 7. Imprime apenas os números primos
    mov ecx, 0
.print_primes_loop:
    cmp ecx, n
    jge .exit_program
    push rcx
    mov eax, [array + ecx*4]
    call is_prime
    cmp eax, 1
    jne .skip_print
    mov eax, [array + ecx*4]
    call print_number
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
.skip_print:
    pop rcx
    inc ecx
    jmp .print_primes_loop

.exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall
