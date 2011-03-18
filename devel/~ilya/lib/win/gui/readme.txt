Для адаптации  GUI либ от ~nn использую следующее решение:
1) Из win32forth (http://www.win32forth.org/) берём wincon.dll
2) Добавляем в spf4.ini
				REQUIRE UseDLL  ~NN\LIB\USEDLL.F 
				REQUIRE (WINAPI:) ~nn/lib/winapi.f
				REQUIRE LH-INCLUDED  ~nn/lib/lh.f
				S" ~nn/lib/wincon.f"  LH-INCLUDED
				UseDLL USER32.DLL
				UseDLL KERNEL32.DLL
				UseDLL GDI32.DLL

Пользуем !
