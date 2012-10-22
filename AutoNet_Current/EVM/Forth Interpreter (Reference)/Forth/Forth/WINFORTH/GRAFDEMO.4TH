\ GRAFDEMO.4TH -- Various graphics demos for WinForth
\ Copyright (C) 1982-1992 LMI

INCLUDE TURTLE.4TH

FORTH DEFINITIONS DECIMAL

WCB MAINWIN    \ window control block for frame window
VARIABLE 'DEMO  ' NOOP 'DEMO !  \ execution vector for demo

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT
110 CONSTANT IDM_BINTREE
111 CONSTANT IDM_POLYSPI1
112 CONSTANT IDM_POLYSPI2
113 CONSTANT IDM_POLYSPI3
114 CONSTANT IDM_DRAGON1
115 CONSTANT IDM_DRAGON2
116 CONSTANT IDM_SPINSQUARE
117 CONSTANT IDM_SNOWFLAKE
118 CONSTANT IDM_OSCILLOSCOPE
119 CONSTANT IDM_HILBERT
120 CONSTANT IDM_CIRCDEMO
121 CONSTANT IDM_BULLSEYE
123 CONSTANT IDM_MOIRE
124 CONSTANT IDM_WALK
125 CONSTANT IDM_FTRIANGLE
126 CONSTANT IDM_FSQUARE
127 CONSTANT IDM_BOXDEMO
128 CONSTANT IDM_ROUNDRECTDEMO
129 CONSTANT IDM_POLYGONDEMO
131 CONSTANT IDM_ELLIPSEDEMO
132 CONSTANT IDM_COLORDEMO
133 CONSTANT IDM_PELDEMO

\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
    " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
    " "          0              MF_SEPARATOR MENUITEM 
    " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
  END-POPUP 
  " &Pick Demo" POPUP
    " Binary Tree"    IDM_BINTREE MF_ENABLED  MENUITEM
    " Polyspi #1"     IDM_POLYSPI1 MF_ENABLED  MENUITEM
    " Polyspi #2"     IDM_POLYSPI2 MF_ENABLED  MENUITEM
    " Polyspi #3"     IDM_POLYSPI3 MF_ENABLED  MENUITEM
    " Right Dragon Curve" IDM_DRAGON1 MF_ENABLED  MENUITEM
    " Left Dragon Curve" IDM_DRAGON2 MF_ENABLED  MENUITEM
    " Spinsquare"     IDM_SPINSQUARE MF_ENABLED MENUITEM
    " Snowflake"      IDM_SNOWFLAKE MF_ENABLED MENUITEM
    " Oscilloscope"   IDM_OSCILLOSCOPE MF_ENABLED MENUITEM
    " Hilbert Curve"  IDM_HILBERT MF_ENABLED MENUITEM
    " Circles"        IDM_CIRCDEMO MF_ENABLED MENUITEM
    " Ellipses"       IDM_ELLIPSEDEMO MF_ENABLED MENUITEM
    " Boxes"          IDM_BOXDEMO MF_ENABLED MENUITEM
    " Round Rectangles" IDM_ROUNDRECTDEMO MF_ENABLED MENUITEM
    " Polygons"       IDM_POLYGONDEMO MF_ENABLED MENUITEM
    " Bullseye"       IDM_BULLSEYE MF_ENABLED MENUITEM
    " Moire"          IDM_MOIRE MF_ENABLED MENUITEM
    " Walking Lines"  IDM_WALK MF_ENABLED MENUITEM
    " Square Wave"    IDM_FSQUARE MF_ENABLED MENUITEM
    " Triangle Wave"  IDM_FTRIANGLE MF_ENABLED MENUITEM
    " Colored Text"   IDM_COLORDEMO MF_ENABLED MENUITEM
  END-POPUP
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About GrafDemo..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " Graphics Demos"         32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1991 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

VARIABLE SEED

8 EQU ?COLORS

: (RAND) SEED @ 259 * 3 + 32767 AND DUP SEED ! ;
: RANDOM    ( n1 -- n2 )  (RAND) 32767 */ ;
: RXY ( --- x y ) XMAX 1+ RANDOM  YMAX 1+ RANDOM ;

CREATE COLORTABLE  RED , ,      BLUE , ,      GREEN , ,   GREY , , 
                   CYAN , ,     MAGENTA , ,   YELLOW , ,  BLACK , , 

\ n --- colorref ; converts integer value to 32-bit colorref value
: N>COLOR    7 MOD 4 * COLORTABLE + 2@ ;

