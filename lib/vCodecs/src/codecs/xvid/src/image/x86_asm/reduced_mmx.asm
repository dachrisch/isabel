;/*****************************************************************************
; *
; *  XVID MPEG-4 VIDEO CODEC
; *  - Reduced-Resolution utilities -
; *
; *  Copyright(C) 2002 Pascal Massimino <skal@planet-d.net>
; *
; *  XviD is free software; you can redistribute it and/or modify it
; *  under the terms of the Affero GNU General Public License as published by
; *  the Free Software Foundation; either version 2 of the License, or
; *  (at your option) any later version.
; *
; *  This program is distributed in the hope that it will be useful,
; *  but WITHOUT ANY WARRANTY; without even the implied warranty of
; *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; *  Affero GNU General Public License for more details.
; *
; *  You should have received a copy of the Affero GNU General Public License
; *  along with this program; if not, write to the Free Software
; *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
; *
; * $Id: reduced_mmx.asm 20206 2010-04-08 10:55:00Z gabriel $
; *
; *************************************************************************/

BITS 32

%macro cglobal 1
	%ifdef PREFIX
		global _%1
		%define %1 _%1
	%else
		global %1
	%endif
%endmacro

;===========================================================================

%ifdef FORMAT_COFF
SECTION .rodata
%else
SECTION .rodata align=16
%endif

align 16
Up31 dw  3, 1, 3, 1
Up13 dw  1, 3, 1, 3
Up93 dw  9, 3, 9, 3
Up39 dw  3, 9, 3, 9
Cst0 dw  0, 0, 0, 0
Cst2 dw  2, 2, 2, 2
Cst3 dw  3, 3, 3, 3
Cst32 dw 32,32,32,32
Cst2000 dw  2, 0, 0, 0
Cst0002 dw  0, 0, 0, 2

Mask_ff dw 0xff,0xff,0xff,0xff

;===========================================================================

SECTION .text

cglobal xvid_Copy_Upsampled_8x8_16To8_mmx
cglobal xvid_Add_Upsampled_8x8_16To8_mmx
cglobal xvid_Copy_Upsampled_8x8_16To8_xmm
cglobal xvid_Add_Upsampled_8x8_16To8_xmm

cglobal xvid_HFilter_31_mmx
cglobal xvid_VFilter_31_x86
cglobal xvid_HFilter_31_x86

cglobal xvid_Filter_18x18_To_8x8_mmx
cglobal xvid_Filter_Diff_18x18_To_8x8_mmx


;//////////////////////////////////////////////////////////////////////
;// 8x8 -> 16x16 upsampling (16b)
;//////////////////////////////////////////////////////////////////////

%macro MUL_PACK 4     ; %1/%2: regs   %3/%4/%5: Up13/Up31
  pmullw %1,  %3 ; [Up13]
  pmullw mm4, %4 ; [Up31]
  pmullw %2,  %3 ; [Up13]
  pmullw mm5, %4 ; [Up31]
  paddsw %1, [Cst2]
  paddsw %2, [Cst2]
  paddsw %1, mm4
  paddsw %2, mm5
%endmacro

    ; MMX-way of reordering columns...

%macro COL03 3    ;%1/%2: regs, %3: row   -output: mm4/mm5
  movq %1, [edx+%3*16+0*2]   ; %1  = 0|1|2|3
  movq %2,[edx+%3*16+1*2]    ; %2  = 1|2|3|4
  movq mm5, %1               ; mm5 = 0|1|2|3
  movq mm4, %1               ; mm4 = 0|1|2|3
  punpckhwd mm5,%2           ; mm5 = 2|3|3|4
  punpcklwd mm4,%2           ; mm4 = 0|1|1|2
  punpcklwd %1,%1            ; %1  = 0|0|1|1
  punpcklwd %2, mm5          ; %2  = 1|2|2|3
  punpcklwd %1, mm4          ; %1  = 0|0|0|1
%endmacro

%macro COL47 3    ;%1-%2: regs, %3: row   -output: mm4/mm5
  movq mm5, [edx+%3*16+4*2]   ; mm5 = 4|5|6|7
  movq %1, [edx+%3*16+3*2]    ; %1  = 3|4|5|6
  movq %2,  mm5               ; %2  = 4|5|6|7
  movq mm4, mm5               ; mm4 = 4|5|6|7
  punpckhwd %2, %2            ; %2  = 6|6|7|7
  punpckhwd mm5, %2           ; mm5 = 6|7|7|7
  movq %2,  %1                ; %2  = 3|4|5|6
  punpcklwd %1, mm4           ; %1  = 3|4|4|5
  punpckhwd %2, mm4           ; %2  = 5|6|6|7
  punpcklwd mm4, %2           ; mm4 = 4|5|5|6
