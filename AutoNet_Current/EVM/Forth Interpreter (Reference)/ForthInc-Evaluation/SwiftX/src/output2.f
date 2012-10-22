{ =====================================================================
Double number output

Copyright (c) 1972-2000, FORTH, Inc.

The common double-precision integer output words are implemented here.

Requires: Double-precision integer math, number output formatting

Exports: (D.)  D.  D.R
===================================================================== }

TARGET

: (D.) ( d-- c-addr len)   DUP >R  DABS <#  #S  R> SIGN  #> ;
: D. ( d -- )   (D.) TYPE SPACE ;
: D.R ( d len -- )   >R (D.)  R> OVER - SPACES TYPE ;

