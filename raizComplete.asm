name "raiz"
org 100h

;Ir para o inicio do programa
jmp start
start:

;----------------------------------------------------------------
;-------------------------Radicando--------------------------------
;----------------------------------------------------------------

;Escreve a mensagem de introducao do dividendo
mensagemRadicando:
    mov dl, 10; New line ASCII
    mov ah, 02h; Escreve um caracter
    int 21h; Do it
    mov dl, 13
    mov ah, 02h
    int 21h

    lea dx, msgRadicando; Endereco da source
    mov ah, 9h; Escreve string
    int 21h
    mov radicandoAux, 1
    jmp numRadicando

    ;Vai buscar o radicando, 1 digito de cada vez, ou seja cada
    ;iteracao vai buscar um digito
numRadicando:
    mov ah,1h; Input de um caracter
    int 21h
    mov dl,al

    cmp dl, 0Dh; Compara com o valor introduzido pela tecla ENTER(0DH)
    jz checkRadicando; Caso o utilizador carregue no ENTER

    mov bx, radicandoArrayIndex; Numero de digitos atuais
    sub dl, 48; Converte para decimal
    mov radicandoArray[bx],dl; Vai por os elementos no array de digitos
    ; por ordem, arr = (pos0,pos1,...)
    inc radicandoArrayLength; Aumenta o valor do numero de digitos
    inc radicandoArrayIndex
    loop numRadicando

;Converte o array dos digitos do radicando para um numero
;decimal ex {1,2,3,4} = 1234
checkRadicando:
    xor ax,ax; limpa o registo ax (0 xor 0 = 0; 1 xor 1 = 0)
    mov bx, radicandoArrayIndex
    dec bx
    cmp bx, 5;Se index >= 5, o numero > 16 bit porque o max e
    ;65535(5 digitos) e o index vai de 0-(index-1)
    jae ErroMaior
    mov al, radicandoArray[bx]; Digito na posicao do index
    cmp al, 0; Vai para erro caso o caracter introduzido seja
    ;menor que 0
    jb msgInvalido
    cmp al, 9; Vai para erro caso o caracter introduzido seja
    ;maior que 9
    ja msgInvalido
    mov bx, radicandoAux
    mul bx; Caso a introducao do numero em ax ativar a CF
    ;(carry flag), ir para msgErro porque o numero e > 16bit
    jc ErroMaior
    add radicandoSemVirgula, ax; Adiciona ao valor atual do radicando
    jc ErroMaior
    dec radicandoArrayIndex

    cmp radicandoArrayIndex, 0; Se 0, significa que ja nao
    ;existe mais digitos para ir buscar no array
    jz raiz

    mov ax, 10
  	mul bx; +1 casa decimal porque as casas decimais estao
  	;definidas de acordo com 10^x onde x e a sucessao de casas
  	mov radicandoAux, ax; Move o valor atual da casa decimal para o aux
  	loop checkRadicando

;Escreve a mensagem de erro caso o numero introduzido contenha
;caracteres nao validos
msgInvalido:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    lea dx, msgCharInvalido
    mov ah,9h; Escreve string
    int 21h
    jmp ResetVars; Ir para reset das vars

;Escreve a mensagem de erro caso o numero introduzido
;seja > 16bits
ErroMaior:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13

    lea dx, msgErroMaior
    mov ah,9h
    int 21h

    mov radicandoAux, 0
    mov radicandoArrayIndex, 0
    mov radicandoArrayLength, 0

    jmp mensagemRadicando

;Repoe os valores necessarios para os seus valores originais
ResetVars:
    mov radicandoAux, 0
    mov radicandoArrayIndex, 0
    mov radicandoArrayLength, 0
    jmp mensagemRadicando; Voltar a mostra a msg de Introducao
    ;para voltar a pedir o radicando

;----------------------------------------------------------------
;----------------------------Raiz--------------------------------
;----------------------------------------------------------------

