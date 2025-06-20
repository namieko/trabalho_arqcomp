; Trabalho de Arq Comp – Ordena array com Insertion Sort e imprime os números primos.
; Assemble com: nasm -felf64 trabalho.asm -o trabalho.o 
; Link com: ld trabalho.o -o trabalho

section .data
    initial_msg      db "Array inicial:", 0xA
    initial_msg_len  equ $ - initial_msg
    
    sorted_all_msg   db "Array ordenado (completo):", 0xA
    sorted_all_msg_len equ $ - sorted_all_msg
    
    sorted_msg       db 0xA, "Numeros primos (ordenados):", 0xA
    sorted_msg_len   equ $ - sorted_msg

    array            dd 29, 15, 2, 11, 4, 17, 9, 13, 3, 7
    n                equ 10

    newline          db 0xA
    space            db ' '

section .bss
    numbuf           resb 21

section .text
    global _start

;---------------------------------------------------------------
; As funções insertion_sort, is_prime e print_number
; permanecem exatamente como no código original.
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

is_prime:
    push rcx
    push rdx
    push rsi
    mov esi, eax
    cmp esi, 2
    jl .not_prime
    cmp esi, 2
    je .is_prime
    mov ecx, 2
.check_loop:
    mov eax, ecx
    imul eax, ecx
    cmp eax, esi
    ja .is_prime
    mov eax, esi
    xor edx, edx
    div ecx
    cmp edx, 0
    je .not_prime
    inc ecx
    jmp .check_loop
.is_prime:
    mov eax, 1
    jmp .done
.not_prime:
    mov eax, 0
.done:
    pop rsi
    pop rdx
    pop rcx
    ret

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
; ፤ ALTERADO: Função para imprimir o array completo com a correção
;---------------------------------------------------------------
print_array_full:
    mov ecx, 0        ; Inicia o contador do loop
.loop:
    cmp ecx, n
    jge .end          ; Se ecx >= n, termina o loop

    push rcx          ; <<< CORREÇÃO: Salva o contador do loop antes das chamadas

    mov eax, [array + ecx*4]
    call print_number

    ; Imprime um espaço
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    pop rcx           ; <<< CORREÇÃO: Restaura o contador do loop

    inc ecx           ; Incrementa o contador (agora com o valor correto)
    jmp .loop         ; Volta para o início do loop
.end:
    ; Imprime uma nova linha no final
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
    ; 1. Imprime o array inicial
    mov rax, 1
    mov rdi, 1
    mov rsi, initial_msg
    mov rdx, initial_msg_len
    syscall
    call print_array_full

    ; 2. Ordena o array
    call insertion_sort

    ; 3. Imprime o array completo ordenado
    mov rax, 1
    mov rdi, 1
    mov rsi, sorted_all_msg
    mov rdx, sorted_all_msg_len
    syscall
    call print_array_full

    ; 4. Imprime a mensagem para os números primos
    mov rax, 1
    mov rdi, 1
    mov rsi, sorted_msg
    mov rdx, sorted_msg_len
    syscall

    ; 5. Imprime apenas os números primos
    ; ፤ ALTERADO: Lógica de salvar/restaurar RCX corrigida para como era no original
    mov ecx, 0
.print_primes_loop:
    cmp ecx, n
    jge .exit_program

    push rcx          ; Salva o contador do loop

    mov eax, [array + ecx*4]
    call is_prime
    
    cmp eax, 1
    jne .skip_print   ; Se não for primo, pula para restaurar o rcx

    mov eax, [array + ecx*4] ; eax já foi modificado por is_prime, precisa carregar de novo
    call print_number
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

.skip_print:
    pop rcx           ; Restaura o contador do loop
    inc ecx
    jmp .print_primes_loop

.exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall
