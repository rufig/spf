for /R %%A in (section*.htm*) DO @if exist %%A del %%A
cmd/c spf makechm.f
hhc spf_help_ru.hhp