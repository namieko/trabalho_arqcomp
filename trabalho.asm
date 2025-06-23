;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    Trabalho de Arquitetura de Computadores
;
;    PARA COMPILAR E LINKAR:
;    nasm -felf64 insertion.asm -o trabalho.o
;    ld trabalho.o -o trabalho
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;----------------------------------------------------------------------------------------
;   SEÇÃO DE DADOS INICIALIZADOS
;----------------------------------------------------------------------------------------
section .data
    ; Mensagem para solicitar a entrada de 10 números ao usuário
    prompt_msg          db "Digite 10 numeros inteiros, um por linha:", 0xA
    ; Calcula o comprimento da mensagem 'prompt_msg'
    prompt_msg_len      equ $ - prompt_msg
    
    ; Mensagem a ser exibida antes de mostrar o array fornecido
    initial_msg         db 0xA, "Array fornecido:", 0xA
    ; Calcula o comprimento da mensagem 'initial_msg'
    initial_msg_len     equ $ - initial_msg
    
    ; Mensagem a ser exibida antes de mostrar o array ordenado completo
    sorted_all_msg      db "Array ordenado:", 0xA
    ; Calcula o comprimento da mensagem 'sorted_all_msg'
    sorted_all_msg_len  equ $ - sorted_all_msg
    
    ; Mensagem a ser exibida antes de mostrar os números primos ordenados
    sorted_msg          db 0xA, "Numeros primos:", 0xA
    ; Calcula o comprimento da mensagem 'sorted_msg'
    sorted_msg_len      equ $ - sorted_msg
    
    ; Define uma constante 'n' com o valor 10, representando o número de elementos no array
    n                   equ 10
    
    ; Caractere de nova linha (Line Feed)
    newline             db 0xA
    
    ; Caractere de espaço
    space               db ' '
    
    ; Caractere de sinal negativo
    minus_char          db '-'

;----------------------------------------------------------------------------------------
;   SEÇÃO DE DADOS NÃO INICIALIZADOS
;----------------------------------------------------------------------------------------
section .bss
    ; Aloca espaço para 'n' (10) double words (4 bytes cada), formando o array de inteiros
    array               resd n
    ; Aloca 16 bytes para um buffer de entrada, usado para ler strings do usuário
    input_buffer        resb 16
    ; Aloca 21 bytes para um buffer numérico, usado para converter inteiros em strings para impressão
    numbuf              resb 21


;----------------------------------------------------------------------------------------
;   SEÇÃO DE CÓDIGO (TEXTO)
;----------------------------------------------------------------------------------------
section .text
    ; Declara '_start' como um símbolo global, tornando-o o ponto de entrada do programa
    global _start


;----------------------------------------------------------------------------------------
; PROCEDURE string_to_int
; Converte uma string numérica (apontada por RSI) em um inteiro (retornado em RAX).
; Suporta números negativos.
;----------------------------------------------------------------------------------------
string_to_int:
    xor rax, rax        ; Limpa RAX (acumulador para o número inteiro)
    xor rbx, rbx        ; Limpa RBX (usado como flag para indicar número negativo: 0 = positivo, 1 = negativo)
    
    mov cl, [rsi]       ; Carrega o primeiro caractere da string em CL
    cmp cl, '-'         ; Compara o primeiro caractere com o sinal de menos
    jne .s2i_check_digits ; Se não for '-', pula para verificar os dígitos
    mov rbx, 1          ; Se for '-', define a flag de negativo em RBX
    inc rsi             ; Avança RSI para pular o sinal '-'
    