\ --- colorref ; return random nonzero colorref
: RCOLOR   255 RANDOM  255 RANDOM  255 RANDOM  RGB 
           2DUP WHITE D= IF 2DROP RECURSE THEN ;

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " Graphics Demos"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

( --- flag ; this is the callback handler for the test dialog )
: ABOUTDLGPROC  wMsg WM_INITDIALOG =
                IF    TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam ID_PUSHB =
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

\ msg --- ; send message to frame window
: MSG>MAINWIN  MAINWIN WCB>HWND SWAP 0 0. SendMessage 2DROP ;

\
\  Binary Tree Demo section
\
VARIABLE 'LBR  \ execution vectors for co-routines
VARIABLE 'RBR
VARIABLE LEVEL  8 LEVEL !   \ number of branching levels
VARIABLE ANGLE  15 ANGLE !  \ angle at branchpoint

( --- ; draw a left branch )
: LBR       'LBR PERFORM ;

( --- ; draw a right branch )
: RBR       'RBR PERFORM ;

( --- ; draws left and right branches at a node )
: NODE      TURTLE LEVEL @ 1 <               \ is this level 0?
            IF    EXIT                        \ yes we are done
            THEN  -1 LEVEL +!            \ no, backup one level
            ANGLE @  LEFT      LBR           \ draw left branch
            ANGLE @  2* RIGHT  RBR          \ draw right branch
            ANGLE @ LEFT 1 LEVEL +! ;           \ restore level

( length --- ; draw left branch of 2* length )
: (LBR)     TURTLE DUP 2* PENDOWN FORWARD NODE
            DUP 2* PENUP BACKWARD ;

( length --- ; draw right branch )
: (RBR)     TURTLE DUP PENDOWN FORWARD NODE
            DUP PENUP BACKWARD ;

' (LBR)  'LBR !   ' (RBR)  'RBR !     \ set execution vectors

( --- ; binary tree demo )
: BINTREE   TURTLE 4 1 
            DO    I PENWIDTH  I 1- N>COLOR PEN
                  XMAX 2/ YMAX SETXY \ set starting point
                  -90 DIRECTION  \ and head upwards
                  YMAX 2/ LEVEL @ 1- /  LBR  \ start with left branch
                  DROP
            LOOP  FORTH 1 PENWIDTH ;

EXCISE  'LBR (RBR)

\
\ Hilbert curves by Joe Barnhart
\

480 CONSTANT START.LEG          ( 192 FOR 320X200 )

VARIABLE LEG
VARIABLE X
VARIABLE XPREV
VARIABLE Y
VARIABLE YPREV
VARIABLE X0
VARIABLE Y0
VARIABLE 'A
VARIABLE 'V
VARIABLE '<
VARIABLE '>

: DRAW  XPREV @ YPREV @ X @ Y @ LINE  X @ XPREV ! Y @ YPREV ! ;
: UP    LEG @ Y +! DRAW ;
: DOWN  LEG @ NEGATE Y +! DRAW ;
: LEFT  LEG @ NEGATE X +! DRAW ;
: RIGHT LEG @ X +! DRAW ;
: ~A    'A PERFORM ;
: ~V    'V PERFORM ;
: ~<    '< PERFORM ;
: ~>    '> PERFORM ;
: [<]   DUP 0> IF DUP 1- ~V LEFT ~< DOWN ~< RIGHT ~A DROP THEN ;
: [A]   DUP 0> IF DUP 1- ~> UP ~A RIGHT ~A DOWN ~< DROP THEN ;
: [>]   DUP 0> IF DUP 1- ~A RIGHT ~> UP ~> LEFT ~V DROP THEN ;
: [V]   DUP 0> IF DUP 1- ~< DOWN ~V LEFT ~V UP ~> DROP THEN ;

' [A] 'A !      ' [V] 'V !      ' [<] '< !    ' [>] '> !

( --- )
: HILBERT   6 ( degree, use 3-6 )
        XMAX YMAX 32 - MIN 32 / 32 * DUP LEG ! 2/ 
        16 + DUP X0 ! Y0 !   0 
        DO  I N>COLOR PEN
            LEG @ 2/ DUP LEG ! 2/ DUP X0 +! Y0 +!
            X0 @ X !  Y0 @ Y ! X @ XPREV !  Y @ YPREV !
            I 1+ ~< DROP
        LOOP FORTH ;

EXCISE START.LEG  [V]

\
\ PolySpi section
\ 

