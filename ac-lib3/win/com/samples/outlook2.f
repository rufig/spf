.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

: TEST { \ outlook ns }
  COM-init THROW

  Z" Outlook.Application" create-object THROW -> outlook
  arg( Z" MAPI" _str )arg outlook :: GetNameSpace >
  DROP -> ns
\  arg( Z" c:\\delosoft.pst" _str )arg ns :: AddStore >
\  . .
  ns :: Folders ["Personal Folders"] @
  DROP :: Folders ["Contacts"] @
\ oSourceInbox = oNS.Folders("mypst").Folders("Inbox")
  DROP :: Items @

\  ns :: Folders @
  DROP FOREACH 
        OBJ-I DROP :: FirstName @
        DROP ASCIIZ> TYPE SPACE
        OBJ-I DROP :: LastName @
        DROP ASCIIZ> TYPE CR
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
