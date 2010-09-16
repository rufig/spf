\ http://libetpan.sourceforge.net/ клиент для почтовых протоколов

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f

ALSO SO NEW: libetpan.dll
ALSO SO NEW: libetpan.so

0 CONSTANT IMAP_AUTH_TYPE_PLAIN            \ plain text authentication
0 CONSTANT CONNECTION_TYPE_PLAIN
1 CONSTANT CONNECTION_TYPE_STARTTLS

: TEST { \ st mf ml count size addr -- }
  0 1 mailstorage_new -> st
  0 0 S" password" DROP S" postmaster" DROP IMAP_AUTH_TYPE_PLAIN CONNECTION_TYPE_PLAIN 0 143 S" 127.0.0.1" DROP st 10 imap_mailstorage_init .
  st 1 mailstorage_connect ." connected=" .

  0 S" INBOX" DROP st 3 mailfolder_new DUP . -> mf
  mf 1 mailfolder_connect ." folder=" .
  ^ ml mf 2 mailfolder_get_messages_list . ml .
  ml @ CELL+ @ DUP -> count ." count=" . \ carray_count 
  \ ml @ @ 100 DUMP
  count 0 DO
    ^ size I CELLS ml @ @ + @
    2 mailmessage_fetch_size DROP size . ." :"
    ^ size ^ addr I CELLS ml @ @ + @
    3 mailmessage_fetch . addr . size .
    addr size 30 MIN TYPE CR
  LOOP
  ml 1 mailmessage_list_free DROP
  st 1 mailstorage_disconnect DROP
  st 1 mailstorage_free DROP CR ." ok" CR
;
TEST