: <POLYSPI>   ( distance  angle  change  --- )    TURTLE
        ?QUIT IF EXIT THEN
        2 PICK FORWARD  1 PICK RIGHT
        ROT OVER + ROT ROT  RECURSE  FORTH ;
        
( --- )
: <PSETUP>   TURTLE CENTER RCOLOR PEN  PENDOWN  FORTH ;

: POLYSPI1  <PSETUP> 10 62 5 <POLYSPI> 3DROP ;
: POLYSPI2  <PSETUP> 10 91 5 <POLYSPI> 3DROP ;
: POLYSPI3  <PSETUP> 10 122 5 <POLYSPI> 3DROP ;

EXCISE <POLYSPI> <PSETUP>

\
\ Spinsquare section
\

( size angle difference --- )
: <SPINSQUARE>  TURTLE  2 PICK 170 >
                IF   EXIT
                THEN 2 PICK SQUARE 1 PICK RIGHT
                ROT OVER + ROT ROT RECURSE FORTH ;

( --- ; spinsquare demo )
: SPINSQUARE    TURTLE  PENDOWN   RCOLOR PEN
                CENTER  10 10 3 <SPINSQUARE> 3DROP
                FORTH ;

EXCISE <SPINSQUARE> <SPINSQUARE>

\
\ Dragon Curve section
\

VARIABLE 'RDRAGON   \ holds cfa for RDRAGON

( size level --- )
: LDRAGON   TURTLE DUP 0=
            IF    DROP FORWARD EXIT
            THEN  2DUP 1- RECURSE
            90 LEFT  1-  'RDRAGON PERFORM ;

( size level --- )
: RDRAGON   TURTLE DUP 0=
            IF    DROP FORWARD EXIT
            THEN  2DUP 1- LDRAGON
            90 RIGHT 1- RECURSE ;

' RDRAGON 'RDRAGON !

( --- ; demo of 10 level right dragon curve )
: DRAGON1   TURTLE  125 YMAX 2 3 */ SETXY  0 DIRECTION
            PENDOWN  RCOLOR PEN  10 10 RDRAGON ;

( --- ; demo of 10 level left dragon curve )
: DRAGON2   TURTLE  300 YMAX 3 4 */ SETXY 0 DIRECTION
            PENDOWN  RCOLOR PEN  10 10 LDRAGON  FORTH ;

EXCISE 'RDRAGON RDRAGON

\
\ Snowflake demo
\

( size level --- ; draws one side of a snowflake )
: FLAKE1    TURTLE  DUP 0=
            IF    DROP  FORWARD   EXIT  THEN
            2DUP  SWAP 3 /  SWAP 1-  RECURSE  60 LEFT
            2DUP  SWAP 3 /  SWAP 1-  RECURSE  120 RIGHT
            2DUP  SWAP 3 /  SWAP 1-  RECURSE  60 LEFT
                  SWAP 3 /  SWAP 1-  RECURSE ;

( size level --- )
: FLAKE2    TURTLE   0 DIRECTION    3 0
            DO    2DUP  FLAKE1  120 RIGHT
            LOOP  2DROP ;

( --- ; snowflake demo )
: SNOWFLAKE TURTLE PENDOWN  BLUE PEN
            XMAX 4 / YMAX 4 / SETXY   
            XMAX 2 / ( 400 ) 200 MAX 4 FLAKE2  
            FORTH ;

EXCISE FLAKE1 FLAKE2

\
\ Oscilloscope
\

VARIABLE CPX   VARIABLE CPY

: MOVE-XY ( x y -- ) CPY ! CPX ! ;

: LINE-XY ( x y -- ) CPX @ CPY @ 2SWAP 2DUP CPY ! CPX ! LINE ;

: OSCILLOSCOPE ( -- )   RCOLOR PEN
    233 307 MOVE-XY                               ( 1st point )
    3595 0 DO
    I 16 10 t*/ SIN 300 10000 t*/ 320  +  ( X )
    I 17 10 t*/ 35 + SIN 230 10000 t*/ 240 + ( Y )
    LINE-XY 5 +LOOP ;  
    
\
\ random circles demo
\
: CIRC-DEMO 100 0 
    DO  RCOLOR PEN  I 1 AND
        IF   SOLID PENSTYLE  10 RANDOM PENWIDTH
        ELSE DASHDOTDOT 1+  RANDOM PENSTYLE  1 PENWIDTH
        THEN RXY RXY CIRCLE
    LOOP SOLID PENSTYLE 1 PENWIDTH ;

