{===================================================================
****TAREA-PACMAN****
* CLAVE DE INICIO (0000)
*EL JUEGO TERMINA CUANDO SE ACABAN LAS VIDAS O
 CUANDO SE ALCANSAN LOS 3000 PUNTOS(EL HI-SCORE ES DE 2500 PUNTOS)
*TENER CUIDADO CON EL FANTASMA DEBIDO A QUE PUEDE SER
  MAS AGIL DE LO QUE PIENSAS (PUEDE USAR TELETRANSPORTACION :o )
*DISFRUTA DEL JUEGO :D
===================================================================}
program PACMAN;
begin
asm


{===============================================================
            INICIO INSTRUCCIONES INICIALES DEL JUEGO
================================================================}
@inicio:
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx

call @memoria
call @mostrar_puntaje
call @sesion
call @pausar
call @limpiar_pantalla
call @ocultar_cursor
call @mapa
call @procesos_juego
call @fin
{===================================================}
@ocultar_cursor:
                    mov ch,$32
                    mov ah,$1
                    int $10

ret
{===================================================}
@time_01:
		        push ax
		        push cx
		        push dx

		        mov ah,$86
		        mov dx,$dfff
		        mov cx,$0000
		        int $15

                        pop dx
                        pop cx
		        pop ax
ret
{================================================}
@time_02:
		        push ax
		        push cx
		        push dx

                        mov ah,$86
		        mov dx,$7eee
		        mov cx,$0000
		        int $15

                        pop dx
                        pop cx
		        pop ax
ret
{================================================}
@memoria:
            mov ax,$8000
            mov ds,ax
            mov ax,$0000
            mov [0000],ah     {guarda parte alta del puntaje}
            mov [0001],al     {guarda parte baja del puntaje}
            mov ah,$3
            mov [0002],ah     {guadar la cantidad de vidas}

            mov ah,$11        {centra el pacman  en (11,23)}
            mov [0003],ah     {guarda la fila actual de pacman}
            mov [0010],ah     {guarda la fila inicial para resetear el pacman}
            mov al,$23
            mov [0004],al     {guarda la columna actual del pacman}
            mov [0011],al     {guarda la columna inicial para resear el pacman}
            mov ah,$8         {centra el fantasma en 9,23}
            mov [0005],ah     {guarda la fila actual del fantasma}
            mov [0008],ah     {guarda la fila inicial para resetear el fantasma}
            mov al,$23
            mov [0006],al     {guarda la columna actual del fantasma}
            mov [0009],al     {guarda la columna inicial para resetear el fantasma}

            mov [0007],al     {guarda el movimiento del pacman}
            mov al,$04
            mov [0012],al     {guarda lo que restaura el fantasma}
            mov al,$20
            mov [0013],al     { [0013] Cordenadas vidas}
            mov al,$00
            mov [0014],al     {flag fantasmas blanco}
            mov al,$00
            mov [0015],al     {CONTADOR TIEMPO FANTASMA BLANCO}
            mov al,$3         {color y forma  fantasma}
            mov [0016],al
            mov al,$02
            mov [0017],al
            mov al,$5
            mov [0018],al     {color de lo obtenido por el fantasma}

ret
{================================================}
@game_over:
            mov dh,$a
            mov dl,$18
            call @mover_cursor
            call @limpiar_pantalla
            call @texto_game_over
            mov dh,$a
            mov dl,$25
            call @mover_cursor
            call @texto_puntaje
            mov dh,$c
            mov dl,$1a
            call @mover_cursor
            call @texto_principal
            call  @time_01
            mov ah,$00
            int $16
            call @time_01
jmp @fin

{================================================}
@mostrar_vidas:
            push ax
            push bx
            push cx
            push dx

            mov ah,$02
            mov dh,$2
            mov dl,[0013]
            sub dl,$1
            mov [0013],dl
            mov bh,$0
            int $10
              
            mov ah,$09
            mov al,$00
            mov bl,$0
            mov cx,$1
            int $10
              
            pop dx
            pop cx
            pop bx
            pop ax

jmp @volver
{================================================}
@mostrar_puntaje:
            push ax
            push dx
            push cx
            push bx

            mov dh,$2
            mov dl,$9
            call @mover_cursor
            xor dx,dx
            mov bl,[0001]
            mov bh,[0000]

        @puntaje_decmal:
            mov dh,bh
            mov cl,$4
            shr dh,cl
            add dh,$30
            mov al,dh
            call  @imprimir

            mov dx,$0
            mov dh,bh
            mov cl,$4
            shl dh,cl
            shr dh,cl
            add dh,$30
            mov al,dh
            call  @imprimir
            
            mov dl,bl
            mov cl,$4
            shr dl,cl
            add dl,$30
            mov al,dl
            call  @imprimir
            
            mov dl,$00
            mov dl,bl
            mov cl,$c
            shl dx,cl
            mov cl,$4
            shr dx,cl
            add dh,$30
            mov al,dh
            call  @imprimir
            
            pop bx
            pop cx
            pop dx
            pop ax
ret
{==========================================================
    TOMA DE DECICION PRINCIPAL DE MOVIMIENTO DEL PACMAN 
=========================================================}

@procesos_juego:

        @mover_pacman:
            call  @time_01
            mov ah,$01
            int $16

            jz  @no_tecla_precionada

            mov ah,$00
            int $16
            mov [0007],ah

        @no_tecla_precionada:

            call @time_01
            mov al,[0016]
            cmp al,$3
            je @fantasmin
            jmp @fantasmin_arranca
        @end_cfan:
            mov al,[0016]
            cmp al,$3
            je @pacman_fantasma
            jmp @comer_fantasmin
        @end_pacman_fantasma:
            mov ah,[0007]
            cmp ah,$01
            je @game_over

            cmp ah,$48
            je @up_pacman

            cmp ah,$50
            je @down_pacman

            cmp ah,$4d
            je @right_pacman

            cmp ah,$4b
            je @left_pacman
jmp  @mover_pacman

{=======================================================================
   SECCION DE CONTROL DE  MOVIMIENTO
========================================================================}
@up_pacman:
            call @borrarsombra
            call @limiteup
            mov bh,$0
            mov ah,$02
            dec dh
            int $10
            mov [0003],dh
            mov [0004],dl
            call @mostrarcaraup

jmp @mover_pacman

@down_pacman:
            call @borrarsombra
            call @limitedown
            mov bh,$0
            mov ah,$2
            inc dh
            int $10
            mov [0003],dh
            mov [0004],dl
            call @mostrarcaradown

jmp @mover_pacman

@left_pacman:
            call @borrarsombra
            call @viaje_a_derecha
            call @limiteleft
            mov bh,$0
            mov ah,$02
            dec dl
            int $10
            mov [0003],dh
            mov [0004],dl
            call @mostrarcaraleft
jmp @mover_pacman

