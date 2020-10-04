SOURCE + 1 CHARS - C@ 0xA = CHAR | AND PARSE | UNIX-LINES
2DROP
\ If the last character in the buffer is LF (0xA)
\ then this file has LF line endigns and the current mode is not UNIX-LINES.
\ Perform UNIX-LINES in this case. Otherwise do nothing.
