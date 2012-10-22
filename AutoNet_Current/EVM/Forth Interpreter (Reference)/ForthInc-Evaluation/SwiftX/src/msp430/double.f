{ =====================================================================
Double numbers

Copyright (C) 2001  FORTH, Inc.

This file implements the CPU-specific functions in the ANS Forth
Double-number and double-number extension word sets.  It also supplies
mixed-precision operators.
===================================================================== }

TARGET

CODE 2ROT ( d1 d2 d3 -- d2 d3 d1 )
   6 (S) R8 MOV   8 (S) R9 MOV
   2 (S) 6 (S) MOV   4 (S) 8 (S) MOV
   T 2 (S) MOV   @S 4 (S) MOV
   R8 T MOV   R9 0 (S) MOV
   RET   END-CODE

CODE DNEGATE ( d1 -- d2 )
   R8 CLR   R9 CLR
   @S R8 SUB   T R9 SUBC
   R9 T MOV   R8 0 (S) MOV
   RET   END-CODE

CODE D+ ( d1 d2 -- d3 )
   @S+ 2 (S) ADD   @S+ T ADDC
   RET   END-CODE

CODE D- ( d1 d2 -- d3 )
   @S+ 2 (S) SUB   T 0 (S) SUBC
   TPOP   RET   END-CODE

CODE D< ( d1 d2 - flag )
   @S+ 2 (S) SUB   T 0 (S) SUBC   0 # T MOV
   S< IF   -1 # T MOV   THEN   4 # S ADD
   RET   END-CODE

CODE DU< ( d1 d2 - flag)
   @S+ 2 (S) SUB   T 0 (S) SUBC   T T SUBC
   4 # S ADD   RET   END-CODE

CODE D2* ( d1 -- d2)
   0 (S) RLA   T RLC   RET   END-CODE

CODE D2/ ( d1 -- d2)
   T RRA   0 (S) RRC   RET   END-CODE