@right_pacman:
           call @borrarsombra
           call @viaje_a_izquierda
           call @limiteright
           mov bh,$0
           mov ah,$02
           inc dl
           int $10
           mov [0003],dh
           mov [0004],dl
           call @mostrarcararight
jmp @mover_pacman

{=======================================================================
   SECCION MOSTRAR CARA DEL PACMAN
========================================================================}   
@mostrarcararight:
            mov ah,$09
            mov al,$10
            mov bh,$0
            mov bl,$e
            mov cx,$1
            int $10
ret

@mostrarcaraup:
            mov ah,$09
            mov al,$1e
            mov bh,$0
            mov bl,$e
            mov cx,$1
            int $10
ret

@mostrarcaradown:
            mov ah,$09
            mov al,$1f
            mov bh,$0
            mov bl,$e
            mov cx,$1
            int $10
ret

@mostrarcaraleft:
            mov ah,$09
            mov al,$11
            mov bh,$0
            mov bl,$e
            mov cx,$1
            int $10
ret

{borra la sombra}
@borrarsombra:
            mov ah,$09
            mov al,$20
            mov bh,$0
            mov bl,$0
            mov cx,$1
            int $10
ret
{=====================================================
            SECCION DE TELETRANSPORTAR PACMAN
=====================================================}

@viaje_a_izquierda:
            push dx
            push ax
            
            cmp dh,$d
            jne @no_viaja_izquierda
            inc dl
            cmp dl,$43
            jne @no_viaja_izquierda
            
            mov dh,$d
            mov dl,$3
            mov ah,$2
            int $10

            call @mostrarcararight

            mov dh,$d
            mov dl,$3
            mov ah,$2
            int $10

            mov ah,$09
            mov al,$b2
            mov bh,$0
            mov bl,$ff
            mov cx,$1
            int $10

@no_viaja_izquierda:
            dec dl
            
            pop ax
            pop dx

ret

@viaje_a_derecha:
            push dx
            push ax
            
            cmp dh,$d
            jne @no_viaja_derecha

            dec dl
            cmp dl,$3
            jne @no_viaja_derecha
            
            mov dh,$d
            mov dl,$43
            mov ah,$2
            int $10

            call @mostrarcaraleft
            mov dh,$d
            mov dl,$43
            mov ah,$2
            int $10

            mov ah,$09
            mov al,$b2
            mov bh,$0
            mov bl,$ff
            mov cx,$1
            int $10

@no_viaja_derecha:
            inc dl
            
            pop ax
            pop dx

ret
{======================================================
          SECCION DE VERIFICAR LIMITES DEL PACMAN
======================================================}
{verifica limite up}
@limiteup:
            {obtener posicion}
            mov ah,$03
            mov bh,$0
            int $10
            dec  dh
            {fijar cursor}
            mov ah,$02
            int $10
            {leer lo que hay el posicion del cursor}
            mov ah,$8
            int $10

            call @comer_1
            cmp al,$b2
            je @bordeup
            inc dh
ret

@bordeup:
            inc dh
            mov ah,$02
            int $10

            mov ah,$09
            mov al,$1e
            mov bl,$e
            mov cx,$1
            int $10

jmp @mover_pacman

{verifica limite down}
@limitedown:
            {obtener posicion}
            mov ah,$03
            mov bh,$0
            int $10

            inc dh
            {fijar cursor}
            mov ah,$02
            int $10

            {leer lo que hay en la posicion del cursor}
            mov ah,$8
            int $10

            call @comer_1
            cmp al,$b2
            je @bordedown
            dec dh
ret
@bordedown:
            dec dh
            mov ah,$02
            int $10

            mov ah,$09
            mov al,$1f
            mov bl,$e
            mov cx,$1
            int $10

jmp @mover_pacman

{verifia limite right}
@limiteright:
            {obtener posicion}
            mov ah,$03
            mov bh,$0
            int $10

            inc dl
            {fijar cursor}
            mov ah,$02
            int $10

            {leer lo que hay en la posicion del cursor}
            mov ah,$8
            int $10

            call @comer_1
            cmp al,$b2
            je @borderight
            dec dl
ret

@borderight:
            dec dl
            mov ah,$02
            int $10

            mov ah,$09
            mov al,$10
            mov bl,$e
            mov cx,$1
            int $10

jmp @mover_pacman


{verifica limite left}
@limiteleft:
            {obtener posicion}
            mov ah,$03
            mov bh,$0
            int $10

            dec  dl
            {fijar cursor}
            mov ah,$02
            int $10

            {leer lo que hay en la posicion del cursor}
            mov ah,$8
            int $10

            call @comer_1
            cmp al,$b2
            je @bordeleft
            inc dl

ret

@bordeleft:
          inc dl
          mov ah,$02
          int $10

          mov ah,$09
          mov al,$11
          mov bl,$e
          mov cx,$1
          int $10
jmp @mover_pacman
{=============================================
      SECCION QUE SUMA EL PUNTO COMIDO
=============================================}
@comer_1:
            push ax
            push bx
            push cx
            push dx

            xor cx,cx
            mov dh,$2
            mov dl,$3
            call @mover_cursor
            call @texto_puntaje
            cmp al,$04
            je @si_come
            cmp al,$0e
            je @sumar_power
            jmp @fin_comer

    @si_come:
            mov dl,[0001]
            mov dh,[0000]
            cmp dl,$90
            je @carry_1

            add dl,$10
            mov [0001],dl
            jmp @fin_comer

    @carry_1:
            mov bh,dh
            mov cl,$4
            shl bh,cl
            shr bh,cl
            cmp bh,$09
            je @carry_2
            add dh,$1
            mov dl,$00
            mov [0001],dl
            mov [0000],dh
    jmp @fin_comer

    @carry_2:
            mov bh,dh
            sub bh,$09
            add bh,$10
            mov dl,$00
            mov [0001],dl
            mov [0000],bh
            cmp bh,$30
            je @game_over
    jmp @fin_comer

    @sumar_power:
            mov al,$8f
            mov [0016],al
            xor ax,ax
            mov dh,[0000]
            mov bh,dh
            mov cl,$4
            shl bh,cl
            shr bh,cl
            cmp bh,$04
            ja  @loop_suma
            add dh,$05
            mov [0000],dh
            jmp @fin_comer
    @loop_suma:
            add ax,$1
            mov dh,[0000]
            mov bh,dh
            mov cl,$4
            shl bh,cl
            shr bh,cl
            cmp bh,$09
            je @carry_power
            jmp @move
    @carry_power:
            xor bx,bx
            mov bh,dh
            sub bh,$09
            add bh,$10
            mov [0000],bh
            cmp ax,$5
            je @fin_comer
    @move:
            cmp ax,$5
            je @fin_comer
            mov dh,[0000]
            add dh,$1
            mov [0000],dh
            cmp ax,$5
            je @fin_comer
            jmp @loop_suma
    @fin_comer:
            mov dl,[0000]
            cmp dl,$30
            jae @game_over

            pop dx
            pop cx
            pop bx
            pop ax

 ret
{================================================================
     CENTRADO INICIAL DE JUEGO CENTRA EL PACMAN-FANTASMA-VIDAS
=================================================================}
@centrarpacman_y_fantasma:

            mov ah,$02
            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            int $10

            mov al,$02
            mov bl,[0016]
            mov ah,$09
            mov cx,$1
            int $10

            mov dh,$[0003]
            mov dl,$[0004]
            mov bh,$0
            mov ah,$2
            int $10

            mov al,$10
            mov bl,$e
            mov ah,$09
            mov cx,$1
            int $10

            mov ah,$02
            mov dh,$2
            mov dl,$1d
            mov bh,$0
            int $10

            mov ah,$09
            mov al,$03
            mov bh,$0
            mov bl,$8c
            mov cx,$03
            int $10
            call @obtener_pos
