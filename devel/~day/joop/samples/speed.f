REQUIRE Object ~day\joop\oop.f

WINAPI: GetTickCount KERNEL32.DLL

<< :test

CLASS: Test

: :test ;

;CLASS

: test 10000000 0 DO Test :test LOOP ;

.( Wait a bit...)
GetTickCount 
test
GetTickCount SWAP - 10000000 SWAP / 1000 * .
.(  calls per second)

(
  Cherezov OOP   27.3    \ fifth method
  Cherezov OOP   25      \ first method  
  Just OOP       12      \ fifth method
  Just OOP       8.8     \ first method  
  hpOOP vmt      6  
  hpOOP vmt-fast 3.4  
  Forth          0.2
)