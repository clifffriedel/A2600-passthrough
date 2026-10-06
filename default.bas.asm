 processor 6502
 include "vcs.h"
 include "macro.h"
 include "2600basic.h"
 include "2600basic_variable_redefs.h"
 ifconst bankswitch
  if bankswitch == 8
     ORG $1000
     RORG $D000
  endif
  if bankswitch == 16
     ORG $1000
     RORG $9000
  endif
  if bankswitch == 32
     ORG $1000
     RORG $1000
  endif
 else
   ORG $F000
 endif
; This is a 2-line kernel!
kernel
 sta WSYNC
 lda #255
 sta TIM64T

 lda #1
 sta VDELBL
 sta VDELP0
 ldx ballheight
 inx
 inx
 stx temp4
 lda player1y
 sta temp3

 ifconst shakescreen
   jsr doshakescreen
 else
   ldx missile0height
   inx
 endif

 inx
 stx stack1

 lda bally
 sta stack2

 lda player0y
 ldx #0
 sta WSYNC
 stx GRP0
 stx GRP1
 stx PF1
 stx PF2
 stx CXCLR
 ifconst readpaddle
   stx paddle
 else
   sleep 3
 endif

 sta temp2,x

 ;store these so they can be retrieved later
 ifnconst pfres
   ldx #128-44
 else
   ldx #132-pfres*4
 endif

 inc player1y

 lda missile0y
 sta temp5
 lda missile1y
 sta temp6

 lda playfieldpos
 sta temp1
 
 ifconst pfrowheight
 lda #pfrowheight+2
 else
 ifnconst pfres
   lda #10
 else
   lda #(96/pfres)+2 ; try to come close to the real size
 endif
 endif

 clc
 sbc playfieldpos
 sta playfieldpos
 jmp .startkernel

.skipDrawP0
 lda #0
 tay
 jmp .continueP0

.skipDrawP1
 lda #0
 tay
 jmp .continueP1

.kerloop ; enter at cycle 59??

continuekernel
 sleep 2
continuekernel2
 lda ballheight
 
 ifconst pfres
 ldy playfield+pfres*4-132,x
 sty PF1 ;3
 ldy playfield+pfres*4-131,x
 sty PF2 ;3
 ldy playfield+pfres*4-129,x
 sty PF1 ; 3 too early?
 ldy playfield+pfres*4-130,x
 sty PF2 ;3
 else
 ldy playfield+44-128,x ;4
 sty PF1 ;3
 ldy playfield+45-128,x ;4
 sty PF2 ;3
 ldy playfield+47-128,x ;4
 sty PF1 ; 3 too early?
 ldy playfield+46-128,x;4
 sty PF2 ;3
 endif

 dcp bally
 rol
 rol
; rol
; rol
goback
 sta ENABL 
.startkernel
 lda player1height ;3
 dcp player1y ;5
 bcc .skipDrawP1 ;2
 ldy player1y ;3
 lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
			; so it doesn't cross a page boundary!

.continueP1
 sta GRP1 ;3

 ifnconst player1colors
   lda missile1height ;3
   dcp missile1y ;5
   rol;2
   rol;2
   sta ENAM1 ;3
 else
   lda (player1color),y
   sta COLUP1
 ifnconst playercolors
   sleep 7
 else
   lda.w player0colorstore
   sta COLUP0
 endif
 endif

 ifconst pfres
 lda playfield+pfres*4-132,x 
 sta PF1 ;3
 lda playfield+pfres*4-131,x 
 sta PF2 ;3
 lda playfield+pfres*4-129,x 
 sta PF1 ; 3 too early?
 lda playfield+pfres*4-130,x 
 sta PF2 ;3
 else
 lda playfield+44-128,x ;4
 sta PF1 ;3
 lda playfield+45-128,x ;4
 sta PF2 ;3
 lda playfield+47-128,x ;4
 sta PF1 ; 3 too early?
 lda playfield+46-128,x;4
 sta PF2 ;3
 endif 
; sleep 3

 lda player0height
 dcp player0y
 bcc .skipDrawP0
 ldy player0y
 lda (player0pointer),y
.continueP0
 sta GRP0

 ifnconst no_blank_lines
 ifnconst playercolors
   lda missile0height ;3
   dcp missile0y ;5
   sbc stack1
   sta ENAM0 ;3
 else
   lda (player0color),y
   sta player0colorstore
   sleep 6
 endif
   dec temp1
   bne continuekernel
 else
   dec temp1
   beq altkernel2
 ifconst readpaddle
   ldy currentpaddle
   lda INPT0,y
   bpl noreadpaddle
   inc paddle
   jmp continuekernel2
noreadpaddle
   sleep 2
   jmp continuekernel
 else
 ifnconst playercolors 
 ifconst PFcolors
   txa
   tay
   lda (pfcolortable),y
 ifnconst backgroundchange
   sta COLUPF
 else
   sta COLUBK
 endif
   jmp continuekernel
 else
   sleep 12
 endif
 else
   lda (player0color),y
   sta player0colorstore
   sleep 4
 endif
   jmp continuekernel
 endif
altkernel2
   txa
   sbx #252
   bmi lastkernelline
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
   jmp continuekernel
 endif

altkernel

 ifconst PFmaskvalue
   lda #PFmaskvalue
 else
   lda #0
 endif
 sta PF1
 sta PF2


 ;sleep 3

 ;28 cycles to fix things
 ;minus 11=17

; lax temp4
; clc
 txa
 sbx #252

 bmi lastkernelline

 ifconst PFcolorandheight
   ldy playfieldcolorandheight-87,x
 ifnconst backgroundchange
   sty COLUPF
 else
   sty COLUBK
 endif
   lda playfieldcolorandheight-88,x
   sta.w temp1
 endif
 ifconst PFheights
   lsr
   lsr
   tay
   lda (pfheighttable),y
   sta.w temp1
 endif
 ifconst PFcolors
   tay
   lda (pfcolortable),y
 ifnconst backgroundchange
   sta COLUPF
 else
   sta COLUBK
 endif
 ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
 endif
 ifnconst PFcolorandheight
 ifnconst PFcolors
 ifnconst PFheights
 ifnconst no_blank_lines
 ; read paddle 0
 ; lo-res paddle read
  ; bit INPT0
  ; bmi paddleskipread
  ; inc paddle0
;donepaddleskip
   sleep 10
 ifconst pfrowheight
   lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif
   sta temp1
 endif
 endif
 endif
 endif
 

 lda ballheight
 dcp bally
 sbc temp4


 jmp goback


 ifnconst no_blank_lines
lastkernelline
 ifnconst PFcolors
   sleep 10
 else
   ldy #124
   lda (pfcolortable),y
   sta COLUPF
 endif

 ifconst PFheights
 ldx #1
 sleep 4
 else
 ldx playfieldpos
 sleep 3
 endif

 jmp enterlastkernel

 else
lastkernelline
 
 ifconst PFheights
 ldx #1
 sleep 5
 else
   ldx playfieldpos
 sleep 4
 endif

   cpx #1
   bne .enterfromNBL
   jmp no_blank_lines_bailout
 endif

 if ((<*)>$d5)
 align 256
 endif
 ; this is a kludge to prevent page wrapping - fix!!!

.skipDrawlastP1
 sleep 2
 lda #0
 jmp .continuelastP1

.endkerloop ; enter at cycle 59??
 
 nop

.enterfromNBL
 ifconst pfres
 ldy.w playfield+pfres*4-4
 sty PF1 ;3
 ldy.w playfield+pfres*4-3
 sty PF2 ;3
 ldy.w playfield+pfres*4-1
 sty PF1 ; possibly too early?
 ldy.w playfield+pfres*4-2
 sty PF2 ;3
 else
 ldy.w playfield+44
 sty PF1 ;3
 ldy.w playfield+45
 sty PF2 ;3
 ldy.w playfield+47
 sty PF1 ; possibly too early?
 ldy.w playfield+46
 sty PF2 ;3
 endif

enterlastkernel
 lda ballheight

; tya
 dcp bally
; sleep 4

; sbc stack3
 rol
 rol
 sta ENABL 

 lda player1height ;3
 dcp player1y ;5
 bcc .skipDrawlastP1
 ldy player1y ;3
 lda (player1pointer),y ;5; player0pointer must be selected carefully by the compiler
			; so it doesn't cross a page boundary!

.continuelastP1
 sta GRP1 ;3

 ifnconst player1colors
   lda missile1height ;3
   dcp missile1y ;5
 else
   lda (player1color),y
   sta COLUP1
 endif

 dex
 ;dec temp4 ; might try putting this above PF writes
 beq endkernel


 ifconst pfres
 ldy.w playfield+pfres*4-4
 sty PF1 ;3
 ldy.w playfield+pfres*4-3
 sty PF2 ;3
 ldy.w playfield+pfres*4-1
 sty PF1 ; possibly too early?
 ldy.w playfield+pfres*4-2
 sty PF2 ;3
 else
 ldy.w playfield+44
 sty PF1 ;3
 ldy.w playfield+45
 sty PF2 ;3
 ldy.w playfield+47
 sty PF1 ; possibly too early?
 ldy.w playfield+46
 sty PF2 ;3
 endif

 ifnconst player1colors
   rol;2
   rol;2
   sta ENAM1 ;3
 else
 ifnconst playercolors
   sleep 7
 else
   lda.w player0colorstore
   sta COLUP0
 endif
 endif
 
 lda.w player0height
 dcp player0y
 bcc .skipDrawlastP0
 ldy player0y
 lda (player0pointer),y
.continuelastP0
 sta GRP0



 ifnconst no_blank_lines
   lda missile0height ;3
   dcp missile0y ;5
   sbc stack1
   sta ENAM0 ;3
   jmp .endkerloop
 else
 ifconst readpaddle
   ldy currentpaddle
   lda INPT0,y
   bpl noreadpaddle2
   inc paddle
   jmp .endkerloop
noreadpaddle2
   sleep 4
   jmp .endkerloop
 else ; no_blank_lines and no paddle reading
 sleep 14
 jmp .endkerloop
 endif
 endif


;  ifconst donepaddleskip
;paddleskipread
 ; this is kind of lame, since it requires 4 cycles from a page boundary crossing
 ; plus we get a lo-res paddle read
; bmi donepaddleskip
;  endif

.skipDrawlastP0
 sleep 2
 lda #0
 jmp .continuelastP0

 ifconst no_blank_lines
no_blank_lines_bailout
 ldx #0
 endif