jmp @mover_pacman
{=============================================
        FIJA EL PACMAN EN UNA POSICION
=============================================}
@fijar_pacman:
            mov ah,$02
            mov dh,[0003]
            mov dl,[0004]
            mov bh,$0
            int $10
ret
{=================================================
                 COMER FANTASMA
=================================================}
@comer_fantasmin:
            mov ah,[0003]
            mov al,[0005]
            mov ch,[0004]
            mov cl,[0006]
            cmp al,ah
            je @comprobar_col_blanco
            jmp @no_juntos_blanco

      @comprobar_col_blanco:
            cmp ch,cl
            je @fin_game_blanco
            jmp @no_juntos_blanco
      @fin_game_blanco:
            mov al,[0000]
            add al,$10
            mov [0000],al
            mov dh,$2
            mov dl,$3
            call @mover_cursor
            call  @texto_puntaje
            cmp al,30
            jae @game_over
            jmp @centra_fantasma
      @no_juntos_blanco:

jmp @end_pacman_fantasma
{========================================
         CENTRA_FANTASMA
========================================}
@centra_fantasma:

            call @borrarsombra
            mov ah,$02
            mov dh,[0008]
            mov dl,[0009]
            mov bh,$0
            int $10

            mov [0005],dh
            mov [0006],dl
            call @mostrar_fantasma
            mov [0005],dh
            mov [0006],dl
            call @fijar_pacman
jmp @no_juntos_blanco

{========================================================================
          CENTRA EL PACMAN Y EL FANTASMA DESPUES DE PERDER UNA VIDA
=========================================================================}
@centra_pacman_fantasmas:

            call @fijar_pacman
            call @borrarsombra

            mov ah,$02
            mov dh,[0008]
            mov dl,[0009]
            mov bh,$0
            int $10

            mov [0005],dh
            mov [0006],dl
            call @mostrar_fantasma
            mov ah,$02
            mov dh,[00010]
            mov dl,[00011]
            mov bh,$0
            int $10

            mov [0003],dh
            mov [0004],dl
            call @mostrarcaraleft
jmp @no_juntos

{===================================================}

 @obtener_pos:
            mov ah,$03
            mov bh,$0
            int $10
ret
{================================================================
    COMPROBAR SI EL PACMAN Y FANTASMA ESTAN EN LA MISMA POSICION
=================================================================}
@pacman_fantasma:
            mov ah,[0003]
            mov al,[0005]
            mov ch,[0004]
            mov cl,[0006]
            cmp al,ah
            je @comprobar_col
            jmp @no_juntos
      @comprobar_col:
            cmp ch,cl
            je @fin_game
            jmp @no_juntos
      @fin_game:
            mov al,[0002]
            sub al,$1
            mov [0002],al
            jmp  @mostrar_vidas
      @volver:
            cmp al,$00
            je @game_over
            jmp @centra_pacman_fantasmas
      @no_juntos:

jmp @end_pacman_fantasma
{===========================================================
                CICLO PRINCIPAL DEL FANTASMA
============================================================}
@fantasmin:

            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            mov ah,$02
            int $10

            mov bh,[0005]  {arriba fanta}
            mov bl,[0003]  {arriba pacman}
            mov ch,[0004]   {lados pacman}
            mov cl,[0006]  {lados fantasma}

            cmp bl,bh
            jb  @up_fantasma

            cmp bl,bh
            ja @down_fantasma

            cmp ch,cl
            ja @right_fantasma

            cmp ch,cl
            jb @left_fantasma

            cmp bl,bh
            je @mov_lado_1

            cmp cl,ch

            je @mov_lado_2
            jmp @terminofantasma

      @mov_lado_1:
            cmp cl,ch
            jb @right_fantasma
            cmp cl,ch
            ja @left_fantasma
      jmp @terminofantasma

      @mov_lado_2:
            cmp bl,bh
            jb  @up_fantasma
            cmp bl,bh
            ja @down_fantasma

    @terminofantasma:
            call @fijar_pacman
jmp @end_cfan
{=================================
   MEUSTRA EL FANTASMA
=================================}
@mostrar_fantasma:
            mov ah,$09
            mov al,[0017]
            mov bh,$0
            mov bl,[0016]
            mov cx,$1
            int $10
ret
{==========================================================
             SECCION DE ARRANQUE DEL FANTASMA
===========================================================}
@fantasmin_arranca:
            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            mov ah,$02
            int $10

            mov al,[0015]
            add al,$1
            mov [0015],al
            cmp al,$4D
            je @fin_arranque
            mov bh,[0005]  {arriba fanta}
            mov bl,[0003]  {arriba pacman}
            mov ch,[0004]   {lados pacman}
            mov cl,[0006]  {lados fantasma}

            cmp ch,cl
            jb @right_fantasma

            cmp ch,cl
            ja @left_fantasma

           cmp bl,bh
            ja  @up_fantasma

             cmp bl,bh
            jb @down_fantasma
            jmp @terminofantasma_azul
@fin_arranque:
            mov al,$3
            mov [0016],al
            mov al,$00
            mov [0015],al
           call @fijar_pacman
jmp @end_cfan

@terminofantasma_azul:
               call @fijar_pacman

jmp @end_cfan
{===========================================================
   SECCION ENCARGADA DE RESTAURAR LOS PUNTO EN EL MAPA
===========================================================}
@restaurar_punto:
            push ax
            push bx
            push cx
            push dx

            mov bh,$10
            cmp [0012],bh
            je @borrar_sombra_muerta
            mov bh,$11
            cmp [0012],bh
            je @borrar_sombra_muerta
            mov bh,$1e
            cmp [0012],bh
            je @borrar_sombra_muerta
            mov bh,$1f
            cmp [0012],bh
            je @borrar_sombra_muerta
            jmp @reemplaza
      
      @borrar_sombra_muerta:
            mov bh,$00
            mov [0012],bh
            jmp @reemplaza
      @reemplaza:
            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            mov ah,$02
            int $10
            
            mov ah,$09
            mov al,[0012]
            mov bh,$0
            mov bl,[0018]
            mov cx,$1
            int $10