;Verificao inicial
raiz:
    mov radicandoAux, 0
    mov radicandoArrayIndex, 0

    ; verificar se o numero de digitos do radicando e par ou impar
    mov ax,radicandoArrayLength
    and ax,1
    jp sePar ; se par
    jnp seImpar ; se impar

; se for par vai buscar os dois digitos mais significativos do radicando = Y
sePar:
    xor ax, ax
    xor bx, bx
    mov al, radicandoArray[0]
    mov bl, radicandoArray[1]
    mov cx, 10
    mul cx
    add ax, bx
    mov radicandoAux, ax
    mov radicandoArrayIndex, 2
    jmp quadradoPerfeito

; se for impar vai buscar apenas o digito mais significativo do radicando = Y
seImpar:
    mov al, radicandoArray[0]
    mov radicandoAux, ax
    mov radicandoArrayIndex, 1
    jmp quadradoPerfeito

; encontrar o maior quadrado perfeito de um numero que e menor que Y
; subtrair o valor de x*x ao Y
; a nossa implementacao faz x*x > Y => x = x - 1
quadradoPerfeito:
    mov ax, x
    mul ax
    cmp ax, radicandoAux
    jg quadradoPerfeito_decX
    inc x
    loop quadradoPerfeito
    quadradoPerfeito_decX:
        dec x
        mov ax, x
        mov resultado[0], ax
        ; subtrair o x^2 ao radicando
        mul ax
        sub radicandoAux, ax

; coloca o resultado em numero inteiro
; exemplo: resultado = 24,67 => 2467
radicandoInteiro:
    xor ax, ax
    mov ax, resultado[0]

    mov cx, tamanhoDecimal
    cmp cx, 1
    jl radicandoInteiro_continuar

    radicandoInteiro_mulTamanho:
        mov dx, 10
        mul dx
        dec cx
        cmp cx, 1
        jge radicandoInteiro_mulTamanho

    radicandoInteiro_continuar:
        add ax, resultado[2]
        mov radicandoSemVirgula, ax
    jmp descerParcela


; descer parcela ou algarismo seguinte do radicando
; senao existir parcela seguinte desce 00
descerParcela:
        ; desce 00
        mov cx, 100
        mov ax, radicandoAux
        mul cx
        ; overflow na introducao de mais dois digitos ao radicandoAux
        jo mostrarResultado
        mov cx, radicandoArrayLength
        mov bx, radicandoArrayIndex
        cmp cx, bx
        je equacaoDecimal ; se nao houve parcela para descer não continua

        ; adiciona o primero algarismo da parcela
        mov cl, radicandoArray[bx]
        mov radicandoAux, ax
        mov ax, cx
        mov dx, 10
        mul dx
        add radicandoAux, ax
        mov ax, radicandoAux
        inc bx
        mov radicandoArrayIndex, bx

        ; adiciona o segundo algarismo da parcela
        mov cl, radicandoArray[bx]
        add ax, cx
        mov radicandoAux, ax
        inc bx
        mov radicandoArrayIndex, bx
        jmp equacao

; se so descer 00 incrementa o tamanhoDecimal, assinalando que se esta a trabalhar na parte decimal
equacaoDecimal:
    mov radicandoAux, ax
    mov dx, tamanhoDecimal
    cmp dx, 3
    je mostrarResultado
    inc tamanhoDecimal

; encontrar o maior x tal que (20*radicandoSemVirgula + x) * x <= radicandoAux
equacao:
    xor dx, dx
    mov x, dx

; loop para encontrar esse x
equacaoLoop:
    inc x
    mov ax, radicandoSemVirgula
    mov dx, 20
    mul dx
    add ax, x
    mul x
    mov bx, radicandoAux
    ; overflow e carry ao se realizar a equacao
    jnc equacaoLoop_continuarCMP
    jo mostrarResultado
    equacaoLoop_continuarCMP:
        cmp ax, bx
        jbe equacaoLoop
        dec x
        xor ax, ax
        mov ax, radicandoSemVirgula
        mov dx, 20
        mul dx
        add ax, x
        mul x
        sub radicandoAux, ax
        ; introducao do x na parte apropriada - inteira ou decimal
        cmp tamanhoDecimal, 0
        je resultadoInteiro
        jne resultadoDecimal

