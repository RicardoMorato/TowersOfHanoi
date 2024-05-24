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
 
section .data ; termos constantes
    msg db "Enter the number of disks for the problem: ", LF ; mensagem a ser exibida
    len equ $-msg ; tamanho da mensagem
    error_msg db "Error: Invalid number entered. The number of disks must be > 0", LF, 0; mensagem de erro, a deve ser um numero positivo
    error_len equ $-error_msg
 
section .bss ; segmento de dados não inicializados // **variáveis**
    num_disks resb 3 ; buffer para a entrada do número 
 
section .text ; começando o programa
    global _start
_start:
 
    ; Exibir a mensagem para o usuário
    mov eax, sys_write
    mov ebx, STDOUT
    mov ecx, msg
    mov edx, len
    int sys_call
 
    ; Ler a entrada do usuário
    mov eax, sys_read
    mov ebx, STDIN
    mov ecx, num_disks
    mov edx, 2 ; tamanho da entrada (ler até 2 algarismos)
    int sys_call
 
    ; Verificar e converter a string para inteiro
    call converter_valor
 
    ; Finalizar o programa
    mov eax, sys_exit
    xor ebx, ebx
    int sys_call
 
; Função para verificar e converter a entrada de string para inteiro
converter_valor:
    lea esi, [num_disks]
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