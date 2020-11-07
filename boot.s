R0 = $0000
R1 = $0001
R2 = $0002
R3 = $0003
R4 = $0004
R5 = $0005
R6 = $0006
R7 = $0007
R8 = $0008
R9 = $0009
R10 = $000a
R11 = $000b
R12 = $000c
R13 = $000d
R14 = $000e
R15 = $000f
LINE = $0010
MESSAGE = $0020
GPREG = $0030
PAR1CHAR1 = $0031
PAR1CHAR2 = $0032
PAR1CHAR3 = $0033
PAR2CHAR1 = $0034
PAR2CHAR2 = $0035
PAR2CHAR3 = $0036
RESULT = $0037
LASTKEY = $0038
LINEPOINTER = $0039
KEYS = $00ff
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000
  
boot:
  jsr lcd_setup
  lda #" "
  sta MESSAGE
  sta MESSAGE + 5
  sta MESSAGE + 8
  sta MESSAGE + 15
  lda #"6"
  sta MESSAGE + 1
  lda #"5"
  sta MESSAGE + 2
  lda #"0"
  sta MESSAGE + 3
  sta MESSAGE + 10
  sta MESSAGE + 12
  sta MESSAGE + 14
  lda #"2"
  sta MESSAGE + 4
  lda #"O"
  sta MESSAGE + 6
  lda #"S"
  sta MESSAGE + 7
  lda #"V"
  sta MESSAGE + 9
  lda #"."
  sta MESSAGE + 11
  sta MESSAGE + 13
  jsr lcd_print
  lda #" "
  sta MESSAGE
  sta MESSAGE + 1
  sta MESSAGE + 9
  sta MESSAGE + 14
  sta MESSAGE + 15
  lda #"B"
  sta MESSAGE + 2
  lda #"o"
  sta MESSAGE + 3
  sta MESSAGE + 4
  lda #"t"
  sta MESSAGE + 5
  lda #"i"
  sta MESSAGE + 6
  lda #"n"
  sta MESSAGE + 7
  lda #"g"
  sta MESSAGE + 8
  lda #"U"
  sta MESSAGE + 10
  lda #"p"
  sta MESSAGE + 11
  lda #"."
  sta MESSAGE + 12
  sta MESSAGE + 13
  jsr mathshell

irq:
  nop
  rti

nmi:
  jmp shutdown

shutdown:
  jsr clear_ram
  jsr clear_io
  jsr shutdown_loop

clear_ram:
  jsr clear_ram_init
  jsr clear_ram_loop
  rts

clear_io:
  lda #$00
  sta DDRA
  sta DDRB
  rts

clear_ram_init:
  lda #$00
  ldx #$00
  rts

clear_ram_loop:
  inx
  clc
  sta GPREG,x
  cpx #$ff
  bne clear_ram_loop
  rts

shutdown_loop:
  .word #$db

lcd_setup:
  ldx #$ff
  txs
  lda #%11111111
  sta DDRB
  lda #%11100000
  sta DDRA
  lda #%00111000
  jsr lcd_instruction
  lda #%00001110
  jsr lcd_instruction
  lda #%00000110
  jsr lcd_instruction
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0
  sta PORTA
  lda #E
  sta PORTA
  lda #0
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #RS
  sta PORTA
  rts

lcd_print:
  lda MESSAGE
  jsr print_char
  lda MESSAGE + 1
  jsr print_char
  lda MESSAGE + 2
  jsr print_char
  lda MESSAGE + 3
  jsr print_char
  lda MESSAGE + 4
  jsr print_char
  lda MESSAGE + 5
  jsr print_char
  lda MESSAGE + 6
  jsr print_char
  lda MESSAGE + 7
  jsr print_char
  lda MESSAGE + 8
  jsr print_char
  lda MESSAGE + 9
  jsr print_char
  lda MESSAGE + 10
  jsr print_char
  lda MESSAGE + 11
  jsr print_char
  lda MESSAGE + 12
  jsr print_char
  lda MESSAGE + 13
  jsr print_char
  lda MESSAGE + 14
  jsr print_char
  lda MESSAGE + 15
  jsr print_char
  rts

lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
  jmp lcdnusy

lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcdbusy
  lda #RW
  sta PORTA
  lda #%11111111  ; Port B is output
  sta DDRB
  pla
  rts

mul:
  dey
  clc
  adc GPREG
  cpy #$00
  bne mul
  rts

div:
  clc
  sbc GPREG
  tax
  cpx #00
  iny
  bne div
  rts

div_remainder:
  sta R0
  clc
  sbc GPREG
  tax
  cpx #00
  iny
  bcc div_neg
  bne div_remainder
  rts

div_neg:
  ldx R0
  stx GPREG
  cpx R0
  dey
  rts

addcommand:
  jsr extractnumadd
  clc
  adc GPREG
  sta RESULT
  jsr preparemath
  rts

subcommand:
  jsr extractnumsub
  clc
  sbc GPREG
  sta RESULT
  jsr preparemath
  rts

mulcommand:
  jsr extractnummul
  tay
  jsr mul
  sta RESULT
  jsr preparemath
  rts

divcommand:
  jsr extractnumdiv
  jsr div
  sty RESULT
  jsr preparemath
  rts

extractnumadd:
  ldx #$00
  jsr getpluspos
  cpx #$01
  beq onedigit
  cpx #$02
  beq twodigit
  cpx #$03
  beq threedigit
  rts

extractnumsub:
  ldx #$00
  jsr getminuspos
  cpx #$01
  beq onedigit
  cpx #$02
  beq twodigit
  cpx #$03
  beq threedigit
  rts

extractnummul:
  ldx #$00
  jsr getasteriskpos
  cpx #$01
  beq onedigit
  cpx #$02
  beq twodigit
  cpx #$03
  beq threedigit
  rts

extractnumdiv:
  ldx #$00
  jsr getslashpos
  cpx #$01
  beq onedigit
  cpx #$02
  beq twodigit
  cpx #$03
  beq threedigit
  rts

onedigit:
  lda #$00
  sta PAR1CHAR3
  sta PAR1CHAR2
  lda LINE
  sta PAR1CHAR1
  rts

twodigit:
  lda #$00
  sta PAR1CHAR2
  lda LINE
  sta PAR1CHAR1
  lda LINE + 1
  sta PAR1CHAR2
  rts

threedigit:
  lda LINE
  sta PAR1CHAR1
  lda LINE + 1
  sta PAR1CHAR2
  lda LINE + 2
  sta PAR1CHAR3
  rts

getpluspos:
  clc
  ldy LINE,x
  cpy #$2b
  iny
  bne getpluspos
  rts

getminuspos:
  clc
  ldy LINE,x
  cpy #$2d
  iny
  bne getminuspos
  rts

getasteriskpos:
  clc
  ldy LINE,x
  cpy #$2a
  iny
  bne getasteriskpos
  rts

getslashpos:
  clc
  ldy LINE,x
  cpy #$2f
  iny
  bne getslashpos
  rts

rand:
  jsr rand_init
  jsr rand_loop
  rts

rand_init:
  sta R0
  lda GPREG
  sta R1
  txa
  sty GPREG
  eor GPREG
  sta R2
  lda R1
  sta GPREG
  lda R0
  eor GPREG
  eor R2
  rts

rand_loop:
  sta R0
  and #$02
  tax
  cpx #$00
  beq rand_shift
  and #$01
  tax
  cpx #$00
  beq label
  cpx #$01
  bne rand_loop
  rts

rand_shift:
  asl
  rts

rand_mul:
  ldy R0
  jsr mul
  rts

