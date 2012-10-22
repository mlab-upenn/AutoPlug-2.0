{ =====================================================================
JTAG cross-target link

Copyright (C) 2001  FORTH, Inc.

This is the target side of the JTAG cross-target link.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Remote execution

The target-host XTL protocol uses register T (R5) to pass a function
code to the host when target enters the REPLY loop.

255 - Target announces reset (not used in this implementation)
254 - Target completed normally
253 - Target aborted
252 - Emit character
251 - Type string
250 - CR
249 - PAGE
248 - AT-XY
247 - Input key
246 - Test for key
245 - Send debugging address to host
244 - Accept input string

Any other value returned in T indicates abnormal entry to REPLY.

PUT-STACK  is the normal return of control to the host.

XTL clears the stacks and enters the high-level JTAG command loop.
--------------------------------------------------------------------- }

CODE REPLY ( u -- )   DINT   SSAVE (U) CLR
   BEGIN ( *)    TPOP   EINT   RET   END-CODE

( *) HOST  'XTL !  TARGET               \ Set XTL breakpoint address

16 BUFFER: TBUF

CODE /TBUF ( -- )
   TBUF # R9 MOV   @R9+ R8 MOV.B   R8 TST   0= NOT IF
      TBUF CLR.B   TPUSH   251 # T MOV   ' REPLY JMP
   THEN   RET   END-CODE

: PUT-STACK ( -- )   /TBUF  254 REPLY ;

: XTL ( -- )   /STACKS                  \ Reset stacks
   BEGIN  STOP  BASE !  CATCH           \ Perform function, return result
   BASE @ SWAP  PUT-STACK  AGAIN ;

{ ---------------------------------------------------------------------
Breakpoint support

'BP holds the breakpoint return stack pointer.

REGLIST holds the register list saved by <DEBUG> in support of
breakpoints in CODE words.

BREAKPOINT calls !BP to retain the return stack pointer and enters
a new instance of the JTAG command loop.

RESUME returns out of the current instance of the JTAG command loop
and back to the point where BREAKPOINT was called.  Does nothing if
'BP contains 0 (no breakpoint set).
--------------------------------------------------------------------- }

VARIABLE 'BP

CODE !BP ( -- )   R R8 MOV   R8 INCD
   R8 'BP MOV   RET   END-CODE

: BREAKPOINT ( -- )   !BP
   0  BEGIN  BASE @ SWAP  PUT-STACK
   STOP  BASE !  CATCH   AGAIN ;

CODE RESUME ( -- )   'BP TST   0= NOT IF
      CATCHER (U) R8 MOV   @R8 CATCHER (U) MOV
   'BP R MOV   'BP CLR   THEN   RET   END-CODE

{ ---------------------------------------------------------------------
Vectored terminal

The (X- words supply the behaviors for the vectored terminal I/O words.
Functions are implemented as described above.  The host retrieves
parameters directory from target memory (including parameters on
the stack).  X-FUNC calls the REPLY loop to deliver the function code
to the host and then calls STOP until the task is awakened when the
host has finished providing the I/O service.

DEBUG-LOOP sets the terminal vectors and enters the XTL loop.
--------------------------------------------------------------------- }

: (X-EMIT) ( char -- )
   TBUF C@ 15 = IF  /TBUF  THEN  TBUF COUNT + C!  1 TBUF C+! ;

CODE ((X-TYPE)) ( addr len -- )
   T R8 MOV   @S+ R9 MOV   251 # T MOV   ' REPLY JMP   END-CODE

: (X-TYPE) ( addr len -- )
   DUP TBUF C@ +  15 < IF  >R  TBUF COUNT + R@ CMOVE  R> TBUF C+!  EXIT  THEN
   /TBUF  DUP 15 < IF  TBUF C!  TBUF COUNT CMOVE  EXIT  THEN  ((X-TYPE)) ;

: (X-CR) ( -- )   /TBUF  250 REPLY ;
: (X-PAGE) ( -- )   /TBUF  249 REPLY ;

CODE ((X-ATXY)) ( x y -- )
   T R8 MOV   @S+ R9 MOV   248 # T MOV   ' REPLY JMP   END-CODE

: (X-ATXY) ( x y -- )   /TBUF ((X-ATXY)) ;

: (X-KEY) ( -- char)   /TBUF  0  247 REPLY STOP ;
: (X-KEY?) ( -- flag)   /TBUF  0  246 REPLY ;

CODE ((X-ACCEPT)) ( c-addr len1 -- c-addr )
   T R8 MOV   @S R9 MOV   244 # T MOV   ' REPLY JMP   END-CODE

: (X-ACCEPT) ( c-addr len1 -- len2)   /TBUF  ((X-ACCEPT)) STOP ;

CODE .' ( x -- )   T R8 MOV   245 # T MOV   ' REPLY JMP   END-CODE

: XTL-TERMINAL ( -- )   ['] (X-EMIT) 'EMIT !  ['] (X-TYPE) 'TYPE !
   ['] (X-CR) 'CR !  ['] (X-PAGE) 'PAGE !  ['] (X-ATXY) 'ATXY !  ['] (GETXY) 'GETXY !
   ['] (X-KEY) 'KEY !  ['] (X-KEY?) 'KEY? !  ['] (X-ACCEPT) 'ACCEPT ! ;

: DEBUG-LOOP ( -- )
   ?XTL @ IF  AM 'LP !  XTL-TERMINAL  0 TBUF C!  XTL  THEN  STOP ;
