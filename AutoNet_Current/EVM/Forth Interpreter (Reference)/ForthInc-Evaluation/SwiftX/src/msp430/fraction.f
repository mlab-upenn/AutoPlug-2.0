{ =====================================================================
Square root

Copyright (C) 2001  FORTH, Inc.

This square root routine will produce a 15-bit integer representing the
non-fractional part of the square root of a positive 30-bit integer.
===================================================================== }

TARGET

CODE SQRT ( d -- n )
   @S+ R8 MOV   T R9 MOV   R10 CLR   16 # R11 MOV
   T CLR   BEGIN
      R8 RLA   R9 RLC   R10 RLC
      R8 RLA   R9 RLC   R10 RLC
      T RLA   T RLA   T INC   T R10 CMP
      CS IF  T R10 SUB   T INC   THEN
   T RRA   R11 DEC   0= UNTIL   RET   END-CODE