endkernel
 ; 6 digit score routine
 stx PF1
 stx PF2
 stx PF0
 clc

 ifconst pfrowheight
 lda #pfrowheight+2
 else
 ifnconst pfres
   lda #10
 else
   lda #(96/pfres)+2 ; try to come close to the real size
 endif
 endif

 sbc playfieldpos
 sta playfieldpos
 txa

 ifconst shakescreen
   bit shakescreen
   bmi noshakescreen2
   ldx #$3D
noshakescreen2
 endif

   sta WSYNC,x

;                STA WSYNC ;first one, need one more
 sta REFP0
 sta REFP1
                STA GRP0
                STA GRP1
 ;               STA PF1
   ;             STA PF2
 sta HMCLR
 sta ENAM0
 sta ENAM1
 sta ENABL

 lda temp2 ;restore variables that were obliterated by kernel
 sta player0y
 lda temp3
 sta player1y
 ifnconst player1colors
   lda temp6
   sta missile1y
 endif
 ifnconst playercolors
 ifnconst readpaddle
   lda temp5
   sta missile0y
 endif
 endif
 lda stack2
 sta bally

 ifconst no_blank_lines
 sta WSYNC
 endif

 lda INTIM
 clc
 ifnconst vblank_time
 adc #43+12+87
 else
 adc #vblank_time+12+87
 endif
; sta WSYNC
 sta TIM64T

 ifconst minikernel
 jsr minikernel
 endif

 ; now reassign temp vars for score pointers

; score pointers contain:
; score1-5: lo1,lo2,lo3,lo4,lo5,lo6
; swap lo2->temp1
; swap lo4->temp3
; swap lo6->temp5
 ifnconst noscore
 lda scorepointers+1
; ldy temp1
 sta temp1
; sty scorepointers+1

 lda scorepointers+3
; ldy temp3
 sta temp3
; sty scorepointers+3


 sta HMCLR
 tsx
 stx stack1 
 ldx #$10
 stx HMP0

 sta WSYNC
 ldx #0
                STx GRP0
                STx GRP1 ; seems to be needed because of vdel

 lda scorepointers+5
; ldy temp5
 sta temp5,x
; sty scorepointers+5
 lda #>scoretable
 sta scorepointers+1
 sta scorepointers+3
 sta scorepointers+5,x
 sta temp2,x
 sta temp4,x
 sta temp6,x
                LDY #7
                STA RESP0
                STA RESP1


        LDA #$03
        STA NUSIZ0
        STA NUSIZ1,x
        STA VDELP0
        STA VDELP1
        LDA #$20
        STA HMP1
               LDA scorecolor 
;               STA HMCLR
;               STA WSYNC; second one
                STA HMOVE ; cycle 73 ?

                STA COLUP0
                STA COLUP1
 lda  (scorepointers),y
 sta  GRP0
 ifconst pfscore
 lda pfscorecolor
 sta COLUPF
 endif
 lda  (scorepointers+8),y
 sta WSYNC
 sleep 2
 jmp beginscore

 if ((<*)>$d4)
 align 256 ; kludge that potentially wastes space!  should be fixed!
 endif

loop2
 lda  (scorepointers),y     ;+5  68  204
 sta  GRP0            ;+3  71  213      D1     --      --     --
 ifconst pfscore
 lda.w pfscore1
 sta PF1
 else
 sleep 7
 endif
 ; cycle 0
 lda  (scorepointers+$8),y  ;+5   5   15
beginscore
 sta  GRP1            ;+3   8   24      D1     D1      D2     --
 lda  (scorepointers+$6),y  ;+5  13   39
 sta  GRP0            ;+3  16   48      D3     D1      D2     D2
 lax  (scorepointers+$2),y  ;+5  29   87
 txs
 lax  (scorepointers+$4),y  ;+5  36  108
 sleep 3

 ifconst pfscore
 lda pfscore2
 sta PF1
 else
 sleep 6
 endif

 lda  (scorepointers+$A),y  ;+5  21   63
 stx  GRP1            ;+3  44  132      D3     D3      D4     D2!
 tsx
 stx  GRP0            ;+3  47  141      D5     D3!     D4     D4
 sta  GRP1            ;+3  50  150      D5     D5      D6     D4!
 sty  GRP0            ;+3  53  159      D4*    D5!     D6     D6
 dey
 bpl  loop2           ;+2  60  180

 ldx stack1 
 txs
; lda scorepointers+1
 ldy temp1
; sta temp1
 sty scorepointers+1

                LDA #0   
 sta PF1
               STA GRP0
                STA GRP1
        STA VDELP0
        STA VDELP1;do we need these
        STA NUSIZ0
        STA NUSIZ1

; lda scorepointers+3
 ldy temp3
; sta temp3
 sty scorepointers+3

; lda scorepointers+5
 ldy temp5
; sta temp5
 sty scorepointers+5
 endif ;noscore
 LDA #%11000010
 sta WSYNC
 STA VBLANK
 RETURN

 ifconst shakescreen
doshakescreen
   bit shakescreen
   bmi noshakescreen
   sta WSYNC
noshakescreen
   ldx missile0height
   inx
   rts
 endif

start
 sei
 cld
 ldy #0
 lda $D0
 cmp #$2C               ;check RAM location #1
 bne MachineIs2600
 lda $D1
 cmp #$A9               ;check RAM location #2
 bne MachineIs2600
 dey
MachineIs2600
 ldx #0
 txa
clearmem
 inx
 txs
 pha
 bne clearmem
 sty temp1
 ifconst pfrowheight
 lda pfrowheight
 else
 ifconst pfres
 lda #(96/pfres)
 else
 lda #8
 endif
 endif
 sta playfieldpos
 ldx #5
initscore
 lda #<scoretable
 sta scorepointers,x 
 dex
 bpl initscore
 lda #1
 sta CTRLPF
 ora INTIM
 sta rand

 ifconst multisprite
   jsr multisprite_setup
 endif

 ifnconst bankswitch
   jmp game
 else
   lda #>(game-1)
   pha
   lda #<(game-1)
   pha
   pha
   pha
   ldx #1
   jmp BS_jsr
 endif
; playfield drawing routines
; you get a 32x12 bitmapped display in a single color :)
; 0-31 and 0-11

pfclear ; clears playfield - or fill with pattern
 ifconst pfres
 ldx #pfres*4-1
 else
 ldx #47
 endif
pfclear_loop
 ifnconst superchip
 sta playfield,x
 else
 sta playfield-128,x
 endif
 dex
 bpl pfclear_loop
 RETURN
 
setuppointers
 stx temp2 ; store on.off.flip value
 tax ; put x-value in x 
 lsr
 lsr
 lsr ; divide x pos by 8 
 sta temp1
 tya
 asl
 asl ; multiply y pos by 4
 clc
 adc temp1 ; add them together to get actual memory location offset
 tay ; put the value in y
 lda temp2 ; restore on.off.flip value
 rts

pfread
;x=xvalue, y=yvalue
 jsr setuppointers
 lda setbyte,x
 and playfield,y
 eor setbyte,x
; beq readzero
; lda #1
; readzero
 RETURN

pfpixel
;x=xvalue, y=yvalue, a=0,1,2
 jsr setuppointers

 ifconst bankswitch
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon_r  ; if "on" go to on
 lsr
 bcs pixeloff_r ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixelon_r
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN
pixeloff_r
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 RETURN

 else
 jmp plotpoint
 endif

pfhline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 jmp noinc
keepgoing
 inx
 txa
 and #7
 bne noinc
 iny
noinc
 jsr plotpoint
 cpx temp3
 bmi keepgoing
 RETURN

pfvline
;x=xvalue, y=yvalue, a=0,1,2, temp3=endx
 jsr setuppointers
 sty temp1 ; store memory location offset
 inc temp3 ; increase final x by 1 
 lda temp3
 asl
 asl ; multiply by 4
 sta temp3 ; store it
 ; Thanks to Michael Rideout for fixing a bug in this code
 ; right now, temp1=y=starting memory location, temp3=final
 ; x should equal original x value
keepgoingy
 jsr plotpoint
 iny
 iny
 iny
 iny
 cpy temp3
 bmi keepgoingy
 RETURN

plotpoint
 lda temp2 ; load on.off.flip value (0,1, or 2)
 beq pixelon  ; if "on" go to on
 lsr
 bcs pixeloff ; value is 1 if true
 lda playfield,y ; if here, it's "flip"
 eor setbyte,x
  ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixelon
 lda playfield,y
 ora setbyte,x
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts
pixeloff
 lda setbyte,x
 eor #$ff
 and playfield,y
 ifconst superchip
 sta playfield-128,y
 else
 sta playfield,y
 endif
 rts

setbyte
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
 .byte $80
 .byte $40
 .byte $20
 .byte $10
 .byte $08
 .byte $04
 .byte $02
 .byte $01
 .byte $01
 .byte $02
 .byte $04
 .byte $08
 .byte $10
 .byte $20
 .byte $40
 .byte $80
pfscroll ;(a=0 left, 1 right, 2 up, 4 down, 6=upup, 12=downdown)
 bne notleft
;left
 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
leftloop
 lda playfield-1,x
 lsr

 ifconst superchip
 lda playfield-2,x
 rol
 sta playfield-130,x
 lda playfield-3,x
 ror
 sta playfield-131,x
 lda playfield-4,x
 rol
 sta playfield-132,x
 lda playfield-1,x
 ror
 sta playfield-129,x
 else
 rol playfield-2,x
 ror playfield-3,x
 rol playfield-4,x
 ror playfield-1,x
 endif

 txa
 sbx #4
 bne leftloop
 RETURN

notleft
 lsr
 bcc notright
;right

 ifconst pfres
 ldx #pfres*4
 else
 ldx #48
 endif
rightloop
 lda playfield-4,x
 lsr
 ifconst superchip
 lda playfield-3,x
 rol
 sta playfield-131,x
 lda playfield-2,x
 ror
 sta playfield-130,x
 lda playfield-1,x
 rol
 sta playfield-129,x
 lda playfield-4,x
 ror
 sta playfield-132,x
 else
 rol playfield-3,x
 ror playfield-2,x
 rol playfield-1,x
 ror playfield-4,x
 endif
 txa
 sbx #4
 bne rightloop
  RETURN

notright
 lsr
 bcc notup
;up
 lsr
 bcc onedecup
 dec playfieldpos
onedecup
 dec playfieldpos
 beq shiftdown 
 bpl noshiftdown2 
shiftdown
  ifconst pfrowheight
 lda #pfrowheight
 else
 ifnconst pfres
   lda #8
 else
   lda #(96/pfres) ; try to come close to the real size
 endif
 endif

 sta playfieldpos
 lda playfield+3
 sta temp4
 lda playfield+2
 sta temp3
 lda playfield+1
 sta temp2
 lda playfield
 sta temp1
 ldx #0
