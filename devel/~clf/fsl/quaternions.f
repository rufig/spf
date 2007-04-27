\ Quaternions and matrices of rotation
\        Forth Scientific Library Algorithm #56
\
\ Copyright 1998 Pierre Henri Michel., Abbat.
\ Anyone may use this code freely, as long as this notice is preserved.
CR
.( Quaternions and matrices of rotation        ) CR
.( by Pierre Abbat     Version 1.1    20001102 ) CR
\
\  What are quaternions?
\
\ Quaternions are an extension of complex numbers. There are three
\ linearly independent (over the reals) numbers, i, j, and k, whose
\ square is -1. Mathematicians use i and electrical engineers use j,
\ but no one as far as I know uses k, except in quaternions. A
\ quaternion is the sum of four real numbers multiplied by 1, i, j,
\ and k respectively.
\
\  What is the algebraic structure of quaternions?
\
\ Quaternions add termwise. Multiplication is a bit complicated, and
\ unlike the complex numbers it is not commutative. The distributive
\ and associative laws hold, and every nonzero quaternion has a
\ multiplicative inverse. Thus the quaternions form a noncommutative
\ division ring.
\
\ To multiply two quaternions, consider them as the sum of a scalar
\ and a vector in 3-space. The product of two scalars is a scalar,
\ the product of a vector and a scalar is a vector, and the product
\ of two vectors is their cross product minus their dot product.
\
\  What are quaternions used for?
\
\ Quaternions are used to represent rotations. The mapping is two-to-one;
\ for every rotation there are two unit-norm quaternions, which are
\ additive inverses, which represent it.
\
\ A rotation about an axis is represented by a quaternion whose scalar part
\ is the cosine of half the angle and whose vector part is along the axis
\ by the sine of half the angle. These are called Euler parameters.
\ http://mathworld.wolfram.com/EulerParameters.html
\
\ If you turn a sphere once around an axis, the quaternion representing
\ that rotation is -1. If you turn it twice around an axis, the quaternion
\ is +1. Thus, a double rotation is topologically deformable to no rotation,
\ whereas a single rotation is not. This is why, in centrifuges with feed lines,
\ the feed line turns once when the centrifuge turns twice.
\
\  Conventions
\
\ The coordinates are oriented as follows:
\ Bow       +x      Stern     -x
\ Starboard +y      Port      -y
\ Keel      +z      Mast      -z
\ This is the convention used for airplanes. The bottom is positive z,
\ which to me is upside down.
\ http://www.monmouth.com/~jsd/how/htm/motion.html#fig_axes
\
\ If the scalar component of a quaternion is positive, and the vector component
\ is nonzero, and the thumb of a right hand forming the dez of ten in American
\ Sign Language is pointed in the direction of the vector component, the quaternion
\ denotes a rotation less than a straight angle in the direction of the curled fingers.
\
\ A matrix of rotation denotes that rotation in which the vector (x y z) is
\                               x'
\ dropped in the top of it and (y') comes out the side.
\                               z'
\
\ If the norm of a quaternion is not 1 and it is interpreted as a rotation,
\ the rotation is accompanied by stretching or shrinking by the norm squared.
\
\ If an object is in the orientation q2 and is then rotated by q1 in
\ world coordinates (for example a ship lists from a north wind),
\ the resulting orientation is q1 q2 q*. If it is rotated by q1 in
\ object coordinates (bzw. it lists to port), it is q2 q1 q*. The same
\ order of operations applies to matrices as well.
\
\  The following words are provided for the user:
\
\ Q ( -<w x y z>- ; f: w x y z )
\ Puts a quaternion literal on the floating-point stack.
\ This word is state-smart.
\
\ QDUP ( f: q - q q )
\ Duplicates a quaternion.
\
\ Q+ ( f: q q - q )
\ Adds two quaternions.
\
\ Q- ( f: q q - q )
\ Subtracts two quaternions.
\
\ QDROP ( f: q )
\ Drops a quaternion.
\
\ Q* ( f: q q - q )
\ Multiplies two quaternions.
\
\ Q/ ( f: q q - q )
\ Divides two quaternions.
\
\ Q. ( f: q )
\ Outputs a quaternion to the console.
\
\ F>Q ( f: f - q )
\ Converts a real number to a quaternion with vector part (0,0,0).
\
\ Q>F ( f: q - f )
\ Returns the real part of a quaternion.
\
\ V>Q ( f: x y z - q )
\ Converts a vector to a quaternion with real part 0.
\
\ Q>V ( f: q - x y z )
\ Returns the vector part of a quaternion.
\
\ NORMAL ( f: q ; - ? )
\ Returns true if the norm of the quaternion is close to 1.
\
\ NORM ( f: q - f )
\ Returns the norm of a quaternion.
\
\ NORMALIZE ( f: q - q )
\ Divides a quaternion by its norm.
\
\ QINV ( f: q - q )
\ Computes the multiplicative inverse of a quaternion.
\
\ QCONJ ( f: q - q )
\ Computes the conjugate of a quaternion.
\
\ QF* ( f: q f - q )
\ Multiplies a quaternion by a real number. Equivalent to F>Q Q* but faster.
\
\ QVARIABLE ( -<name>- )
\ Creates a quaternion variable.
\
\ Q@ ( addr ; f: - q )
\ Fetches a quaternion variable.
\
\ Q! ( addr ; f: q )
\ Stores a quaternion variable.
\
\ DEGREES ( f: f - f )
\ Converts degrees to radians.
\
\ ROLLQ ( f: angle - q )
\ PITCHQ ( f: angle - q )
\ YAWQ ( f: angle - q )
\ Convert an angle in radians to a quaternion representing a rotation about an axis.
\ These can be used to construct a quaternion corresponding to a rotation
\ given in terms of <a href="http://www.astro.virginia.edu/~eww6n/math/EulerAngles.html">Euler angles</a>. There are at least three different Euler-angle
\ conventions, so I shall leave the Euler-angle words to you.
\
\ }}QUAT>MATRIX ( mat{{ ; f: q )
\ Converts a quaternion representing a rotation to a 3*3 matrix
\ representing the same rotation.
\
\ }}MATRIX>QUAT ( mat{{ ; f: - q )
\ Converts a matrix representing a rotation to a quaternion
\ representing the same rotation. If the matrix is not orthogonal
\ or has a nonpositive determinant, the result will be garbage.
\
\ }}MAT*VEC ( mat{{ ; f: x y z - x' y' z' )
\ Multiplies the matrix by the vector.
\
\ QROTATE ( f: q x y z - x' y' z' )
\ Rotates the vector (x y z) by the quaternion q. The result is the
\ same as converting it to a matrix and using }}MAT*VEC. The formula
\ is explained on Laura Downs' website.
\ http://http.cs.berkeley.edu/~laura/cs184/quat/quaternion.html
\
\  ANS Forth Program Label
\
\ This is an ANS Forth program with environmental dependencies
\ requiring the Floating-Point word set.
\
\  Nonstandard and non-core, non-float words:
\
\ \                     CORE EXT
\ NEEDS                 Includes a file if it hasn't been included  already.
\ ANEW -<name>-         Creates a marker, if it doesn't exist, or  forgets
\                       everything after it, if it does.
\ TRUE                  CORE EXT
\ TO                    CORE EXT
\ FPICK                 Copies a number from somewhere in the FP stack.
\ FSQRT                 FLOATING EXT
\ 4DUP                  2OVER 2OVER
\ PI                    3.1415926535897932384E0
\ FSINCOS               FLOATING EXT
\ FCOS                  FLOATING EXT
\ [IF]                  TOOLS EXT
\ [THEN]                TOOLS EXT
\ S" (interpretive)     FILE
\
\ A version of IcosaTest uses many nonstandard words to draw
\ the icosahedron on the screen in Win32Forth. All other compilers
\ ignore the section.
\
\  Environmental dependencies:
\
\ This module assumes that the floating-point stack
\ is separate from the integer stack.
\
\ This module assumes that the floating-point stack is at least 13  floats deep.
\ IcosaTest requires a stack 17 floats deep.
\
\  Ambiguous conditions:
\
\ Attempting to normalize 0 is an ambiguous condition. It will cause
\ division of 0 by 0, which in Win32Forth returns -NAN.
\
\ Calculating the norm of or normalizing a quaternion, where the
\ norm squared exceeds the range of floating-point numbers,
\ is an ambiguous condition. Win32Forth returns infinite for the norm
\ and normalizes such a quaternion to 0.
\
\ Normalizing a quaternion, all of whose elements, when squared,
\ cause floating-point underflow, is an ambiguous condition.
\ Win32Forth returns a quaternion with some or all elements
\ equal to infinity.
\
\ Converting a quaternion whose norm squared exceeds the range of
\ floating-point numbers to a matrix is an ambiguous condition.
\ Win32Forth will return a matrix which may contain one or more
\ elements equal to infinity.
\
\ Converting a matrix which does not represent a rotation, possibly
\ accompanied by a positive stretching, to a quaternion is an
\ ambiguous condition. It may cause attempting to take the square
\ root of a negative number. Win32Forth will ignore and continue.
\
\ Using the word Q followed by fewer than four words, or four words
\ at least one of which is not a valid floating-point number,
\ is an ambiguous condition. Win32Forth aborts with the message:
\ "Error:  invalid floating point number".
\
\ Terminal facilities required: Minimal.
\
\ The system is still standard after loading this module.
\
\ NEEDS FSL_Util
MARKER -quaternions-

( Quaternions are stored on the floating-point stack with the real term
  on the bottom. )

4 FLOATS CONSTANT QUATERNION ( for declaring arrays: 10 QUATERNION 
ARRAY q{ )

: QDUP ( f: q - q q )
  3 FPICK 3 FPICK 3 FPICK 3 FPICK ;

: QSWAP ( f: q1 q2 - q2 q1 )
  FRAME| a b c d e f g h |
  d c b a h g f e |FRAME ;

: QOVER ( f: q1 q2 - q1 q2 q1 )
  7 FPICK 7 FPICK 7 FPICK 7 FPICK ;

: Q+ ( f: q q - q )
  FRAME| a b c d e f g h |
  d h F+ c g F+ b f F+ a e F+
  |FRAME ;

: Q- ( f: q q - q )
  FRAME| a b c d e f g h |
  h d F- g c F- f b F- e a F-
  |FRAME ;

: QNEGATE ( f: q - -q )
  FRAME| a b c d | d FNEGATE c FNEGATE b FNEGATE a FNEGATE |FRAME ;

: resp* ( f: a b c d e f g h - a b c d e f g h ae bf cg dh )
  4 0 DO
    3 FPICK 8 FPICK F*
  LOOP ;

: QDROP ( f: q ) F2DROP F2DROP ;

: Q* ( f: q q - q )
  FRAME| a b c d |
  d c b a   resp* F+ F+ F- &e F! ( 1 ) QDROP
  b a d c   resp* F+ F- F- &g F! ( j ) QDROP
  c d a b   resp* F- F+ F+ &f F! ( i ) QDROP
  a b c d   resp* F- F- F+ &h F! ( k ) QDROP QDROP
  e f g h |FRAME ;

: Q. ( f: q )
  FRAME| a b c d |
  d F. c F. ." i " b F. ." j " a F. ." k "
  |FRAME ;

: Q ( -<f f f f>- ; runtime or interpreted f: f f f f )
  POSTPONE % POSTPONE % POSTPONE % POSTPONE % ;
  IMMEDIATE

: F>Q ( f: f - q )
  0E0 FDUP FDUP ;

: Q>F ( f: q - f )
  F2DROP FDROP ;

: V>Q ( f: x y z - q )
  FRAME| a b c | 0E0 c b a |FRAME ;

: Q>V ( f: q - x y z )
  FRAME| a b c d | c b a |FRAME ;

( Quaternion normalizing )

FVARIABLE FTEMP

: FSQR ( f: f - f ) FDUP F* ;

: NORMSQ ( q - f ) QDUP RESP* F+ F+ F+  FTEMP F!
  QDROP QDROP FTEMP F@ ;

: NORM ( q - f ) NORMSQ FSQRT ;

: NORMAL ( f: q ; - ? )
( Note: In some versions of Win32Forth, F~ returns incorrect results. )
  NORMSQ 1E0 1E-6 F~ ;

: QF* ( q f - q*f )
  FRAME| a b c d e |
  e a F* d a F* c a F* b a F* |FRAME ;
: NORMALIZE ( q - q ) QDUP NORM 1E0 FSWAP F/ QF* ;

: QCONJ ( q - q )
  FROT FNEGATE FROT FNEGATE FROT FNEGATE ;

: QINV ( q - q )
  QCONJ QDUP NORMSQ 1E0 FSWAP F/ QF* ;

: Q/ ( q q - q ) QINV Q* ;

( Quaternions )
: QVARIABLE   CREATE 4 FLOATS ALLOT ;
: Q@ ( addr - ; f: - q )
  3 FLOATS +
  4 0 DO
    DUP F@ FLOAT -
  LOOP DROP ;

: Q! ( f: q ; addr )
  4 0 DO
    DUP F! FLOAT+
  LOOP DROP ;

: DEGREES ( f: f - f )
  PI F* 180E0 F/ ;

: ROLLQ ( f: angle - q )
( Lists to starboard )
  F2/ FSINCOS FSWAP 0E0 FDUP ;

: PITCHQ ( f: angle - q )
( Bow goes up )
  ROLLQ -FROT ;

: YAWQ ( f: angle - q )
( Hard astarboard )
  ROLLQ FROT ;

: }}QUAT>MATRIX ( mat{{ - ; f: q - )
( Converts a quaternion to a matrix of rotation.
  The matrix should be 3*3 float. )
  FRAME| a b c d | ( note d is the real component )
  a a f* &e f!
  b b f* &f f!
  c c f* &g f!
  d d f* &h f!
  h g f+ f f- e f- DUP 0 0 }} f!
  h g f- f f+ e f- DUP 1 1 }} f! ( These terms mean the object stays in 
place. )
  h g f- f f- e f+ DUP 2 2 }} f!
  a b f* f2* &e f!
  c d f* f2* &f f!
  e f f- DUP 1 2 }} f! ( The object rotates about the x-axis. )
  e f f+ DUP 2 1 }} f!
  a c f* f2* &e f!
  b d f* f2* &f f!
  e f f- DUP 2 0 }} f! ( The object rotates about the y-axis. )
  e f f+ DUP 0 2 }} f!
  c b f* f2* &e f!
  a d f* f2* &f f!
  e f f- DUP 0 1 }} f! ( The object rotates about the z-axis. )
  e f f+     1 0 }} f!
  |FRAME ;

