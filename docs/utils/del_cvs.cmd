REM
REM This script will delete all CVS subdirectories if executed from root directory
REM Do not use it if you dont understand what you are doing!
REM
@FOR /R  %%I IN (CVS) DO if exist %%I  rd /S /Q %%I