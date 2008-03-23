OUTPUT("spf4")

SECTIONS
{
 . = 0x8050000;
 .forth : 
 { 
   /* Форт-система */
   spf4.o(.forth) 
 }
 /* Свободное место для расширения словаря */
 .space :
 {
   spf4.o(.space)
 }
}
