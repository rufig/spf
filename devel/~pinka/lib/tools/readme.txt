
\ 09.Aug.2003 Sat 09:20  создан этот комментарий, при обновлении на cvs


make_pe.f    - формирует PE сам, без обращени€ к заголовку spf.exe

pe_struct.f  - структуры PE 
               pe-format: pe1.zip 
               [http://www.wotsit.org/filezdir/pe1.zip]

---

exe2dll.f           - тулзень дл€ создани€ dll

exe2dll.test.f      - тест и простой пример использовани€

comments-log.txt    - прокомментированный лог сообщений "Unknown difference"




»з письма иностранцу одному в spf-dev рассылке
( сорри за ломаный инглишь), 

=================== начало цитаты
Date: Sat, 9 Aug 2003 08:13:52 +0400

Hello!
in answer to PhiHo Hoang, 07.08.2003 20:02

Phiho>     How can I convert Spf.exe into spf.dll and how can I use spf.dll ?
Phiho>     Can I use the tool 'devel\~pinka\lib\tools\exe2dll.f' ?
yes,  if u ready for some work ;)

1.  u must have two spf.exe files, with different IMAGE-BASE, offset 0x10000

=== compile-2.cmd
jpf375c.exe 0x10000 ALLOT src\spf.f
spf4.exe S" spf-2.exe" SAVE BYE
jpf375c.exe src\spf.f
spf4.exe S" spf-1.exe" SAVE BYE
===

run compile-2.cmd in the directory, where jpf375c.exe and src\ located

2. create your dll src.
   u must have the words  "DllMain"  and  "sfind"   in dll src
   sfind - CALLBACK for export.

   see example of 'mydll-src.f'  -  exe2dll.test.f  at attachment.

3. create bin image with offset, by spf-2.exe:
   spf-2.exe  mydll-src.f  S" mydll2.bin" SAVE BYE

4. build dll:
   spf-1.exe  mydll-src.f  exe2dll.f  S" mydll2.bin" S" mydll.dll" SAVE-DLL BYE >log.txt

   usually, log.txt contents is only warnings


5. use dll:

   spf4.exe WINAPI: sfind mydll.dll  VECT eval  S" EVALUATE" sfind TO eval  S" 2 3 + ." eval


”ра! :))

---

Other programs to build dll  from spf4:

~ketmar [http://www.forth.org.ru/~ketmar/arc/spfdll.rar]
( it use Pascal  :-/  )

pe-format: pe1.zip [http://www.wotsit.org/filezdir/pe1.zip]


WBR
______
 Ruvim

=================== конец цитаты.




dll можно делать батником, типа такого
===== make-dll.cmd
spf-2.exe %1.f S" %1-2.bin" SAVE BYE
spf-2.exe %1.f exe2dll.f S" %1-2.bin" S" %1.dll" SAVE-DLL BYE >%1.log
===== 

и вызывать:
make-dll.cmd  mydll



_____________________________________________________________________


email ruvim@forth.org.ru
