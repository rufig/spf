                           The description spf4wc.

  spf4wc  is  attempt to create more convenient environment for experiments
with  the  Forth,  than  standard   Windows  console.  Probably, in the far
future, spf4wc will develop in valuable IDE (but it hardly).

  Keyboard keys:
  Up-arrow  -  the  cursor  moves  on  the last line of the console. Line's
content  vary  on  the  previous string from the buffer of the last entered
commands;
  Down-arrow - the  cursor  moves  on  the last line of the console. Line's
content  vary  on  the following string from the buffer of the last entered
commands;
  If Shift is pressed - up and down keys work as in the usual editor;
  Esc - the last line is cleared;
  Enter - if the cursor is in  the last line, then from  it content removed
prompt  and  it  is   transferred to the ACCEPT. If current line not  last,
then this line at first is wholly copied in last line (together with prompt
- if he in it was) and then is transferred to the ACCEPT.

  Position  and  size of the window of the program on exit are saved in the
ini-file.  The  current  selects  of the case-sensitivity and log are saved
too.

  Except  the window  -  command lines, in spf4wc are window - mini-editor.
Switching  between  windows Ctrl+TAB. The command RunScript starts contents
of the editor on execution.

  spf4wc  has gone on path monstrously - into it the set of the potentially
useful lib is included. For the convenience.
  Are included libs:
  Assembler,  disassembler,  floating point, client of COM-automation, list
of the dictionaries (vocs), str2.
  api-func  -  saves from necessity to declare used API-functions. Possible
simply  to write  a name of the necessary function, and spf4wc  itself will
find  it  in  on-line  dll's.  Are by  default on-line  - user32, kernel32,
gdi32, comdlg32 and comctl32.
  4interp - control structures working in the interpret mode.
  comments  -  the  standard multiline comment does not suit anywhere, so I
have solved to use for comments - (* *).

  After start spf4wc tries to load the file with constants.

  SLITERAL is rewrite  - in the interpret mode the strings, entered through
S" text",  are  copied in dynamic memory and remain there forever. A memory
leaks certainly, but do not disappear anywhere.

                                              Andrey Filatkin
