{ =====================================================================
Application load file

Copyright 2000 FORTH, Inc.

This file is included near the end of Kernel.f and is intended to
load your application source.  Replace the default definition of GO
with one that performs application initialization and start-up.

You may also extend the string in GREET to contain your application name.

===================================================================== }

TARGET

: GREET   ." SwiftX/MSP430 FET430P140/F135 " ;

: GO ( -- )   DEBUG-LOOP ;