preparemath:
  lda PAR1CHAR3
  clc
  sbc #$30
  tay
  ldy #$64
  stx GPREG
  lda #$00
  jsr mul
  tay
  lda PAR1CHAR2
  clc
  sbc #$30
  tay
  ldy #$0a
  stx GPREG
  lda #$00
  jsr mul
  tax
  lda PAR1CHAR1
  clc
  sbc #$30
  sta GPREG
  jsr mul
  lda #$00
  tya
  clc
  adc GPREG
  stx GPREG
  clc
  adc GPREG
  sta GPREG
  lda PAR2CHAR3
  clc
  sbc #$30
  tay
  ldy #$64
  stx GPREG
  lda #$00
  jsr mul
  tay
  lda PAR2CHAR2
  clc
  sbc #$30
  tay
  ldy #$0a
  stx GPREG
  lda #$00
  jsr mul
  tax
  lda PAR2CHAR1
  clc
  sbc #$30
  sta GPREG
  jsr mul
  lda #$00
  tya
  clc
  adc GPREG
  stx GPREG
  clc
  adc GPREG
  rts

displayresult:
  lda #$0a
  sta GPREG
  lda RESULT
  jsr div_remainder
  lda R0
  sta R1
  tya
  lda #$0a
  sta GPREG
  lda RESULT
  jsr div_remainder
  lda R0
  sta R2
  tya
  lda #$0a
  sta GPREG
  lda RESULT
  jsr div_remainder
  lda R0
  clc
  adc #$30
  sta MESSAGE + 2
  lda R2
  clc
  adc #$30
  sta MESSAGE + 1
  lda R1
  clc
  adc #$30
  sta MESSAGE
  lda #$20
  sta MESSAGE + 3
  sta MESSAGE + 4
  sta MESSAGE + 5
  sta MESSAGE + 6
  sta MESSAGE + 7
  sta MESSAGE + 8
  sta MESSAGE + 9
  sta MESSAGE + 10
  sta MESSAGE + 11
  sta MESSAGE + 12
  sta MESSAGE + 13
  sta MESSAGE + 14
  sta MESSAGE + 15
  jsr lcd_print
  rts

mathshell:
  jsr read_key
  ldy LINEPOINTER
  iny
  sty LINEPOINTER
  cpx #$0d
  beq process_line
  bne store_char
  
store_char:
  clc
  stx LINE,y
  jsr print_char
  jmp mathshell

process_line:
  ldy #"P"
  sty GPREG
  ldx LINE
  cpx GPREG
  beq print_command
  ldy #"R"
  sty GPREG
  ldx LINE
  cpx GPREG
  beq rand_command
  ldy LINE + 1
  cpy #$2a
  beq mulcommand
  ldy LINE + 1
  cpy #$2f
  beq divcommand
  ldy LINE + 1
  cpy #$2b
  beq addcommand
  ldy LINE + 1
  cpy #$2d
  beq subcommand
  ldy LINE + 2
  cpy #$2a
  beq mulcommand
  ldy LINE + 2
  cpy #$2f
  beq divcommand
  ldy LINE + 2
  cpy #$2b
  beq addcommand
  ldy LINE + 2
  cpy #$2d
  beq subcommand
  ldy LINE + 3
  cpy #$2a
  beq mulcommand
  ldy LINE + 3
  cpy #$2f
  beq divcommand
  ldy LINE + 3
  cpy #$2b
  beq addcommand
  ldy LINE + 3
  cpy #$2d
  beq subcommand
  lda #$"X"
  jsr print_char
  jmp mathshell
  

read_key:
  ldx KEYS
  cpx LASTKEY
  bne read_key
  stx LASTKEY
  rts

print_command:
  ldx #$07
  clc
  ldy LINE,x
  txa
  clc
  sbc #$07
  stx GPREG
  tax
  clc
  sty MESSAGE,x
  ldx GPREG
  cpy #$"\""
  bne print_inc
  beq print_done
  rts

print_inc:
  inx
  jmp print_command

print_done:
  cly
  jsr lcd_print
  rts

rand_command:
  jsr rand
  jsr displayresult
  rts

  .org $fffa
  .word nmi
  .word boot
  .word irq
