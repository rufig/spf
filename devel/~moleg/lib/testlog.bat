@rem 01-06-2007 ~mOleg
@rem Copyright [C] 2007 mOleg mininoleg@yahoo.com
@rem тестирование библиотек результат в лог

@IF EXIST test.log del test.log
@CALL testall.bat >test.log
