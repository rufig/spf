@rem 31-05-2007 ~mOleg
@rem Copyright [C] 2007 mOleg mininoleg@yahoo.com
@rem тестирование библиотек

@rem логика тестирования находится в самой тестируемой библиотеке
@rem как минимум проверяется собираемость библиотеки под текущей
@rem сборкой СПФ.

@rem собираем текущую версию СПФ, если еще не собрана
@IF NOT EXIST ..\..\..\spf4.exe @CALL makespf.bat
@IF EXIST ..\..\..\spf4.exe CD ..\..\..\

@rem запуск текущего варианта СПФ
@FOR %%f IN ( .\spf*.exe ) DO set spf=%%f

@rem тестируем с помощью следующей библиотечки:
@%spf% devel\~moleg\lib\testing\smal-test.f

@st.exe .S" devel\~moleg\lib\util\addr.f"               TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\bytes.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\compile.f"            TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\ifnot.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\doloop.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\double.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\iw.f"                 TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\shades.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\ansi-esc.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\stackadd.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\parser.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\useful.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\on-error.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\ifcolon.f"            TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\run.f"                TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\control.f"            TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\for-next.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\stack.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\marks.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\does.f"               TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\rstack.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\words.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\spells.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\queue.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\tricks.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\alias.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\priority.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\avds.f"               TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\csp.f"                TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\case.f"               TESTED CR BYE
@st.exe .S" devel\~moleg\lib\util\console.f"            TESTED CR BYE

@st.exe .S" devel\~moleg\lib\mtask\mutex.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\mtask\pmutex.f"            TESTED CR BYE

@st.exe .S" devel\~moleg\lib\arrays\arrays.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\arrays\buff.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\arrays\barray.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\arrays\stream.f"           TESTED CR BYE

@st.exe .S" devel\~moleg\lib\parsing\number.f"          TESTED CR BYE
@st.exe .S" devel\~moleg\lib\parsing\xWord.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\parsing\xWordn.f"          TESTED CR BYE

@st.exe .S" devel\~moleg\lib\postscript\dsadd.f"        TESTED CR BYE
@st.exe .S" devel\~moleg\lib\postscript\ps{}.f"         TESTED CR BYE

@st.exe .S" devel\~moleg\lib\strings\stradd.f"          TESTED CR BYE
@st.exe .S" devel\~moleg\lib\strings\messages.f"        TESTED CR BYE
@st.exe .S" devel\~moleg\lib\strings\sconst.f"          TESTED CR BYE
@st.exe .S" devel\~moleg\lib\strings\string.f"          TESTED CR BYE
@st.exe .S" devel\~moleg\lib\strings\subst.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\strings\utf8.f"            TESTED CR BYE
@st.exe .S" devel\~moleg\lib\strings\utf16.f"           TESTED CR BYE

@st.exe .S" devel\~moleg\lib\struct\struct.f"           TESTED CR BYE

@st.exe .S" devel\~moleg\lib\drafts\vars.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\drafts\vars2.f"            TESTED CR BYE
@st.exe .S" devel\~moleg\lib\drafts\mem.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\drafts\inline.f"           TESTED CR BYE

@st.exe .S" devel\~moleg\lib\newfind\clear.f"           TESTED CR BYE
@st.exe .S" devel\~moleg\lib\newfind\new_find.f"        TESTED CR BYE
@st.exe .S" devel\~moleg\lib\newfind\spf_find.f"        TESTED CR BYE
@st.exe .S" devel\~moleg\lib\newfind\search.f"          TESTED CR BYE

@st.exe .S" devel\~moleg\lib\testing\testing.f"         TESTED CR BYE
@st.exe .S" devel\~moleg\lib\testing\say.f"             TESTED CR BYE
@st.exe .S" devel\~moleg\lib\testing\tested.f"          TESTED CR BYE

@st.exe .S" devel\~moleg\lib\spf_print\pad.f"           TESTED CR BYE

@st.exe .S" devel\~moleg\lib\asm\psevdoasm.f"           TESTED CR BYE

@st.exe .S" devel\~moleg\lib\math\math.f"               TESTED CR BYE
@st.exe .S" devel\~moleg\lib\math\fixed.f"              TESTED CR BYE
@st.exe .S" devel\~moleg\lib\math\shift.f"              TESTED CR BYE

@rem удаляем тестирующую версию СПФа
@del st.exe