@no_reemplaza:
            pop dx
            pop cx
            pop bx
            pop ax
ret
{======================================================
      SECCION DE CONTROL DE MOVIENTOS DE FANTASMA
======================================================}
@up_fantasma:
            call @borrarsombra
            call @limiteup_fantasma
            call @restaurar_punto
            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            mov ah,$02
            dec dh
            int $10
            
            mov [0005],dh
            mov [0006],dl
            call @mostrar_fantasma
jmp @terminofantasma

@down_fantasma:
            call @borrarsombra
            call @limitedown_fantasma
            call @restaurar_punto
            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            mov ah,$2
            inc dh
            int $10

            mov [0005],dh
            mov [0006],dl
            call @mostrar_fantasma
jmp @terminofantasma

@left_fantasma:

            call @borrarsombra
            call @limiteleft_fantasma
            call @restaurar_punto
            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            mov ah,$02
            dec dl
            int $10
            
            mov [0005],dh
            mov [0006],dl
            call @mostrar_fantasma
jmp @terminofantasma

@right_fantasma:
            call @borrarsombra
            call @limiteright_fantasma
            call @restaurar_punto
            mov dh,[0005]
            mov dl,[0006]
            mov bh,$0
            mov ah,$02
            inc dl
            int $10

            mov [0005],dh
            mov [0006],dl
            call @mostrar_fantasma
jmp @terminofantasma
{=========================================
      VERIFICAR LIMITES DEL FANTASMA
==========================================}
@limiteup_fantasma:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10
          
            dec  dh
            {fijar}
            mov ah,$02
            int $10

            {leer}
            mov ah,$8
            int $10
            cmp al,$b2
            mov [0012],al
            mov [0018],ah
            je @bordeup_fantasmin
            inc dh
ret

@bordeup_fantasmin:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10

            inc dl
            inc dh
            {fijar}
            mov ah,$02
            int $10

            {leer}
            mov ah,$8
            int $10

            cmp al,$b2
            je @comprobar_1
            mov [0012],al
            mov [0018],ah
            call @restaurar_punto
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10

            call @mostrar_fantasma
            jmp  @terminofantasma

      @comprobar_1:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10
            
            sub dl,$2
            {fijar}
            mov ah,$02
            int $10
            {leer}
            mov ah,$8
            int $10
            
            cmp al,$b2
            je @reset_1
            mov [0012],al
            mov [0018],ah
            call @restaurar_punto
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10
            
            call @mostrar_fantasma
      @reset_1:
            mov dh,[0005]
            mov dl,[0006]
            mov ah,$02
            int $10
            
            call @mostrar_fantasma
jmp @terminofantasma

@limitedown_fantasma:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10
            
            inc  dh
            {fijar}
            mov ah,$02
            int $10
          
            {leer}
            mov ah,$8
            int $10

            mov [0012],al
            mov [0018],ah
            cmp al,$b2
            je @bordedown_fantasmas
            dec dh
ret
@bordedown_fantasmas:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10

            dec dl
            dec dh
            {fijar}
            mov ah,$02
            int $10

            {leer}
            mov ah,$8
            int $10
            
            cmp al,$b2
            je @comprobar_2
            mov [0012],al
            mov [0018],ah
            call @restaurar_punto
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10

            call @mostrar_fantasma
            jmp  @terminofantasma
      @comprobar_2:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10

            add dl,$2
            {fijar}
            mov ah,$02
            int $10
            
            {leer}
            mov ah,$8
            int $10
            cmp al,$b2
            je @reset_2
            mov [0012],al
            mov [0018],ah
            call @restaurar_punto
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10
  
            call @mostrar_fantasma
    @reset_2:
            mov dh,[0005]
            mov dl,[0006]
            mov ah,$02
            int $10
jmp @terminofantasma

@limiteright_fantasma:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10

            inc dl
            {fijar}
            mov ah,$02
            int $10
            
            {leer}
            mov ah,$8
            int $10

            mov [0012],al
            mov [0018],ah
            cmp al,$b2
            je @borderight_fantasmas
            dec dl
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10
          
            call @restaurar_punto
ret

@borderight_fantasmas:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10

            dec dl
            {fijar}
            mov ah,$02
            int $10
            
            inc dh
            mov ah,$02
            int $10
            
            {leer}
            mov ah,$8
            int $10

            cmp al,$b2
            je @reset_3
            jmp @comprobar_4
      @reset_3:
            mov dh,[0005]
            mov dl,[0006]
            mov ah,$02
            int $10
            
            call @mostrar_fantasma
            jmp @terminofantasma
      @comprobar_4:
            mov [0012],al
            mov [0018],ah
            call @restaurar_punto
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10

            call @mostrar_fantasma
            call @time_02
            jmp @right_fantasma


@limiteleft_fantasma:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10

            dec  dl
            {fijar}
            mov ah,$02
            int $10

            {leer}
            mov ah,$8
            int $10

            mov [0012],al
            mov [0018],ah
            cmp al,$b2
            je @bordeleft_fantasmas
            inc dl
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10

            call @restaurar_punto
ret

@bordeleft_fantasmas:
            {posicion}
            mov ah,$03
            mov bh,$0
            int $10

            inc dl
            {fijar}
            mov ah,$02
            int $10

            dec dh
            mov ah,$02
            int $10
            {leer}
            mov ah,$8
            int $10

            cmp al,$b2
            je @reset_4
            jmp @comprobar_5
      @reset_4:
            mov dh,[0005]
            mov dl,[0006]
            mov ah,$02
            int $10

            call @mostrar_fantasma
            jmp @terminofantasma
      @comprobar_5:
            mov [0012],al
            mov [0018],ah
            call @restaurar_punto
            mov [0005],dh
            mov [0006],dl
            mov ah,$02
            int $10

            call @mostrar_fantasma
            call @time_02
            jmp @left_fantasma
{================================================
  DESDE AQUI EMPIEZA CICLO DEL RUT Y EL MAPA
================================================}
@imprimir:
		        mov ah,$0E
		        int $10
ret
{========================================}
@mover_cursor:
            push ax
            push bx
            push cx
            push dx

            mov ah,$02
            mov bx,$00
            int $10

            pop dx
            pop cx
            pop bx
            pop ax
ret
{========================================}
@ingresar_tecla:
            mov ah,$00
            int $16
ret
{=========================================}
@obtener_numero_decimal:
            mov ah,al
            sub ah,$30
ret
{======================================================}
@etapa_rut:
            mov cx,3 {contador digitos rut}
            @ciclo_rut:
                call @ingresar_tecla
                 call @obtener_numero_decimal
                 call @verificar_decimal
                 call @imprimir
            loop @ciclo_rut
