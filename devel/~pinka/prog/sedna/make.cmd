@echo off
FOR /F %%I IN ("%0") DO (
  spf %%~pIse_svc.f S" se_svc.exe" SAVE BYE
)