up2
 lda playfield+4,x
 ifconst superchip
 sta playfield-128,x
 lda playfield+5,x
 sta playfield-127,x
 lda playfield+6,x
 sta playfield-126,x
 lda playfield+7,x
 sta playfield-125,x
 else
 sta playfield,x
 lda playfield+5,x
 sta playfield+1,x
 lda playfield+6,x
 sta playfield+2,x
 lda playfield+7,x
 sta playfield+3,x
 endif
 txa
 sbx #252
 ifconst pfres
 cpx #(pfres-1)*4
 else
 cpx #44
 endif
 bne up2

 lda temp4
 
 ifconst superchip
 ifconst pfres
 sta playfield+pfres*4-129
 lda temp3
 sta playfield+pfres*4-130
 lda temp2
 sta playfield+pfres*4-131
 lda temp1
 sta playfield+pfres*4-132
 else
 sta playfield+47-128
 lda temp3
 sta playfield+46-128
 lda temp2
 sta playfield+45-128
 lda temp1
 sta playfield+44-128
 endif
 else
 ifconst pfres
 sta playfield+pfres*4-1
 lda temp3
 sta playfield+pfres*4-2
 lda temp2
 sta playfield+pfres*4-3
 lda temp1
 sta playfield+pfres*4-4
 else
 sta playfield+47
 lda temp3
 sta playfield+46
 lda temp2
 sta playfield+45
 lda temp1
 sta playfield+44
 endif
 endif
noshiftdown2
 RETURN


notup
;down
 lsr
 bcs oneincup
 inc playfieldpos
oneincup
 inc playfieldpos
 lda playfieldpos

  ifconst pfrowheight
 cmp #pfrowheight+1
 else
 ifnconst pfres
   cmp #9
 else
   cmp #(96/pfres)+1 ; try to come close to the real size
 endif
 endif

 bcc noshiftdown 
 lda #1
 sta playfieldpos

 ifconst pfres
 lda playfield+pfres*4-1
 sta temp4
 lda playfield+pfres*4-2
 sta temp3
 lda playfield+pfres*4-3
 sta temp2
 lda playfield+pfres*4-4
 else
 lda playfield+47
 sta temp4
 lda playfield+46
 sta temp3
 lda playfield+45
 sta temp2
 lda playfield+44
 endif

 sta temp1

 ifconst pfres
 ldx #(pfres-1)*4
 else
 ldx #44
 endif
down2
 lda playfield-1,x
 ifconst superchip
 sta playfield-125,x
 lda playfield-2,x
 sta playfield-126,x
 lda playfield-3,x
 sta playfield-127,x
 lda playfield-4,x
 sta playfield-128,x
 else
 sta playfield+3,x
 lda playfield-2,x
 sta playfield+2,x
 lda playfield-3,x
 sta playfield+1,x
 lda playfield-4,x
 sta playfield,x
 endif
 txa
 sbx #4
 bne down2

 lda temp4
 ifconst superchip
 sta playfield-125
 lda temp3
 sta playfield-126
 lda temp2
 sta playfield-127
 lda temp1
 sta playfield-128
 else
 sta playfield+3
 lda temp3
 sta playfield+2
 lda temp2
 sta playfield+1
 lda temp1
 sta playfield
 endif
noshiftdown
 RETURN
;standard routines needed for pretty much all games
; just the random number generator is left - maybe we should remove this asm file altogether?
; repositioning code and score pointer setup moved to overscan
; read switches, joysticks now compiler generated (more efficient)

randomize
	lda rand
	lsr
 ifconst rand16
	rol rand16
 endif
	bcc noeor
	eor #$B4
noeor
	sta rand
 ifconst rand16
	eor rand16
 endif
	RETURN
drawscreen
 ifconst debugscore
   ldx #14
   lda INTIM ; display # cycles left in the score

 ifconst mincycles
 lda mincycles 
 cmp INTIM
 lda mincycles
 bcc nochange
 lda INTIM
 sta mincycles
nochange
 endif

;   cmp #$2B
;   bcs no_cycles_left
   bmi cycles_left
   ldx #64
   eor #$ff ;make negative
cycles_left
   stx scorecolor
   and #$7f ; clear sign bit
   tax
   lda scorebcd,x
   sta score+2
   lda scorebcd1,x
   sta score+1
   jmp done_debugscore   
scorebcd
 .byte $00, $64, $28, $92, $56, $20, $84, $48, $12, $76, $40
 .byte $04, $68, $32, $96, $60, $24, $88, $52, $16, $80, $44
 .byte $08, $72, $36, $00, $64, $28, $92, $56, $20, $84, $48
 .byte $12, $76, $40, $04, $68, $32, $96, $60, $24, $88
scorebcd1
 .byte 0, 0, 1, 1, 2, 3, 3, 4, 5, 5, 6
 .byte 7, 7, 8, 8, 9, $10, $10, $11, $12, $12, $13
 .byte $14, $14, $15, $16, $16, $17, $17, $18, $19, $19, $20
 .byte $21, $21, $22, $23, $23, $24, $24, $25, $26, $26
done_debugscore
 endif

 ifconst debugcycles
   lda INTIM ; if we go over, it mucks up the background color
;   cmp #$2B
;   BCC overscan
   bmi overscan
   sta COLUBK
   bcs doneoverscan
 endif

 
overscan
 lda INTIM ;wait for sync
 bmi overscan
doneoverscan
;do VSYNC
 lda #2
 sta WSYNC
 sta VSYNC
 STA WSYNC
 STA WSYNC
 LDA #0
 STA WSYNC
 STA VSYNC
 sta VBLANK
 ifnconst overscan_time
 lda #37+128
 else
 lda #overscan_time+128
 endif
 sta TIM64T

 ifconst legacy
 if legacy < 100
 ldx #4
adjustloop
 lda player0x,x
 sec
 sbc #14 ;?
 sta player0x,x
 dex
 bpl adjustloop
 endif
 endif
 if (<*)>$F0
 align 256, $EA
 endif
  sta WSYNC
  ldx #4
  SLEEP 3
HorPosLoop       ;     5
  lda player0x,X  ;+4   9
  sec           ;+2  11
DivideLoop
  sbc #15
  bcs DivideLoop;+4  15
  sta temp1,X    ;+4  19
  sta RESP0,X   ;+4  23
  sta WSYNC
  dex
  bpl HorPosLoop;+5   5
                ;     4

  ldx #4
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 18

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 32

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 46

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 60

  dex
  ldy temp1,X
  lda repostable-256,Y
  sta HMP0,X    ;+14 74

  sta WSYNC
 
  sta HMOVE     ;+3   3


 ifconst legacy
 if legacy < 100
 ldx #4
adjustloop2
 lda player0x,x
 clc
 adc #14 ;?
 sta player0x,x
 dex
 bpl adjustloop2
 endif
 endif




;set score pointers
 lax score+2
 jsr scorepointerset
 sty scorepointers+5
 stx scorepointers+2
 lax score+1
 jsr scorepointerset
 sty scorepointers+4
 stx scorepointers+1
 lax score
 jsr scorepointerset
 sty scorepointers+3
 stx scorepointers

vblk
; run possible vblank bB code
 ifconst vblank_bB_code
   jsr vblank_bB_code
 endif
vblk2
 LDA INTIM
 bmi vblk2
 jmp kernel
 

    .byte $80,$70,$60,$50,$40,$30,$20,$10,$00
    .byte $F0,$E0,$D0,$C0,$B0,$A0,$90
repostable

scorepointerset
 and #$0F
 asl
 asl
 asl
 adc #<scoretable
 tay 
 txa
; and #$F0
; lsr
 asr #$F0
 adc #<scoretable
 tax
 rts
; y and a contain multiplicands, result in a

mul8
 sty temp1
 sta temp2
 lda #0
reptmul8
 lsr temp2
 bcc skipmul8
 clc
 adc temp1
;bcs donemul8 might save cycles?
skipmul8
;beq donemul8 might save cycles?
 asl temp1
 bne reptmul8
donemul8
 RETURN

div8
 ; a=numerator y=denominator, result in a
 cpy #2
 bcc div8end+1;div by 0 = bad, div by 1=no calc needed, so bail out
 sty temp1
 ldy #$ff
div8loop
 sbc temp1
 iny
 bcs div8loop
div8end
 tya
 ; result in a
 RETURN
	include "banner_img.asm"

