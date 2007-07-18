REQUIRE CLSID, ~ac/lib/win/com/com.f

IID_IUnknown
Interface: IID_IMAPISession {00000000-0000-0000-C000-000000000000}
  Method: ::GetLastError       ( lppMAPIError ulFlags oid -- hresult )
  Method: ::GetMsgStoresTable  ( lppTable ulFlags oid -- hresult )
  Method: ::OpenMsgStore       ( lppMDB ulFlags lpInterface lpEntryID cbEntryID ulUIParam oid -- hresult )
  Method: ::OpenAddressBook \ Not supported - do not use. 
  Method: ::OpenProfileSection \ Not supported - do not use. 
  Method: ::GetStatusTable \ Not supported - do not use. 
  Method: ::OpenEntry1 \ Opens an object and returns an interface pointer for further access. 
  Method: ::CompareEntryIDs \ Compares two entry identifiers to determine whether they refer to the same object. 
  Method: ::Advise \ Registers to receive notification of specified events affecting the session. 
  Method: ::Unadvise \ Cancels the sending of notifications previously set up with a call to the IMAPISession::Advise method. 
  Method: ::MessageOptions \ Not supported - do not use. 
  Method: ::QueryDefaultMessageOpt \ Not supported - do not use. 
  Method: ::EnumAdrTypes \ Not supported - do not use. 
  Method: ::QueryIdentity \ Not supported - do not use. 
  Method: ::Logoff \ Ends a MAPI session. 
  Method: ::SetDefaultStore \ Not supported - do not use. 
  Method: ::AdminServices \ Not supported - do not use. 
  Method: ::ShowForm \ Not supported - do not use. 
  Method: ::PrepareForm \ Not supported - do not use. 
Interface;

IID_IUnknown
Interface: IID_IMAPIProp {00000000-0000-0000-C000-000000000000}
  Method: ::GetLastError2 \ Not supported - do not use. 
  Method: ::SaveChanges \ Not supported - do not use. ( Не правда, работает! :)
  Method: ::GetProps \ Retrieves one or more properties. 
  Method: ::GetPropList \ Not supported - do not use. 
  Method: ::OpenProperty \ Returns a pointer to an interface to be used to access a property. 
  Method: ::SetProps \ Updates one or more properties. 
  Method: ::DeleteProps \ Deletes one or more properties. 
  Method: ::CopyTo__ \ Not supported - do not use. 
  Method: ::CopyProps \ Not supported - do not use. 
  Method: ::GetNamesFromIDs \ Not supported - do not use. 
  Method: ::GetIDsFromNames \ Provides the property identifiers that correspond to one or more property names. 
Interface;

( взято из MSDN, не работает OpenEntry!, т.к. ошибочно алфавитный порядок vtable...
IID_IMAPIProp
Interface: IID_IMsgStore {00000000-0000-0000-C000-000000000000}
  Method: ::AbortSubmit \ Not supported - do not use. 
  Method: ::Advise2 \ Registers to receive notification of specified events affecting the message store. 
  Method: ::CompareEntryIDs2 \ Not supported - do not use. 
  Method: ::FinishedMsg \ Not supported - do not use. 
  Method: ::GetOutgoingQueue \ Not supported - do not use. 
  Method: ::GetReceiveFolder \ Obtains the folder that was established as the destination for incoming messages of a specified message class or the default receive folder for the message store. 
  Method: ::GetReceiveFolderTable \ Not supported - do not use. 
  Method: ::NotifyNewMail \ Not supported - do not use. 
  Method: ::OpenEntry2 \ Opens a folder or message and returns an interface pointer for further access. 
  Method: ::SetLockState \ Not supported - do not use. 
  Method: ::SetReceiveFolder \ Not supported - do not use. 
  Method: ::StoreLogoff \ Not supported - do not use. 
  Method: ::Unadvise2 \ Cancels the sending of notifications previously set up with a call to the Advise method.  
Interface;
)

( из MAPIdefs.h:)
IID_IMAPIProp
Interface: IID_IMsgStore {00000000-0000-0000-C000-000000000000}
  Method: ::Advise2
  Method: ::Unadvise2
  Method: ::CompareEntryIDs2
  Method: ::OpenEntry2
  Method: ::SetReceiveFolder
  Method: ::GetReceiveFolder
  Method: ::GetReceiveFolderTable
  Method: ::StoreLogoff
  Method: ::AbortSubmit
  Method: ::GetOutgoingQueue
  Method: ::SetLockState
  Method: ::FinishedMsg
  Method: ::NotifyNewMail
