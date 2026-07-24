# spf64 LSP — языковой сервер для SP-Forth, написанный на SP-Forth

LSP-сервер для spf64, работающий **на самом spf64**: знания о Форте берутся не из
абстрактного стандарта, а из живого словаря того образа, на котором сервер запущен,
из `.wdb`-журналов сборки (file:line запечённых слов) и из индекса `*.f`-исходников.
Числа распознаёт родной `?NUM` (десятичные, `0x…`, hex-режим).

## Состав

| Файл | Что делает |
|---|---|
| `json.f` | JSON: парсер (корпус acWEB64 json.f на ALLOCATE/FREE, честный `\uXXXX`→UTF-8) + растущий выходной буфер `OB` с экранированием |
| `dict.f` | снимок живого словаря (обход `_VOC-LIST` + `FOR-WORDLIST`, имя/словарь/IMMEDIATE-бит) и загрузка `.wdb` (TSV `слово адрес словарь файл строка`) |
| `scan.f` | токенизатор поверхности spf4 (`\`, `( )`, строки `…"`, `{ локалы }`, `REQUIRE`, `\EOF`) с VECT-хуками (вкл. `ON-REQUIRE` — пути REQUIRE/INCLUDE/`S"…" INCLUDED`) + индекс определений по дереву `*.f` (FNV-хэш; обход каталогов — порт `~ac/lib/win/file/FINDFILE.F`) + рёбра «кто что подключает» + cp1251→UTF-8 |
| `doc.f` | открытые документы: полный текст, таблица строк, два прохода WALK-F (определения → диагностика неизвестных слов), слово-по-позиции (колонки в UTF-16) |
| `lsp-server.f` | Content-Length-фрейминг на `H-STDIN`/`H-STDOUT` (stdout стерилен, лог в stderr), dispatch, обработчики |
| `vscode-spf64/` | расширение VS Code: LanguageClient + язык `spf-forth` (`.f`, `.spf`) + TextMate-грамматика + cp1251 по умолчанию |
| `web/` | браузерная подсветка: `spf64-hl.js` грузит `spf-min.wasm`, Forth-драйвер печатает весь словарь (`!`=immediate), токены красятся по живому словарю |
| `tests/` | юнит-тесты (`spf64.exe lsp\tests\*-test.f`) и e2e (`node lsp\tests\e2e.js`) |

## Возможности LSP

- **диагностика**: неизвестные слова (нет ни в живом словаре, ни в индексе, ни среди
  локалов/определений файла, и не число) — предупреждения при didOpen/didChange;
- **completion**: по префиксу (без регистра) из определений файла, индекса исходников
  и живого словаря (с пометкой словаря и immediate);
- **hover**: категория слова, строка определения (код), файл:строка; для запечённых
  слов — строка исходника из `spf-x64` по `.wdb`;
- **definition**: определение в файле → индекс `*.f` → `.wdb` (в исходники spf-x64);
- **контекст как при интерпретации**: hover/definition ищут в порядке
  «этот файл → файлы, достижимые из него по `REQUIRE`/`INCLUDE`/`S" …" INCLUDED`
  (транзитивно, разрешение путей spf4-style: каталог файла → exedir → exedir\devel →
  scanRoots) → живой словарь + `.wdb` → остальной индекс». Переопределение `IF` в
  далёкой библиотеке не перекрывает ядро, пока её не подключили; слово только из
  неподключённого файла помечается в hover «**not loaded in this file**», а
  definition ведёт туда лишь как last resort (для запечённых слов без `.wdb`-позиции —
  никогда);
- **documentSymbol**: структура файла (все определения с типами).

## Запуск

```bash
D:\PRO\spf\spf64.exe lsp\lsp-server.f
```

— сервер говорит LSP по stdio (так его и запускает расширение). CWD должен быть
каталогом, содержащим `lsp/` (или spf64.exe должен лежать рядом с `lsp/` —
`REQUIRE lsp/...` резолвится и от exedir).

### Тесты

```bash
spf64.exe lsp\tests\json-test.f
spf64.exe lsp\tests\dict-test.f
spf64.exe lsp\tests\scan-test.f
spf64.exe lsp\tests\doc-test.f
node lsp\tests\e2e.js
```

## VS Code

Готовый пакет: `lsp/vscode-spf64/spf64-forth-0.1.0.vsix` (уже установлен командой
`code --install-extension …`). Пересборка:

```bash
cd lsp\vscode-spf64 && npm install && npx @vscode/vsce package
```

Настройки (`spf64.*`):

- `serverPath` — путь к spf64.exe (по умолчанию `D:\PRO\spf\spf64.exe`);
- `serverScript` — путь к `lsp-server.f`;
- `spfx64Root` — checkout dsForth64 (резолв исходников `.wdb`);
- `wdb` — список `.wdb`-файлов (пусто = `<spf64>.wdb` + дефолты из spfx64Root);
- `scanRoots` — каталоги индексации (пусто = корень workspace + `<exedir>\devel`).

Для `.f`-файлов расширение по умолчанию включает `files.encoding: windows1251`.

## Браузерная подсветка (wasm)

```bash
node lsp\web\serve.js        # http://localhost:8642/  (COOP/COEP для shared memory)
```

`spf64-hl.js` инстанцирует `spf-min.wasm` (сборка spf64→WASM), скармливает ему на
stdin Forth-драйвер, который обходит `_VOC-LIST` и печатает каждое слово с флагом
immediate; далее токены `<pre class="forth">` красятся по этому словарю: управление
(immediate) / слова словаря / определения / локалы / числа / строки / комментарии,
неизвестные — подчёркиваются. Без cross-origin isolation модуль честно деградирует
до статической подсветки. `spf-min.wasm` здесь — копия из
`spf-x64/src/wasm` (пересборка: `build-wasm.bat` там же).

Подключение на любой странице:

```html
<script src="spf64-hl.js" data-wasm="spf-min.wasm"></script>
<pre class="forth"> : HI ." Hello" ; </pre>
```

## Ограничения (v0.1)

- слово, случайно парсящееся как hex-число (`ADD`, `FACE`), не попадёт в диагностику
  (плата за поддержку HEX-режима без отслеживания BASE);
- ветки `[IF]…[THEN]` под чужую платформу дают ложные «unknown word» (severity warning);
- синхронизация текста полная (textDocumentSync=1), definition возвращает одну локацию;
- сервер однопоточный: тяжёлый скан корней выполняется один раз на `initialized`
  (~3.5 с на всё дерево `devel/`, 1.5 тыс. файлов).
