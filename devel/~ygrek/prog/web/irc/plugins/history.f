\ $Id$
\ История сообщений

MODULE: bot_plugin_history

() VALUE log-history

: n-get-history-> ( n --> logentry \ <-- )
   log-history length TUCK MIN - log-history nth PRO list-> CONT ;

: log>string ( logentry -- a u ) car cdar STR@ ;
: log>stamp ( logentry -- stamp ) car car ;

: secs-get-history-> ( n --> logentry \ <-- )
   TIME&DATE DateTime>Num SWAP - ( stamp )
   PRO log-history START{ list-> ( stamp logentry ) 2DUP log>stamp < IF CONT ELSE DROP THEN }EMERGE DROP ;

: Time>PAD { s m h -- a u } <# s #N## [CHAR] : HOLD m #N## [CHAR] : HOLD h #N## 0 0 #> ;

0 VALUE counter
20 CONSTANT counter_max

EXPORT

MODULE: VOC-IRC-COMMAND
: PRIVMSG
   ACCERT( ." PRIVMSG of history" CR )
   TIME&DATE DateTime>Num { stamp -- }
   ACCERT( ." try previous PRIVMSG" CR )
   PRIVMSG
   %[
     stamp %
     current-msg-text irc-action? >R
     current-msg-sender stamp Num>Time Time>PAD
     R> IF " ({s}) {s} {s}" ELSE " ({s}) [{s}] {s}" THEN %s
   ]% vnode as-list log-history append TO log-history
   ACCERT( ." PRIVMSG of history done" CR )
  ;
;MODULE

MODULE: BOT-COMMANDS-HELP
: !last S" Usage: !last <n>|<n>min|<n>sec - bot will send last n messages from channel back to you (as NOTICEs, max 20)" S-REPLY ;
;MODULE

MODULE: BOT-COMMANDS

: !last
    0 TO counter
    0 PARSE FINE-HEAD FINE-TAIL
    RE" (\d+)\s*(min|sec)?" re_match? 0= IF BOT-COMMANDS-HELP::!last EXIT THEN
    1 get-group NUMBER 0= IF BOT-COMMANDS-HELP::!last EXIT THEN
    ( num )
    2 get-group NIP IF
     2 get-group S" sec" COMPARE 0= IF 1
     ELSE
     2 get-group S" min" COMPARE 0= IF 60
     ELSE
     DROP
     S" Strange error. Please file a bugreport" S-REPLY EXIT
     THEN THEN
     * START{ secs-get-history-> counter counter_max < IF log>string current-msg-sender S-NOTICE-TO counter 1+ TO counter ELSE DROP THEN }EMERGE
    ELSE
     START{ n-get-history-> counter counter_max < IF log>string current-msg-sender S-NOTICE-TO counter 1+ TO counter ELSE DROP THEN }EMERGE
    THEN
  ;

;MODULE

;MODULE

$Revision$ " -- History plugin {s} loaded" STYPE CR