.s2i_check_digits:
    movzx rdx, byte [rsi] ; Carrega o byte atual da string em RDX (MOVZX zera o restante do registrador)
    cmp dl, '0'         ; Compara o caractere com '0' (ASCII)
    jl .s2i_apply_sign  ; Se for menor que '0' (não é dígito), a conversão dos dígitos termina, aplica o sinal
    cmp dl, '9'         ; Compara o caractere com '9' (ASCII)
    jg .s2i_apply_sign  ; Se for maior que '9' (não é dígito), a conversão dos dígitos termina, aplica o sinal
    
    sub dl, '0'         ; Converte o caractere ASCII do dígito para seu valor numérico real
    imul rax, rax, 10   ; Multiplica o valor acumulado em RAX por 10 (prepara para o próximo dígito)
    add rax, rdx        ; Adiciona o valor do dígito atual a RAX
    inc rsi             ; Avança para o próximo caractere na string
    jmp .s2i_check_digits ; Continua o loop para processar o próximo dígito
    
.s2i_apply_sign:
    cmp rbx, 1          ; Verifica se a flag de negativo está setada
    jne .s2i_done       ; Se RBX não for 1, o número é positivo ou zero, então pula para o fim
    neg rax             ; Se RBX for 1, nega o valor em RAX para torná-lo negativo
    
.s2i_done:
    ret                 ; Retorna da função; o inteiro convertido está em RAX

;----------------------------------------------------------------------------------------
; PROCEDURE insertion_sort
; Ordena um array de 'n' inteiros usando o algoritmo Insertion Sort.
; O array é armazenado na seção .bss sob o rótulo 'array'.
;----------------------------------------------------------------------------------------
insertion_sort:
    mov ecx, 1          ; Inicializa o contador do loop externo (índice 'i' no Insertion Sort) com 1
                        ; (começa a partir do segundo elemento, array[1])
.sort_outer_loop:
    cmp ecx, n          ; Compara o índice 'i' com o tamanho total do array 'n'
    jge .sort_end       ; Se i >= n, o array está totalmente ordenado, sai do loop
    
    mov eax, [array + ecx*4] ; Carrega o valor do elemento atual (array[i]) em EAX (este é o "key" ou "chave")
    mov ebx, ecx        ; Copia o índice 'i' para EBX (EBX será o índice 'j' no Insertion Sort)
    dec ebx             ; Decrementa EBX para apontar para o elemento anterior a 'key' (array[i-1])
    
.sort_inner_loop:
    cmp ebx, 0          ; Compara o índice 'j' com 0
    jl .sort_insert_key ; Se j < 0 (alcançou o início do array), o lugar correto para a chave foi encontrado
    
    mov edx, [array + ebx*4] ; Carrega o valor do elemento array[j] em EDX
    cmp edx, eax        ; Compara array[j] com a "key" (EAX)
    jle .sort_insert_key ; Se array[j] <= key, o lugar correto para a chave foi encontrado (não precisa mais deslocar)
    
    ; Se array[j] > key, desloca array[j] uma posição para a direita
    mov edx, [array + ebx*4] ; (Essa linha é redundante, EDX já contém [array + ebx*4])
    mov [array + ebx*4 + 4], edx ; Move array[j] para array[j+1]
    
    dec ebx             ; Decrementa EBX para comparar com o próximo elemento à esquerda
    jmp .sort_inner_loop ; Continua o loop interno
    
.sort_insert_key:
    inc ebx             ; Incrementa EBX de volta para a posição correta onde a chave deve ser inserida
    mov [array + ebx*4], eax ; Insere a "key" (EAX) na posição correta do array
    
    inc ecx             ; Incrementa o contador do loop externo para processar o próximo elemento
    jmp .sort_outer_loop ; Continua o loop externo
    
.sort_end:
    ret                 ; Retorna da função

