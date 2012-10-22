{ =====================================================================
Common core words

Copyright (c) 1972-2000, FORTH, Inc.

Common words from the Core and Core Ext word set which are generic
to all kernels are defined here.

Exports: DECIMAL, HEX, S>D, system constants
===================================================================== }

TARGET

-1 CONSTANT TRUE   0 CONSTANT FALSE   32 CONSTANT BL   -? CELL CONSTANT CELL

: DECIMAL ( -- )   10 BASE ! ;
: HEX ( -- )   16 BASE ! ;
: OCTAL ( -- )   8 BASE ! ;
: BINARY ( - )    2 BASE ! ;

: S>D ( n -- d)   DUP 0< ;

