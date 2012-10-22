{ =====================================================================
Serial XTL support

Copyright (c) 1972-2000, FORTH, Inc.

This file supplies the cross-target link (XTL) protocol control
character constants common to most serial XTL implementations.

Exports: XTL constants
===================================================================== }

TARGET

{ --------------------------------------------------------------------
XTL control characters

The target XTL serial input handler treats the <ESC> character as a
special case:

<ESC> <ESC> is translated to a single <ESC>

<ESC> followed by anything else aborts the command input routine,
replies with <RST>, and goes back to the idle state awaiting a
new XTL command from the host.
-------------------------------------------------------------------- }

27 EQU <ESC>            \ Escape character
248 EQU <XY>            \ Position cursor
253 EQU <NAK>           \ Target announces it has aborted or restarted
254 EQU <ACK>           \ Target command completed ok
255 EQU <RST>           \ Target ready for new XTL command