;----------------------------------------------------------------------------------------
; PROCEDURE is_prime
; Verifica se um número inteiro (passado em EAX) é primo.
; Retorna 1 em EAX se for primo, 0 se não for.
; Não suporta números negativos (considera-os não primos).
;----------------------------------------------------------------------------------------
is_prime:
    push rcx            ; Salva o valor de RCX na pilha (preserva o registrador para o chamador)
    push rdx            ; Salva o valor de RDX na pilha
    push rsi            ; Salva o valor de RSI na pilha
    
    mov esi, eax        ; Move o número a ser verificado (de EAX) para ESI (ESI contém 'n')
    
    cmp esi, 2          ; Compara 'n' com 2
    jl is_prime_not_prime ; Se n < 2, não é primo (0 e 1 não são primos, negativos também não)
    
    cmp esi, 2          ; Compara 'n' com 2 novamente
    je is_prime_is_prime ; Se n = 2, é primo (2 é o único primo par)
    
    ; Loop de verificação para divisores a partir de 2
    mov ecx, 2          ; Inicializa ECX com 2 (ECX será o divisor 'i')
is_prime_check_loop:
    mov eax, ecx        ; Copia o divisor 'i' para EAX
    imul eax, ecx       ; Calcula i * i (i^2). O resultado fica em EAX
    cmp eax, esi        ; Compara i^2 com 'n'
    ja is_prime_is_prime ; Se i^2 > n, significa que não há divisores entre 2 e sqrt(n), então 'n' é primo
    
    mov eax, esi        ; Carrega 'n' de volta em EAX para a operação de divisão
    xor edx, edx        ; Zera EDX (necessário para a instrução DIV)
    div ecx             ; Divide EAX (n) por ECX (i). O resto da divisão vai para EDX
    
    cmp edx, 0          ; Compara o resto com 0
    je is_prime_not_prime ; Se o resto for 0, 'n' é divisível por 'i', então 'n' não é primo
    
    inc ecx             ; Incrementa o divisor 'i'
    jmp is_prime_check_loop ; Continua o loop com o próximo divisor
    
is_prime_is_prime:
    mov eax, 1          ; Se o número é primo, define EAX como 1
    jmp is_prime_done   ; Pula para o final da função
    
is_prime_not_prime:
    mov eax, 0          ; Se o número não é primo, define EAX como 0
    
is_prime_done:
    pop rsi             ; Restaura o valor de RSI da pilha
    pop rdx             ; Restaura o valor de RDX da pilha
    pop rcx             ; Restaura o valor de RCX da pilha
    ret                 ; Retorna da função

;----------------------------------------------------------------------------------------
; PROCEDURE print_number
; Converte um inteiro (passado em RAX) em uma string e a imprime na saída padrão.
; Suporta números positivos e negativos.
;----------------------------------------------------------------------------------------
print_number:
    push rbx            ; Salva RBX na pilha (será usado para o ponteiro do buffer)
    
    cmp rax, 0          ; Compara o número em RAX com 0
    jge .positive_or_zero ; Se o número for maior ou igual a 0, é positivo ou zero, então pula
    
    ; Se o número é negativo, imprime o sinal de menos
    push rax            ; Salva o número original na pilha antes de alterá-lo
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, minus_char ; Ponteiro para o caractere '-'
    mov rdx, 1          ; Comprimento do caractere
    syscall             ; Executa a syscall para imprimir '-'
    pop rax             ; Restaura o número original da pilha
    neg rax             ; Nega o número para trabalhar com seu valor absoluto na conversão para string
    
.positive_or_zero:
    mov rbx, numbuf     ; Carrega o endereço base do buffer numérico em RBX
    add rbx, 20         ; Aponta RBX para o final do buffer (Numbuf tem 21 bytes, então índice 20)
                        ; A conversão para string será feita de trás para frente.
    mov rcx, 0          ; Inicializa RCX (contador de dígitos) com 0
    
    cmp rax, 0          ; Compara o número em RAX com 0
    jne .print_number_loop ; Se o número não for zero, entra no loop de conversão
    
    ; Caso especial: se o número é 0
    dec rbx             ; Decrementa RBX para apontar para a penúltima posição (onde '0' será armazenado)
    mov byte [rbx], '0' ; Coloca o caractere '0' no buffer
    mov rcx, 1          ; Define o comprimento da string como 1
    jmp .print_number_output ; Pula para a etapa de impressão
    