\
\ random ellipses demo
\
: ELLIPSE-DEMO 100 0 
    DO  RCOLOR PEN   RXY RXY ELLIPSE
    LOOP ;

\
\ random filled boxes demo
\
: BOX-DEMO 100 0 
    DO   RCOLOR PEN  RCOLOR BRUSH RXY RXY RECTANGLE
    LOOP HOLLOW BRUSH ;    \ deselect fill color

\
\ random filled rounded rectangle demo
\
: ROUNDRECT-DEMO 100 0 
    DO  RCOLOR PEN  RCOLOR BRUSH
        RXY RXY   \ rectangle corners
        2OVER 2OVER ROT - ABS 4 / -ROT - ABS 4 / SWAP \ ellipse sizes
        ROUNDRECT    \ random round rectangle, clipped at screen edges
    LOOP  HOLLOW BRUSH ;    \ deselect fill color

\
\ random filled polygon demo
\
10 CONSTANT #POINTS

CREATE STARDATA  271 , 29 ,  330 , 210 ,  389 , 29 ,
                 235 , 141 , 425 , 141 ,

CREATE POLYDATA      #POINTS WSIZE 2* * ALLOT

: POLYGON-DEMO 100 0
    DO  #POINTS 0
        DO    RXY  POLYDATA I WSIZE * 2* +  PNT!
        LOOP  RCOLOR PEN  RCOLOR BRUSH  POLYDATA #POINTS POLYGON 
    LOOP  HOLLOW BRUSH ;

\    
\ concentric circles demo
\
: BULLSEYE  XMAX 2/  YMAX 2/  ( x,y of center) BLACK PEN  
    0   XMAX 2/ DUP M*  YMAX 2/ DUP M*  D+ 2SQRT 
    DO  RCOLOR BRUSH  2DUP I circle
    -10 +LOOP  HOLLOW BRUSH ;

: TRIANGLE ( x1 y1 x2 y2 x3 y3 --- )
   2DUP 5 PICK 5 PICK LINE   5 PICK 5 PICK LINE  LINE ;

\
\ Moire demo
\
: MOIRE ( -- )
    XOR-ON  RCOLOR PEN   XMAX 1+ 0 
    DO   0 0 I YMAX LINE    0 YMAX I 0 LINE    
    LOOP YMAX 1+ 0 
    DO   0 0 XMAX YMAX I - LINE    0 YMAX XMAX I LINE    
    LOOP YMAX 1+ 0
    DO   XMAX 0 0 I LINE   XMAX YMAX 0 YMAX I - LINE  
    LOOP XMAX 1+ 0
    DO   XMAX 0 I YMAX LINE   XMAX YMAX I 0 LINE   
    LOOP XOR-OFF ;

\
\ Walking lines
\

\ n1 n2 n3 n4 --- n1 n2 n3 n4 n1 n2 n3 n4
: 4DUP          3 PICK 3 PICK 3 PICK 3 PICK ;

VARIABLE X0
VARIABLE Y0
VARIABLE X1
VARIABLE Y1
VARIABLE X0INC
VARIABLE Y0INC
VARIABLE X1INC
VARIABLE Y1INC
179 CONSTANT MAXDEPTH

: ?XSWITCH ( x -- flag ) DUP 4 <= SWAP 4 + XMAX >= OR ;
: ?YSWITCH ( y -- flag ) DUP 4 <= SWAP 4 + YMAX >= OR ;

: DROP-MAXDEPTH  MAXDEPTH 1+ 0 DO DROP LOOP ;

: XYINIT ( -- ) 10 X0 !  10 Y0 !  100 X1 !  10 Y1 !
   -6 Y1INC !  -5 X1INC !  3 Y0INC !  3 X0INC ! ;
   
\ x1 y1 x2 y2 --- 
: LINE10   DUP N>COLOR PEN  LINE ;

: SHOW-LINE   DEPTH MAXDEPTH >
   IF    MAXDEPTH ROLL MAXDEPTH ROLL 
         MAXDEPTH ROLL MAXDEPTH ROLL LINE10 
   THEN  X0 @ Y0 @ X1 @ Y1 @  4DUP LINE10 ;

