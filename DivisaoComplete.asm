name "divisao"
org 100h

;Ir para o inicio do programa
jmp start
start:    

;----------------------------------------------------------------
;-------------------------Dividendo------------------------------
;----------------------------------------------------------------  

;Escreve a mensagem de introducao do dividendo
mensagemDividendo:
    mov dl, 10; New line ASCII
    mov ah, 02h; Escreve um caracter
    int 21h; Do it
    mov dl, 13
    mov ah, 02h
    int 21h
    
    lea dx, msgDividendo; Endereco da source
    mov ah,9h; Escreve string
    int 21h
    jmp numDividendo
	
;Vai buscar o dividendo, 1 digito de cada vez, ou seja cada 
;iteracao vai buscar um digito	
numDividendo: 
    mov aux, 1
    mov dividendo, 0
    mov ah,1h; Input de um caracter
    int 21h
    mov dl,al
    
    cmp dl, 0Dh; Compara com o valor introduzido pela tecla ENTER
    ;(0DH)
    jz checkDividendo; Caso o utilizador carregue no ENTER
    
    mov bx, index; Numero de digitos atuais
    sub dl, 48; Converte para decimal
    mov digitosDividendo[bx],dl; Vai por os elementos no array 
    ;de digitos por ordem, arr = (pos0,pos1,...)
    inc lengthDividendo; Aumenta o valor do numero de digitos 
    inc index 
    loop numDividendo

;Converte o array dos digitos do dividendo para um numero
;decimal ex {1,2,3,4} = 1234     
checkDividendo:
    xor ax,ax; limpa o registo ax (0 xor 0 = 0; 1 xor 1 = 0)
    mov bx, index
    dec bx
    cmp bx, 5;Se index >= 5, o numero > 16 bit porque o max e 
    ;65535(5 digitos) e o index vai de 0-(index-1)
    jae msgErroMaiorDividendo
    mov al, digitosDividendo[bx]; Digito na posicao do index
    cmp al, 0; Vai para erro caso o caracter introduzido seja 
    ;menor que 0 
    jb msgInvalidoDividendo
    cmp al, 9; Vai para erro caso o caracter introduzido seja 
    ;maior que 9 
    ja msgInvalidoDividendo
    mov bx, aux
    mul bx; Caso a introducao do numero em ax ativar a CF
    ;(carry flag), ir para msgErro porque o numero e > 16bit
    jc msgErroMaiorDividendo 
    add dividendo, ax; Adiciona ao valor atual do dividendo
    jc msgErroMaiorDividendo
    dec index
    
    cmp index, 0; Se 0, significa que ja nao existe mais digitos
    ;para ir buscar no array
	jz mensagemDivisor
	
	mov ax, 10
	mul bx; +1 casa decimal porque as casas decimais estao 
	;definidas de acordo com 10^x onde x e a sucessao de casas
	mov aux, ax; Move o valor atual da casa decimal para o aux 
	loop checkDividendo

;Escreve a mensagem de erro caso o numero introduzido contenha 
;caracteres nao validos
msgInvalidoDividendo:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    lea dx, msgCharInvalido
    mov ah,9h; Escreve string
    int 21h
    jmp ResetVarsDividendo; Ir para reset das vars

;Escreve a mensagem de erro caso o numero introduzido 
;seja > 16bits	
msgErroMaiorDividendo:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    
    lea dx, msgErroMaior
    mov ah,9h
    int 21h
;Repoe os valores necessarios para os seus valores originais    
ResetVarsDividendo: 
    mov aux, 1
    mov index, 0
    mov lengthDividendo, 0
    jmp mensagemDividendo; Voltar a mostra a msg de Introducao
    ;para voltar a pedir o dividendo   
     
;----------------------------------------------------------------
;-------------------------Divisor--------------------------------
;----------------------------------------------------------------	

numDivisor: 
    mov aux, 1 
    mov divisor, 0
    mov ah,1h
    int 21h
    mov dl,al
    
    cmp dl, 0Dh
    jz checkDivisor
    
    mov bx, index
    sub dl, 48
    mov digitosDivisor[bx], dl

    inc lengthDivisor
    inc index
    loop numDivisor
    
mensagemDivisor:
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    
    lea dx, msgDivisor
    mov ah,9h
    int 21h
    jmp numDivisor

checkDivisor:
    xor ax,ax
    mov bx, index
    dec bx
    cmp bx, 5
    jae msgErroMaiorDivisor
    mov al, digitosDivisor[bx]
    cmp al, 0
    jb msgInvalidoDivisor
    cmp al, 9
    ja msgInvalidoDivisor
    mov bx, aux
    mul bx
    jc msgErroMaiorDivisor
    add divisor, ax
    jc msgErroMaiorDivisor
    dec index
    
    cmp index, 0
	jz divisao
	
	mov ax, 10
	mul bx
	mov aux, ax
	
	loop checkDivisor

msgInvalidoDivisor:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    lea dx, msgCharInvalido
    mov ah,9h
    int 21h
    jmp ResetVarsDivisor
    
;Mensagem caso tente dividir por 0
msgZero:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    
    lea dx, msgErroZero
    mov ah,9h
    int 21h
    jmp ResetVarsDivisor
	
msgErroMaiorDivisor:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    
    lea dx, msgErroMaior
    mov ah,9h
    int 21h
    
ResetVarsDivisor:
    mov aux, 1
    mov index, 0
    mov lengthDivisor, 0
    jmp mensagemDivisor    
    
;----------------------------------------------------------------
;-------------------------Divisao--------------------------------
;----------------------------------------------------------------
 