.print_number_loop:
    xor rdx, rdx        ; Zera RDX (necessário para a operação DIV)
    mov r8, 10          ; Define R8 como 10 (divisor para extrair dígitos)
    div r8              ; Divide RAX por R8. O quociente vai para RAX, o resto (dígito) para RDX
    
    add rdx, '0'        ; Converte o dígito numérico (em RDX) para seu caractere ASCII correspondente
    dec rbx             ; Decrementa RBX para apontar para a próxima posição no buffer (para a esquerda)
    mov [rbx], dl       ; Armazena o caractere do dígito no buffer
    inc rcx             ; Incrementa o contador de dígitos
    cmp rax, 0          ; Compara o quociente em RAX com 0
    jne .print_number_loop ; Se o quociente não for zero, continua o loop para extrair mais dígitos
    
.print_number_output:
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, rbx        ; Ponteiro para o início da string no buffer (onde RBX parou)
    mov rdx, rcx        ; Comprimento da string (número de dígitos)
    syscall             ; Executa a syscall para imprimir o número
    
    pop rbx             ; Restaura o valor de RBX da pilha
    ret                 ; Retorna da função

;----------------------------------------------------------------------------------------
; PROCEDURE print_array_full
; Imprime todos os elementos do array 'array', separados por um espaço, seguidos por uma nova linha.
;----------------------------------------------------------------------------------------
print_array_full:
    mov ecx, 0          ; Inicializa ECX (contador de loop/índice do array) com 0
.loop:
    cmp ecx, n          ; Compara o índice com o tamanho total do array
    jge .end            ; Se o índice for maior ou igual ao tamanho, todos os elementos foram impressos, sai do loop
    
    push rcx            ; Salva RCX na pilha para preservar o índice do loop
    
    ; CORREÇÃO: Usar movsx para carregar o número de 32 bits (dword) do array para o registrador de 64 bits (RAX)
    ; preservando o sinal, pra funcionar com negativos
    movsx rax, dword [array + ecx*4] 
    
    call print_number   ; Chama a função 'print_number' para imprimir o elemento atual do array
    
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, space      ; Ponteiro para o caractere de espaço
    mov rdx, 1          ; Comprimento do caractere de espaço
    syscall             ; Imprime um espaço após cada número
    
    pop rcx             ; Restaura RCX da pilha
    inc ecx             ; Incrementa o índice para o próximo elemento
    jmp .loop           ; Continua o loop
    
.end:
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, newline    ; Ponteiro para o caractere de nova linha
    mov rdx, 1          ; Comprimento do caractere de nova linha
    syscall             ; Imprime uma nova linha para finalizar a impressão do array
    ret                 ; Retorna da função
    
;----------------------------------------------------------------------------------------
; PROCEDURE _start
; Ponto de entrada principal do programa.
; Gerencia o fluxo de execução: leitura, ordenação e impressão.
;----------------------------------------------------------------------------------------
_start:
    ; 1. Pede para o usuário digitar os números
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, prompt_msg ; Ponteiro para a mensagem de prompt
    mov rdx, prompt_msg_len ; Comprimento da mensagem
    syscall             ; Imprime a mensagem para o usuário
    
    ; 2. Loop para ler os 10 números inteiros do usuário
    mov ecx, 0          ; Inicializa ECX (contador/índice) com 0