ret
{==========================================================}
@verificar_decimal:

            cmp cx,$1
            je @digito_1
            cmp cx,$2
            je @digito_2
            cmp cx,$3
            je @digito_3
ret
{==============================================================}
            @digito_1:
                      cmp ah,$0
                      jne @error_digito
            ret
            @digito_2 :
                      cmp ah,$0
                     jne @error_digito
            ret
            @digito_3:
                      cmp ah,$0
                      jne @error_digito
            ret

{=====================================================================}
@pausar:
            push ax
            mov ah,$00
            int $16
            pop ax
ret
@error_digito:
            call @limpiar_pantalla
            mov dh,$a
            mov dl,$17
            call @mover_cursor
            call @texto_error_rut
            call @pausar
            call @fin
{==========================}
@limpiar_pantalla:
           
                        push ax
		        push bx
  		        push cx

	 	        mov ah,$06
		        mov al,$0
		        mov bh,$07
        		mov ch,$0
        		mov cl,$0
		        mov dh,$18
		        mov dl,$4f
		        int $10

                         pop cx
		        pop bx
		        pop ax
ret
@sesion:
         call @limpiar_pantalla
         mov dh,$a
         mov dl,$1b
         call @mover_cursor
         call @texto_principal
         call @texto_nombre
         mov dh,$00
         mov dl,$13
         call @mover_cursor
         call @texto_rut
         call @etapa_rut
         mov dh,$00
         mov dl,$13
         call @mover_cursor
         call @texto_ok_rut
ret


{==============================================}
 {SECCION DE TEXTO DE LA PANTALLA INICIAL) }

{==============================================}

@texto_principal:
            push ax

            mov al,$5
	    call @imprimir
	    mov al,'P'
	    call @imprimir
            mov al,'A'
	    call @imprimir
            mov al,'C'
            call @imprimir
            mov al,'M'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,'N'
	    call @imprimir
            mov al,' '
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,'S'
	    call @imprimir
	    mov al,'S'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,'S'
	    call @imprimir
	    mov al,'S'
	    call @imprimir
	    mov al,'I'
            call @imprimir
	    mov al,'N'
	    call @imprimir
	    mov al,'S'
	    call @imprimir
            mov al,$5
	    call @imprimir

            pop ax
ret
{===============================================}
@texto_rut:
            push ax
	    mov al,'I'
	    call @imprimir
	    mov al,'N'
	    call @imprimir
	    mov al,'G'
	    call @imprimir
	    mov al,'R'
	    call @imprimir
	    mov al,'E'
	    call @imprimir
	    mov al,'S'
	    call @imprimir
	    mov al,'E'
            call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'E'
	    call @imprimir
	    mov al,'L'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'R'
	    call @imprimir
	    mov al,'U'
            call @imprimir
	    mov al,'T'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'D'
	    call @imprimir
	    mov al,'E'
	    call @imprimir
	    mov al,'L'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'C'
	    call @imprimir
	    mov al,'R'
	    call @imprimir
	    mov al,'E'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
            mov al,'D'
	    call @imprimir
	    mov al,'O'
	    call @imprimir
	    mov al,'R'
	    call @imprimir
            mov al,'.'
            call @imprimir
            mov al,'.'
            call @imprimir
	    mov al,$0E
	    call @imprimir
            mov al,' '
            call @imprimir
            mov al,$1A
            call @imprimir

            pop ax
ret


{================================================}
@texto_error_rut:

            push ax
	    mov al,'R'
	    call @imprimir
	    mov al,'U'
	    call @imprimir
	    mov al,'T'
	    call @imprimir
	    mov al,' '
	    call @imprimir
            mov al,'I'
            call @imprimir
       	    mov al,'N'
            call @imprimir
            mov al,'G'
            call @imprimir
	    mov al,'R'
	    call @imprimir
	    mov al,'E'
	    call @imprimir
	    mov al,'S'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,'D'
	    call @imprimir
	    mov al,'O'
	    call @imprimir
	    mov al,' '
	    call @imprimir
            mov al,'N'
	    call @imprimir
            mov al,'O'
            call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'E'
	    call @imprimir
            mov al,'S'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'V'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,'L'
	    call @imprimir
	    mov al,'I'
	    call @imprimir
	    mov al,'D'
	    call @imprimir
            mov al,'0'
            call @imprimir
	    mov al,' '
            call @imprimir
	    mov al,':'
            call @imprimir
            mov al,'`'
	    call @imprimir
            mov al,'('
            call @imprimir
            mov al,' '

            pop ax
ret
{=============================================================}
@texto_ok_rut:

            push ax
            mov al,$2
	    call @imprimir
	    mov al,$2
            call @imprimir
            mov al,$2
            call @imprimir
            mov al,'P'
            call @imprimir
	    mov al,'R'
            call @imprimir
	    mov al,'E'
            call @imprimir
            mov al,'S'
            call @imprimir
            mov al,'I'
            call @imprimir
	    mov al,'O'
	    call @imprimir
	    mov al,'N'
	    call @imprimir
	    mov al,'E'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'U'
	    call @imprimir
	    mov al,'N'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'T'
	    call @imprimir
	    mov al,'E'
	    call @imprimir
	    mov al,'C'
	    call @imprimir
	    mov al,'L'
	    call @imprimir
  	    mov al,'A'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'P'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,'R'
	    call @imprimir
	    mov al,'A'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,'C'
	    call @imprimir
	    mov al,'O'
	    call @imprimir
            mov al,'N'
            call @imprimir
            mov al,'T'
            call @imprimir
            mov al,'I'
            call @imprimir
            mov al,'N'
	    call @imprimir
	    mov al,'U'
            call @imprimir
            mov al,'A'
            call @imprimir
            mov al,'R'
	    call @imprimir
	    mov al,' '
	    call @imprimir
	    mov al,$1
	    call @imprimir
	    mov al,$1
          call @imprimir
          mov al,$1
          call @imprimir
           pop ax
ret
{=====================================================}
@mostrar_score_vida:

            mov dh,$2
            mov dl,$3
            call @mover_cursor
            mov al,'S'
	    call @imprimir
	    mov al,'C'
            call @imprimir
            mov al,'O'
	    call @imprimir
            mov al,'R'
	    call @imprimir
            mov al,'E'
            call @imprimir
	    mov al,':'
	    call @imprimir
	    mov al,' '
	    call @imprimir
            mov dh,$2
            mov dl,$17
            call @mover_cursor
            mov al,'V'
	    call @imprimir
	    mov al,'I'
	    call @imprimir
	    mov al,'D'
	    call @imprimir
            mov al,'A'
	    call @imprimir
            mov al,'S'
            call @imprimir
            mov al,':'
            call @imprimir
            mov dh,$2
            mov dl,$29
            call @mover_cursor
             mov al,'H'
	    call @imprimir
	    mov al,'I'
            call @imprimir
            mov al,'-'
	    call @imprimir
            mov al,'S'
	    call @imprimir
	    mov al,'C'
            call @imprimir
            mov al,'O'
	    call @imprimir
            mov al,'R'
	    call @imprimir
            mov al,'E'
            call @imprimir
	    mov al,':'
	    call @imprimir
	    mov al,' '
            mov al,'2'
	    call @imprimir
            mov al,'5'
	    call @imprimir
            mov al,'0'
            call @imprimir
	    mov al,'0'
	    call @imprimir
            call @mostrar_puntaje