%endmacro

%macro MIX_ROWS 4   ; %1/%2:prev %3/4:cur (preserved)  mm4/mm5: output
  ; we need to perform: (%1,%3) -> (%1 = 3*%1+%3, mm4 = 3*%3+%1), %3 preserved.
  movq mm4, [Cst3]
  movq mm5, [Cst3]
  pmullw mm4, %3
  pmullw mm5, %4
  paddsw mm4, %1
  paddsw mm5, %2
  pmullw %1, [Cst3]
  pmullw %2, [Cst3]
  paddsw %1, %3
  paddsw %2, %4
%endmacro

;===========================================================================
;
; void xvid_Copy_Upsampled_8x8_16To8_mmx(uint8_t *Dst,
;                                        const int16_t *Src, const int BpS);
;
;===========================================================================

  ; Note: we can use ">>2" instead of "/4" here, since we
  ; are (supposed to be) averaging positive values

%macro STORE_1 2
  psraw %1, 2
  psraw %2, 2
  packuswb %1,%2
  movq [ecx], %1
%endmacro

%macro STORE_2 2    ; pack and store (%1,%2) + (mm4,mm5)
  psraw %1, 4
  psraw %2, 4
  psraw mm4, 4
  psraw mm5, 4
  packuswb %1,%2
  packuswb mm4, mm5
  movq [ecx], %1
  movq [ecx+eax], mm4
  lea ecx, [ecx+2*eax]
%endmacro

;//////////////////////////////////////////////////////////////////////

align 16
xvid_Copy_Upsampled_8x8_16To8_mmx:  ; 344c

  mov ecx, [esp+4]  ; Dst
  mov edx, [esp+8]  ; Src
  mov eax, [esp+12] ; BpS

  movq mm6, [Up13]
  movq mm7, [Up31]

  COL03 mm0, mm1, 0
  MUL_PACK mm0,mm1, mm6, mm7
  movq mm4, mm0
  movq mm5, mm1
  STORE_1 mm4, mm5
  add ecx, eax

  COL03 mm2, mm3, 1
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL03 mm0, mm1, 2
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL03 mm2, mm3, 3
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL03 mm0, mm1, 4
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL03 mm2, mm3, 5
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL03 mm0, mm1, 6
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL03 mm2, mm3, 7
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  STORE_1 mm2, mm3

  mov ecx, [esp+4]
  add ecx, 8

  COL47 mm0, mm1, 0
  MUL_PACK mm0,mm1, mm6, mm7
  movq mm4, mm0
  movq mm5, mm1
  STORE_1 mm4, mm5
  add ecx, eax

  COL47 mm2, mm3, 1
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL47 mm0, mm1, 2
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL47 mm2, mm3, 3
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL47 mm0, mm1, 4
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL47 mm2, mm3, 5
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL47 mm0, mm1, 6
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL47 mm2, mm3, 7
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  STORE_1 mm2, mm3

  ret

;===========================================================================
;
; void xvid_Add_Upsampled_8x8_16To8_mmx(uint8_t *Dst,
;                                       const int16_t *Src, const int BpS);
;
;===========================================================================

    ; Note: grrr... the 'pcmpgtw' stuff are the "/4" and "/16" operators
    ; implemented with ">>2" and ">>4" using:
    ;       x/4  = ( (x-(x<0))>>2 ) + (x<0)
    ;       x/16 = ( (x-(x<0))>>4 ) + (x<0)

%macro STORE_ADD_1 2
    ; We substract the rounder '2' for corner pixels,
    ; since when 'x' is negative, (x*4 + 2)/4 is *not*
    ; equal to 'x'. In fact, the correct relation is:
    ;         (x*4 + 2)/4 = x - (x<0)
    ; So, better revert to (x*4)/4 = x.

  psubsw %1, [Cst2000]
  psubsw %2, [Cst0002]
  pxor mm6, mm6
  pxor mm7, mm7
  pcmpgtw mm6, %1
  pcmpgtw mm7, %2
  paddsw %1, mm6
  paddsw %2, mm7
  psraw %1, 2
  psraw %2, 2
  psubsw %1, mm6
  psubsw %2, mm7

    ; mix with destination [ecx]
  movq mm6, [ecx]
  movq mm7, [ecx]
  punpcklbw mm6, [Cst0]
  punpckhbw mm7, [Cst0]
  paddsw %1, mm6
  paddsw %2, mm7
  packuswb %1,%2
  movq [ecx], %1