: (WALK)     ( --- )  XYINIT  2000 0
    DO      X0 @ ?XSWITCH IF X0INC @ NEGATE X0INC ! THEN
            X1 @ ?XSWITCH  IF X1INC @ NEGATE X1INC ! THEN
            Y0 @ ?YSWITCH  IF Y0INC @ NEGATE Y0INC ! THEN
            Y1 @ ?YSWITCH  IF Y1INC @ NEGATE Y1INC ! THEN
            X0INC @ X0 +!   X1INC @ X1 +!
            Y0INC @ Y0 +!   Y1INC @ Y1 +!
            SHOW-LINE
    LOOP DROP-MAXDEPTH ;

: WALK     XOR-ON (WALK) XOR-OFF ;

EXCISE X0 (WALK)

\
\ Fourier curves by Joe Barnhart
\

VARIABLE X_MIN
VARIABLE Y_MIN
VARIABLE X_DIFF
VARIABLE Y_DIFF
VARIABLE X
VARIABLE XPREV
VARIABLE Y
VARIABLE YPREV
VARIABLE LCOLOR  1 LCOLOR !

: W* WSIZE * ;

: SCALE  ( X1 Y1 X2 Y2 --- )
  ROT   DUP Y_MIN !  - Y_DIFF !
  SWAP  DUP X_MIN !  - X_DIFF ! ;

: MAP    ( X1 Y1 --- X1' Y1' )
  Y_MIN @ - YMAX Y_DIFF @ t*/ SWAP
  X_MIN @ - XMAX X_DIFF @ t*/ SWAP ;

: DMOVE         MAP   YPREV !  XPREV ! ;
: DLINE         LCOLOR @ N>COLOR PEN
                MAP 2DUP XPREV @ YPREV @ LINE
                YPREV !  XPREV ! ;

VARIABLE (INCR)         5 (INCR) !

CREATE WAVE_ARRAY   360 1+ W* ALLOT

CREATE OLD_ARRAY    360 1+ W* ALLOT

CREATE SQUARE.C    0 C, 1 C, 0 C, 3 C, 0 C,
  5 C, 0 C, 7 C, 0 C, 9 C, 0 C, 11 C, 0 C, 13 C, 0 C, 15 C,

CREATE TRI.C      0 C, 1 C, 0 C, -9 C, 0 C,
  25 C, 0 C, -49 C, 0 C, 81 C, 0 C, -121 C,

: B@            C@ DUP 128 > IF 256 - THEN ;
: INCR          (INCR) @ ;
: STEPS         (INCR) ! ;
: POINTS        360 INCR / ;

: CLEAR_WAVE    WAVE_ARRAY POINTS 1+ W* ERASE
                OLD_ARRAY  POINTS 1+ W* ERASE ;

: HARMONIC      DUP INCR * 0  POINTS 1+ 0 DO  DUP SIN  4 PICK
                4 PICK  + B@ / WAVE_ARRAY I W* + +!
                OVER + LOOP 2DROP DROP ;

: COPY_SIN      WAVE_ARRAY OLD_ARRAY POINTS W* CMOVE ;

: PLOT_WAVE POINTS 1+ 1 
            DO  I 1- INCR * OLD_ARRAY I 1- W*
                + @ DMOVE  I INCR * OLD_ARRAY I W* + @ DLINE
                I 1- INCR * WAVE_ARRAY I 1- W* + @ DMOVE
                I INCR * WAVE_ARRAY I W* + @ DLINE
            LOOP COPY_SIN ;

: AXES      0 0 DMOVE  0 -10000 DMOVE  0 10000 DLINE ;

: SUM.WAVES 2 PENWIDTH  0 -15000 360 15000 SCALE  CLEAR_WAVE AXES  1+ 1
            DO  I 7 MOD 1+ LCOLOR !   I HARMONIC PLOT_WAVE
            2 +LOOP  DROP 1 PENWIDTH ;

( --- )
: F_SQUARE  1 LCOLOR ! 1 1 GOTOXY  BLACK PEN
            ." Fourier approximation to a SQUARE wave."
            SQUARE.C  16  SUM.WAVES ;

( ---)
: F_TRIANGLE 1 LCOLOR ! 1 1 GOTOXY  BLACK PEN
             ." Fourier approximation to a TRIANGLE wave."
             TRI.C  12 SUM.WAVES ;

EXCISE X_MIN SUM.WAVES