.read_loop:
    cmp ecx, n          ; Compara o índice com o número total de elementos a serem lidos
    jge .reading_done   ; Se todos os números foram lidos, sai do loop
    
    push rcx            ; Salva RCX na pilha (o valor do índice do array)
    
    mov rax, 0          ; Syscall number para 'read'
    mov rdi, 0          ; File descriptor para stdin (entrada padrão)
    mov rsi, input_buffer ; Ponteiro para o buffer onde a entrada será armazenada
    mov rdx, 16         ; Número máximo de bytes a serem lidos (tamanho do buffer)
    syscall             ; Executa a syscall para ler a entrada do usuário
    
    mov rsi, input_buffer ; Move o endereço do buffer de entrada para RSI (argumento para string_to_int)
    call string_to_int  ; Chama a função para converter a string lida em um inteiro (resultado em EAX)
    
    pop rcx             ; Restaura RCX da pilha
    mov [array + rcx*4], eax ; Armazena o inteiro convertido em EAX na posição correta do array
    
    inc ecx             ; Incrementa o contador para o próximo número
    jmp .read_loop      ; Continua o loop para ler mais números
    
.reading_done:
    ; 3. Imprime o array fornecido (original)
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, initial_msg ; Ponteiro para a mensagem "Array fornecido:"
    mov rdx, initial_msg_len ; Comprimento da mensagem
    syscall             ; Imprime a mensagem
    call print_array_full ; Chama a função para imprimir o conteúdo completo do array
    
    ; 4. Ordena o array usando o algoritmo Insertion Sort
    call insertion_sort ; Chama a função 'insertion_sort' para ordenar o array
    
    ; 5. Imprime o array completo ordenado
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, sorted_all_msg ; Ponteiro para a mensagem "Array ordenado:"
    mov rdx, sorted_all_msg_len ; Comprimento da mensagem
    syscall             ; Imprime a mensagem
    call print_array_full ; Chama a função para imprimir o array agora ordenado
    
    ; 6. Imprime a mensagem para os números primos
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, sorted_msg ; Ponteiro para a mensagem "Numeros primos:"
    mov rdx, sorted_msg_len ; Comprimento da mensagem
    syscall             ; Imprime a mensagem
    
    ; 7. Itera sobre o array ordenado e imprime apenas os números primos
    mov ecx, 0          ; Inicializa ECX (contador/índice) com 0
.print_primes_loop:
    cmp ecx, n          ; Compara o índice com o tamanho total do array
    jge .exit_program   ; Se todos os elementos foram verificados, sai do loop e termina o programa
    
    push rcx            ; Salva RCX na pilha (preserva o índice do array)

    ; CORREÇÃO: Usar movsx para carregar o número de 32 bits (dword) do array para o registrador de 64 bits (RAX)
    ; e estender o sinal para RAX. A função is_prime espera seu argumento em EAX.
    movsx rax, dword [array + ecx*4] 
    
    ; A função is_prime espera o número em EAX. O movsx acima já colocou o valor corretamente.
    call is_prime       ; Chama a função 'is_prime' para verificar se o número atual é primo (resultado em EAX: 1=primo, 0=não)
    
    cmp eax, 1          ; Compara o resultado de is_prime com 1
    jne .skip_print     ; Se o resultado não for 1 (não é primo), pula para .skip_print
    
    ; CORREÇÃO: Se o número for primo, carregue-o novamente em RAX usando movsx antes de chamar print_number.
    ; Isso garante que o valor correto (incluindo o sinal) seja passado para a função de impressão.
    movsx rax, dword [array + ecx*4] 
    
    call print_number   ; Chama 'print_number' para imprimir o número primo
    
    mov rax, 1          ; Syscall number para 'write'
    mov rdi, 1          ; File descriptor para stdout
    mov rsi, newline    ; Ponteiro para o caractere de nova linha
    mov rdx, 1          ; Comprimento do caractere de nova linha
    syscall             ; Imprime uma nova linha após cada número primo
    
.skip_print:
    pop rcx             ; Restaura RCX da pilha
    inc ecx             ; Incrementa o índice para o próximo elemento do array
    jmp .print_primes_loop ; Continua o loop
    
.exit_program:
    ; Finaliza o programa
    mov rax, 60         ; Syscall number para 'exit'
    xor rdi, rdi        ; Define o código de saída para 0 (sucesso)
    syscall             ; Executa a syscall para sair do programa