%endmacro

%macro STORE_ADD_2 2
  pxor mm6, mm6
  pxor mm7, mm7
  pcmpgtw mm6, %1
  pcmpgtw mm7, %2
  paddsw %1, mm6
  paddsw %2, mm7
  psraw %1, 4
  psraw %2, 4
  psubsw %1, mm6
  psubsw %2, mm7

  pxor mm6, mm6
  pxor mm7, mm7
  pcmpgtw mm6, mm4
  pcmpgtw mm7, mm5
  paddsw mm4, mm6
  paddsw mm5, mm7
  psraw mm4, 4
  psraw mm5, 4
  psubsw mm4, mm6
  psubsw mm5, mm7

    ; mix with destination
  movq mm6, [ecx]
  movq mm7, [ecx]
  punpcklbw mm6, [Cst0]
  punpckhbw mm7, [Cst0]
  paddsw %1, mm6
  paddsw %2, mm7

  movq mm6, [ecx+eax]
  movq mm7, [ecx+eax]

  punpcklbw mm6, [Cst0]
  punpckhbw mm7, [Cst0]
  paddsw mm4, mm6
  paddsw mm5, mm7

  packuswb %1,%2
  packuswb mm4, mm5

  movq [ecx], %1
  movq [ecx+eax], mm4

  lea ecx, [ecx+2*eax]
%endmacro

;//////////////////////////////////////////////////////////////////////

align 16
xvid_Add_Upsampled_8x8_16To8_mmx:  ; 579c

  mov ecx, [esp+4]  ; Dst
  mov edx, [esp+8]  ; Src
  mov eax, [esp+12] ; BpS

  COL03 mm0, mm1, 0
  MUL_PACK mm0,mm1, [Up13], [Up31]
  movq mm4, mm0
  movq mm5, mm1
  STORE_ADD_1 mm4, mm5
  add ecx, eax

  COL03 mm2, mm3, 1
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL03 mm0, mm1, 2
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL03 mm2, mm3, 3
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL03 mm0, mm1, 4
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL03 mm2, mm3, 5
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL03 mm0, mm1, 6
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL03 mm2, mm3, 7
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  STORE_ADD_1 mm2, mm3


  mov ecx, [esp+4]
  add ecx, 8

  COL47 mm0, mm1, 0
  MUL_PACK mm0,mm1, [Up13], [Up31]
  movq mm4, mm0
  movq mm5, mm1
  STORE_ADD_1 mm4, mm5
  add ecx, eax

  COL47 mm2, mm3, 1
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL47 mm0, mm1, 2
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL47 mm2, mm3, 3
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL47 mm0, mm1, 4
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL47 mm2, mm3, 5
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL47 mm0, mm1, 6
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL47 mm2, mm3, 7
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  STORE_ADD_1 mm2, mm3

  ret

;===========================================================================
;
; void xvid_Copy_Upsampled_8x8_16To8_xmm(uint8_t *Dst,
;                                        const int16_t *Src, const int BpS);
;
;===========================================================================

  ; xmm version can take (little) advantage of 'pshufw'

%macro COL03_SSE 3    ;%1/%2: regs, %3: row   -trashes mm4/mm5
  movq %2, [edx+%3*16+0*2]               ; <- 0|1|2|3
  pshufw %1,  %2,  (0+0*4+0*16+1*64)     ; %1 = 0|0|0|1
  pshufw mm4, %2,  (0+1*4+1*16+2*64)     ; mm4= 0|1|1|2
  pshufw %2,  %2,  (1+2*4+2*16+3*64)     ; %2 = 1|2|2|3
  pshufw mm5, [edx+%3*16+2*2],  (0+1*4+1*16+2*64) ; mm5 = 2|3|3|4
%endmacro

%macro COL47_SSE 3    ;%1-%2: regs, %3: row   -trashes mm4/mm5
  pshufw %1, [edx+%3*16+2*2],  (1+2*4+2*16+3*64) ; 3|4|4|5
  movq mm5, [edx+%3*16+2*4]                      ; <- 4|5|6|7
  pshufw mm4, mm5,  (0+1*4+1*16+2*64)            ; 4|5|5|6
  pshufw %2,  mm5,  (1+2*4+2*16+3*64)            ; 5|6|6|7
  pshufw mm5, mm5,  (2+3*4+3*16+3*64)            ; 6|7|7|7
