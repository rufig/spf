\ ssss.f Simple Static Scoping for Structures
\ (p) Michael L Gassanenko
\ the below code and specification are Public Domain
\ History: v1.1 -- 5 Jan 2009 -- bug fixes, two more RIs, description
\          v1.0 -- 18 Dec 2008 -- initial

\ ======================================
\ Contents:
\ 0. Foreword
\ 1. Description
\ 2. Specification
\ 3. Reference implementations
\ 3.1. Reference Implementation 1
\ 3.2. Reference Implementation 2
\ 3.3. Reference Implementation 3
\ 3.4. Reference Implementation 4
\ 4. Example Code: lists of strings and integers
\ 5. Functionality Tester

\ ======================================
\ 0. Foreword
\
\ First of all, it is arguable if scopes/namespaces are needed at all.
\ I will assume that you have a compelling reason to use them.
\
\ The main idea of the approach implemente in this file is:
\ do not try to find out at compile-time
\ what will happen with data at run-time.
\ Instead, explicitly specify the bounds where
\ words from a name space are visible,
\ and let name spaces be completely separate from run-time data.
\
\ There are following sections:
\ 1. Description that informally explains how the scopes work;
\ 2. Specification that formally defines the behaviour of words;
\ 3. a number of Reference Implementations (RIs).
\ It is possible that not all of them will work on your system;
\ or that you will dislike the source that implements some of them.
\ You, at least, have a choice.
\ 4. Example Code demonstrates how it works.
\ 5. Functionality Tester allows you to ensure against bugs
\ when you bring this code to a new system, or write your own
\ implementation.

\ ======================================
\ 1. Descripion:
\
\ The basic functionality is provided with the words SCOPE s{ }s :
\
\ SCOPE _name_ or NEW-SCOPE _name_ -- create a new empty scope
\ (two names because one of them may be already there in your system,
\  choose the one that is not used)
\
\ s{ _scope_ -- enter the scope _scope_
\
\ s{ _scope_ DEFINITIONS -- enter the scope _scope_,
\ the new definitions will be added to _scope_
\
\ }s -- leave the last opened scope
\
\ }s DEFINITIONS -- use this to leave the scope opened via s{ _name_ DEFINITIONS
\
\ Extended functionality: there is also an option to create a tree of scopes
\ where child scopes inherit all words visible in the parent scopes:
\
\ ' _scope_ EXTENSION-SCOPE _child_scope_ -- all words defined in _scope_ will
\ be also visible in _child_scope_, but not vice versa. This implements the classical
\ visibility rule for nested scopes and derived classes.
\
\ ' _scope_ SAME-SCOPE _new_name_ -- make _scope_ also available via _new_name_.
\ This is for the case that you do not need nested scopes, but still want to use
\ different names. (For example, you want some classes to share the same namespace.)

\ ======================================
\ 2. Specification:

\ SCOPE ( "scope-name" -- ) Create an empty scope that later may be
\ referenced as scope-name. scope-name is a definition that may be,
\ for example, ticked. A word list is associated with scope-name,
\ this word list may be added to the search order by executing
\ s{ scope-name or ' scope-name OPEN-SCOPE.
\ The behaviour of scope-name is implementation-defined.

\ EXTENSION-SCOPE ( scope-xt "scope-name" -- ) create a scope that
\ later may be referenced as scope-name. scope-name is associate with
\ all word lists from the scope identified by scope-xt (later referenced
\ as the basic scope for scope-name) plus one more word list
\ (later referenced as own word list of scope-name).
\ The behaviour of scope-name is implementation-defined.
\ Ambiguous conditions:
\ - The word }s is not visible in the search order, or
\ some different functionality is visible under the name }s

\ SAME-SCOPE ( scope-xt "scope-name" -- ) create an alias scope
\ for scope-xt. The same set of word lists is associated with
\ scope-xt and scope-name.
\ The behaviour of scope-name is implementation-defined.

\ OPEN-SCOPE ( scope-xt -- ) Add all word lists associated with the scope
\ to the search order. If scope-xt identifies an extension scope,
\ first (recursively) add word lists from the basic scope, then
\ add own word list (so that it is searhed first).
\ An ambiguous condition exists if scope-xt does not represent a scope.

