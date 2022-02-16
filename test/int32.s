; /*****************************************************************************
;  ________          ___ ________  ________          ________  ________  ___  ___     
; |\_____  \        /  /|\   __  \|\   __  \        |\   ____\|\   __  \|\  \|\  \    
;  \|___/  /|      /  //\ \  \|\  \ \  \|\  \       \ \  \___|\ \  \|\  \ \  \\\  \   
;      /  / /     /  //  \ \   __  \ \  \\\  \       \ \  \    \ \   ____\ \  \\\  \  
;     /  /_/__   /  //    \ \  \|\  \ \  \\\  \       \ \  \____\ \  \___|\ \  \\\  \ 
;    |\________\/_ //      \ \_______\ \_______\       \ \_______\ \__\    \ \_______\
;     \|_______|__|/        \|_______|\|_______|        \|_______|\|__|     \|_______|
                                                                                    
; MIT License

; Copyright (c) 2022 Mike Sharkey

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
; ******************************************************************************/

                .extern __z80_enter_ix

                .global __z80_mul16_8
                .global __z80_mul16
                .global __z80_smul16

; 16*8 multiplication
; The following routine multiplies de by a and places the result in 
; ahl (which means a is the most significant byte of the product, 
; l the least significant and h the intermediate one...)
; return value 32 bit dehl
__z80_mul16_8:  call    __z80_enter_ix
                ld      d,(ix+7)
                ld      e,(ix+6)
                ld      a,(ix+4)
;
                ld  	c, 0
                ld	    h, c
                ld	    l, h

                add	    a, a		; optimised 1st iteration
                jr	    nc, $+4
                ld	    h,d
                ld	    l,e

                ld      b, 7
1:
                add	    hl, hl
                rla
                jr	    nc, $+4
                add	    hl, de
                ; yes this is actually adc a, 0 but since c is 
                ; free we set it to zero and so we can save 
                ; 1 byte and up to 3 T-states per iteration
                adc	    a, c
                
                djnz	1b
   ;
                ld      e,a 
                ld      d,0
                ret
 


; 16*16 multiplication
; The following routine multiplies bc by de and places the result in dehl.
__z80_mul16:    call    __z80_enter_ix
                ld      b,(ix+7)
                ld      c,(ix+6)
                ld      d,(ix+5)
                ld      e,(ix+4)
;
                ld	    hl, 0

                sla	    e		; optimised 1st iteration
                rl	    d
                jr	    nc, $+4
                ld	    h, b
                ld	    l, c

                ld	    a, 15
1:
                add	    hl, hl
                rl	    e
                rl	    d
                jr	    nc, $+6
                add	    hl, bc
                jr	    nc, $+3
                inc	    de
                
                dec	    a
                jr	    nz, 1b
                
                ret
 

; 16 bit signed multiply
; call with bc, de = 16 bit signed numbers to multiply
; returns   de:hl = 32 bit signed product
; corrupts  a
; de:hl = bc*de
__z80_smul16:   call    __z80_enter_ix
                ld      b,(ix+7)
                ld      c,(ix+6)
                ld      d,(ix+5)
                ld      e,(ix+4)
;
                xor     a
                ld      h,a
                ld      l,a
                bit     7,d
                jr z,   1f
                sbc     hl,bc
1:              ; muldpos:
                ld      a,b
                sra     a
                and     0C0h
                add     a,d
                ld      d,a

                ld      a,16
2:              ; mulloop:
                add     hl,hl
                rl      e
                rl      d
                jr      nc,3f
            add         hl,bc
                jr      nc,3f
                inc     de
3:              ; mul0bit:
                dec     a
                jr      nz,2b

                ret

                .end
    