minikernel
	;setup score pointers to point at my bitmap slices instead

	lda (#<bmp_banner_1_00)
 if #bmp_banner_1_height != #bmp_banner_1_window
        clc
        adc #(#bmp_banner_1_height-#bmp_banner_1_window)
 ifconst bmp_banner_1_index
        sec
        sbc bmp_banner_1_index
 endif
 endif
        sta scorepointers+0
        lda #>bmp_banner_1_00
        sta scorepointers+1

	lda (#<bmp_banner_1_01)
 if #bmp_banner_1_height != #bmp_banner_1_window
        clc
        adc #(#bmp_banner_1_height-#bmp_banner_1_window)
 ifconst bmp_banner_1_index
        sec
        sbc bmp_banner_1_index
 endif
 endif
        sta scorepointers+2
        lda #>bmp_banner_1_01
        sta scorepointers+3

	lda (#<bmp_banner_1_02)
 if #bmp_banner_1_height != #bmp_banner_1_window
        clc
        adc #(#bmp_banner_1_height-#bmp_banner_1_window)
 ifconst bmp_banner_1_index
        sec
        sbc bmp_banner_1_index
 endif
 endif
        sta scorepointers+4
        lda #>bmp_banner_1_02
        sta scorepointers+5

	lda (#<bmp_banner_1_03)
 if #bmp_banner_1_height != #bmp_banner_1_window
        clc
        adc #(#bmp_banner_1_height-#bmp_banner_1_window)
 ifconst bmp_banner_1_index
        sec
        sbc bmp_banner_1_index
 endif
 endif
        sta scorepointers+6
        lda #>bmp_banner_1_03
        sta scorepointers+7

	lda (#<bmp_banner_1_04)
 if #bmp_banner_1_height != #bmp_banner_1_window
        clc
        adc #(#bmp_banner_1_height-#bmp_banner_1_window)
 ifconst bmp_banner_1_index
        sec
        sbc bmp_banner_1_index
 endif
 endif
        sta scorepointers+8
        lda #>bmp_banner_1_04
        sta scorepointers+9

	lda (#<bmp_banner_1_05)
 if #bmp_banner_1_height != #bmp_banner_1_window
        clc
        adc #(#bmp_banner_1_height-#bmp_banner_1_window)
 ifconst bmp_banner_1_index
        sec
        sbc bmp_banner_1_index
 endif
 endif
        sta scorepointers+10
        lda #>bmp_banner_1_05
        sta scorepointers+11

        lda bmp_banner_1_color
        sta COLUP0              ;3
        sta COLUP1              ;3
        sta HMCLR               ;3

	ldy #(bmp_banner_1_window)

draw_bmp_banner

	lda #3
	sta NUSIZ0	;3=Player and Missile are drawn twice 32 clocks apart 
	sta NUSIZ1	;3=Player and Missile are drawn twice 32 clocks apart 

 ifconst bannerbackcolor
	lda bannerbackcolor
 else
	lda #0
 endif
        sta COLUPF              ;3
	sta COLUBK
	lda #5
	sta CTRLPF

	tsx
	stx stack1 ;save the stack pointer

	;postion P0 and P1, Ball and Missile0
	lda #%10010000
	sta HMP0
	lda #%10100000
	sta HMP1
	lda #%00110000
	sta HMBL
	lda #%11110000
	sta HMM0

	sta WSYNC
	sleep 29
	sta RESM0
	sleep 3
	sta RESP0 ; 3
	sta RESP1 ; 3
	sta RESBL
	sta WSYNC
	sta HMOVE 	;3

	lda #0		;2
	sta VDELP0	;3
	sta VDELP1	;3

	;sleep (57-7)		;59
	sleep (57-8-8-10-2)		;59
	lda #%11111111
	sta PF1
	lda #%00000001
	sta PF2

	lda #2
	sta ENABL
	sta ENAM0

	jmp pfbanner_loop_line1 	;3

      if >. != >[.+$2a]
      align 256
      endif

pfbanner_loop_line1
	dey
	lda (scorepointers+0),y 	;5
	sta GRP0		;3

        ;fix the lost bit0 in the first character
        rol             ;2
        eor #2          ;2
        sta ENABL       ;3

	lda (scorepointers+2),y 	;5
	sta GRP1		; 3

	sty aux6

	lax (scorepointers+10),y	; 5
	txs			; 2	
	lax (scorepointers+8),y	; 5

	lda (scorepointers+6),y	; 5
	sta aux5
	lda (scorepointers+4),y	; 5
	ldy aux5

	sta GRP0
	sty GRP1
	stx GRP0
	tsx
	stx GRP1

	ldy aux6
	
	;dey			;2
	;bpl pfbanner_loop_line1		;2/3
	bne pfbanner_loop_line1		;2/3

pfbanner_codeend
 ;echo "critical code in banner is ",(pfbanner_codeend-pfbanner_loop_line1), " bytes long."

	lda #0
	sta GRP0
	sta GRP1
	sta ENABL
	sta ENAM0
	sta PF1
	sta PF2
	lda #1
	sta CTRLPF

	ldx stack1 ;restore the stack pointer
	txs

	;fix the bB score pointers, which we borrowed...
	lax score+2
	jsr scorepointerset
	sty scorepointers+5
	stx scorepointers+2
	lax score+1
	jsr scorepointerset
	sty scorepointers+4
	stx scorepointers+1
	lax score
	jsr scorepointerset
	sty scorepointers+3
	stx scorepointers

	rts
game
.L00 ;  rem Generated 8/18/2010 10:21:08 PM by Visual bB Version 1.0.0.550

.L01 ;  rem *******************************************

.L02 ;  rem * Passthrough 2600                         *

.L03 ;  rem * A simple but fun game                   *

.L04 ;  rem * By Cliff Friedel                               *

.L05 ;  rem * Custom Minikernel by Reveng      *

.L06 ;  rem * Version 1.0.0	                               *

.L07 ;  rem *                                                      *

.L08 ;  rem * 8/30.2010                                     *

.L09 ;  rem *******************************************

.
 ; 

.L010 ;  set tv ntsc

.
 ; 

.L011 ;  include div_mul.asm

.L012 ;  include banner_mk.asm

.L013 ;  set smartbranching on

.
 ; 

.L014 ;  dim sc1 = score

.L015 ;  dim sc2 = score + 1

.L016 ;  dim sc3 = score + 2

.
 ; 

.L017 ;  gosub title

 jsr .title

.
 ; 

.main_loop
 ; main_loop

.L018 ;  if switchreset then reboot

 lda #1
 bit SWCHB
	BNE .skipL018
.condpart0
	JMP ($FFFC)
.skipL018
.L019 ;  scorecolor  =  14

	LDA #14
	STA scorecolor
.L020 ;  if h = 0 then COLUP0 = $C0 else COLUP0 = c

	LDA h
	CMP #0
     BNE .skipL020
.condpart1
	LDA #$C0
	STA COLUP0
 jmp .skipelse0
.skipL020
	LDA c
	STA COLUP0
.skipelse0
.L021 ;  if i  >  0 then COLUP0 = i

	LDA #0
	CMP i
     BCS .skipL021
.condpart2
	LDA i
	STA COLUP0
.skipL021
.L022 ;  if x{0} then COLUP1 = $C6 else COLUP1 = $44

	LDA x
	LSR
	BCC .skipL022
.condpart3
	LDA #$C6
	STA COLUP1
 jmp .skipelse1
.skipL022
	LDA #$44
	STA COLUP1
.skipelse1
.L023 ;  if l = 1 then gosub level1

	LDA l
	CMP #1
     BNE .skipL023
.condpart4
 jsr .level1

.skipL023
.L024 ;  if l = 2 then gosub level2

	LDA l
	CMP #2
     BNE .skipL024
.condpart5
 jsr .level2

.skipL024
.L025 ;  if l = 3 then gosub level3

	LDA l
	CMP #3
     BNE .skipL025
.condpart6
 jsr .level3

.skipL025
.L026 ;  if l = 4 then gosub level4

	LDA l
	CMP #4
     BNE .skipL026
.condpart7
 jsr .level4

.skipL026
.L027 ;  if l = 5 then gosub level5

	LDA l
	CMP #5
     BNE .skipL027
.condpart8
 jsr .level5

.skipL027
.L028 ;  if l = 6 then gosub level6

	LDA l
	CMP #6
     BNE .skipL028
.condpart9
 jsr .level6

.skipL028
.L029 ;  if l = 7 then gosub level7

	LDA l
	CMP #7
     BNE .skipL029
.condpart10
 jsr .level7

.skipL029
.L030 ;  if l = 8 then gosub level8

	LDA l
	CMP #8
     BNE .skipL030
.condpart11
 jsr .level8

.skipL030
.L031 ;  if l = 9 then gosub level9

	LDA l
	CMP #9
     BNE .skipL031
.condpart12
 jsr .level9

.skipL031
.L032 ;  if l = 10 then gosub level10

	LDA l
	CMP #10
     BNE .skipL032
.condpart13
 jsr .level10

.skipL032
.L033 ;  if l > 10 then goto gameover

	LDA #10
	CMP l
     BCS .skipL033
.condpart14
 jmp .gameover

.skipL033
.L034 ;  if n > 0 then gosub makenoise

	LDA #0
	CMP n
     BCS .skipL034
.condpart15
 jsr .makenoise

.skipL034
.L035 ;  gosub powerups

 jsr .powerups

.L036 ;  if sc1 = $00  &&  sc2 = $00  &&  sc3 = $00 then goto gameover

	LDA sc1
	CMP #$00
     BNE .skipL036
.condpart16
	LDA sc2
	CMP #$00
     BNE .skip16then
.condpart17
	LDA sc3
	CMP #$00
     BNE .skip17then
.condpart18
 jmp .gameover

.skip17then
.skip16then
.skipL036
.L037 ;  gosub moveplayer

 jsr .moveplayer

.L038 ;  if g <> 0 then COLUPF  =  0 else COLUPF = c

	LDA g
	CMP #0
     BEQ .skipL038
.condpart19
	LDA #0
	STA COLUPF
 jmp .skipelse2
.skipL038
	LDA c
	STA COLUPF
.skipelse2
.L039 ;  drawscreen

 jsr drawscreen
.L040 ;  if joy0fire  &&  f = 0 then gosub checkplayercol

 lda #$80
 bit INPT4
	BNE .skipL040
.condpart20
	LDA f
	CMP #0
     BNE .skip20then
.condpart21
 jsr .checkplayercol

.skip20then
.skipL040
.L041 ;  if f  >  0 then f = f + 1  :  if f  >  10 then f = 0

	LDA #0
	CMP f
     BCS .skipL041
.condpart22
	INC f
	LDA #10
	CMP f
     BCS .skip22then
.condpart23
	LDA #0
	STA f
.skip22then
.skipL041
.L042 ;  if g  >  0 then g = g + 1  :  if g  >  200 then g = 0

	LDA #0
	CMP g
     BCS .skipL042
.condpart24
	INC g
	LDA #200
	CMP g
     BCS .skip24then
.condpart25
	LDA #0
	STA g
.skip24then
.skipL042
.L043 ;  if h  >  0 then h = h + 1  :  if h  >  200 then h = 0

	LDA #0
	CMP h
     BCS .skipL043
.condpart26
	INC h
	LDA #200
	CMP h
     BCS .skip26then
.condpart27
	LDA #0
	STA h
.skip26then
.skipL043
.L044 ;  if i  >  0 then i = i + 1  :  if i  >  200 then i = 0

	LDA #0
	CMP i
     BCS .skipL044
.condpart28
	INC i
	LDA #200
	CMP i
     BCS .skip28then
.condpart29
	LDA #0
	STA i
.skip28then
.skipL044
.L045 ;  if e  >  0 then e = e + 1  :  if e  >  200 then e = 0

	LDA #0
	CMP e
     BCS .skipL045
.condpart30
	INC e
	LDA #200
	CMP e
     BCS .skip30then
.condpart31
	LDA #0
	STA e
.skip30then
.skipL045
.L046 ;  if y  >  0 then y = y + 1  :  if y  = 200 then y = 1  :  w = w + 1

	LDA #0
	CMP y
     BCS .skipL046
.condpart32
	INC y
	LDA y
	CMP #200
     BNE .skip32then
.condpart33
	LDA #1
	STA y
	INC w
.skip32then
.skipL046
.L047 ;  if w  >  1 then y = 0  :  w = 0

	LDA #1
	CMP w
     BCS .skipL047
.condpart34
	LDA #0
	STA y
	STA w
.skipL047
.L048 ;  if e = 0  &&  l < 11 then score  =  score  -  100

	LDA e
	CMP #0
     BNE .skipL048
.condpart35
	LDA l
	CMP #11
     BCS .skip35then
.condpart36
	SED
	SEC
	LDA score+2
	SBC #$00
	STA score+2
	LDA score+1
	SBC #$01
	STA score+1
	LDA score
	SBC #$00
	STA score
	CLD
.skip35then
.skipL048
.L049 ;  goto main_loop

 jmp .main_loop

.
 ; 

.moveplayer
 ; moveplayer

.L050 ;  if l  >  1 then m = m + 1

	LDA #1
	CMP l
     BCS .skipL050
.condpart37
	INC m
.skipL050
.L051 ;  if m  >  l then m  =  0

	LDA l
	CMP m
     BCS .skipL051
.condpart38
	LDA #0
	STA m
.skipL051
.L052 ;  if l  <=  1  ||  l <> m then SingleStep

	LDA #1
	CMP l
 if ((* - .SingleStep) < 127) && ((* - .SingleStep) > -128)
	bcs .SingleStep
 else
	bcc .0skipSingleStep
	jmp .SingleStep
.0skipSingleStep
 endif
	LDA l
	CMP m
 if ((* - .SingleStep) < 127) && ((* - .SingleStep) > -128)
	BNE .SingleStep
 else
	beq .1skipSingleStep
	jmp .SingleStep
.1skipSingleStep
 endif
.L053 ;  if p  =  1 then player0x  =  player0x  +   ( l / 2 ) 

	LDA p
	CMP #1
     BNE .skipL053
.condpart39
; complex statement detected
	LDA player0x
	PHA
	LDA l
	lsr
	TSX
	INX
	TXS
	CLC
	ADC $100,x
	STA player0x
.skipL053
.L054 ;  if p  =  0 then player0x  =  player0x  -   ( l / 2 ) 

	LDA p
	CMP #0
     BNE .skipL054
.condpart40
; complex statement detected
	LDA player0x
	PHA
	LDA l
	lsr
	TAY
	PLA
	TSX
	STY $00,x
	SEC
	SBC $100,x
	STA player0x
.skipL054
.SingleStep
 ; SingleStep

.L055 ;  if p  =  1 then player0x  =  player0x  +  1

	LDA p
	CMP #1
     BNE .skipL055
.condpart41
	INC player0x
.skipL055
.L056 ;  if p  =  0 then player0x  =  player0x  -  1

	LDA p
	CMP #0
     BNE .skipL056
.condpart42
	DEC player0x
.skipL056
.L057 ;  if player0x  <  140 then Negchange

	LDA player0x
	CMP #140
 if ((* - .Negchange) < 127) && ((* - .Negchange) > -128)
	bcc .Negchange
 else
	bcs .2skipNegchange
	jmp .Negchange
.2skipNegchange
 endif
.L058 ;  p  =  0

	LDA #0
	STA p
.L059 ;  player0x  =  140

	LDA #140
	STA player0x
.Negchange
 ; Negchange

.L060 ;  if player0x  >  16 then Poschange

	LDA #16
	CMP player0x
 if ((* - .Poschange) < 127) && ((* - .Poschange) > -128)
	bcc .Poschange
 else
	bcs .3skipPoschange
	jmp .Poschange
.3skipPoschange
 endif
.L061 ;  p  =  1

	LDA #1
	STA p
.L062 ;  player0x  =  16

	LDA #16
	STA player0x
.Poschange
 ; Poschange

.L063 ;  return

	RTS
.
 ; 

.powerups
 ; powerups

.L064 ;  rem if there is no powerup on the board, pick one using the random number generator

.L065 ;  if y <> 0 then PowerupPicked

	LDA y
	CMP #0
 if ((* - .PowerupPicked) < 127) && ((* - .PowerupPicked) > -128)
	BNE .PowerupPicked
 else
	beq .4skipPowerupPicked
	jmp .PowerupPicked
.4skipPowerupPicked
 endif
.L066 ;  x  =   ( rand & 7 )  + 1

; complex statement detected
 jsr randomize
	AND #7
	CLC
	ADC #1
	STA x
.L067 ;  y = 1

	LDA #1
	STA y
.100 ; 100 z = rand  :  rem I am using a line number here so I can call back to it if the number is out of bounds

 jsr randomize
	STA z
.L068 ;  if z  <  30  ||  z  >  130 then goto 100  :  rem this should put the ships closer to the screen 

	LDA z
	CMP #30
     BCS .skipL068
.condpart43
 jmp .condpart44
.skipL068
	LDA #130
	CMP z
     BCS .skip5OR
.condpart44
 jmp .100
.skip5OR
.L069 ;  player1x  =  z

	LDA z
	STA player1x
.110 ; 110 z =  ( rand & 15 )   :  rem I am using a line number here so I can call back to it if the number is out of bounds

; complex statement detected
 jsr randomize
	AND #15
	STA z
.L070 ;  if z  <  1  ||  z  >  11 then goto 110  :  rem this should put the ships closer to the screen

	LDA z
	CMP #1
     BCS .skipL070
.condpart45
 jmp .condpart46
.skipL070
	LDA #11
	CMP z
     BCS .skip6OR
.condpart46
 jmp .110
.skip6OR
.L071 ;  z = z * 8

	LDA z
	asl
	asl
	asl
	STA z
.L072 ;  player1y  =  z

	LDA z
	STA player1y
.L073 ;  COLUPF = c

	LDA c
	STA COLUPF
.L074 ;  drawscreen

 jsr drawscreen
.PowerupPicked
 ; PowerupPicked

.L075 ;  if !collision(player0,player1) then EndCollision

	BIT CXPPMM
 if ((* - .EndCollision) < 127) && ((* - .EndCollision) > -128)
	bpl .EndCollision
 else
	bmi .5skipEndCollision
	jmp .EndCollision
.5skipEndCollision
 endif
.L076 ;  rem x =1 Score+100000

.L077 ;  if x <> 1 then SkipOne

	LDA x
	CMP #1
 if ((* - .SkipOne) < 127) && ((* - .SkipOne) > -128)
	BNE .SkipOne
 else
	beq .6skipSkipOne
	jmp .SkipOne
.6skipSkipOne
 endif
.L078 ;  if sc1  <  $89  &&  sc2  <  $99 then score = score + 100000 else score  = 999900

	LDA sc1
	CMP #$89
     BCS .skipL078
.condpart47
	LDA sc2
	CMP #$99
     BCS .skip47then
.condpart48
	SED
	CLC
	LDA score+2
	ADC #$00
	STA score+2
	LDA score+1
	ADC #$00
	STA score+1
	LDA score
	ADC #$10
	STA score
	CLD
 jmp .skipelse3
.skip47then
.skipL078
	LDA #$00
	STA score+2
	LDA #$99
	STA score+1
	LDA #$99
	STA score
.skipelse3
.L079 ;  n = 3

	LDA #3
	STA n
.SkipOne
 ; SkipOne

.L080 ;  rem x =2 Score-100000

.L081 ;  if x <> 2 then SkipTwo

	LDA x
	CMP #2
 if ((* - .SkipTwo) < 127) && ((* - .SkipTwo) > -128)
	BNE .SkipTwo
 else
	beq .7skipSkipTwo
	jmp .SkipTwo
.7skipSkipTwo
 endif
.L082 ;  score = score - 100000

	SED
	SEC
	LDA score+2
	SBC #$00
	STA score+2
	LDA score+1
	SBC #$00
	STA score+1
	LDA score
	SBC #$10
	STA score
	CLD
.L083 ;  if sc1  <  $09  &&  sc2  <  $99 then goto gameover

	LDA sc1
	CMP #$09
     BCS .skipL083
.condpart49
	LDA sc2
	CMP #$99
     BCS .skip49then
.condpart50
 jmp .gameover

.skip49then
.skipL083
.L084 ;  n = 1

	LDA #1
	STA n
.SkipTwo
 ; SkipTwo

.L085 ;  rem x =3 Player moves up three rows

.L086 ;  if x <> 3 then SkipThree

	LDA x
	CMP #3
 if ((* - .SkipThree) < 127) && ((* - .SkipThree) > -128)
	BNE .SkipThree
 else
	beq .8skipSkipThree
	jmp .SkipThree
.8skipSkipThree
 endif
.L087 ;  player0y  =  player0y  -  24

	LDA player0y
	SEC
	SBC #24
	STA player0y
.L088 ;  gosub moveplayer

 jsr .moveplayer

.L089 ;  n = 3

	LDA #3
	STA n
.SkipThree
 ; SkipThree

.L090 ;  rem x =4 move player back; call backtostart

.L091 ;  if x <> 4 then SkipFour

	LDA x
	CMP #4
 if ((* - .SkipFour) < 127) && ((* - .SkipFour) > -128)
	BNE .SkipFour
 else
	beq .9skipSkipFour
	jmp .SkipFour
.9skipSkipFour
 endif
.L092 ;  gosub backtostart

 jsr .backtostart

.L093 ;  n = 1

	LDA #1
	STA n
.SkipFour
 ; SkipFour

.L094 ;  rem x=5 temporary invincibility

.L095 ;  if x <> 5 then SkipFive

	LDA x
	CMP #5
 if ((* - .SkipFive) < 127) && ((* - .SkipFive) > -128)
	BNE .SkipFive
 else
	beq .10skipSkipFive
	jmp .SkipFive
.10skipSkipFive
 endif
.L096 ;  i = 1

	LDA #1
	STA i
.L097 ;  n = 3

	LDA #3
	STA n
.SkipFive
 ; SkipFive

.L098 ;  rem x =6 make the player disappear for a short time

.L099 ;  if x <> 6 then SkipSix

	LDA x
	CMP #6
 if ((* - .SkipSix) < 127) && ((* - .SkipSix) > -128)
	BNE .SkipSix
 else
	beq .11skipSkipSix
	jmp .SkipSix
.11skipSkipSix
 endif
.L0100 ;  h = 1

	LDA #1
	STA h
.L0101 ;  n = 1

	LDA #1
	STA n
.SkipSix
 ; SkipSix

.L0102 ;  rem will stop the score from decreasing for a short time

.L0103 ;  if x <> 7 then SkipSeven

	LDA x
	CMP #7
 if ((* - .SkipSeven) < 127) && ((* - .SkipSeven) > -128)
	BNE .SkipSeven
 else
	beq .12skipSkipSeven
	jmp .SkipSeven
.12skipSkipSeven
 endif
.L0104 ;  e = 1

	LDA #1
	STA e
.L0105 ;  n = 3

	LDA #3
	STA n
.SkipSeven
 ; SkipSeven

.L0106 ;  rem x =8 playfield will disappear for a short itme

.L0107 ;  if x <> 8 then SkipEight

	LDA x
	CMP #8
 if ((* - .SkipEight) < 127) && ((* - .SkipEight) > -128)
	BNE .SkipEight
 else
	beq .13skipSkipEight
	jmp .SkipEight
.13skipSkipEight
 endif
.L0108 ;  g = 1

	LDA #1
	STA g
.L0109 ;  n = 1

	LDA #1
	STA n
.SkipEight
 ; SkipEight

.L0110 ;  gosub removepowerup

 jsr .removepowerup

.EndCollision
 ; EndCollision

.L0111 ;  return

	RTS
.
 ; 

.removepowerup
 ; removepowerup

.L0112 ;  player1x = 0

	LDA #0
	STA player1x
.L0113 ;  player1y = 0

	LDA #0
	STA player1y
.L0114 ;  x = 0

	LDA #0
	STA x
.L0115 ;  y = 0

	LDA #0
	STA y
.L0116 ;  return

	RTS
.
 ; 

.
 ; 

.checkplayercol
 ; checkplayercol

.L0117 ;  if collision(player0,playfield)  &&  i = 0 then gosub backtostart else player0y  =  player0y  -  8

	BIT CXP0FB
	BPL .skipL0117
.condpart51
	LDA i
	CMP #0
     BNE .skip51then
.condpart52
 jsr .backtostart
 jmp .skipelse4
.skip51then
.skipL0117
	LDA player0y
	SEC
	SBC #8
	STA player0y
.skipelse4
.L0118 ;  if player0y  >=  8 then NewLevel

	LDA player0y
	CMP #8
 if ((* - .NewLevel) < 127) && ((* - .NewLevel) > -128)
	bcs .NewLevel
 else
	bcc .14skipNewLevel
	jmp .NewLevel
.14skipNewLevel
 endif
.L0119 ;  l = l + 1

	INC l
.L0120 ;  n = 2

	LDA #2
	STA n
.L0121 ;  if sc1 < $79  &&  sc2 < $99 then score  =  score  +  200000 else score  = 999900

	LDA sc1
	CMP #$79
     BCS .skipL0121
.condpart53
	LDA sc2
	CMP #$99
     BCS .skip53then
.condpart54
	SED
	CLC
	LDA score+2
	ADC #$00
	STA score+2
	LDA score+1
	ADC #$00
	STA score+1
	LDA score
	ADC #$20
	STA score
	CLD
 jmp .skipelse5
.skip53then
.skipL0121
	LDA #$00
	STA score+2
	LDA #$99
	STA score+1
	LDA #$99
	STA score
.skipelse5
.L0122 ;  player0x  =  76

	LDA #76
	STA player0x
.L0123 ;  player0y  =  88

	LDA #88
	STA player0y
.L0124 ;  gosub removepowerup

 jsr .removepowerup

.NewLevel
 ; NewLevel

.L0125 ;  f = 1

	LDA #1
	STA f
.L0126 ;  return

	RTS
.
 ; 

.backtostart
 ; backtostart

.L0127 ;  if i  <> 0 then Invincible

	LDA i
	CMP #0
 if ((* - .Invincible) < 127) && ((* - .Invincible) > -128)
	BNE .Invincible
 else
	beq .15skipInvincible
	jmp .Invincible
.15skipInvincible
 endif
.L0128 ;  if switchleftb then BeginnerSettings

 lda #$40
 bit SWCHB
 if ((* - .BeginnerSettings) < 127) && ((* - .BeginnerSettings) > -128)
	BEQ .BeginnerSettings
 else
	bne .16skipBeginnerSettings
	jmp .BeginnerSettings
.16skipBeginnerSettings
 endif
.L0129 ;  player0x  =  76

	LDA #76
	STA player0x
.L0130 ;  player0y  =  88

	LDA #88
	STA player0y
.L0131 ;  if sc1 < $05 then l = 11 else score  =  score  -  50000

	LDA sc1
	CMP #$05
     BCS .skipL0131
.condpart55
	LDA #11
	STA l
 jmp .skipelse6
.skipL0131
	SED
	SEC
	LDA score+2
	SBC #$00
	STA score+2
	LDA score+1
	SBC #$00
	STA score+1
	LDA score
	SBC #$05
	STA score
	CLD
.skipelse6
.BeginnerSettings
 ; BeginnerSettings

.L0132 ;  if !switchleftb then CommonSettings

 lda #$40
 bit SWCHB
 if ((* - .CommonSettings) < 127) && ((* - .CommonSettings) > -128)
	BNE .CommonSettings
 else
	beq .17skipCommonSettings
	jmp .CommonSettings
.17skipCommonSettings
 endif
.L0133 ;  player0x  =  76

	LDA #76
	STA player0x
.L0134 ;  player0y  =  player0y  +  24

	LDA player0y
	CLC
	ADC #24
	STA player0y
.L0135 ;  if player0y  >  88 then player0y  =  88

	LDA #88
	CMP player0y
     BCS .skipL0135
.condpart56
	LDA #88
	STA player0y
.skipL0135
.L0136 ;  if sc1 <= $02  &&  sc2 <= $49 then l = 11  :  n = 1  :  return

	LDA #$02
	CMP sc1
     BCC .skipL0136
.condpart57
	LDA #$49
	CMP sc2
     BCC .skip57then
.condpart58
	LDA #11
	STA l
	LDA #1
	STA n
	RTS
.skip57then
.skipL0136
.L0137 ;  if sc1 <= $01  &&  sc2 <= $99 then l = 11  :  n = 1  :  return

	LDA #$01
	CMP sc1
     BCC .skipL0137
.condpart59
	LDA #$99
	CMP sc2
     BCC .skip59then
.condpart60
	LDA #11
	STA l
	LDA #1
	STA n
	RTS
.skip59then
.skipL0137
.L0138 ;  score  =  score  -  25000

	SED
	SEC
	LDA score+2
	SBC #$00
	STA score+2
	LDA score+1
	SBC #$50
	STA score+1
	LDA score
	SBC #$02
	STA score
	CLD
.CommonSettings
 ; CommonSettings

.L0139 ;  n = 1

	LDA #1
	STA n
.Invincible
 ; Invincible

.L0140 ;  return

	RTS
.
 ; 

.makenoise
 ; makenoise

.L0141 ;  if n <> 1 then Sound2

	LDA n
	CMP #1
 if ((* - .Sound2) < 127) && ((* - .Sound2) > -128)
	BNE .Sound2
 else
	beq .18skipSound2
	jmp .Sound2
.18skipSound2
 endif
.L0142 ;  if s  >=  1 then Sound2

	LDA s
	CMP #1
 if ((* - .Sound2) < 127) && ((* - .Sound2) > -128)
	bcs .Sound2
 else
	bcc .19skipSound2
	jmp .Sound2
.19skipSound2
 endif
.L0143 ;  r  =  r + 1

	INC r
.L0144 ;  if r  >  30 then s = s + 1

	LDA #30
	CMP r
     BCS .skipL0144
.condpart61
	INC s
.skipL0144
.L0145 ;  AUDV0 = 7  :  AUDC0 = 14  :  AUDF0  =  14

	LDA #7
	STA AUDV0
	LDA #14
	STA AUDC0
	STA AUDF0
.L0146 ;  COLUP0 = $C0

	LDA #$C0
	STA COLUP0
.L0147 ;  if r  >  30 then r  =  1

	LDA #30
	CMP r
     BCS .skipL0147
.condpart62
	LDA #1
	STA r
.skipL0147
.L0148 ;  if g <> 0 then COLUPF  =  0 else COLUPF = c

	LDA g
	CMP #0
     BEQ .skipL0148
.condpart63
	LDA #0
	STA COLUPF
 jmp .skipelse7
.skipL0148
	LDA c
	STA COLUPF
.skipelse7
.L0149 ;  drawscreen

 jsr drawscreen
.L0150 ;  goto makenoise

 jmp .makenoise

.Sound2
 ; Sound2

.L0151 ;  if n <> 2 then Sound3

	LDA n
	CMP #2
 if ((* - .Sound3) < 127) && ((* - .Sound3) > -128)
	BNE .Sound3
 else
	beq .20skipSound3
	jmp .Sound3
.20skipSound3
 endif
.L0152 ;  if s  >=  3 then Sound3

	LDA s
	CMP #3
 if ((* - .Sound3) < 127) && ((* - .Sound3) > -128)
	bcs .Sound3
 else
	bcc .21skipSound3
	jmp .Sound3
.21skipSound3
 endif
.L0153 ;  if r  = 1 then s = s + 1

	LDA r
	CMP #1
     BNE .skipL0153
.condpart64
	INC s
.skipL0153
.L0154 ;  if r  <= 1 then r  =  31

	LDA #1
	CMP r
     BCC .skipL0154
.condpart65
	LDA #31
	STA r
.skipL0154
.L0155 ;  r  =  r - 1

	DEC r
.L0156 ;  AUDV0 = 7  :  AUDC0 = 12  :  AUDF0  =  r

	LDA #7
	STA AUDV0
	LDA #12
	STA AUDC0
	LDA r
	STA AUDF0
.L0157 ;  COLUP0 = $C0

	LDA #$C0
	STA COLUP0
.L0158 ;  if g <> 0 then COLUPF  =  0 else COLUPF = c

	LDA g
	CMP #0
     BEQ .skipL0158
.condpart66
	LDA #0
	STA COLUPF
 jmp .skipelse8
.skipL0158
	LDA c
	STA COLUPF
.skipelse8
.L0159 ;  drawscreen

 jsr drawscreen
.L0160 ;  goto makenoise

 jmp .makenoise

.Sound3
 ; Sound3

.L0161 ;  if n <> 3 then Sound4

	LDA n
	CMP #3
 if ((* - .Sound4) < 127) && ((* - .Sound4) > -128)
	BNE .Sound4
 else
	beq .22skipSound4
	jmp .Sound4
.22skipSound4
 endif
.L0162 ;  if s  >=  2 then Sound4

	LDA s
	CMP #2
 if ((* - .Sound4) < 127) && ((* - .Sound4) > -128)
	bcs .Sound4
 else
	bcc .23skipSound4
	jmp .Sound4
.23skipSound4
 endif
.L0163 ;  if r  = 1 then s = s + 1

	LDA r
	CMP #1
     BNE .skipL0163
.condpart67
	INC s
.skipL0163
.L0164 ;  if r  <=  1 then r  =  31

	LDA #1
	CMP r
     BCC .skipL0164
.condpart68
	LDA #31
	STA r
.skipL0164
.L0165 ;  r  =  r - 1

	DEC r
.L0166 ;  AUDV0 = 7  :  AUDC0 = 7  :  AUDF0  = r

	LDA #7
	STA AUDV0
	STA AUDC0
	LDA r
	STA AUDF0
.L0167 ;  COLUP0 = $C0

	LDA #$C0
	STA COLUP0
.L0168 ;  if g <> 0 then COLUPF  =  0 else COLUPF = c

	LDA g
	CMP #0
     BEQ .skipL0168
.condpart69
	LDA #0
	STA COLUPF
 jmp .skipelse9
.skipL0168
	LDA c
	STA COLUPF
.skipelse9
.L0169 ;  drawscreen

 jsr drawscreen
.L0170 ;  goto makenoise

 jmp .makenoise

.Sound4
 ; Sound4

.L0171 ;  AUDV0  =  0

	LDA #0
	STA AUDV0
.L0172 ;  s  =  0

	LDA #0
	STA s
.L0173 ;  r  =  1

	LDA #1
	STA r
.L0174 ;  n  =  0

	LDA #0
	STA n
.L0175 ;  return

	RTS
.
 ; 

.level1
 ; level1

.L0176 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel0
PF_data0
	.byte %11111111, %01111111, %00111111, %11111111
	.byte %11111111, %01111111, %00111111, %11111111
	.byte %11111111, %01111111, %00111111, %11111111
	.byte %11111111, %00111111, %00111111, %11111111
	.byte %11111111, %00111111, %00111111, %11111111
	.byte %11111111, %00011111, %00011111, %11111111
	.byte %11111111, %00001111, %00001111, %11111111
	.byte %11111111, %00000111, %00000111, %11111111
	.byte %11111110, %00000000, %00000000, %11111111
	.byte %11111000, %00000000, %00000000, %11111000
	.byte %11000000, %00000000, %00000000, %11000000
pflabel0
	lda PF_data0,x
	sta playfield,x
	dex
	bpl pflabel0
.L0177 ;  c = $2E

	LDA #$2E
	STA c
.L0178 ;  return

	RTS
.
 ; 

.level2
 ; level2

.L0179 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel1
PF_data1
	.byte %11111111, %00011111, %11111111, %11111111
	.byte %11111111, %00001111, %01111111, %11111111
	.byte %11111111, %00000001, %00011111, %11111111
	.byte %11111111, %11110001, %00011111, %11111111
	.byte %11111111, %11110001, %00011111, %11111111
	.byte %11111111, %00000001, %00011111, %11111111
	.byte %11111111, %00000001, %00011111, %11111111
	.byte %11111111, %00000111, %01111111, %11111111
	.byte %11111111, %00000111, %01111111, %11111111
	.byte %11111111, %00000111, %11111111, %11111111
	.byte %11111111, %11000001, %11111111, %11111111
pflabel1
	lda PF_data1,x
	sta playfield,x
	dex
	bpl pflabel1
.L0180 ;  c = $8E

	LDA #$8E
	STA c
.L0181 ;  return

	RTS
.
 ; 

.level3
 ; level3

.L0182 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel2
PF_data2
	.byte %11111111, %00100011, %00100011, %11111111
	.byte %11111111, %00100011, %00100011, %11111111
	.byte %11111111, %00100011, %00100011, %11111111
	.byte %11111111, %00100011, %00100011, %11111111
	.byte %11111111, %00100011, %00100011, %11111111
	.byte %11111111, %00100011, %00100011, %11111111
	.byte %11111111, %00100011, %00100011, %11111111
	.byte %11111111, %00110001, %00110001, %11111111
	.byte %11111110, %00111000, %00111000, %11111110
	.byte %11110000, %00111110, %00111110, %11110000
	.byte %00000011, %00111111, %00111111, %00000011
pflabel2
	lda PF_data2,x
	sta playfield,x
	dex
	bpl pflabel2
.L0183 ;  c = $6E

	LDA #$6E
	STA c
.L0184 ;  return

	RTS
.
 ; 

.level4
 ; level4

.L0185 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel3
PF_data3
	.byte %11111111, %11111111, %11111111, %00011111
	.byte %11111111, %11111111, %11111111, %00011111
	.byte %11111111, %11111111, %11111111, %00011111
	.byte %11111111, %11111111, %11111111, %10001111
	.byte %11111111, %11111111, %11111111, %11000111
	.byte %11111111, %11111111, %11111111, %11110001
	.byte %11111111, %11111111, %11111110, %11111100
	.byte %11111111, %11111111, %11110001, %11111111
	.byte %11111111, %11111111, %10001111, %11111111
	.byte %11111111, %00001111, %01111111, %11111111
	.byte %11111100, %11110000, %11111111, %11111111
pflabel3
	lda PF_data3,x
	sta playfield,x
	dex
	bpl pflabel3
.L0186 ;  c = $BE

	LDA #$BE
	STA c
.L0187 ;  return

	RTS
.
 ; 

.level5
 ; level5

.L0188 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel4
PF_data4
	.byte %11111111, %00111111, %01111111, %11111111
	.byte %11111111, %11111111, %11111111, %00011111
	.byte %11111111, %11111111, %10001111, %11111111
	.byte %11111111, %11111111, %11111111, %11111000
	.byte %11111111, %11000111, %11111111, %11111111
	.byte %11110001, %11111111, %11111111, %11111111
	.byte %11111111, %11111111, %11110001, %11111111
	.byte %11111111, %11111111, %11111111, %11000111
	.byte %11111110, %11111100, %11111111, %11111111
	.byte %00011111, %11111111, %11111111, %11111111
	.byte %11111111, %00111111, %01111111, %11111111
pflabel4
	lda PF_data4,x
	sta playfield,x
	dex
	bpl pflabel4
.L0189 ;  c = $DA

	LDA #$DA
	STA c
.L0190 ;  return

	RTS
.
 ; 

.level6
 ; level6

.L0191 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel5
PF_data5
	.byte %11111111, %01111111, %00111111, %11111111
	.byte %11111111, %01111111, %00111111, %11111111
	.byte %11111111, %01111111, %00111111, %11111111
	.byte %11111111, %01111111, %00111111, %11111111
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %10000000, %11000000, %00000000
	.byte %00000000, %11000000, %11100000, %00000000
	.byte %10000000, %10000000, %11000000, %10000000
	.byte %11100000, %11000000, %11100000, %11100000
	.byte %11111100, %11111000, %11111000, %11111100
	.byte %00011111, %11111111, %11111111, %00011111
pflabel5
	lda PF_data5,x
	sta playfield,x
	dex
	bpl pflabel5
.L0192 ;  c = $FE

	LDA #$FE
	STA c
.L0193 ;  return

	RTS
.
 ; 

.level7
 ; level7

.L0194 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel6
PF_data6
	.byte %11111111, %00000011, %00000000, %00000000
	.byte %11111111, %00000011, %00000000, %00000000
	.byte %11111111, %11111111, %11111111, %11000011
	.byte %11111111, %11111111, %11111111, %11110000
	.byte %11111111, %11111111, %11111100, %11111100
	.byte %11111111, %11111111, %11110000, %11111111
	.byte %11111111, %11111111, %11000011, %11111111
	.byte %11111111, %11111111, %00001111, %11111111
	.byte %11111111, %00111111, %00111111, %11111111
	.byte %11111111, %00111111, %00111111, %11111111
	.byte %11111111, %00111111, %00111111, %11111111
pflabel6
	lda PF_data6,x
	sta playfield,x
	dex
	bpl pflabel6
.L0195 ;  c = $0C

	LDA #$0C
	STA c
.L0196 ;  return

	RTS
.
 ; 

.level8
 ; level8

.L0197 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel7
PF_data7
	.byte %11111111, %00000011, %00000000, %11000000
	.byte %11111110, %11111100, %11111111, %11000000
	.byte %11110001, %11111111, %11111000, %11000111
	.byte %10001111, %11111111, %11000111, %11000111
	.byte %00000000, %00000000, %00111111, %11000111
	.byte %01111111, %11111111, %10111111, %11000111
	.byte %01111111, %11111111, %10111111, %11000111
	.byte %01111111, %11111111, %10111111, %11111000
	.byte %01111111, %11111111, %10111000, %11111111
	.byte %01111111, %11111111, %10000111, %11111111
	.byte %00000000, %00000000, %00111111, %11111111
pflabel7
	lda PF_data7,x
	sta playfield,x
	dex
	bpl pflabel7
.L0198 ;  c = $3E

	LDA #$3E
	STA c
.L0199 ;  return

	RTS
.
 ; 

.level9
 ; level9

.L0200 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel8
PF_data8
	.byte %00000000, %11100010, %11111111, %00011111
	.byte %11100011, %11100011, %11111111, %00011111
	.byte %11100011, %00011111, %11111111, %11100011
	.byte %11100011, %11111111, %00011110, %11111100
	.byte %11100011, %11111111, %11100001, %11111111
	.byte %11100011, %11111111, %11100001, %11111111
	.byte %11100011, %11111111, %11100001, %11111111
	.byte %11100011, %11111111, %00011110, %11111100
	.byte %11100011, %00011111, %11111111, %11100011
	.byte %11100011, %11100011, %11111111, %00011111
	.byte %00000000, %11100010, %11111111, %00011111
pflabel8
	lda PF_data8,x
	sta playfield,x
	dex
	bpl pflabel8
.L0201 ;  c = $1C

	LDA #$1C
	STA c
.L0202 ;  return

	RTS
.
 ; 

.level10
 ; level10

.L0203 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel9
PF_data9
	.byte %11111111, %11000111, %10001111, %11111111
	.byte %11111111, %11111111, %11111111, %00011111
	.byte %10001111, %11111111, %11111111, %11111111
	.byte %11111111, %11111111, %11111111, %11100011
	.byte %11110001, %11111111, %11111111, %11111111
	.byte %11111111, %11111111, %11111110, %11111100
	.byte %11111111, %11111000, %11111111, %11111111
	.byte %11111111, %11111111, %11110001, %11111111
	.byte %11111111, %11000111, %11111111, %11111111
	.byte %11111111, %11111111, %10001111, %11111111
	.byte %11111111, %00111111, %01111111, %11111111
pflabel9
	lda PF_data9,x
	sta playfield,x
	dex
	bpl pflabel9
.L0204 ;  c = $8E

	LDA #$8E
	STA c
.L0205 ;  return

	RTS
.
 ; 

.joywait
 ; joywait

.L0206 ;  COLUPF = c

	LDA c
	STA COLUPF
.L0207 ;  drawscreen

 jsr drawscreen
.L0208 ;  b = b + 1  :  if b > 50 then b = 50  :  if b = 50  &&  joy0fire then b = 0  :  f = 1  :  return

	INC b
	LDA #50
	CMP b
     BCS .skipL0208
.condpart70
	LDA #50
	STA b
	LDA b
	CMP #50
     BNE .skip70then
.condpart71
 lda #$80
 bit INPT4
	BNE .skip71then
.condpart72
	LDA #0
	STA b
	LDA #1
	STA f
	RTS
.skip71then
.skip70then
.skipL0208
.L0209 ;  goto joywait

 jmp .joywait

.L0210 ;  return

	RTS
.
 ; 

.gameover
 ; gameover

.L0211 ;  score = 0

	LDA #$00
	STA score+2
	LDA #$00
	STA score+1
	LDA #$00
	STA score
.L0212 ;  player0x  =  0

	LDA #0
	STA player0x
.L0213 ;  player0y  =  0

	LDA #0
	STA player0y
.L0214 ;  player1x  =  0

	LDA #0
	STA player1x
.L0215 ;  player1y  =  0

	LDA #0
	STA player1y
.L0216 ;  c = 68

	LDA #68
	STA c
.L0217 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel10
PF_data10
	.byte %01111000, %00010001, %10111110, %00000000
	.byte %10000001, %10110010, %10100000, %00000000
	.byte %10111011, %01010111, %10111100, %00000000
	.byte %10001010, %00010100, %10100000, %00000000
	.byte %01110010, %00010100, %10111110, %00000000
	.byte %00000000, %00000000, %00000000, %00000000
	.byte %00000011, %10001001, %01111101, %00000111
	.byte %00000100, %10001010, %01000001, %00001000
	.byte %00000100, %10001010, %01111001, %00000111
	.byte %00000100, %01010010, %01000001, %00001000
	.byte %00000011, %00100001, %01111101, %00001000
pflabel10
	lda PF_data10,x
	sta playfield,x
	dex
	bpl pflabel10
.L0218 ;  COLUBK  =  64

	LDA #64
	STA COLUBK
.L0219 ;  COLUPF  =  c

	LDA c
	STA COLUPF
.L0220 ;  drawscreen

 jsr drawscreen
.L0221 ;  if switchreset then reboot

 lda #1
 bit SWCHB
	BNE .skipL0221
.condpart73
	JMP ($FFFC)
.skipL0221
.L0222 ;  goto gameover

 jmp .gameover

.
 ; 

.title
 ; title

.L0223 ;  player0x  =  20

	LDA #20
	STA player0x
.L0224 ;  player0y  =  77

	LDA #77
	STA player0y
.L0225 ;  rem this vairable is used to count frames for the game over screen.

.L0226 ;  a  =  1

	LDA #1
	STA a
.L0227 ;  rem this variable gives the current playfield color.  This is used to change the player to invisible should they receive that powerup.

.L0228 ;  c  =  30

	LDA #30
	STA c
.L0229 ;  rem this variable will set the duration of stopping the score (powerup)

.L0230 ;  e  =  0

	LDA #0
	STA e
.L0231 ;  rem this variable sets the level, which in turn sets the playfield.

.L0232 ;  l  =  1

	LDA #1
	STA l
.L0233 ;  rem This variable tells the program whether the button has been fired and sets a delay so that it won't repeat over and over

.L0234 ;  f  =  0

	LDA #0
	STA f
.L0235 ;  rem this variable sets whether the playfield is visible or not and times it (powerup effect)

.L0236 ;  g  =  0

	LDA #0
	STA g
.L0237 ;  rem this variable sets whether the player is visible or not. (powerup effect)

.L0238 ;  h  =  0

	LDA #0
	STA h
.L0239 ;  rem this variable sets invincibility for a short time.

.L0240 ;  i  =  0

	LDA #0
	STA i
.L0241 ;  rem This variable tells the moveplayer subroutine whether to move the player positively or negatively. 1 is positive (right), 0 is negative (left).

.L0242 ;  p  =  1

	LDA #1
	STA p
.L0243 ;  rem This variable sets the move rate for the player.  A higher number means the player will move faster.

.L0244 ;  m  =  0

	LDA #0
	STA m
.L0245 ;  rem set the beginning score at 999990.  We are going to have it countdown from there.

.L0246 ;  score  =  999900

	LDA #$00
	STA score+2
	LDA #$99
	STA score+1
	LDA #$99
	STA score
.L0247 ;  rem this variable is the sound counter for the number of loops.

.L0248 ;  s  =  0

	LDA #0
	STA s
.L0249 ;  rem this variable is for the volume counter.

.L0250 ;  v  =  0

	LDA #0
	STA v
.L0251 ;  rem this variable is for the frequency counter.

.L0252 ;  r  =  0

	LDA #0
	STA r
.L0253 ;  rem this variable says whether to make noise and what type.

.L0254 ;  n  =  0

	LDA #0
	STA n
.L0255 ;  rem this lets the powerup stay out longer

.L0256 ;  w  =  0

	LDA #0
	STA w
.L0257 ;  rem powerup variable go to powerup to see what this value can be.  Starts at 0

.L0258 ;  x  =  0

	LDA #0
	STA x
.L0259 ;  rem powerup variable to determine whether a powerup is on the board.

.L0260 ;  y  =  0

	LDA #0
	STA y
.L0261 ;  rem powerup location variable

.L0262 ;  z  =  0

	LDA #0
	STA z
.L0263 ;  scorecolor  =  14

	LDA #14
	STA scorecolor
.L0264 ;  playfield:

  ifconst pfres
    ldx #4*pfres-1
  else
	  ldx #47
  endif
	jmp pflabel11
PF_data11
	.byte %11111110, %11111100, %11111111, %11111111
	.byte %11111101, %11111011, %11111111, %11111111
	.byte %11111111, %00001100, %11111111, %11111111
	.byte %11111110, %11110111, %11111111, %11111111
	.byte %11111100, %10000000, %10001111, %11111111
	.byte %11111111, %01110111, %01110111, %11111111
	.byte %11111111, %10001111, %01110100, %11111110
	.byte %11111111, %11111111, %01110011, %11111101
	.byte %11111111, %11111111, %10001011, %11111101
	.byte %11111111, %11111111, %11111011, %11111101
	.byte %11111111, %11111111, %11111100, %11111110
pflabel11
	lda PF_data11,x
	sta playfield,x
	dex
	bpl pflabel11
.L0265 ;  COLUBK  =  00

	LDA #00
	STA COLUBK
.L0266 ;  COLUPF  =  c

	LDA c
	STA COLUPF
.L0267 ;  drawscreen

 jsr drawscreen
.L0268 ;  gosub joywait

 jsr .joywait

.L0269 ;  player0:

	LDA #<playerL0269_0

	STA player0pointerlo
	LDA #>playerL0269_0

	STA player0pointerhi
	LDA #8
	STA player0height
.L0270 ;  player1:

	LDA #<playerL0270_1

	STA player1pointerlo
	LDA #>playerL0270_1

	STA player1pointerhi
	LDA #8
	STA player1height
.L0271 ;  player0x = 76

	LDA #76
	STA player0x
.L0272 ;  player0y = 88

	LDA #88
	STA player0y
.L0273 ;  goto main_loop

 jmp .main_loop

.L0274 ;  return

	RTS
 if (<*) > (<(*+9))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL0269_0

	.byte 0
	.byte  %00000000
	.byte  %11000110
	.byte  %01111100
	.byte  %00111000
	.byte  %00010000
	.byte  %00010000
	.byte  %00010000
	.byte  %00010000
 if (<*) > (<(*+9))
	repeat ($100-<*)
	.byte 0
	repend
	endif
playerL0270_1

	.byte 0
	.byte  %01111110
	.byte  %10111101
	.byte  %11000011
	.byte  %11011011
	.byte  %11011011
	.byte  %11000011
	.byte  %10111101
	.byte  %01111110
       echo "    ",[(scoretable - *)]d , "bytes of ROM space left")
 
 
 
; feel free to modify the score graphics - just keep each digit 8 high
; and keep the conditional compilation stuff intact
 ifconst ROM2k
   ORG $F7AC
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2F94-bscode_length
       RORG $FF94-bscode_length
     endif
     if bankswitch == 16
       ORG $4F94-bscode_length
       RORG $FF94-bscode_length
     endif
     if bankswitch == 32
       ORG $8F94-bscode_length
       RORG $FF94-bscode_length
     endif
   else
     ORG $FF9C
   endif
 endif


scoretable
       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100

       .byte %01111110
       .byte %00011000
       .byte %00011000
       .byte %00011000
       .byte %00011000
       .byte %00111000
       .byte %00011000
       .byte %00001000

       .byte %01111110
       .byte %01100000
       .byte %01100000
       .byte %00111100
       .byte %00000110
       .byte %00000110
       .byte %01000110
       .byte %00111100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00000110
       .byte %00011100
       .byte %00000110
       .byte %01000110
       .byte %00111100

       .byte %00001100
       .byte %00001100
       .byte %01111110
       .byte %01001100
       .byte %01001100
       .byte %00101100
       .byte %00011100
       .byte %00001100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00000110
       .byte %00111100
       .byte %01100000
       .byte %01100000
       .byte %01111110

       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %01111100
       .byte %01100000
       .byte %01100010
       .byte %00111100

       .byte %00110000
       .byte %00110000
       .byte %00110000
       .byte %00011000
       .byte %00001100
       .byte %00000110
       .byte %01000010
       .byte %00111110

       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100
       .byte %01100110
       .byte %01100110
       .byte %00111100

       .byte %00111100
       .byte %01000110
       .byte %00000110
       .byte %00111110
       .byte %01100110
       .byte %01100110
       .byte %01100110
       .byte %00111100 


 ifconst ROM2k
   ORG $F7FC
 else
   ifconst bankswitch
     if bankswitch == 8
       ORG $2FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 16
       ORG $4FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
     if bankswitch == 32
       ORG $8FF4-bscode_length
       RORG $FFF4-bscode_length
     endif
   else
     ORG $FFFC
   endif
 endif
 ifconst bankswitch
   if bankswitch == 8
     ORG $2FFC
     RORG $FFFC
   endif
   if bankswitch == 16
     ORG $4FFC
     RORG $FFFC
   endif
   if bankswitch == 32
     ORG $8FFC
     RORG $FFFC
   endif
 else
   ifconst ROM2k
     ORG $F7FC
   else
     ORG $FFFC
   endif
 endif
 .word start
 .word start