%endmacro


;//////////////////////////////////////////////////////////////////////

align 16
xvid_Copy_Upsampled_8x8_16To8_xmm:  ; 315c

  mov ecx, [esp+4]  ; Dst
  mov edx, [esp+8]  ; Src
  mov eax, [esp+12] ; BpS

  movq mm6, [Up13]
  movq mm7, [Up31]

  COL03_SSE mm0, mm1, 0
  MUL_PACK mm0,mm1, mm6, mm7
  movq mm4, mm0
  movq mm5, mm1
  STORE_1 mm4, mm5
  add ecx, eax

  COL03_SSE mm2, mm3, 1
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL03_SSE mm0, mm1, 2
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL03_SSE mm2, mm3, 3
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL03_SSE mm0, mm1, 4
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL03_SSE mm2, mm3, 5
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL03_SSE mm0, mm1, 6
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL03_SSE mm2, mm3, 7
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  STORE_1 mm2, mm3

  mov ecx, [esp+4]
  add ecx, 8

  COL47_SSE mm0, mm1, 0
  MUL_PACK mm0,mm1, mm6, mm7
  movq mm4, mm0
  movq mm5, mm1
  STORE_1 mm4, mm5
  add ecx, eax

  COL47_SSE mm2, mm3, 1
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL47_SSE mm0, mm1, 2
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL47_SSE mm2, mm3, 3
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL47_SSE mm0, mm1, 4
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL47_SSE mm2, mm3, 5
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  COL47_SSE mm0, mm1, 6
  MUL_PACK mm0,mm1, mm6, mm7
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_2 mm2, mm3

  COL47_SSE mm2, mm3, 7
  MUL_PACK mm2,mm3, mm6, mm7
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_2 mm0, mm1

  STORE_1 mm2, mm3

  ret

;===========================================================================
;
; void xvid_Add_Upsampled_8x8_16To8_xmm(uint8_t *Dst,
;                                       const int16_t *Src, const int BpS);
;
;===========================================================================

align 16
xvid_Add_Upsampled_8x8_16To8_xmm:  ; 549c

  mov ecx, [esp+4]  ; Dst
  mov edx, [esp+8]  ; Src
  mov eax, [esp+12] ; BpS

  COL03_SSE mm0, mm1, 0
  MUL_PACK mm0,mm1, [Up13], [Up31]
  movq mm4, mm0
  movq mm5, mm1
  STORE_ADD_1 mm4, mm5
  add ecx, eax

  COL03_SSE mm2, mm3, 1
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL03_SSE mm0, mm1, 2
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL03_SSE mm2, mm3, 3
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL03_SSE mm0, mm1, 4
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL03_SSE mm2, mm3, 5
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL03_SSE mm0, mm1, 6
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL03_SSE mm2, mm3, 7
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  STORE_ADD_1 mm2, mm3


  mov ecx, [esp+4]
  add ecx, 8

  COL47_SSE mm0, mm1, 0
  MUL_PACK mm0,mm1, [Up13], [Up31]
  movq mm4, mm0
  movq mm5, mm1
  STORE_ADD_1 mm4, mm5
  add ecx, eax

  COL47_SSE mm2, mm3, 1
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL47_SSE mm0, mm1, 2
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL47_SSE mm2, mm3, 3
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL47_SSE mm0, mm1, 4
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL47_SSE mm2, mm3, 5
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  COL47_SSE mm0, mm1, 6
  MUL_PACK mm0,mm1, [Up13], [Up31]
  MIX_ROWS mm2, mm3, mm0, mm1
  STORE_ADD_2 mm2, mm3

  COL47_SSE mm2, mm3, 7
  MUL_PACK mm2,mm3, [Up13], [Up31]
  MIX_ROWS mm0, mm1, mm2, mm3
  STORE_ADD_2 mm0, mm1

  STORE_ADD_1 mm2, mm3

  ret


;===========================================================================
;
; void xvid_HFilter_31_mmx(uint8_t *Src1, uint8_t *Src2, int Nb_Blks);
; void xvid_VFilter_31_x86(uint8_t *Src1, uint8_t *Src2, const int BpS, int Nb_Blks);
; void xvid_HFilter_31_x86(uint8_t *Src1, uint8_t *Src2, int Nb_Blks);
;
;===========================================================================