Interface;

IID_IMAPIProp
Interface: IID_IMAPIContainer {00000000-0000-0000-C000-000000000000}
  Method: ::GetContentsTable \ Returns a pointer to the container's contents table. 
  Method: ::GetHierarchyTable \ Returns a pointer to the container's hierarchy table. 
  Method: ::OpenEntry3 \ Opens an object within the container, returning an interface pointer for further access. 
  Method: ::SetSearchCriteria \ Not supported - do not use. 
  Method: ::GetSearchCriteria 
Interface;

IID_IMAPIContainer
Interface: IID_IMAPIFolder {00000000-0000-0000-C000-000000000000}
  Method: ::CreateMessage \ Creates a new message. 
\ HRESULT CreateMessage (
\   LPCIID lpInterface,
\   ULONG ulFlags,
\   LPMESSAGE FAR * lppMessage
\ );
  Method: ::CopyMessages \ Copies or moves one or more messages. 
  Method: ::DeleteMessages \ Deletes one or more messages. 
  Method: ::CreateFolder \ Creates a new subfolder. 
  Method: ::CopyFolder \ Copies or moves a subfolder. 
  Method: ::DeleteFolder \ Deletes a subfolder. 
  Method: ::SetReadFlags \ Not supported - do not use.
  Method: ::GetMessageStatus \ Not supported - do not use. 
  Method: ::SetMessageStatus \ Not supported - do not use. 
  Method: ::SaveContentsSort \ Not supported - do not use. 
  Method: ::EmptyFolder \ Deletes all messages and subfolders from a folder without deleting the folder itself. Available only for Windows Mobile 5.0 and later. 
Interface;

IID_IUnknown
Interface: IID_IMAPITable {00000000-0000-0000-C000-000000000000}
  Method: ::GetLastError3 \ Not supported - do not use. 
  Method: ::Advise3 \ Not supported - do not use. 
  Method: ::Unadvise3 \ Not supported - do not use. 
  Method: ::GetStatus \ Not supported - do not use. 
  Method: ::SetColumns \ Defines the particular properties and order of properties to appear as columns in the table.  
  Method: ::QueryColumns \ Not supported - do not use. 
  Method: ::GetRowCount \ Returns the number of rows in the table that meet a set of criteria. 
  Method: ::SeekRow \ Moves the cursor to a specific position in the table. 
  Method: ::SeekRowApprox \ Not supported - do not use. 
  Method: ::QueryPosition \ Retrieves the current table row position of the cursor, based on a fractional value. 
  Method: ::FindRow \ Not supported - do not use. 
  Method: ::Restrict \ Applies a filter to a table, reducing the row set to only those rows matching the specified criteria. 
  Method: ::CreateBookmark \ Not supported - do not use. 
  Method: ::FreeBookmark \ Not supported - do not use. 
  Method: ::SortTable \ Orders the rows of the table based on sort criteria. 
  Method: ::QuerySortOrder \ Not supported - do not use. 
  Method: ::QueryRows \ Returns one or more rows from a table, beginning at the current cursor position. 
  Method: ::Abort \ Not supported - do not use. 
  Method: ::ExpandRow \ Not supported - do not use. 
  Method: ::CollapseRow \ Not supported - do not use. 
  Method: ::WaitForCompletion \ Not supported - do not use. 
  Method: ::GetCollapseState \ Not supported - do not use. 
  Method: ::SetCollapseState \ Not supported - do not use. 
Interface;

IID_IMAPIProp
Interface: IID_IMessage {00000000-0000-0000-C000-000000000000}
  Method: ::GetAttachmentTable \ Returns the message's attachment table. 
  Method: ::OpenAttach \ Opens an attachment. 
  Method: ::CreateAttach \ Creates a new attachment. 
  Method: ::DeleteAttach \ Deletes an attachment. 
  Method: ::GetRecipientTable \ Returns the message's recipient table. 
  Method: ::ModifyRecipients \ Adds, deletes, or modifies message recipients. 
  Method: ::SubmitMessage \ Saves all changes to the message and marks it as ready for sending. 
  Method: ::SetReadFlag \ Not supported - do not use. (А на деле работает! :)