: }}DET3 ( mat{{ - ; f: - f )
( Computes the determinant of a 3*3 matrix. )
  DUP 0 0 }} F@ DUP 1 1 }} F@ DUP 2 2 }} F@ F* F*
  DUP 0 1 }} F@ DUP 1 2 }} F@ DUP 2 0 }} F@ F* F* F+
  DUP 0 2 }} F@ DUP 1 0 }} F@ DUP 2 1 }} F@ F* F* F+
  DUP 0 0 }} F@ DUP 1 2 }} F@ DUP 2 1 }} F@ F* F* F-
  DUP 0 2 }} F@ DUP 1 1 }} F@ DUP 2 0 }} F@ F* F* F-
  DUP 0 1 }} F@ DUP 1 0 }} F@     2 2 }} F@ F* F* F- ;

FVARIABLE W^2
FVARIABLE X^2
FVARIABLE Y^2
FVARIABLE Z^2
FVARIABLE 2WX
FVARIABLE 2YZ
FVARIABLE 2WY
FVARIABLE 2XZ
FVARIABLE 2WZ
FVARIABLE 2XY

: UNSUMDIF ( f: a+b a-b - a b )
  FOVER F+ F2/ FSWAP FOVER F- ;

: WXYZ-BIGGEST ( - n ; f: - w^2|x^2|y^2|z^2 )
  W^2 F@ 0
  X^2 F@ F2DUP F< IF
    FSWAP 1+
  THEN FDROP
  Y^2 F@ F2DUP F< IF
    FSWAP DROP 2
  THEN FDROP
  Z^2 F@ F2DUP F< IF
    FSWAP DROP 3
  THEN FDROP ;