ret
{==============================================================}
@texto_game_over:
                push ax
	        mov al,'G'
                call @imprimir
	        mov al,'A'
	        call @imprimir
          	mov al,'M'
          	call @imprimir
          	mov al,'E'
          	call @imprimir
          	mov al,' '
          	call @imprimir
       	        mov al,'O'
          	call @imprimir
          	mov al,'V'
          	call @imprimir
          	mov al,'E'
          	call @imprimir
          	mov al,'R'
          	call @imprimir

            pop ax
ret
{====================================================}
@texto_puntaje:
            push ax
            push bx
            push cx
            push dx

            mov bh,[0000]
            cmp bh,$25
            jae @comprobar_parte_baja
            jmp @no_new_hiscore
        @comprobar_parte_baja:
            mov bh,[0001]
            cmp bh,$00
            jae @new_hiscore

        @no_new_hiscore:
            mov al,'S'
            call @imprimir
            mov al,'C'
            call @imprimir
            mov al,'O'
            call @imprimir
            mov al,'R'
            call @imprimir
            mov al,'E'
            call @imprimir
            mov al,':'
            call @imprimir
            jmp @puntaje

      @new_hiscore:

            mov al,'N'
            call @imprimir
            mov al,'E'
            call @imprimir
            mov al,'W'
            call @imprimir
            mov al,' '
            call @imprimir
            mov al,'H'
            call @imprimir
            mov al,'I'
            call @imprimir
            mov al,'-'
            call @imprimir
            mov al,'S'
            call @imprimir
            mov al,'C'
            call @imprimir
            mov al,'O'
            call @imprimir
            mov al,'R'
            call @imprimir
            mov al,'E'
            call @imprimir
            mov al,':'
            call @imprimir
            mov al,' '
            call @imprimir
      @puntaje:
            mov bl,[0001]
            mov bh,[0000]
            mov dh,bh
            mov cl,$4
            shr dh,cl
            add dh,$30
            mov al,dh
            call  @imprimir
            mov dx,$0
            mov dh,bh
            mov cl,$4
            shl dh,cl
            shr dh,cl
            add dh,$30
            mov al,dh
            call  @imprimir
            mov dl,bl
            mov cl,$4
            shr dl,cl
            add dl,$30
            mov al,dl
            call  @imprimir
            mov dl,$00
            mov dl,bl
            mov cl,$c
            shl dx,cl
            mov cl,$4
            shr dx,cl
            add dh,$30
            mov al,dh
            call  @imprimir

            pop dx
            pop cx
            pop bx
            pop ax
ret
{====================================================}
@texto_nombre:

            mov dh,$17
            mov dl,$23
            call @mover_cursor
            mov al,'B'
	    call @imprimir
	    mov al,'Y'
	    call @imprimir
	    mov al,':'
	    call @imprimir
      	    mov al,' '
            call @imprimir
            mov al,'N'
            call @imprimir
            mov al,'i'
            call @imprimir
            mov al,'c'
            call @imprimir
            mov al,'o'
            call @imprimir
            mov al,'l'
            call @imprimir
            mov al,'a'
            call @imprimir
            mov al,'s'
            call @imprimir
            mov al,' '
            call @imprimir
            mov al,'C'
            call @imprimir
            mov al,'o'
            call @imprimir
            mov al,'n'
            call @imprimir
            mov al,'t'
            call @imprimir
            mov al,'r'
            call @imprimir
            mov al,'e'
            call @imprimir
            mov al,'r'
            call @imprimir
            mov al,'a'
            call @imprimir
            mov al,'s'
            call @imprimir
            mov al,' '
            call @imprimir
            mov al,'B'
            call @imprimir
            mov al,'e'
            call @imprimir
            mov al,'c'
            call @imprimir
       	    mov al,'e'
	    call @imprimir
	    mov al,'r'
            call @imprimir
            mov al,'r'
            call @imprimir
            mov al,'a'
	    call @imprimir
            mov al,'.'
            call @imprimir
            mov al,'.'
            call @imprimir
            mov al,$e
	          call @imprimir
ret
{====================================================}
@mapa:
                  call @mostrar_score_vida
                  call @linea_1
                  call @time_01
                  call @linea_2
                  call @time_01
                  call @vacio_1
                  call @time_01
                  call @linea_3
                  call @time_01
                  call @linea_4
                  call @time_01
                  call @linea_5
                  call @time_01
                  call @vacio_2
                  call @time_01
                  call @linea_6
                  call @time_01
                  call @linea_7
                  call @time_01
                  call @linea_8
                  call @time_01
                  call @linea_9
                  call @time_01
                  call @linea_10
                  call @time_01
                  call @linea_11
                  call @time_01
                  call @linea_12
                  call @time_01
                  call @linea_13
                  call @time_01
                  call @linea_14
                  call @time_01
                  call @linea_16
                  call @time_01
                  call @linea_17
                  call @time_01
                  call @linea_18
                  call @time_01
                  call @linea_19
                  call @time_01
                  call @linea_20
                  call @time_01
                  call @linea_21
                  call @time_01
                  call @linea_22
                  call @time_01
                  call @relleno_1
                  call @time_01
                  call @relleno_especial
                  call @time_01
                  call @relleno_2
                  call @time_01
                  call @power_pelets
jmp @centrarpacman_y_fantasma
{=====================================================}
 @linea_1:
             mov ah,$2
             mov dh,$3
             mov dl,$3
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$41
             int $10
ret
{=======================================================}
@linea_2:
             mov ah,$2
             mov dh,$4
             mov dl,$3
             mov bh,$0
             int $10
             jmp @loop2

@loop2:
             mov ah,$09
             mov al,$b2
             mov bh,$0
             mov bl,$1
             mov cx,$1
             int $10
             add dh,$1
             mov dl,$3
             mov ah,$2
             int $10
             cmp dh,$d
             je @retornar
jmp @loop2
{====================================================================}
@vacio_1:

            mov dh,$d
            mov dl,$3
            mov ah,$2
            int $10
            mov ah,$09
            mov al,$b2
            mov bh,$0
            mov bl,$ff
            mov cx,$1
            int $10
ret

{=====================================================}
@linea_3:
             mov ah,$2
             mov dh,$e
             mov dl,$3
             mov bh,$0
             int $10
             jmp @loop3

