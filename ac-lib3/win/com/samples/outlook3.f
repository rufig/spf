.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: ListContacts
\  ns :: Folders @
  DROP FOREACH 
        OBJ-I DROP :: Class @
        DROP 40 ( olContactItem=40; olDistListItem=69) =
        IF
          OBJ-I DROP :: FirstName @
          DROP ASCIIZ> \ TYPE SPACE
          OBJ-I DROP :: LastName @
          DROP ASCIIZ> \ TYPE CR
          SWAP >R 2DUP + 0 >
          IF R> SWAP 2SWAP TYPE SPACE TYPE 
             OBJ-I DROP :: Email1Address @
             DROP ASCIIZ> ."  <" TYPE ." >"
             CR 
          ELSE R> 2DROP 2DROP THEN
        THEN
  NEXT
;
WINAPI: VarFormatDateTime Oleaut32.dll

: DateAsString ( date -- addr u ) { \ var s }
  make-variant -> var
  _date var variant!
  ^ s 0 0 var VarFormatDateTime 0=
  IF s unicode>buf ASCIIZ> ELSE S" " THEN
;

: TEST { \ outlook ns }
  COM-init THROW

." ====== Contacts" CR
  Z" Outlook.Application" create-object THROW -> outlook
  arg( Z" MAPI" _str )arg outlook :: GetNameSpace >
  DROP -> ns
\  arg( Z" c:\\delosoft.pst" _str )arg ns :: AddStore >
\  . .
  ns :: Folders ["Personal Folders"] @
  DROP :: Folders ["Contacts"] @
\ oSourceInbox = oNS.Folders("mypst").Folders("Inbox")
  DROP :: Items @
  ListContacts

." ====== Контакты" CR

  ns :: Folders ["Личные папки"] @
  DROP :: Folders ["Контакты"] @
  DROP :: Items @
  ListContacts

." ====== Tasks" CR

  ns :: Folders ["Personal Folders"] @
  DROP :: Folders ["Tasks"] @
  DROP :: Folders ["eserv2"] @
  DROP :: Items @

  DROP FOREACH 
        OBJ-I DROP :: Class @
        DROP 48 = ( olTaskItem)
        IF 
          OBJ-I DROP :: Subject @
          DROP ASCIIZ> NIP
          OBJ-I DROP :: Body @
          DROP ASCIIZ> NIP
          + 0 >
          IF 
\             OBJ-I DROP :: Status @
\             DROP 2 <> \ невыполненные - 0, выполненные - 2
\ более читабельно:
             OBJ-I DROP :: Complete @
             DROP 0= \ не выполненные
             IF
               ." ----|" 
               OBJ-I DROP :: CreationTime @
               DROP DateAsString TYPE ." |"
               OBJ-I DROP :: Subject @
               DROP ASCIIZ> TYPE
               ." |----" CR
               OBJ-I DROP :: Body @
               DROP ASCIIZ> ?DUP IF TYPE CR ELSE DROP THEN
             THEN
          THEN
        THEN
  NEXT

  COM-destroy
;

TEST

\ Dim myOlApp As New Outlook.Application
\ Dim myNS As Outlook.NameSpace
\ Set myNS = myOlApp.GetNamespace("MAPI")
\ Set myFolder = myNS.Folders("Personal Folders")
\ myNS.RemoveStore myFolder 

\ VBscript:
\ Set myNS = Application.GetNamespace("MAPI")
\ Set myFolder = myNS.Folders("Personal Folders")
\ myNS.RemoveStore myFolder 


\ Sub MoveItems()
\     Dim oOL As Outlook.Application
\     Dim oNS As Outlook.NameSpace
\     Dim oSourceInbox As Outlook.MAPIFolder
\     Dim oDestinationInbox As Outlook.MAPIFolder
\     Dim oItem As Outlook.MailItem
\
\     Set oOL = CreateObject("Outlook.Application")
\     Set oNS = oOL.GetNamespace("MAPI")
\     Set oDestinationInbox = oNS.GetDefaultFolder(olFolderInbox)
\     oNS.AddStore "mypath\mypst.pst"
\     Set oSourceInbox = oNS.Folders("mypst").Folders("Inbox")
\     For Each oItem In oSourceInbox.Items
\         oItem.Move oDestinationInbox
\     Next
\     oNS.RemoveStore oNS.Folders("mypst") 'hidden method
\
\    Set oOL = Nothing
\    Set oNS = Nothing
\    Set oSourceInbox = Nothing
\    Set oDestinationInbox = Nothing
\    Set oItem = Nothing
\ End Sub