: }}DISSECT ( mat{{ )
( Given a matrix assumed to be of the form
  | w^2+x^2-y^2-z^2     2xy-2wz         2xz+2wy     |
  |     2xy+2wz     w^2-x^2+y^2-z^2     2yz-2wx     |
  |     2xz-2wy         2yz+2wx     w^2-x^2-y^2+z^2 |,
  as computed by }}QUAT>MATRIX, figures out what 2wx etc. are
  and what w^2 etc. should be. )
  DUP 1 0 }} F@ DUP 0 1 }} F@ UNSUMDIF 2WZ F! 2XY F!
  DUP 2 1 }} F@ DUP 1 2 }} F@ UNSUMDIF 2WX F! 2YZ F!
  DUP 0 2 }} F@ DUP 2 0 }} F@ UNSUMDIF 2WY F! 2XZ F!
  DUP }}DET3 FABS 1E0 3E0 F/ F** ( this should be w^2+x^2+y^2+z^2 )
  FDUP DUP 0 0 }} F@ F+ DUP 1 1 }} F@ F+ DUP 2 2 }} F@ F+ F2/ F2/ W^2 F!
  FDUP DUP 0 0 }} F@ F+ DUP 1 1 }} F@ F- DUP 2 2 }} F@ F- F2/ F2/ X^2 F!
  FDUP DUP 0 0 }} F@ F- DUP 1 1 }} F@ F+ DUP 2 2 }} F@ F- F2/ F2/ Y^2 F!
       DUP 0 0 }} F@ F- DUP 1 1 }} F@ F-     2 2 }} F@ F+ F2/ F2/ Z^2 