@loop3:
             mov ah,$09
             mov al,$b2
             mov bh,$0
             mov bl,$1
             mov cx,$1
             int $10
             add dh,$1
             mov dl,$3
             mov ah,$2
             int $10
             cmp dh,$18
             je @retornar
jmp @loop3
{===================================================================}

@linea_4:
             mov ah,$2
             mov dh,$18
             mov dl,$3
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$41
             int $10
ret
{==============================================================}
@linea_5:
             mov ah,$2
             mov dh,$4
             mov dl,$43
             mov bh,$0
             int $10
             jmp @loop5

@loop5:
             mov ah,$09
             mov al,$b2
             mov bh,$0
             mov bl,$1
             mov cx,$1
             int $10
             add dh,$1
             mov dl,$43
             mov ah,$2
             int $10
             cmp dh,$d
             je @retornar
jmp @loop5
{====================================================}
@vacio_2:
             mov dh,$d
             mov dl,$43
             mov ah,$2
             int $10
             mov ah,$09
             mov al,$b2
             mov bh,$0
             mov bl,$ff
             mov cx,$1
             int $10
ret
{=======================================================}
@linea_6:

             mov ah,$2
             mov dh,$e
             mov dl,$43
             mov bh,$0
             int $10
             jmp @loop6

@loop6:
             mov ah,$09
             mov al,$b2
             mov bh,$0
             mov bl,$1
             mov cx,$1
             int $10
             add dh,$1
             mov dl,$43
             mov ah,$2
             int $10
             cmp dh,$18
             je @retornar
jmp @loop6
{====================================================}

@linea_7:
             mov ah,$2
             mov dh,$5
             mov dl,$5
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$a
             int $10
    @loop7:
             mov ah,$09
             mov cx,$a
             int $10
             add dh,$1
             mov ah,$2
             int $10
             cmp dh,$b
             je @retornar
    jmp @loop7
{===============================================================}
@linea_8:
             mov ah,$2
             mov dh,$13         {cruz izquierda abajo}
             mov dl,$5
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$c
             mov bh,$0
             int $10
      @loop8:
             mov ah,$09
             mov cx,$c
             int $10
             add dh,$1
             mov ah,$2
             int $10
             cmp dh,$17
             je @retornar
    jmp @loop8
ret
{===============================================================}
@linea_9:

             mov ah,$02
             mov dl,$18
             mov dh,$c
             mov bh,$0
             int $10           {centro}
         @loop9:
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$18
             int $10
             add dh,1
             mov ah,$2
             mov dl,$18
             mov bh,$0
             int $10
             cmp dh,$11
             je @retornar
         jmp @loop9


{===========================================================}
@linea_10:
             mov ah,$2
             mov dh,$5
             mov dl,$39  {cruz derecha arriba}
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$9
             mov bh,$0
             int $10
      @loop10:
             mov ah,$09
             mov cx,$9
             int $10
             add dh,$1
             mov ah,$2
             int $10
             cmp dh,$b
             je @retornar
    jmp @loop10
{============================================================}
@linea_11:

             mov ah,$2
             mov dh,$13
             mov dl,$36
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$c
             mov bh,$0   {cruz derecha abajo}
             int $10
      @loop11:
             mov ah,$09
             mov cx,$c
             int $10
             add dh,$1
             mov ah,$2
             int $10
             cmp dh,$17
             je @retornar
    jmp @loop11

{==================================================================}
@linea_12:
             mov ah,$2
             mov dh,$c
             mov dl,$5
             mov bh,$0
             int $10

             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$a    {cuadrado izquierdo}
             int $10

             mov ah,$2
             mov dh,$c
             mov dl,$5
             mov bh,$0
             int $10

    @loop12_1:
             mov ah,$09
             mov cx,$1
             int $10

             add dh,$1
             mov ah,$2
             int $10

             cmp dh,$11
             je @linea12_1
    jmp @loop12_1
    @linea12_1:
             mov ah,$2
             mov dh,$11
             mov dl,$5
             mov bh,$0
             int $10

             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$a
             int $10

             mov ah,$2
             mov dh,$d
             mov dl,$e
             mov bh,$0
             int $10
     @loop12_2:
             mov ah,$09
             mov cx,$1
             int $10

             add dh,$1
             mov ah,$2
             int $10
             cmp dh,$11
             je @retornar
    jmp @loop12_2

{=======================================================}
@linea_13:

             mov ah,$2
             mov dh,$c
             mov dl,$39
             mov bh,$0
             int $10

             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$9
             int $10

             mov ah,$2
             mov dh,$d
             mov dl,$39
             mov bh,$0
             int $10

    @loop13_1:
             mov ah,$09
             mov cx,$1
             int $10

             add dh,$1
             mov ah,$2
             int $10

             cmp dh,$11
             je @linea13_1
    jmp @loop13_1
    @linea13_1:
             mov ah,$2
             mov dh,$11
             mov dl,$39
             mov bh,$0
             int $10

             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$9
             int $10

             mov ah,$2
             mov dh,$d
             mov dl,$41
             mov bh,$0
             int $10

     @loop13_2:
             mov ah,$09
             mov cx,$1
             int $10

             add dh,$1
             mov ah,$2
             int $10

             cmp dh,$11
             je @retornar
    jmp @loop13_2
{=====================================================}
@linea_14:

             mov ah,$2
             mov dh,$12
             mov dl,$19    {linea medio abajo}
             mov bh,$0
             int $10

            @loop_14:
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$15
             int $10

             mov ah,$2
             mov dl,$19    {linea medio abajo}
             mov bh,$0
             int $10
             add dh,$1
             cmp dh,$18
             je @retornar
            jmp @loop_14
ret
{==================================================}
@linea_16:

             mov ah,$2
             mov dh,$5
             mov dl,$10
             mov bh,$0
             int $10

             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$10
             int $10         {cuadrado izquiedo}
         @loop16:
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$13
             int $10

             add dh,1
             mov ah,$2
             mov dl,$11
             mov bh,$0
             int $10
             cmp dh,$8
             je @retornar
         jmp @loop16
{=====================================================================}

@linea_17:

             mov ah,$2
             mov dh,$5
             mov dl,$20
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$18
             int $10
         @loop17:
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$13
             int $10                              {cuadrado derecho}
             add dh,1
             mov ah,$2
             mov dl,$24
             mov bh,$0
             int $10
             cmp dh,$8
             je @retornar
         jmp @loop17
{==================================================================}
@linea_18:

             mov dh,$9
             mov dl,$10
             mov ah,$2
             mov cx,$8
             mov bh,$0
             int $10           {cuadrado negro izquiedo}
         @loop18:
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$8
             int $10
             add dh,1
             mov ah,$2
             mov dl,$10
             mov bh,$0
             int $10
             cmp dh,$12
             je @retornar
         jmp @loop18

