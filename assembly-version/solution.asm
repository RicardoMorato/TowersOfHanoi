segment .data ; segmento de dados
    ;renomeação do das operações utilizadas pra ficar mais fácil de chamar
    LF          equ 0xA ; Quebra de linha
    NULL        equ 0xD ; Final de linha
    sys_call    equ 0x80 ; interrupção do sistema e envio de informações
    ret_exit    equ 0x0 ; operação de finalização
    sys_exit    equ 0x1 ; operação de saída
    sys_write   equ 0x4 ; operação de escrita
    sys_read    equ 0x3 ; operação de leitura
    STDIN       equ 0x0 ; entrada padrão
    STDOUT      equ 0x1 ; saída padrão

section .data
    msg db "Move disk ", 0
    from_msg db " from ", 0
    to_msg db " to ", 0
    newline db 10

    error_msg db "Error: Invalid number entered. The number of disks must be > 0", LF, 0; mensagem de erro, a deve ser um numero positivo
    error_len equ $-error_msg

    msg_test db "KKKKKKKKK ", LF ; mensagem a ser exibida
    len equ $-msg_test ; tamanho da mensagem

section .bss
    digit resb 4  ; Buffer para armazenar o número do disco como string
    disk_number resb 4
    source resb 1
    destination resb 1
    auxiliar resb 1

section .text
    global _start

_start:
    ; Chamada inicial para a função tower_of_hanoi
    mov dword [disk_number], 3       ; Defina o número de discos
    mov byte [source], 'A'
    mov byte [destination], 'C'
    mov byte [auxiliar], 'B'

    mov edx, [disk_number]
    push edx ; Salva valor de disk_number na pilha

    movzx eax, byte [source]
    movzx ecx, byte [destination]
    movzx ebx, byte [auxiliar]
    call tower_of_hanoi
    call exit

tower_of_hanoi:
    push ebp
    mov ebp, esp

    ; Parâmetros: (disk_number, source, destination, auxiliar)
    ; [edx] = disk_number
    ; [eax] = source
    ; [ecx] = destination
    ; [ebx] = auxiliar

    ; Caso base: if disk_number <= 0
    cmp edx, 0
    jle end_recursion

    ; Recursively call tower_of_hanoi(disk_number - 1, source, auxiliar, destination)
    dec edx
    movzx eax, byte [source]
    movzx ecx, byte [destination]
    movzx ebx, byte [auxiliar]
    call tower_of_hanoi

    ; Print "MOVE DISK N TO Y FROM Z" -> Não tá rolando, tá printando a msg_test
    mov eax, sys_write
    mov ebx, STDOUT
    mov ecx, msg_test
    mov edx, len
    int sys_call

    call atualiza_num_disks

    movzx eax, byte [source]
    movzx ecx, byte [destination]
    movzx ebx, byte [auxiliar]
    call tower_of_hanoi

atualiza_num_disks:
    pop edx
    dec edx

    cmp edx, 0
    jge .push_edx

    .push_edx:
        push edx

end_recursion:
    mov esp, ebp
    pop ebp
    ret

exit:
    mov eax, 1  ; sys_exit
    xor ebx, ebx
    int 0x80

; Função para verificar e converter a entrada de string para inteiro
converter_valor:
    lea esi, [disk_number]
    mov ecx, 2 ; tamanho máximo da entrada
    call string_to_int
    test eax, eax
    js invalid_number ; se eax < 0, é um número inválido
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
    cmp al, LF
    je end_convert
    cmp al, '0'
    jbe invalid_input ; se o caractere for menor ou igual a '0', é inválido
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