;Verificao inicial
divisao:
    mov ax, dividendo
    mov bx, divisor
    cmp bx, 0; Nao se divide por 0
    jz msgZero
    cmp ax, bx; Caso o dividendo seja maior que o divisor, como
    ;estamos a trabalhar em divisao inteira, o resultado sera
    ;igual a 0 e o resto = dividendo
    inc lengthQuociente; Incrementa o numero de digitos do 
    ;quociente
    ; para apresentar o resultado 0, visto que o array e 
    ; inicializado como {0,0,0,0,0} 
    jb Resultado; Ir para a apresentacao do resultado
    mov bx, 0
    mov digitosQuociente[bx], 1
    mov bx, divisor
    cmp ax, bx
    jz Resultado
    dec lengthQuociente; Repo
    mov aux, 10
    xor ax,ax
    jge find
;Encontra a parcela inicial do dividendo que seja >= divisor
; para iniciar a operacao    
find:
    xor bx,bx
    mov bx, index; Index atual do dividendo
    add al, digitosDividendo[bx];Somar 
    mov bx, divisor
    cmp ax,bx; Compara o/os digito/os mais significativo/os 
    ;do dividendo com o valor total do divisor
    mov dividendo, ax
    jae loopMultiplicacao
    mov bx, aux
    mul bx; Multiplica os digitos mais significativos por 10
    ;para ir para a proxima casa do dividendo
    inc index; Aumenta o index da parcela do dividendo
    loop find
    
;Loop para encontra x tal que x*divisor <= parcela do dividendo    
loopMultiplicacao:
    mov ax, divisor
    mov cx, dividendo
    mov bx, counter
    mul bx
    cmp ax, cx; Compara o valor da parcela do dividendo com
    ; o valor de x*divisor
    jg addDigitoQuoc
    inc counter; Incrementa o contador(x)
    loop loopMultiplicacao
   
    ;Adiciona os digitos x ao array do quociente e realiza as
    ; subtracoes necessarias para a operacao da divisao 
    addDigitoQuoc:
        dec counter; Decrementa o contador porque o 
        ;contador * divisor > parcela do dividendo  
        mov bx, indexQuociente
        mov cx, counter
        mov digitosQuociente[bx], cl;Adiciona o counter(x) aos
        ;digitos do quociente
        inc lengthQuociente
        inc indexQuociente; Atualiza a posicao do index
        ;do quociente
        
        mov ax, divisor
        mul cx ; x*divisor
        mov cx, dividendo
        sub cx, ax; Parcela dividendo - (x * divisor)
        mov dividendo, cx; Atualiza o nosso dividendo,
        ; cada parcela irá substituir o nosso dividendo
        
        inc index; Incrementa o index da parcela do dividendo
        mov bx, lengthDividendo
        dec bx ;
        mov ax, index
        cmp ax, bx; Se o index do dividendo ultrapassar o tamanho-1
        ;significa que o ultimo digito ja foi lido
        ja Resultado
        
        mov ax, dividendo
        mov bx, aux
        mul bx; Multiplica a parcela atual por 10 para poder 
        ;adicionar o proximo digito
        mov bx, index
        xor dx, dx
        mov dl, digitosDividendo[bx]
        add ax, dx; Soma ao dividendo o valor do digito seguinte
        
        mov dividendo, ax ; Atualiza o valor do dividendo
        
        ;Limpa os registos
        xor ax,ax
        xor cx,cx
        xor dx,dx
        mov counter, 0; Repoe o valor do contador para o proximo loop
        
        jmp loopMultiplicacao

;----------------------------------------------------------------
;-------------------------Resultado------------------------------
;----------------------------------------------------------------

;Apresenta o resultado na consola
Resultado:
    mov dl, 10;
    mov ah, 02h;
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    
    lea dx, msgResultado
    mov ah,9h
    int 21h
    mov bx, dividendo
    ;Resto ira ser igual a ultima parcela do dividendo
    mov resto, bx
    xor bx,bx
    
    ;Percorre o array dos digitos do quociente e 
    ;imprime-os
    escreveDigitos:
        mov dx, lengthQuociente
        dec dx
        cmp bx, dx
        jg stop; Quando o contador bx for maior que tamanho-1
        mov ah,2h
        mov dl, digitosQuociente[bx]
        add dl, 48; Converte para hex outra vez para poder
        ;escrever corretamente na consola
        int 21h
        inc bx
        jmp escreveDigitos

;Para o programa
stop:
    ret; return

;----------------------------------------------------------------
;-------------------------Variaveis------------------------------
;----------------------------------------------------------------

    ;Variaveis e constantes
	numMax equ 5
	aux dw 1;
	index dw 0
	indexQuociente dw 0
	counter dw 1
	
	;Mensagens a apresentar
	msgResultado db "Resultado = $"
	msgDividendo db "Insira um dividendo:  $"
    msgDivisor db "Insira um divisor:  $"
	msgErroMaior db "Erro. O valor e superior a 2 bytes$"
	msgCharInvalido db "Valor contem caracteres nao validos. Insira novamente (0-9)$"
    msgErroZero db "Erro. Nao pode dividir por 0$"
    
    digitosDividendo db numMax Dup(0); Array que vai conter os digitos do dividendo
	lengthDividendo dw 0;Numero de digitos do dividendo
	
	digitosDivisor db numMax Dup(0)
	lengthDivisor dw 0
	
	dividendo dw 0
	divisor dw 0
	digitosQuociente db numMax Dup(0)
	lengthQuociente dw 0
    resto dw 0