; introduz o x no resultado da parte inteira
resultadoInteiro:
    xor ax, ax
    mov ax, resultado[0]
    mov bx, 10
    mul bx
    add ax, x
    mov resultado[0], ax
    jmp radicandoInteiro
; introduz o x no resultado da parte decimal
resultadoDecimal:
    xor ax, ax
    mov ax, resultado[2]
    mov bx, 10
    mul bx
    add ax, x
    mov resultado[2], ax

    ; Se raiz de 123=11,090, isto traz problemas na insercao devido ao zero
    ; mais significativo nao dar para ser inserido no array juntamente com os
    ; outros digitos da parte decimal ja que 090 = 90
    ;
    ; Vemos se estamos a colocar o zero nessa posicao e se tivermos coloca-se
    ; uma "flag" que indica que a parte decimal tem um zero no inicio
    cmp ax, 0
    jne radicandoInteiro
    cmp tamanhoDecimal, 1
    jne radicandoInteiro
    mov cx, 1
    mov resultado[4], cx
    jmp radicandoInteiro

;----------------------------------------------------------------
;-------------------------Resultado------------------------------
;----------------------------------------------------------------

;Apresenta o resultado na consola
mostrarResultado:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h

    lea dx, msgResultado; Endereco da source
    mov ah,9h; Escreve string
    int 21h

    ; apresenta a parte inteira
    xor ax, ax
    mov ax, resultado[0]
    call printResultado

    ; virgula
    mov dl, 2Ch ; hex para o caracter virgula
    mov ah,2h
    int 21h

    ; se tiver a flag onde a parte tem decimal tem zero no inicio
    ; e apresenta um zero antes de mostrar a parte decimal
    cmp resultado[4], 1
    jne mostrarResultadoDecimal
    xor ax, ax
    mov dx, 30h
    mov ah,2h
    int 21h

    ; apresenta a parte decimal
    mostrarResultadoDecimal:
      xor ax, ax
      mov ax, resultado[2]
      call printResultado

;Para o programa
stop:
    ret; return

;----------------------------------------------------------------
;-----------------------Procedimentos----------------------------
;----------------------------------------------------------------

; apresenta na consola o numero que estiver em ax
printResultado PROC
    mov bx, 10
    xor cx, cx

    ; faz push para a stack os digitos do numero em ax um a um
    ; atraves da divisao por 10 que faz com a parte decimal fique
    ; em dx
    pushLoop:
        xor dx, dx
        div bx
        push dx
        inc cx
        cmp ax, 0
        jne pushLoop

    ; pop dos elementos na stack e apresenta-os na consola
    popPrintLoop:
        mov ah,2h
        pop dx
        or dx, 30h ; conversao de decimal para hex
        int 21h
        dec cx
        cmp cx, 0
        jne popPrintLoop
ret
printResultado ENDP

;----------------------------------------------------------------
;-------------------------Variaveis------------------------------
;----------------------------------------------------------------

; Variaveis
tamanhoDecimal dw 0 ; tamanho da parte decimal do resultado
radicandoSemVirgula dw 0
radicandoArray db 5 Dup(0) ; arrray dos digitos do radicando
radicandoArrayLength dw 0 ; tamanho do array
radicandoArrayIndex dw 0 ; posicao do proximo digito a ser usado
radicandoAux dw 0, 0 ; digito(s) do radicando a ser usados e auxiliar a ser usado nas subtracoes com o radicando
resultado dw 0, 0, 0 ; (parte inteira, parte decimal, flag de zero no algarismo mais significativo)
x dw 0 ; auxiliar

; Mensagens a apresentar
msgRadicando db "Insira o radicando:  $"
msgErroMaior db "Erro. O valor e superior a 2 bytes$"
msgCharInvalido db "Valor contem caracteres nao validos. Insira novamente (0-9)$"
msgResultado db "Resultado = $"
