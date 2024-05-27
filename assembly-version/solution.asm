section .data
    ;renomeação do das operações utilizadas pra ficar mais fácil de chamar
    EOL         equ 0xA ; Quebra de linha
    NULL        equ 0xD ; Final de linha
    sys_call    equ 0x80 ; interrupção do sistema e envio de informações
    ret_exit    equ 0x0 ; operação de finalização
    sys_exit    equ 0x1 ; operação de saída
    sys_write   equ 0x4 ; operação de escrita
    sys_read    equ 0x3 ; operação de leitura
    STDIN       equ 0x0 ; entrada padrão
    STDOUT      equ 0x1 ; saída padrão

    ; Mensagem de input de quantidade de discos
    INPUT_DISK_MSG db "Enter the number of disks for the problem: "
    len equ $-INPUT_DISK_MSG

    ; Mensagem de erro, o número de discos deve ser um numero positivo e maior que 0
    INPUT_ERROR_MESSAGE db "Error: Invalid number entered. The number of disks must be > 0", EOL, 0
    error_len equ $-INPUT_ERROR_MESSAGE

    ; Mensagem para exibir o número de movimentos
    num_cal db "Minimum number of movements required is:", 0
    len_cal equ $-num_cal

    finalizar db "Algorithm Concluded!", EOL, 0
    finalizar_len equ $-finalizar

    buffer db '', 0, EOL
    buffer_len equ $ - buffer
    num_buffer db 5, 0, EOL    ; Buffer para armazenar o número convertido em string

    ; Mensagem para exibir o movimento dos discos
    OUTPUT_MESSAGE:     db "Move disk "
    DISK_NUMBER:        db  " "           ; disco a ser movido
                        db " from "       ; de
    TOWER_SOURCE:       db " "            ; torre de saída
                        db " to "         ; para
    TOWER_DESTINATION:  db " ", EOL       ; torre de destino
    OUTPUT_LENGTH       equ $-OUTPUT_MESSAGE

section .bss
    NUM_DISKS resb 3 ; buffer para a entrada do número de discos

section .text
    global _start

_start:
    ; Exibir a mensagem para o usuário
    mov eax, sys_write
    mov ebx, STDOUT
    mov ecx, INPUT_DISK_MSG
    mov edx, len
    int sys_call

    ; Ler a entrada do usuário
    mov eax, sys_read
    mov ebx, STDIN
    mov ecx, NUM_DISKS
    mov edx, 2                     ; tamanho da entrada (ler até 2 algarismos)
    int sys_call

    ; Verificar e converter a string para inteiro
    call converter_valor

    ; Exemplo de uso da função:
    ; mov ebx, 5          ; Suponha que queremos calcular (2^5) - 1
    ; Movendo o valor de entrada do usuário para ebx
    mov ebx, eax
    call power_of_two_minus_one

    ; Converte o número em eax para string em num_buffer
    mov edi, num_buffer
    call int_to_string

    ; Imprimir movimentos
    mov eax, sys_write          ; syscall number for sys_write
    mov ebx, STDOUT             ; file descriptor 1 is stdout
    mov ecx, num_cal
    mov edx, len_cal
    int sys_call                 ; chamar o kernel

    ; Imprimir o número
    mov eax, sys_write           ; syscall number for sys_read
    mov ebx, STDOUT              ; file descriptor 0 is stdin
    mov ecx, buffer
    mov edx, 5                   ; tamanho da entrada (ler até 2 algarismos)
    int sys_call                 ; chamar o kernel

    ; Verificar e converter a string para inteiro
    call converter_valor

    ; Empurrando as torres e a quantidade de discos na pilha de referencia para que fiquem em ordem
    push dword 2                  ; Torre Auxiliar
    push dword 3                  ; Torre Destino
    push dword 1                  ; Torre Origem
    push eax                      ; Número de discos inserido pelo usuário

    call tower_of_hanoi

    ; Exibir a mensagem de finalização do algoritmo
    mov eax, sys_write
    mov ebx, STDOUT
    mov ecx, finalizar
    mov edx, finalizar_len
    int sys_call
    call exit

power_of_two_minus_one:
    ; Calcular 2^valor - 1
    ; O valor está em ebx
    mov ecx, ebx        ; Guardar valor em ecx para usar como contador de deslocamento
    mov eax, 1          ; Começar com 2^0, que é 1
    shl eax, cl         ; Deslocar eax à esquerda por cl (valor de ecx, que é o valor de ebx)
    dec eax             ; Subtrair 1 de eax
    ret                 ; Retornar, resultado está em eax

int_to_string:
    ; Converte o valor em eax para string em edi (num_buffer)
    mov ecx, 10         ; divisor para obter dígitos
    mov esi, edi        ; guardar o início do buffer