\ s{ ( "scope-name" -- ) "s-brace" Parse scope-name delimited by spaces.
\ Find scope-name in the search order and perform OPEN-SCOPE.
\ This is an immediate word.

\ }s ( -- ) "closing-brace-s" Close the scope, that is, remove from
\ the search order all word lists associated with the last opened scope. 
\ This is an immediate word.
\ Ambiguous conditions:
\ - In the process of removing the word lists, the search order
\ reaches such a state that the name }s is not visible, or
\ some different functionality is visible under the name }s
\ - The execution token for }s is executed when the search order is
\ in a different state than at the moment of finding }s
\ - The state of the search order is different than what was established
\ by OPEN-SCOPE or s{


\ ======================================
\ 3. Reference implementations (I think, you need only one of them)

\ --- choosing the implementation ---
\ There are 4 implementations, the most laconic is #4,
\ while #3 is VOCABULARY-based and probably most convenient (but having
\ the longest source too).
\ If you do not need extension scopes, you may easily remove them from #1 and #2.

4 constant RI-of-choice
cr .( RI-of-choice=) RI-of-choice . cr

\ ======================================
\ 3.1. Reference Implementation 1
\ In this implementation, the behaviour of a SCOPE is to add the corresponding
\ word list(s) to the search order. Each scope has its own }s, the }s from
\ parent scope is searched at run-time.
RI-of-choice 1 = [IF]

: order-depth ( -- n ) get-order dup >r 0 ?do drop loop r> ;
: >order ( wid -- ) >r get-order r> swap 1+ set-order ;
: add-definition ( wid addr len -- )
  rot get-current swap set-current  >r evaluate r>  set-current ;
: scope ( "name" -- ) wordlist
  dup S" : }s previous ; immediate" add-definition
  create , does> @ >order ;
: same-scope ( xt "name" -- ) create , does> @ execute ;
: open-scope ( xt -- ) order-depth >r execute
                       order-depth r> > 0= abort" expected a scope"; 
: s{ ( "name" -- ) ' open-scope ; immediate

: extension-scope ( xt "name" -- )
  wordlist 
  dup
  [ char | parse : }s previous s" }s" evaluate ; immediate|] sliteral
    add-definition
  create , , does> 2@ >r open-scope r> >order ;

[ELSE]

\ ======================================
\ 3.2. Reference Implementation 2
\ In this implementation, a SCOPE leaves the word lists on the data stack.
\ Each scope has its own }s, the }s from parent scope is searched at compile-time.
RI-of-choice 2 = [IF]
315 constant scope-tag
: ?scope scope-tag xor abort" expected a scope";
: open-scope ( xt -- )
  >r get-order depth - r> swap >r execute ?scope r> depth + set-order ;
: scope wordlist
  get-current swap set-current
  S" : }s previous ; immediate" evaluate
  get-current swap set-current
  scope-tag 2constant ;
: same-scope >r : r> compile, postpone ; ;
: extension-scope ( xt "name" -- )
  wordlist
  get-current swap set-current
  over open-scope
  S" : }s previous postpone }s ; immediate }s" evaluate
  get-current swap set-current
  ( xt wid ) create , , does> 2@ >r execute ?scope r> scope-tag ; 
