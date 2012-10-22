{ =====================================================================
Application load file

Copyright 2008 FORTH, Inc.

This file is included near the end of Kernel.f and is intended to
load your application source.  Replace the default definition of GO
with one that performs application initialization and start-up.

You may also extend the string in GREET to contain your application name.

===================================================================== }

TARGET

: GREET   ." SwiftX/MSP430 eZ430-RF2500 " ;

: GO ( -- )   DEBUG-LOOP ;
