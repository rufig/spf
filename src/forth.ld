OUTPUT("spf4")

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
