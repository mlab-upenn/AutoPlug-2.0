\ Random number generator        
\ Copyright 1986-1993 Laboratory Microsystems Inc.

\ Given an argument, returns a pseudo-random number between
\  0 and that argument.  The pseudo-random sequence can be
\  altered by changing the seed.

VARIABLE SEED

: random ( -- n )                             \ 0 <= n <= 32767
   SEED @ 259 * 3 + 32767 AND
   DUP SEED ! ;

: RANDOM ( n1 -- n2 )                            \ 0 <= n2 < n1
   random M* 32768 UM/MOD NIP ;

CR .( Random number utility loaded.) CR

