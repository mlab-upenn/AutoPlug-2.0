{ =====================================================================
Multitasker

Copyright 2001  FORTH, Inc.

SwiftOS multitasker executive for the MSP430.

===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Round-robin multitasker interface

The two-word STATUS field at the start of eash task's user area
contains either an immediate MOV to PC or CALL opcode in the first
word.  The second word is the address of the next task.

GIVE  is the address of the code which returns control to a
suspended a task.  This subroutine is called through register T
 by the WAKE code in STATUS of the task which is waking up.

STOP  is the normal entry for a task that will remain suspended
(asleep) until some event (such as an interrupt) awakens it
by storing  WAKE  in its  STATUS .  WAIT can be branched to
from a code definition.

PAUSE  is the entry to the multiprogrammer.  It stores  WAKE
in the caller's  STATUS  so the task will remain active
next time around the loop.
--------------------------------------------------------------------- }

$1285 EQU WAKE          \ Target task wake-up opcode: T CALL
$4030 EQU SLEEP         \ Target task suspended opcode:  a # BR

LABEL GIVE                              \ Give CPU to next task, addr on stack
   U POP   U DECD                       \ Calculate task address in U
   SLEEP # STATUS (U) MOV               \ Set task's STATUS to SLEEP
   SSAVE (U) S MOV   TPOP               \ Restore data stack
   RSAVE (U) R MOV   RET   END-CODE     \ Restore return stack, return to task code

CODE STOP ( -- )                        \ Suspend task execution
   TPUSH   GIVE # T MOV                 \ Save TOS, set T to addr of GIVE
   S SSAVE (U) MOV   R RSAVE (U) MOV    \ Save stack pointers
   FOLLOWER (U) BR   END-CODE

' STOP EQU WAIT

CODE PAUSE ( -- )
   WAKE # STATUS (U) MOV                \ Mark task ready to resume
   WAIT JMP   END-CODE

{ ---------------------------------------------------------------------
Facility access control

GRAB asserts control of a facility by storing the current user's
STATUS  address in its facility variable.  If the facility isn't
available (i.e, value non-zero and not this user)  waits in PAUSE
until it is available.

GET calls GRAB after one lap around the multiprogrammer.

RELEASE releases a specified facility variable by setting it to zero if
it belongs to the current user.  Leaves it set if not current user's.
--------------------------------------------------------------------- }

CODE GRAB ( addr -- )
   BEGIN   @T U CMP   0= NOT IF   0 (T) TST
         0= IF   U 0 (T) MOV   SWAP THEN
      TPOP   RET   THEN   ' PAUSE # CALL
   AGAIN   END-CODE

: GET ( addr -- )   PAUSE GRAB ;

CODE RELEASE ( addr -- )
   @T U CMP   0= IF   0 (T) CLR   THEN
   TPOP   RET   END-CODE

{ ---------------------------------------------------------------------
Task defining and control

ACTIVATE  starts a task whose address is given executing the
remainder of the colon definition in which ACTIVATE occurs.
The code after ACTIVATE must never EXIT.

BACKGROUND sets up the task definition table for a non-terminal
task, given user area size and stack sizes.

TERMINAL defines a target terminal task.  Takes size of additional
target dictionary or PAD allocation.

HIS takes task address and user variable, returns address in
task's user area.  Host and target versions are provided.
Example:  TASK CTR HIS

HALT assigns task addr the NOD behavior which sleeps forever.

BUILD  takes the address of a table set up by BACKGROUND and
builds the task's user area in RAM.

CONSTRUCT is the equivalent of BUILD for a TERMINAL task.
--------------------------------------------------------------------- }

CODE ACTIVATE ( addr -- )
   U R8 MOV   @T U MOV                  \ Point at task's user area
   WAKE # STATUS (U) MOV                \ Awaken task
   S0 (U) SSAVE (U) MOV                 \ Set initial data stack pointer
   STATUS 2- (U) POP   U RSAVE (U) MOV  \ Pop return address
   SSAVE (U) DECD   RSAVE (U) DECD      \ Adjust stack pointers
   R8 U MOV   TPOP   RET   END-CODE

INTERPRETER

: BACKGROUND ( nu ns nr -- )
     ALIGN  CREATE                      \ Make definition
     SWAP ALIGNED RESERVE DROP          \ Reserve data stack space
     ALIGNED RESERVE                    \ Reserve return stack space
     SWAP ALIGNED RESERVE  , , ;        \ Reserve user area, save STATUS & S0

: TERMINAL ( n -- )
   |NUM| + |PAD| + RESERVE              \ Space for NUM, PAD, HERE
   |U| |S| |R| BACKGROUND , ;           \ Allocate task, save its HERE

: HIS ( addr1 addr2 -- addr3 )
   STATUS - SWAP @ + ;

TARGET

: HIS ( addr1 addr2 -- addr3 )
   STATUS - SWAP @ + ;

: NOD ( -- )   BEGIN  STOP  AGAIN ;

: HALT ( addr -- )   ACTIVATE  NOD ;

: BUILD ( addr -- )
   DUP >R 2@  STATUS OVER 4 CMOVE
   FOLLOWER !  R@ S0 HIS !  R> HALT ;

: CONSTRUCT ( addr -- )   >R            \ Task descriptor address
   STATUS R@ @ |U| MOVE                 \ Give a copy of our user area
   R@ BUILD  R@ CELL+ CELL+ @           \ Build task, get initial H
   DUP R> H HIS 2! ;                    \ Save in H, H0

