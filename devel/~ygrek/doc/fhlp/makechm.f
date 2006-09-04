REQUIRE convertm ~ygrek/prog/fhlp/convertm.f

S" spf_help_ru.hhp" start-project
S" spf_help_ru.hhk" start-index
S" spf_help_ru.hhc" start-toc

S" index.ru.htm" project-start-file
S" SPF help" project-title
project-full-search
S" spf_help_ru.chm" project-out-file

 ' NOOP TO ANSI><OEM
 S" index.ru.htm" S" Справка SPF" add-file
 ' OEM>ANSI TO ANSI><OEM

 \ S" docs/help/ANSFth94.fhlp" S" parts\ans94\" S" fhlp.css"  convertm
 S" docs/help/ANS94ru.fhlp"  S" parts\ans94ru\" S" ANS'94"    S" fhlp.css" convertm
 S" docs/help/SPForth.fhlp"  S" parts\spf\"     S" SPF"       S" fhlp.css" convertm
 S" docs/help/opt.fhlp"      S" parts\opt\"     S" optimizer" S" fhlp.css" convertm

end-index
end-toc
end-project

.( Done)
BYE