;//////////////////////////////////////////////////////////////////////
;// horizontal/vertical filtering: [x,y] -> [ (3x+y+2)>>2, (x+3y+2)>>2 ]
;//
;// We use the trick: tmp = (x+y+2) -> [x = (tmp+2x)>>2, y = (tmp+2y)>>2]
;//////////////////////////////////////////////////////////////////////

align 16
xvid_HFilter_31_mmx:
  push esi
  push edi
  mov esi, [esp+4  +8]  ; Src1
  mov edi, [esp+8  +8]  ; Src2
  mov eax, [esp+12 +8] ; Nb_Blks
  lea eax,[eax*2]
  movq mm5, [Cst2]
  pxor mm7, mm7

  lea esi, [esi+eax*4]
  lea edi, [edi+eax*4]

  neg eax

.Loop:  ;12c
  movd mm0, [esi+eax*4]
  movd mm1, [edi+eax*4]
  movq mm2, mm5
  punpcklbw mm0, mm7
  punpcklbw mm1, mm7
  paddsw mm2, mm0
  paddsw mm0, mm0
  paddsw mm2, mm1
  paddsw mm1, mm1
  paddsw mm0, mm2
  paddsw mm1, mm2
  psraw mm0, 2
  psraw mm1, 2
  packuswb mm0, mm7
  packuswb mm1, mm7
  movd [esi+eax*4], mm0
  movd [edi+eax*4], mm1
  add eax,1
  jl .Loop

  pop edi
  pop esi
  ret

  ; mmx is of no use here. Better use plain ASM. Moreover,
  ; this is for the fun of ASM coding, coz' every modern compiler can
  ; end up with a code that looks very much like this one...

align 16
xvid_VFilter_31_x86:
  push esi
  push edi
  push ebx
  push ebp
  mov esi, [esp+4  +16]  ; Src1
  mov edi, [esp+8  +16]  ; Src2
  mov ebp, [esp+12 +16]  ; BpS
  mov eax, [esp+16 +16]  ; Nb_Blks
  lea eax,[eax*8]

.Loop:  ;7c
  movzx ecx, byte [esi]
  movzx edx, byte [edi]

  lea ebx, [ecx+edx+2]
  lea ecx,[ebx+2*ecx]
  lea edx,[ebx+2*edx]

  shr ecx,2
  shr edx,2
  mov [esi], cl
  mov [edi], dl
  lea esi, [esi+ebp]
  lea edi, [edi+ebp]
  dec eax
  jg .Loop

  pop ebp
  pop ebx
  pop edi
  pop esi
  ret

  ; this one's just a little faster than gcc's code. Very little.

align 16
xvid_HFilter_31_x86:
  push esi
  push edi
  push ebx
  mov esi, [esp+4  +12]  ; Src1
  mov edi, [esp+8  +12]  ; Src2
  mov eax, [esp+12 +12]  ; Nb_Blks

  lea eax,[eax*8]
  lea esi, [esi+eax]
  lea edi, [esi+eax]
  neg eax

.Loop:  ; 6c
  movzx ecx, byte [esi+eax]
  movzx edx, byte [edi+eax]

  lea ebx, [ecx+edx+2]
  lea ecx,[ebx+2*ecx]
  lea edx,[ebx+2*edx]
  shr ecx,2
  shr edx,2
  mov [esi+eax], cl
  mov [edi+eax], dl
  inc eax

  jl .Loop

  pop ebx
  pop edi
  pop esi
  ret

;//////////////////////////////////////////////////////////////////////
;// 16b downsampling 16x16 -> 8x8
;//////////////////////////////////////////////////////////////////////

%macro HFILTER_1331 2  ;%1:src %2:dst reg. -trashes mm0/mm1/mm2
  movq mm2, [Mask_ff]
  movq %2,  [%1-1]    ;-10123456
  movq mm0, [%1]      ; 01234567
  movq mm1, [%1+1]    ; 12345678
  pand  %2, mm2       ;-1|1|3|5
  pand mm0, mm2       ; 0|2|4|6
  pand mm1, mm2       ; 1|3|5|7
  pand mm2, [%1+2]    ; 2|4|6|8
  paddusw mm0, mm1
  paddusw %2, mm2
  pmullw mm0,  mm7
  paddusw %2, mm0
%endmacro

%macro VFILTER_1331 4  ; %1-4: regs  %1-%2: trashed
  paddsw %1, [Cst32]
  paddsw %2, %3
  pmullw %2, mm7
  paddsw %1,%4
  paddsw %1, %2
  psraw %1, 6
%endmacro

