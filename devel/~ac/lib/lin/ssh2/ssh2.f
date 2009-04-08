(
  $Id$
)

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f
REQUIRE fsockopen     ~ac/lib/win/winsock/psocket.f 

ALSO SO NEW: libssh2.dll

:NONAME { abstract responses prompts num_prompts instruction_len instruction name_len name -- }
  ." AUTH:"
  name name_len TYPE
  instruction instruction_len TYPE
  num_prompts DUP . 1 =
  IF
    prompts @ prompts CELL+ @ S" Password:" SEARCH
    IF 2DROP S" passw" responses CELL+ ! responses ! ELSE TYPE CR THEN
  THEN
  abstract responses prompts num_prompts instruction_len instruction name_len name 0
; 8 CELLS CALLBACK: LIBSSH2_USERAUTH_KBDINT_RESPONSE

: TEST { \ sess sock }
  0 0 0 0 4 libssh2_session_init_ex -> sess
  S" myssh2host" 22 ConnectHost THROW -> sock
  sock sess 2 libssh2_session_startup .
  S" root" SWAP sess 3 libssh2_userauth_list ASCIIZ> TYPE CR
  ['] LIBSSH2_USERAUTH_KBDINT_RESPONSE S" root" SWAP sess 4 libssh2_userauth_keyboard_interactive_ex .
\  0 S" passw" SWAP S" root" SWAP sess 6 libssh2_userauth_password_ex .
  sess 1 libssh2_userauth_authenticated .
;
SocketsStartup THROW
TEST