: s{ ( "name" -- ) ' open-scope ; immediate

[ELSE]
\ ======================================
\ 3.3. Reference Implementation 3
\ In this implementation, SCOPE is VOCABULARY, which means that it can be
\ correctly displayed by ORDER on any system. Vocabularies contain
\ attributes (definitions) used while opening and closing the scopes.
\ It does not even use GET-ORDER/SET-ORDER! But there are 7 auxiliary definitions.
RI-of-choice 3 = [IF]

only forth also definitions
: order-top get-current definitions get-current swap set-current ;
: add-definition ( wid addr len -- )
  rot get-current swap set-current  >r evaluate r>  set-current ;
vocabulary dummy-voc  dummy-voc order-top forth constant dummy-wl
: execute-scope ( xt -- )
  also dummy-voc execute order-top dummy-wl = abort" scope expected" ;
: scope>wl ( xt -- wid ) execute-scope order-top previous ;
: get-vocs/scope ( wid -- n )
  S" vocs/scope" rot search-wordlist if execute else 1 then ;

: scope vocabulary ;
: same-scope >r : r> compile, postpone ; ;
: open-scope ( xt -- )
  dup scope>wl S" parent-scope" rot search-wordlist if recurse then execute-scope ;
: extension-scope
  dup scope>wl get-vocs/scope 1+ ( xt n )
  >in @ vocabulary >in ! ' scope>wl
  S" constant vocs/scope same-scope parent-scope" add-definition ;
: s{ ( "name" -- ) ' open-scope ; immediate
: }s order-top get-vocs/scope 0 ?do previous loop ; immediate
  
[ELSE]
\ ======================================
\ 3.4. Reference Implementation 4
\ In this implementation, a SCOPE modifies the array of word lists
\ left on the stack by GET-ORDER. This is the most laconic implementation.
RI-of-choice 4 = [IF]

: scope-closer create immediate , does> @ 0 ?do previous loop ;
: execute-scope ( xn .. x0 n xt -- xn .. x0 ym .. y0 n+m )
  over depth - >r execute r> over depth - <> abort" expected a scope" ;
: do-scope does> 2@ >r execute r> swap 1+ ;

: extension-scope wordlist 2dup create , , do-scope
  get-current >r set-current
  0 swap execute-scope dup 0 ?do nip loop 1+
  S" scope-closer }s" evaluate r> set-current ;
: scope ['] noop extension-scope ;
: same-scope >r : r> compile, postpone ; ;
: s{ ' >r get-order r> execute-scope set-order ; immediate

[THEN]
[THEN]
[THEN]
[THEN]

\ ======================================
\ 4. Example code: lists of strings and integers
1 [IF]

cr .( == example: lists ==) cr
.( starting: ) cr order cr .s

\ define a simple field
: SFIELD ( offset "name" -- ) ( name: addr -- addr+offset )
  CREATE DUP , DOES> @ + ;



scope list
s{ list definitions
 0
 sfield next cell+
 : .next next @ ;
 : !next next ! ;
}s definitions
 constant /listelem

cr .( /listelem = ) /listelem .

: reverse-list ( head -- head' )
  0 swap
  begin dup while ( prev this )
    s{ list
      dup dup .next ( prev this this next ) 2swap !next
    }s
  repeat
  drop
;

' list extension-scope intlist
  /listelem
  s{ intlist definitions
    sfield data cell+
    : .data data @ ;
    : !data data ! ;
  }s definitions
  constant /intlist-elem

cr .( /intlist-elem = ) /intlist-elem .

: int-elem ( tail x -- head )
  align here /intlist-elem allot >r
  s{ intlist r@ !data r@ !next }s r> ;

: print-intlist ( head -- )
  begin dup while s{ intlist dup .data . .next }s repeat drop ;

variable my-intlist
0
  10 int-elem  20 int-elem  30 int-elem  40 int-elem
my-intlist !

cr .( int list: )
my-intlist @ print-intlist
my-intlist @  reverse-list  my-intlist !
cr .( reverse int list: )
my-intlist @ print-intlist

' list extension-scope stringlist

  /listelem
  s{ stringlist definitions
    sfield length cell+
    sfield data
    : .data dup data swap length @ ;
    : .length length @ ;
    : !length length ! ;
  }s definitions
  constant /stringlist-base

cr .( /stringlist-base = ) /stringlist-base .

: string-elem ( tail addr len -- head )
  align here over /stringlist-base + allot >r
  s{ stringlist r@ !length  r@ data r@ .length cmove  r@ !next }s r>
;
: print-stringlist ( head -- )
  begin dup while s{ stringlist dup .data type space .next }s repeat drop ;

variable my-stringlist
0
  S" first" string-elem  S" second" string-elem
  S" third" string-elem  S" fourth" string-elem
my-stringlist !

cr .( string list: )
my-stringlist @ print-stringlist
my-stringlist @  reverse-list  my-stringlist !
cr .( reverse string list: )
my-stringlist @ print-stringlist

cr .( finishing: ) cr order cr .s
[THEN]


\ ======================================
\ 5. Functionality tester

\ --- tester --
\ auxiliary definitions
1 [IF]
cr .( testing... ) cr
only forth also definitions

: please" postpone s" postpone evaluate ; immediate
: odepth get-order dup 0 ?do nip loop ;
: eq? 2dup <> if cr ." mismatch:" swap . . order .s 1 abort" mismatch" then 2drop ;

odepth constant od0
depth constant sd0
sd0 [IF] cr .( *** WARNING *** stack not empty: ) .s cr [THEN]

\ --- tester --
\ outside of any scopes

-1 constant x
-2 constant yy
: no-s1 please" -1 x eq?" ;
: no-s2 please" -2 yy eq?" ;
: outside please" odepth od0 eq? depth sd0 eq? -1 x eq? -2 yy eq?"
          please" get-current forth-wordlist eq?";

\ --- tester --
\ 2 basic scopes

outside
scope s1
s{ s1 definitions
1 constant x
10 constant y
100 constant z
}s definitions
outside

scope s2
s{ s2 definitions
20001 constant xx
20010 constant yy
20100 constant zz
}s definitions

: in-s1 please" ( in-s1) x 1 eq? y 10 eq? z 100 eq? 11 t eq? " ;
: in-s2 please" ( in-s2) 20001 xx eq? 20010 yy eq? 20100 zz eq?" ;

\ --- tester --
\ alias and extension scopes

' s1 same-scope s1'
' s1' extension-scope s1a
' s1a extension-scope s1b
' s2  extension-scope s2a
' s2a same-scope s2a'
' s2 same-scope s2'
s{ s1a definitions
  x 1+ constant x1
  12 constant y
}s definitions
s{ s1' definitions
 11 constant t
}s definitions
s{ s2a definitions
  xx 1+ constant xx1
  120 constant yy
}s definitions
s{ s1b definitions
  x1 1+ constant x2
  14 constant y
}s definitions

: in-s1a please" ( in-s1a) x 1 eq? 2 x1 eq? y 12 eq? z 100 eq? 11 t eq?";
: in-s1b please" ( in-s1a) x 1 eq? 2 x1 eq? 3 x2 eq? y 14 eq? z 100 eq? 11 t eq?";
: in-s2a please" ( in-s2a) 20001 xx eq? 20002 xx1 eq? 120 yy eq? 20100 zz eq?";

\ --- tester --
\ testing: no nested scopes

outside s{ s1 in-s1 no-s2 }s
outside s{ s2 in-s2 no-s1 }s
outside s{ s1' in-s1 no-s2 }s
outside s{ s1a in-s1a no-s2 }s
outside s{ s1b in-s1b no-s2 }s
outside s{ s2a in-s2a no-s1 }s
outside s{ s2a' in-s2a no-s1 }s

\ --- tester --
\ testing: nested basic scopes

outside s{ s1  in-s1 no-s2 s{ s1  in-s1 no-s2 }s in-s1 no-s2 }s
outside s{ s1' in-s1 no-s2 s{ s1  in-s1 no-s2 }s in-s1 no-s2 }s
outside s{ s2  in-s2 no-s1 s{ s1  in-s1 in-s2 }s in-s2 no-s1 }s
outside s{ s1  in-s1 no-s2 s{ s2  in-s1 in-s2 }s in-s1 no-s2 }s
outside s{ s2' in-s2 no-s1 s{ s1' in-s1 in-s2 }s in-s2 no-s1 }s
outside s{ s1' in-s1 no-s2 s{ s2' in-s1 in-s2 }s in-s1 no-s2 }s

\ --- tester --
\ testing: nested basic and extension scopes
outside s{ s1a  in-s1a no-s2 s{ s1   in-s1  no-s2 }s in-s1a no-s2 }s
outside s{ s1   in-s1  no-s2 s{ s1a  in-s1a no-s2 }s in-s1  no-s2 }s
outside s{ s2a' in-s2a no-s1 s{ s2   in-s2  no-s1 }s in-s2a no-s1 }s
outside s{ s2   in-s2  no-s1 s{ s2a' in-s2a no-s1 }s in-s2  no-s1 }s

\ --- tester --
\ testing: nested extension scopes

outside s{ s1a  in-s1a no-s2 s{ s1a  in-s1a no-s2 }s in-s1a no-s2 }s
outside s{ s1b  in-s1b no-s2 s{ s1b  in-s1b no-s2 }s in-s1b no-s2 }s
outside s{ s2a  in-s2a no-s1 s{ s2a  in-s2a no-s1 }s in-s2a no-s1 }s
outside s{ s2a  in-s2a no-s1 s{ s2a' in-s2a no-s1 }s in-s2a no-s1 }s
outside s{ s2a' in-s2a no-s1 s{ s2a  in-s2a no-s1 }s in-s2a no-s1 }s
outside s{ s2a' in-s2a no-s1 s{ s2a' in-s2a no-s1 }s in-s2a no-s1 }s

outside s{ s1a  in-s1a no-s2 s{ s2a' in-s2a in-s1a }s in-s1a no-s2 }s
outside s{ s1b  in-s1b no-s2 s{ s2a' in-s2a in-s1b }s in-s1b no-s2 }s
outside s{ s2a' in-s2a no-s1 s{ s1a  in-s2a in-s1a }s in-s2a no-s1 }s
outside s{ s2a' in-s2a no-s1 s{ s1b  in-s2a in-s1b }s in-s2a no-s1 }s
outside s{ s1a  in-s1a no-s2 s{ s1b  in-s1b no-s2  }s in-s1a no-s2 }s
outside s{ s1a  in-s1a no-s2 s{ s2a' in-s2a in-s1a
                             s{ s1b  in-s2a in-s1b }s
	                             in-s2a in-s1a }s in-s1a no-s2 }s
outside
.( tests passed) cr
[THEN]
cr .( RI-of-choice=) RI-of-choice . cr
\ ======================================
\ end of file

