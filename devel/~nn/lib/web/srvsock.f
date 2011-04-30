REQUIRE   CreateSocket ~nn/lib/sock2.f
REQUIRE { lib/ext/locals.f

: CreateServerSocket ( port -- socket )
  { port \ s }
  CreateSocket THROW TO s
  port s BindSocket THROW
  s ListenSocket THROW
  s
;
