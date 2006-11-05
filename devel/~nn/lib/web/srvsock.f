REQUIRE   CreateSocket ~nn/lib/sock2.f
REQUIRE { ~ac/lib/locals.f

: CreateServerSocket ( port -- socket )
  { port \ s }
  CreateSocket THROW TO s
  port s BindSocket THROW
  s ListenSocket THROW
  s
;
