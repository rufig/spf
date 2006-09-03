REQUIRE convertm ~ygrek/prog/fhlp/convertm.f

S" spf_help_ru.hhp" start-project
S" spf_help_ru.hhk" start-index
S" spf_help_ru.hhc" start-toc

 S" index.ru.htm" S" Home" add-file

 \ S" docs/help/ANSFth94.fhlp" S" parts\ans94\" S" fhlp.css"  convertm
 S" docs/help/ANS94ru.fhlp"  S" parts\ans94ru\" S" ANS'94"    S" fhlp.css" convertm
 S" docs/help/SPForth.fhlp"  S" parts\spf\"     S" SPF"       S" fhlp.css" convertm
 S" docs/help/opt.fhlp"      S" parts\opt\"     S" optimizer" S" fhlp.css" convertm

end-project
end-index
end-toc

.( Done)
BYE
