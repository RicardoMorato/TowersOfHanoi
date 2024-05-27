segment .data ; segmento de dados
    ;renomeação do das operações utilizadas pra ficar mais fácil de chamar
    EOL          equ 0xA ; Quebra de linha
    NULL        equ 0xD ; Final de linha
    sys_call    equ 0x80 ; interrupção do sistema e envio de informações
    ret_exit    equ 0x0 ; operação de finalização
    sys_exit    equ 0x1 ; operação de saída
    sys_write   equ 0x4 ; operação de escrita
    sys_read    equ 0x3 ; operação de leitura
    STDIN       equ 0x0 ; entrada padrão
    STDOUT      equ 0x1 ; saída padrão

section .data
    ; Definindo a mensagem

        msg:              db        "disc: "
        disco:            db        " "
                          db        "   "
        torre_saida:      db        " "
                          db        " -> "
        torre_ida:        db        " ", EOL

        lenght            equ       $-msg

section .text                         ; Usada para armazenar o código executável do nosso programa
    global _start

_start:
    mov eax, 3                    ; Definindo o número de discos que terá na torre A

    ; Empurrando as torres e a quantidade de discos na pilha de referencia para que fiquem em ordem
    push dword 2                  ; Torre Auxiliar
    push dword 3                  ; Torre Destino
    push dword 1                  ; Torre Origem
    push eax                      ; Número inicial de discos

    call tower_of_hanoi
    call exit

tower_of_hanoi:
    ; Parâmetros: (disk_number, source, auxiliar, destino)
    ;[ebp+8] número de discos restantes na Torre de origem
    ;[ebp+12] = Torre de origem
    ;[ebp+16] = Torre de auxiliar
    ;[ebp+20] = Torre de destino

    push ebp                      ; empurra o registrador ebp na pilha (para ser a base)
    mov ebp,esp                   ; aponta o ponteiro do topo da pilha (esp) para a base

    mov eax, [ebp+8]              ; move para o registrador ax o numero de discos na Torre de origem

    cmp eax, 0                    ; verifica se Ainda há disco a ser movido na torre de origem
    je end_procedure              ; caso nao tenha nunhum disco, pula finalizar o procedimento recursivo

    ; Primeira recursão
    push dword [ebp+16]           ; Empurra a torre Auxiliar
    push dword [ebp+20]           ; Empurra a torre Destino
    push dword [ebp+12]           ; Empurra a torre Origem

    dec eax                       ; tira o disco do topo da torre de origem para ser colocado outra torre
    push dword eax                ; empurra o numero de discos restantes a serem movidos na Torre de origem

    call tower_of_hanoi                    ; chama a label tower_of_hanoi para guardar a linha de retorno (recursao)

    ; Printando os movimentos
    push dword [ebp+16]           ; empilha o torre de Saida
    push dword [ebp+12]           ; empilha o torre de Ida
    push dword [ebp+8]            ; empilha o disco

    call imprime                  ; chama a label para imprimir os movimentos

    ; Segunda recursão
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

imprime:

    push ebp                      ; empurra o registrador ebp na pilha (para ser a base)
    mov ebp, esp                  ; aponta o ponteiro do topo da pilha (esp) para a base

    mov eax, [ebp + 8]            ; coloca no registrador ax o disco a ser movido
    add al, 48                    ; conversao na tabela ASCII
    mov [disco], al               ; coloca o valor no [disco] para o print

    mov eax, [ebp + 12]           ; coloca no registrador ax a torre de onde o disco saiu
    add al, 64                    ; conversao na tabela ASCII
    mov [torre_saida], al         ; coloca o valor no [torre_saida] para o print

    mov eax, [ebp + 16]           ; coloca no registrador ax a torre de onde o disco foi
    add al, 64                    ; conversao na tabela ASCII
    mov [torre_ida], al           ; coloca o valor no [torre_ida] para o print

    mov edx, lenght               ; tamanho da mensagem
    mov ecx, msg                  ; mensagem em si
    mov ebx, 1                    ; dá permissão para a saida
    mov eax, 4                    ; informa que será uma escrita
    int 128                       ; Interrupção para kernel

    call end_procedure

exit:
    mov eax, sys_exit
    mov ebx, ret_exit
    int sys_call
