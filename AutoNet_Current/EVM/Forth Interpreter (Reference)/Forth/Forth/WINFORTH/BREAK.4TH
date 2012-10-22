\ Breakpoint utility                             00:02 10/02/92
\
\ Implementation-dependent breakpoint for LMI WinForth 1.0
\ Copyright (c) 1989-1992 Laboratory Microsystems Inc.
\ Assumes separate stack segment.
\
\ Syntax:  BREAK <name> [n]
\ <name> is the word to be breakpointed
\ n = pass number to break on, default = 1
\
\ Example:  BREAK DUP 5
\ will break at DUP on the 5th execution of that word

EXISTS? CODE NOT .IF ASM .THEN \ load assembler if necessary

 VARIABLE BPA                               \ cfa of breakpoint
 VARIABLE BPC                                    \ pass counter
 VARIABLE BPN                                  \ desired passes

CREATE BPNEXT  10 ALLOT  BPNEXT 10 ERASE         \ copy of NEXT

\ u --- ; display hex number in form nnnnH with trailing blank
: .HEX      0 <# ASCII H HOLD  # # # # #> TYPE SPACE ;

\ offset depth --- ; display depth & stack contents
: .STK      ASCII ( EMIT  DUP 0 .R  ASCII ) EMIT SPACE
            10 MIN 0
            ?DO  DUP I WSIZE * + SS0 SWAP @L .HEX
            LOOP DROP ;

\ offset depth --- ; display names in return stack
: .RSTK     ASCII ( EMIT  DUP 0 .R  ASCII ) EMIT SPACE
            10 MIN 0
            ?DO  DUP I WSIZE * + SS0 SWAP @L  2- @
                 >NAME DUP -1 =
                 IF    DROP ." ? "
                 ELSE  .NAME SPACE
                 THEN
            LOOP DROP ;

\ --- ; display breakpoint information
: .BKPT     HEX CR
            CR ." Breakpoint:   "  BPA @ >NAME .NAME
            CR ." Forth IP:     "  .HEX
            CR ." Data stack:   "               \ data stack hex
               S0 @  OVER - WSIZE / .STK
            CR ." Return stack: "             \ return stack hex
               R0 @  OVER - WSIZE /  2DUP .STK
            CR 14 SPACES .RSTK              \ return stack names
            CR  BPA OFF ABORT ;             \ release breakpoint

\ all NEXTs in system are patched to jump here
PROC BPCODE WORD LODS                      \ cfa to be executed
            AX, BPA CMP  1$ JE              \ match found, jump
            AX JMP                        \ not match, continue
    1$:     WORD BPC INC                     \ check pass count
            CX, BPC MOV  CX, BPN CMP  2$ JE
            AX JMP                \ not enough passes, continue
    2$:     BX PUSH                     \ update physical stack
            AX, SP MOV  BP PUSH              \ return stack ptr
            AX PUSH                        \ data stack pointer
            BX, SI MOV                               \ Forth IP
            ' .BKPT JMP  END-PROC       \ go display breakpoint

\ build copy of inline NEXT in data segment      11:49 10/22/89

PROC TEMPCODE   NEXT,  END-PROC           \ assemble inline NEXT

CS0 TEMPCODE                           \ address in code segment
DS0 BPNEXT 1+                          \ address in data segment
CP @ TEMPCODE -                          \ length of inline NEXT

DUP BPNEXT ! CMOVEL                       \ copy to data segment

FORGET TEMPCODE                   \ throw away code segment copy

\ search for inline NEXT                         
\ starting_offset --- match_offset | -1
: BPSCH     >R  CS0 R@  CP @ R@ -       \ code segment: ptr len
            DS0  BPNEXT COUNT               \ template: ptr len
            STRNDXL                  \ search for next instance
            R>  OVER  -1 =                         \ none left?
            IF   DROP                    \ exhausted, return -1
            ELSE +                      \ return offset of NEXT
            THEN ;

\ dest source --- ; assemble  "JMP dest"  at location "source"
: BPJMP     >R  [ HEX ] 0E9 [ DECIMAL ] HERE C!
            R@  3 + -  HERE 1+ !
            DS0 HERE  CS0 R>  3  CMOVEL ;

\ --- ; find all instances of NEXT and replace them
: BPREPL    0               \ start at beginning of code segment
            BEGIN  BPSCH             \ look for next inline NEXT
                   DUP -1 =                    \ found any more?
                   IF    DROP EXIT                        \ done
                   THEN  BPCODE OVER BPJMP   \ patch NEXT to JMP
                   BPNEXT C@ +          \ advance past this NEXT
            AGAIN  ;


\ --- ; sets breakpoint, used in the form:  BREAK <name> [n]
\ n = pass number to break on, default = 1
: BREAK     ' BPA !              \ get cfa of breakpointed word
            BPREPL                   \ patch all copies of NEXT
            BL WORD DUP C@                  \ passes specified?
            IF    NUMBER? 2DROP    \ yes, convert no. of passes
            ELSE  DROP 1               \ no, default passes = 1
            THEN  1 MAX BPN !                     \ save passes
            BPC OFF ;                  \ initialize pass counter

\ discard building blocks and variables
EXCISE BPA BPREPL

CR 
CR .( To set breakpoint enter: BREAK wordname passnumber )
CR .( For example, to break on the 4th pass thru FOOBAR, enter:)
CR .(   BREAK FOOBAR 4)
CR .( Only one breakpoint can be active at a time.)
CR CR

