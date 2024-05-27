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
    msg_disk db "Enter the number of disks for the problem: "
    len equ $-msg_disk

    ; Mensagem de erro, o número de discos deve ser um numero positivo e maior que 0
    error_msg db "Error: Invalid number entered. The number of disks must be > 0", EOL, 0
    error_len equ $-error_msg

    ; Mensagem para exibir o movimento dos discos
    msg:                db "Move disk "
    disk:               db  " "           ; disco a ser movido
                        db " from "       ; de
    tower_source:       db " "            ; torre de saída
                        db " to "         ; para
    tower_destination:  db " ", EOL       ; torre de destino
    output_length       equ $-msg

section .bss
    num_disks resb 3 ; buffer para a entrada do número de discos
    num_disks_int resd 1 ; armazenamento do número de discos como inteiro

section .text
    global _start

_start:
    ; Exibir a mensagem para o usuário
    mov eax, sys_write
    mov ebx, STDOUT
    mov ecx, msg_disk
    mov edx, len
    int sys_call

    ; Ler a entrada do usuário
    mov eax, sys_read
    mov ebx, STDIN
    mov ecx, num_disks
    mov edx, 2                     ; tamanho da entrada (ler até 2 algarismos)
    int sys_call

    ; Verificar e converter a string para inteiro
    call converter_valor

    ; Empurrando as torres e a quantidade de discos na pilha de referencia para que fiquem em ordem
    push dword 2                  ; Torre Auxiliar
    push dword 3                  ; Torre Destino
    push dword 1                  ; Torre Origem
    push eax                      ; Número de discos inserido pelo usuário

    call tower_of_hanoi
    call exit

; Função para verificar e converter a entrada de string para inteiro
converter_valor:
    lea esi, [num_disks]
    mov ecx, 2 ; tamanho máximo da entrada
    call string_to_int
    cmp eax, 0
    jl invalid_number ; se eax < 0, é um número inválido
    ret

invalid_number:
    ; Exibir a mensagem de erro
    mov eax, sys_write
    mov ebx, STDOUT
    mov ecx, error_msg
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
    jb invalid_input ; se o caractere for menor que '0', é inválido
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
    je end_procedure              ; caso nao tenha nunhum disco, pula finalizar o procedimento recursivo

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

    call tower_of_hanoi           ; chama a label tower_of_hanoi para guardar a linha de retorno (recursao)

end_procedure:
    mov esp, ebp
    pop ebp
    ret

print_disk_movement:
    push ebp                     ; empurra o registrador ebp na pilha (para ser a base)
    mov ebp, esp                 ; aponta o ponteiro do topo da pilha (esp) para a base

    mov eax, [ebp+8]             ; coloca no registrador eax o disco a ser movido
    add al, 48                   ; conversão na tabela ASCII
    mov [disk], al               ; coloca o valor em [disk] para o print

    mov eax, [ebp+12]            ; coloca no registrador eax a torre de onde o disco saiu
    add al, 64                   ; conversão na tabela ASCII
    mov [tower_source], al       ; coloca o valor em [tower_source] para o print

    mov eax, [ebp+16]            ; coloca no registrador eax a torre de onde o disco foi
    add al, 64                   ; conversão na tabela ASCII
    mov [tower_destination], al  ; coloca o valor em [tower_destination] para o print

    mov edx, output_length
    mov ecx, msg
    mov ebx, STDOUT
    mov eax, sys_write
    int sys_call

    call end_procedure

exit:
    mov eax, sys_exit
    mov ebx, ret_exit
    int sys_call
