\ Turtle graphics extension for WinForth
\ Copyright (C) 1982-1992 Laboratory Microsystems Inc.

ASM  DECIMAL

CREATE SINTABLE
0 , 175 , 349 , 523 , 698 , 872 , 1045 , 1219 , 1392 , 1564 ,
1736 , 1908 , 2079 , 2250 , 2419 , 2588 , 2756 , 2924 , 3090 ,
3256 , 3420 , 3584 , 3746 , 3907 , 4067 , 4226 , 4384 , 4540 ,
4695 , 4848 , 5000 , 5150 , 5299 , 5446 , 5592 , 5736 , 5878 ,
6018 , 6157 , 6293 , 6428 , 6561 , 6691 , 6820 , 6947 , 7071 ,
7193 , 7314 , 7431 , 7547 , 7660 , 7771 , 7880 , 7986 , 8090 ,
8192 , 8290 , 8387 , 8480 , 8572 , 8660 , 8746 , 8829 , 8910 ,
8988 , 9063 , 9135 , 9205 , 9272 , 9336 , 9397 , 9455 , 9511 ,
9563 , 9613 , 9659 , 9703 , 9744 , 9781 , 9816 , 9848 , 9877 ,
9903 , 9925 , 9945 , 9962 , 9976 , 9986 , 9994 , 9998 , 10000 ,

( take sine of angle 0-180 deg )
PROC TRIG   BX, # 90 CMP  1$ JLE       \ jump if angle 0-90 deg
            BX, # 180 SUB  BX NEG        \ angle = -(angle-180)
    1$:     BX, 1 SAL  BX, # SINTABLE ADD    \ hit lookup table
            BX, [BX] MOV  RET  END-PROC

( degrees --- sin*10000 )
CODE SIN    AX, BX MOV  CWD                    \ DS:AX := angle
            BX, # 360 MOV           \ reduce angle to 0-359 deg
            BX IDIV  BX, DX MOV                 \ use remainder
            BX, BX OR  2$ JNS                \ jump if angle >0
            BX, # 360 ADD                 \ make angle positive
     2$:    BX, # 180 CMP  3$ JLE     \ jump if angle 0-179 deg
            BX, # 180 SUB               \ angle was 180-359 deg
            TRIG CALL  BX NEG  NEXT,         \ so result is neg
     3$:    TRIG CALL  NEXT,        \ result pos if angle 0-179
            END-CODE
            
( degrees --- cos*10000 )
CODE COS    BX, # 90 ADD                  \ get cos by adding 90
            ' SIN JMP  END-CODE                  \ and using sin

VOCABULARY TURTLE IMMEDIATE   

( math redefinitions without flooring for turtle graphics)

( n1 n2 n3 --- n1*n2/n3 )
CODE t*/    AX POP   CX POP     CX IMUL BX IDIV
            BX, AX MOV  NEXT,  END-CODE

( n1 n2 --- remainder )
CODE tMOD   AX POP   CWD    BX IDIV BX, DX MOV NEXT, END-CODE

TURTLE DEFINITIONS DECIMAL

VARIABLE turtleX        ( Turtle current X coordinate )
VARIABLE turtleY        ( Turtle current Y coordinate )
VARIABLE turtleD        ( Turtle's direction, degrees )
VARIABLE turtleP        ( Turtle's pen, 0=pen up, <>0=pen down)

1 turtleP !             ( default turn on pen )

: moveTurtle    ( units --- x' y' )
            DUP  turtleD @  COS  10000  t*/  turtleX @ +
            SWAP turtleD @  SIN  10000  t*/  turtleY @ + ;

( --- flag ; return TRUE if turtle has gone outside bounds )
: ?QUIT     turtleX @  DUP  XMAX > SWAP 0< OR 
            turtleY @  DUP  YMAX > SWAP 0< OR  OR  ;
            
( units --- )
: FORWARD   moveTurtle  turtleP @                    \ pendown?
            IF   turtleX @  turtleY @            \ old position
                 2OVER  turtleY !  turtleX !     \ new position
                 ?QUIT                        \ outside bounds?
                 IF    4DROP                       \ don't draw
                 ELSE  LINE               \ draw to new position
                 THEN
            ELSE turtleY ! turtleX !   \ no just update position
            THEN ;
            
( units --- )
: BACKWARD  NEGATE FORWARD ;

( degrees --- )
: RIGHT     turtleD @  +  360 tMOD  turtleD !  ;

( degrees --- )
: LEFT      NEGATE RIGHT ;

( --- ; put turtle in center of screen )
: CENTER    XMAX 2/ turtleX !
            YMAX 2/ turtleY !  turtleD OFF ;

( --- ; put turtle in upper left corner )
: HOME      turtleX OFF  turtleY OFF  turtleD OFF ;

( x y --- ;  set current location of turtle )
: SETXY     turtleY !  turtleX ! ;

( --- n ;  return current direction in degrees )
: ?DIRECTION    turtleD @ ;

( n --- ; set direction in degrees )
: DIRECTION     turtleD ! ;

( --- ; lift pen, i.e. turtle movements do not leave a trail )
: PENUP     turtleP OFF ;

( --- ; lower pen, i.e. movements by turtle leave a trail )
: PENDOWN   turtleP ON ;

( size --- ; draw a square from current loc'n )
: SQUARE    DUP FORWARD 90 RIGHT DUP FORWARD 90 RIGHT
            DUP FORWARD 90 RIGHT FORWARD 90 RIGHT ;