F! ;

: }}MATRIX>QUAT ( mat{{ ; f: - q )
( If mat{{ was produced from q by }}QUAT>MATRIX, this will return
  either q or its additive inverse. If mat{{ is not orthogonal,
  this will return garbage. )
  }}DISSECT
  WXYZ-BIGGEST FSQRT CASE
    0 OF
      2WX F@ FOVER F/ F2/
      2WY F@ 2 FPICK F/ F2/
      2WZ F@ 3 FPICK F/ F2/ ENDOF
    1 OF
      2WX F@ FOVER F/ F2/ FSWAP
      2XY F@ FOVER F/ F2/
      2XZ F@ 2 FPICK F/ F2/ ENDOF
    2 OF
      2WY F@ FOVER F/ F2/ FSWAP
      2XY F@ FOVER F/ F2/ FSWAP
      2YZ F@ FOVER F/ F2/ ENDOF
    3 OF
      2WZ F@ FOVER F/ F2/ FSWAP
      2XZ F@ FOVER F/ F2/ FSWAP
      2YZ F@ FOVER F/ F2/ FSWAP ENDOF
  ENDCASE ; 

: }}MAT*VEC ( addr{{ ; f: x y z - x' y' z' )
  FRAME| a b c |
  3 0 DO
    DUP I 2 }} F@ a F* DUP I 1 }} F@ b F* DUP I 0 }} F@ c F* F+ F+
  LOOP DROP |FRAME ;