Interface;


IID_IUnknown
Interface: IID_IConverterSession {4b401570-b77b-11d0-9da5-00c04fd65685}
  Method: ::SetAddressBook \ member Not supported or documented. 
  Method: ::SetEncoding \ Initializes the encoding to be used during conversion. 
  Method: ::Placeholder \ member  Not supported or documented. 
  Method: ::MIMEToMAPI  \ Converts a MIME stream to a MAPI message. 
\ HRESULT IConverterSession:: MIMEToMAPI (
\ 	LPSTREAM pstm,
\ 	LPMESSAGE pmsg,
\ 	LPCSTR pszSrcSrv,
\ 	ULONG ulFlags
\ );
  Method: ::MAPIToMIMEStm  \ Converts a MAPI message to a MIME stream. 
  Method: ::Placeholder2 \ member  Not supported or documented. 
  Method: ::Placeholder3 \ member Not supported or documented. 
  Method: ::Placeholder4 \ member Not supported or documented. 
  Method: ::SetTextWrapping \ Sets the text wrapping width for a MIME stream that the converter will return in MAPIToMIMEStm. 
  Method: ::SetSaveFormat \ Sets the format that the converter will return a MIME stream in MAPIToMIMEStm. 
  Method: ::Placeholder5 \ member  Not supported or documented. 
  Method: ::Placeholder6 \ member  Not supported or documented. 
Interface;

IID_IMAPIProp
Interface: IID_IAddrBook  {00000000-0000-0000-C000-000000000000}
  Method: ::OpenEntry4
  Method: ::CompareEntryIDs4
  Method: ::Advise4
  Method: ::Unadvise4
  Method: ::CreateOneOff
  Method: ::NewEntry
  Method: ::ResolveName												\
\		(THIS_	ULONG_PTR					ulUIParam,					\
\				ULONG						ulFlags,					\
\				LPTSTR						lpszNewEntryTitle,			\
\				LPADRLIST					lpAdrList) IPURE;			\
  Method: ::Address
  Method: ::Details
  Method: ::RecipOptions
  Method: ::QueryDefaultRecipOpt
  Method: ::GetPAB
  Method: ::SetPAB
  Method: ::GetDefaultDir
  Method: ::SetDefaultDir
  Method: ::GetSearchPath
  Method: ::SetSearchPath
  Method: ::PrepareRecips
Interface;


\ typedef ULONG (FAR PASCAL MAPILOGON)(
\ 	ULONG_PTR ulUIParam,
\ 	LPSTR lpszProfileName,
\ 	LPSTR lpszPassword,
\ 	FLAGS flFlags,
\ 	ULONG ulReserved,
\	LPLHANDLE lplhSession
\ );

IID_IUnknown
Interface: IID_IStream	{0000000C-0000-0000-C000-000000000046}
  Method: ::Read 	\ Reads a specified number of bytes from the stream object into memory starting at the current seek pointer.
  Method: ::Write 	\ Writes a specified number of bytes into the stream object starting at the current seek pointer.
  Method: ::Seek 	\ Changes the seek pointer to a new location relative to the beginning of the stream, the end of the stream, or the current seek pointer.
  Method: ::SetSize 	\ Changes the size of the stream object.
  Method: ::CopyTo  	\ Copies a specified number of bytes from the current seek pointer in the stream to the current seek pointer in another stream.
  Method: ::Commit 	\ Ensures that any changes made to a stream object open in transacted mode are reflected in the parent storage object.
  Method: ::Revert 	\ Discards all changes that have been made to a transacted stream since the last call to IStream::Commit.
  Method: ::LockRegion 	\ Restricts access to a specified range of bytes in the stream. Supporting this functionality is optional since some file systems do not provide it.
  Method: ::UnlockRegion \ Removes the access restriction on a range of bytes previously restricted with IStream::LockRegion.
  Method: ::Stat 	\ Retrieves the STATSTG structure for this stream.
  Method: ::Clone 	\ Creates a new stream object that references the same bytes as the original stream but provides a separate seek pointer to those bytes.
Interface;

: CLSID_IConverterSession S" {4E3A7680-B77A-11D0-9DA5-00C04FD65685}" ;
