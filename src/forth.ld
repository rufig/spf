OUTPUT("spf4") /* the default output file name
  * (it is used if `-o filename` is not specified in the `ld` command-line)
  */


/*
  This linker script augments the main linker script used for linking
  (see https://sourceware.org/binutils/docs/ld/Options.html#unrecognised_002dinput_002dfiles)
  Therefore, we should not use `-T` option to specify this script.
  So, ignore the message like
    "/usr/bin/ld: warning: forth.ld contains output sections; did you forget -T?"
*/


SECTIONS
{
 FORTH_START = 0x8050000;
 /* start .forth section at FORTH_START */
 .forth FORTH_START :
 {
   /* put forth system here */
   spf4.o(.forth)
   /* end of this section */
   _eforth = .;
 }
 /*
  * put .space section immediately after .forth
  * (linker will combine them in one segment)
  */
 .space _eforth :
 {
   /* free space to enlarge forth system */
   spf4.o(.space)
 }
}