.int_to_string_loop:
    xor edx, edx        ; limpar edx
    div ecx             ; dividir eax por 10
    add dl, '0'         ; converter o resto em caractere ASCII
    dec edi             ; mover o ponteiro do buffer para trás
    mov [edi], dl       ; armazenar o caractere no buffer
    test eax, eax       ; verificar se eax é zero
    jnz .int_to_string_loop   ; se não, continuar
    mov ecx, esi        ; recuperar o início do buffer original
    sub ecx, edi        ; calcular o comprimento da string
    mov eax, ecx        ; colocar o comprimento da string em eax
    ret

converter_valor:
    lea esi, [NUM_DISKS]
    mov ecx, 2 ; tamanho máximo da entrada
    call string_to_int
    cmp eax, 0
    jl invalid_number ; se eax < 0, é um número inválido
    ret

invalid_number:
    ; Exibir a mensagem de erro
    mov eax, sys_write
    mov ebx, STDOUT
    mov ecx, INPUT_ERROR_MESSAGE
    mov edx, error_len
    int sys_call

    ; Finalizar o programa com erro
    mov eax, sys_exit
    mov ebx, 1 ; código de erro
    int sys_call

; Função de conversão de string para inteiro
string_to_int:
    xor ebx, ebx ; limpar ebx para o acumulador
    xor eax, eax ; limpar eax para o valor de retorno

.prox_digito:
    movzx eax, byte [esi]
    inc esi
    cmp al, EOL
    je end_convert
    cmp al, '0'
    jl invalid_input ; se o caractere for menor que '0', é inválido
    sub al, '0'
    imul ebx, ebx, 10
    add ebx, eax ; ebx = ebx*10 + eax
    loop .prox_digito ; while (--ecx)
    mov eax, ebx
    ret

invalid_input:
    mov eax, -1 ; retornar -1 para indicar erro
    ret

end_convert:
    mov eax, ebx
    ret

tower_of_hanoi:
    ; Parâmetros: (disk_number, source, auxiliar, destino)
    ; [ebp+8] número de discos restantes na Torre de origem
    ; [ebp+12] = Torre de origem
    ; [ebp+16] = Torre de auxiliar
    ; [ebp+20] = Torre de destino

    push ebp                      ; empurra o registrador ebp na pilha
    mov ebp, esp                  ; aponta o ponteiro do topo da pilha para a base

    mov eax, [ebp+8]              ; move para o registrador ax o numero de discos na Torre de origem

    cmp eax, 0                    ; verifica se Ainda há disco a ser movido na torre de origem
    je end_procedure              ; caso nao tenha nunhum disco, vai finalizar o procedimento recursivo

    ; Primeira chamada recursiva
    push dword [ebp+16]           ; Empurra a torre Auxiliar
    push dword [ebp+20]           ; Empurra a torre Destino
    push dword [ebp+12]           ; Empurra a torre Origem

    dec eax                       ; tira o disco do topo da torre de origem para ser colocado outra torre
    push dword eax                ; empurra o numero de discos restantes a serem movidos na Torre de origem

    call tower_of_hanoi

    ; Printando os movimentos
    push dword [ebp+16]           ; empilha o torre de Saida
    push dword [ebp+12]           ; empilha o torre de Ida
    push dword [ebp+8]            ; empilha o disco
    call print_disk_movement

    ; Segunda chamada recursiva
    push dword [ebp+12]           ; Empurra a torre Origem
    push dword [ebp+16]           ; Empurra a torre Auxiliar
    push dword [ebp+20]           ; Empurra a torre Destino

    mov eax, [ebp+8]              ; move para o registrador eax o número de discos restantes

    dec eax                       ; tira o disco do topo da torre de origem para ser colocado outra torre
    push dword eax                ; empurra o numero de discos restantes a serem movidos na Torre de origem

    call tower_of_hanoi

end_procedure:
    mov esp, ebp
    pop ebp
    ret

print_disk_movement:
    push ebp                     ; empurra o registrador ebp na pilha (para ser a base)
    mov ebp, esp                 ; aponta o ponteiro do topo da pilha (esp) para a base

    mov eax, [ebp+8]             ; coloca no registrador eax o disco a ser movido
    add al, 48                   ; conversão na tabela ASCII
    mov [DISK_NUMBER], al        ; coloca o valor em [DISK_NUMBER] para o print

    mov eax, [ebp+12]            ; coloca no registrador eax a torre de onde o disco saiu
    add al, 64                   ; conversão na tabela ASCII
    mov [TOWER_SOURCE], al       ; coloca o valor em [TOWER_SOURCE] para o print

    mov eax, [ebp+16]            ; coloca no registrador eax a torre de onde o disco foi
    add al, 64                   ; conversão na tabela ASCII
    mov [TOWER_DESTINATION], al  ; coloca o valor em [TOWER_DESTINATION] para o print

    mov edx, OUTPUT_LENGTH
    mov ecx, OUTPUT_MESSAGE
    mov ebx, STDOUT
    mov eax, sys_write
    int sys_call

    call end_procedure

exit:
    mov eax, sys_exit
    mov ebx, ret_exit
    int sys_call