;===========================================================================
;
; void xvid_Filter_18x18_To_8x8_mmx(int16_t *Dst,
;                                   const uint8_t *Src, const int BpS);
;
;===========================================================================

%macro COPY_TWO_LINES_1331 1     ; %1: dst
  HFILTER_1331 edx    , mm5
  HFILTER_1331 edx+eax, mm6
  lea edx, [edx+2*eax]
  VFILTER_1331 mm3,mm4,mm5, mm6
  movq [%1], mm3

  HFILTER_1331 edx    , mm3
  HFILTER_1331 edx+eax, mm4
  lea edx, [edx+2*eax]
  VFILTER_1331 mm5,mm6,mm3,mm4
  movq [%1+16], mm5
%endmacro

align 16
xvid_Filter_18x18_To_8x8_mmx:  ; 283c   (~4.4c per output pixel)

  mov ecx, [esp+4]  ; Dst
  mov edx, [esp+8]  ; Src
  mov eax, [esp+12] ; BpS

  movq mm7, [Cst3]
  sub edx, eax

    ; mm3/mm4/mm5/mm6 is used as a 4-samples delay line.

      ; process columns 0-3

  HFILTER_1331 edx    , mm3   ; pre-load mm3/mm4
  HFILTER_1331 edx+eax, mm4
  lea edx, [edx+2*eax]

  COPY_TWO_LINES_1331 ecx + 0*16
  COPY_TWO_LINES_1331 ecx + 2*16
  COPY_TWO_LINES_1331 ecx + 4*16
  COPY_TWO_LINES_1331 ecx + 6*16

      ; process columns 4-7

  mov edx, [esp+8]
  sub edx, eax
  add edx, 8

  HFILTER_1331 edx    , mm3   ; pre-load mm3/mm4
  HFILTER_1331 edx+eax, mm4
  lea edx, [edx+2*eax]

  COPY_TWO_LINES_1331 ecx + 0*16 +8
  COPY_TWO_LINES_1331 ecx + 2*16 +8
  COPY_TWO_LINES_1331 ecx + 4*16 +8
  COPY_TWO_LINES_1331 ecx + 6*16 +8

  ret

;===========================================================================
;
; void xvid_Filter_Diff_18x18_To_8x8_mmx(int16_t *Dst,
;                                        const uint8_t *Src, const int BpS);
;
;===========================================================================

%macro DIFF_TWO_LINES_1331 1     ; %1: dst
  HFILTER_1331 edx    , mm5
  HFILTER_1331 edx+eax, mm6
  lea edx, [edx+2*eax]
  movq mm2, [%1]
  VFILTER_1331 mm3,mm4,mm5, mm6
  psubsw mm2, mm3
  movq [%1], mm2

  HFILTER_1331 edx    , mm3
  HFILTER_1331 edx+eax, mm4
  lea edx, [edx+2*eax]
  movq mm2, [%1+16]
  VFILTER_1331 mm5,mm6,mm3,mm4
  psubsw mm2, mm5
  movq [%1+16], mm2
%endmacro

align 16
xvid_Filter_Diff_18x18_To_8x8_mmx:  ; 302c

  mov ecx, [esp+4]  ; Dst
  mov edx, [esp+8]  ; Src
  mov eax, [esp+12] ; BpS

  movq mm7, [Cst3]
  sub edx, eax

    ; mm3/mm4/mm5/mm6 is used as a 4-samples delay line.

      ; process columns 0-3

  HFILTER_1331 edx    , mm3   ; pre-load mm3/mm4
  HFILTER_1331 edx+eax, mm4
  lea edx, [edx+2*eax]

  DIFF_TWO_LINES_1331 ecx + 0*16
  DIFF_TWO_LINES_1331 ecx + 2*16
  DIFF_TWO_LINES_1331 ecx + 4*16
  DIFF_TWO_LINES_1331 ecx + 6*16

      ; process columns 4-7
  mov edx, [esp+8]
  sub edx, eax
  add edx, 8

  HFILTER_1331 edx    , mm3   ; pre-load mm3/mm4
  HFILTER_1331 edx+eax, mm4
  lea edx, [edx+2*eax]

  DIFF_TWO_LINES_1331 ecx + 0*16 +8
  DIFF_TWO_LINES_1331 ecx + 2*16 +8
  DIFF_TWO_LINES_1331 ecx + 4*16 +8
  DIFF_TWO_LINES_1331 ecx + 6*16 +8

  ret

;//////////////////////////////////////////////////////////////////////

  ; pfeewwww... Never Do That On Stage Again. :)

