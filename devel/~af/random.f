\ generates random numbers                             12jan94py

\ Copyright (C) 1995 Free Software Foundation, Inc.

\ This file is part of Gforth.

\ Gforth is free software; you can redistribute it and/or
\ modify it under the terms of the GNU General Public License
\ as published by the Free Software Foundation; either version 2
\ of the License, or (at your option) any later version.

WINAPI: GetTickCount KERNEL32.DLL

VARIABLE RND

0x10450405 CONSTANT generator

: RANDOMIZE GetTickCount RND ! ;
RANDOMIZE

: RANDOM  ( -- n )  RND @ generator UM* DROP 1+ DUP RND ! ;

: CHOOSE ( n -- 0..n-1 )  RANDOM UM* NIP ;