: QROTATE ( q x y z - x' y' z' )
  V>Q QOVER QCONJ Q* Q* Q>V ;

TEST-CODE? [IF]

3 3 FLOAT matrix orient{{
orient{{ Q .5 .5 .5 .5 }}QUAT>MATRIX
CR .( This should print)
CR .( 0 0 1)
CR .( 1 0 0)
CR .( 0 1 0) CR
3 3 orient{{ }}fprint

CR .( This should print 1 0 i 0 j 0 k ) CR
Q 1 2 3 4 QDUP Q/ Q.

CR .( This should print .707 .707 0 ) CR
45E0 DEGREES YAWQ orient{{ }}QUAT>MATRIX
1E0 0E0 0E0 orient{{ }}MAT*VEC FROT F. FSWAP F. F. CR
45E0 DEGREES YAWQ 1E0 0E0 0E0 QROTATE FROT F. FSWAP F. F. CR

: TwistTest ( f: q )
  QDUP NORMALIZE orient{{ }}QUAT>MATRIX
  3 3 orient{{ }}fprint
  orient{{ }}MAT*VEC Q. ;

: 2FLIP ( f: q - q ) Q 0 1 0 0 QSWAP Q* ;
: 3TWIST ( f: q - q ) Q .5 .5 .5 .5 QSWAP Q* ;
\ : 5TWIST ( about .85067 .52573 0, which is a corner of
\   an icosahedron ) Q .809016994374947416  .5 .309016994374947416  0 
\   Q* ;
: 5TWIST ( f: q - q )
  36E0 DEGREES FCOS 5E-1 F2DUP F- 0E0 QSWAP Q* ;

( Roundoff error in 8-byte float arithmetic
  after executing 5twist five times, versus digits after 7494:
  7456    6.4E-16
  7444    6.4E-16
  7432    6.4E-16
  74     -3.84E-16
  7416    4.8E-16
)
: MEXIT   Q 0 0 0 0 Q* ;

: IcosaTest
  ." This is a test of roundoff error in quaternion multiplication" CR
  ." by rotating an icosahedron." CR
  ." Hit any of 2, 3, 5, or Q"
  Q 1 0 0 0
  BEGIN
    KEY CASE
      [CHAR] 2 OF   2FLIP ENDOF
      [CHAR] 3 OF  3TWIST ENDOF
      [CHAR] 5 OF  5TWIST ENDOF
      [CHAR] Q OF   MEXIT ENDOF
    ENDCASE
    CR QDUP Q.
    QDUP NORM F0=
  UNTIL QDROP ;


CR
..( Tests available: ) CR
..( IcosaTest    Twiddle an icosahedron to test roundoff error. ) CR
S" TwistTest    ( q - ) Turns the vector part of a quaternion about its 
" TYPE CR
..(              corresponding matrix. ) CR

[THEN] ( if test )