: COLOR-DEMO  0 0 GOTOXY
	RED PEN CR ." This is RED."
	LIGHTRED PEN CR ." This is LIGHTRED."
	BLUE PEN CR ." This is BLUE."
	LIGHTBLUE PEN CR ." This is LIGHTBLUE."
	GREEN PEN CR ." This is GREEN."
	LIGHTGREEN PEN CR ." This is LIGHTGREEN."
	CYAN PEN CR ." This is CYAN."
	LIGHTCYAN PEN CR ." This is LIGHTCYAN."
	MAGENTA PEN CR ." This is MAGENTA."
	LIGHTMAGENTA PEN CR ." This is LIGHTMAGENTA."
	BROWN PEN CR ." This is BROWN."
	YELLOW PEN CR ." This is YELLOW."
	BLACK PEN CR ." This is BLACK."
	GREY PEN CR ." This is GREY." ;

\ --------------------------------------------------------------

\ --- ; force repaint of main window
: REPAINT   MAINWIN WREPAINT ;

\ --- This routine handles WM_COMMAND messages from the 
\ frame window's menu.
: DOCOMMAND wParam CASE
    IDM_FILEEXIT OF WM_CLOSE MSG>MAINWIN   ENDOF
    IDM_FILEABOUT OF ABOUTDLG ['] ABOUTDLGPROC RUNDLG DROP ENDOF
    IDM_BINTREE OF ['] BINTREE  'DEMO !  REPAINT  ENDOF
    IDM_DRAGON1 OF ['] DRAGON1  'DEMO !  REPAINT  ENDOF
    IDM_DRAGON2 OF ['] DRAGON2  'DEMO !  REPAINT  ENDOF
    IDM_POLYSPI1 OF ['] POLYSPI1 'DEMO !  REPAINT  ENDOF
    IDM_POLYSPI2 OF ['] POLYSPI2 'DEMO !  REPAINT  ENDOF
    IDM_POLYSPI3 OF ['] POLYSPI3 'DEMO !  REPAINT  ENDOF
    IDM_SPINSQUARE OF ['] SPINSQUARE 'DEMO !  REPAINT ENDOF
    IDM_SNOWFLAKE OF ['] SNOWFLAKE 'DEMO ! REPAINT ENDOF
    IDM_OSCILLOSCOPE OF ['] OSCILLOSCOPE 'DEMO ! REPAINT ENDOF
    IDM_HILBERT OF ['] HILBERT 'DEMO !   REPAINT ENDOF
    IDM_CIRCDEMO OF ['] CIRC-DEMO 'DEMO !  REPAINT ENDOF
    IDM_BULLSEYE OF ['] BULLSEYE  'DEMO !  REPAINT ENDOF
    IDM_MOIRE OF ['] MOIRE 'DEMO ! REPAINT ENDOF
    IDM_WALK OF ['] WALK 'DEMO ! REPAINT ENDOF
    IDM_FTRIANGLE OF ['] F_TRIANGLE 'DEMO ! REPAINT ENDOF
    IDM_FSQUARE OF ['] F_SQUARE 'DEMO ! REPAINT ENDOF
    IDM_BOXDEMO OF ['] BOX-DEMO 'DEMO ! REPAINT ENDOF
    IDM_ROUNDRECTDEMO OF ['] ROUNDRECT-DEMO 'DEMO ! REPAINT ENDOF
    IDM_POLYGONDEMO OF ['] POLYGON-DEMO 'DEMO ! REPAINT ENDOF
    IDM_ELLIPSEDEMO OF ['] ELLIPSE-DEMO 'DEMO ! REPAINT ENDOF
    IDM_COLORDEMO OF ['] COLOR-DEMO 'DEMO ! REPAINT ENDOF
    " Command not implemented" ERRORBOX 
    ENDCASE ;


\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    \ window needs updating, run graphics demo
                           GetFocus hWnd = 
                           IF 'DEMO PERFORM  THEN  ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           MAINWIN WREPAINT
                           ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_DESTROY OF  0 PostQuitMessage \ kill message loop
                           ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double returned from message handler

\ "main word" of graphics demo application;
\ creates the frame window and then enters message loop
: GRAFDEMO  ['] BINTREE  'DEMO !  \ default demo = binary tree
            ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " LMI Graphics Demo" MAINWIN WSETNAME \ set frame window caption
	    " FORTHICON" MAINWIN WLOADICON DROP \ icon for minimized state
            MAINWIN WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
            MAINWIN WCLOSE
            QUIT ( 0 RETURN ) ; \ exit to Windows

CR
CR .( To run the demo, type:  GRAFDEMO <Enter> )
CR .( Pick the various graphics demos from the menu bar.  )
CR .( Then resize the window by dragging its borders, and watch the )
CR .( demo program adjust its painting operations to the new size.)
CR 


            