{===============================================================}
@linea_19:

             mov dl,$2f
             mov dh,$9
             mov bh,$0
             int $10           {cuadrado negro derecho}
         @loop19:
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$9
             int $10
             add dh,1
             mov ah,$2
             mov dl,$2f
             mov bh,$0
             int $10
             cmp dh,$12
             je @retornar
         jmp @loop19
@linea_20:

              mov ah,$2
              mov dh,$14
              mov dl,$12  {escalera1}
              mov bh,$0
              int $10

              mov ah,$09
              mov al,$b2
              mov bl,$1
              mov cx,$5
              int $10

         @loop20:
              mov ah,$2
              add dh,$1
              add dl,$1    {escalera1}
              mov bh,$0
              int $10

              mov ah,$09
              mov al,$b2
              mov bl,$1
              mov cx,$3
              int $10
              cmp dh,$16
             je @retornar
         jmp @loop20
@linea_21:

              mov ah,$2
              mov dh,$13
              mov dl,$2f  {escalera2}
              mov bh,$0
              int $10

              mov ah,$09
              mov al,$b2
              mov bl,$1
              mov cx,$6
              int $10
         @loop21:
              mov ah,$2
              add dH,$1    {escalera2}
              mov bh,$0
              int $10

              mov ah,$09
              mov al,$b2
              mov bl,$1
              mov cx,$6
              int $10
              cmp dh,$16
             je @retornar
         jmp @loop21

{=====================================================}

@linea_22:

             mov ah,$2
             mov dh,$9
             mov dl,$19   {linea medio arriba}
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$15
             int $10

             mov ah,$2
             mov dh,$a
             mov dl,$19   {linea medio arriba}
             mov bh,$0
             int $10
             mov ah,$09
             mov al,$b2
             mov bl,$1
             mov cx,$15
             int $10
ret
{==========================================================}
@relleno_1:
             mov dl,$3
             mov dh,$4
      @lopp_1:

             add dl,1
             cmp dl,$43
         je @aumentar_fila
             mov ah,$2
             mov bh,$0
             int $10
             mov ah,$08
             int $10
             cmp al,$b2
         je @lopp_1
              mov ah,$09
              mov al,$04
              mov bl,$5
              mov cx,$1
              int $10
         jmp @lopp_1
@aumentar_fila: cmp dh,$b
                je @retornar
                add dh,$1
                mov dl,$3
                jmp @lopp_1
{========================================================================}
@relleno_2:
             mov dl,$3
             mov dh,$11
        @lopp_2:

             add dl,1
             cmp dl,$43
         je @aumentar_fila2
             mov ah,$2
             mov bh,$0
             int $10
             mov ah,$08
             int $10
             cmp al,$b2
         je @lopp_2
             mov ah,$09
             mov al,$04
             mov bl,$5
             mov cx,$1
             int $10
         jmp @lopp_2
@aumentar_fila2: cmp dh,$18
                 je @retornar
                 add dh,$1
                 mov dl,$3
                 jmp @lopp_2
{========================================================}
@relleno_especial:
      @parte_1:
             mov dl,$4
             mov dh,$c
      @loop_relleno_especial_1:
             mov ah,$2
             mov bh,$0
             int $10

             add dh,$1
             cmp dh,$12
             je @caritas_1
             mov ah,$09
             mov al,$04
             mov bl,$05
             mov cx,$1
             int $10
           jmp @loop_relleno_especial_1
{=======================================================================}
@caritas_1:

             mov dl,$6  {caritas}
             mov dh,$d
       @loop_caritas1:
             mov ah,$2
             mov bh,$0
             int $10

             add dh,$1
             cmp dh,$12
           je @parte_2
             mov ah,$09
             mov al,$09
             mov bl,$8c
             mov cx,$8
             int $10
           jmp @loop_caritas1
{=========================================================}

   @parte_2:
              mov dl,$f
              mov dh,$c
           @loop_relleno_especial_2:
             mov ah,$2
             mov bh,$0
             int $10

             add dh,$1
             cmp dh,$12
             je @parte_3
             mov ah,$09
             mov al,$04
             mov bl,$05
             mov cx,$1
             int $10
           jmp @loop_relleno_especial_2

{=============================================}
    @parte_3:
             mov dl,$18
             mov dh,$c
        @loop_relleno_especial_3:
             mov ah,$2
             mov bh,$0
             int $10

             add dh,$1
             cmp dh,$12
             je @parte_4
             mov ah,$09
             mov al,$04
             mov bl,$05
             mov cx,$1
             int $10
           jmp @loop_relleno_especial_3

{==================================================}
    @parte_4:
             mov dl,$2e
             mov dh,$c
       @loop_relleno_especial_4:
             mov ah,$2
             mov bh,$0
             int $10
             add dh,$1
             cmp dh,$12
           je @parte_5
             mov ah,$09
             mov al,$04
             mov bl,$05
             mov cx,$1
             int $10
           jmp @loop_relleno_especial_4

{=========================================}
    @parte_5:
             mov dl,$38
             mov dh,$c
      @loop_relleno_especial_5:
             mov ah,$2
             mov bh,$0
             int $10
             add dh,$1
             cmp dh,$12
             je @parte_6
             mov ah,$09
             mov al,$04
             mov bl,$05
             mov cx,$1
             int $10
           jmp @loop_relleno_especial_5
{====================================================}
    @parte_6:
             mov dl,$42
             mov dh,$c
      @loop_relleno_especial_6:
             mov ah,$2
             mov bh,$0
             int $10

             add dh,$1
             cmp dh,$12
             je @caritas_2
             mov ah,$09
             mov al,$04
             mov bl,$05
             mov cx,$1
             int $10
           jmp @loop_relleno_especial_6

 {=====================================================}
 @caritas_2:

              mov dl,$3a  {caritas}
             mov dh,$d
      @loop_caritas2:
             mov ah,$2
             mov bh,$0
             int $10

             add dh,$1
             cmp dh,$12
             je @retornar
             mov ah,$09
             mov al,$09
             mov bl,$8c
             mov cx,$7
             int $10
           jmp @loop_caritas2

{===============================================}
 @power_pelets:

             mov dl,$4
             mov dh,$4
             mov ah,$2
             mov bh,$0
             int $10

             mov ah,$09
             mov al,$0e
             mov bl,$82
             mov cx,$1
             int $10

             mov dl,$4
             mov dh,$17
             mov ah,$2
             int $10

             mov ah,$09
             int $10

             mov dl,$42
             mov dh,$17
             mov ah,$2
             int $10

             mov ah,$09
             int $10

             mov dl,$42
             mov dh,$4
             mov ah,$2
             int $10

             mov ah,$09
             int $10

 ret

{=====================================}
@retornar: ret
{=====================================}


@fin:
 call  @borrarsombra

nop
nop
nop
nop
end;
end.