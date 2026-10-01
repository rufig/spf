# `~ac/lib/net` — авто-обнаружение своего флота поверх BitTorrent DHT + взаимный DTLS

Документация соответствует состоянию ветки `spf64` на 2026-10-01
(последний коммит `77aa4c39`). Загружается и на spf4, и на spf64.

## 1. Назначение

Децентрализованное **авто-обнаружение собственного флота** серверов Eserv/acWEB64
(публичные VPS + машины за NAT) **без доверия к DNS/регистраторам/центральным CA** —
именно потому, что они перестали быть надёжными. Discovery идёт по публичному
**BitTorrent Mainline DHT**, а всё доверие устанавливается **после** обнаружения через
**взаимный DTLS**. Обнаруженному IP не доверяем никогда — доверяем только тому, кто
предъявил сертификат, подписанный нашим общим тестовым CA.

Проверено на практике: при полном отказе зоны DNS `snop.org` узлы продолжали находить
друг друга и держать связь через DHT; при дрейфе внешнего IP (в т.ч. у VPS) связь
восстанавливалась автоматически.

## 2. Модель доверия (идентичность)

- **Идентичность узла = `SHA1(SubjectPublicKeyInfo)`** его X.509-сертификата. Стабильна
  при перевыпуске сертификата (пока не меняется ключ).
- Два анонсируемых в DHT ключа (20-байтовые инфохэши):
  - **`IH-SELF` = SHA1(SPKI собственного сертификата)** — найти конкретный узел;
  - **`IH-GROUP` = SHA1(SPKI сертификата CA)** — каждый член флота анонсирует его, так что
    `get_peers(IH-GROUP)` перечисляет весь флот.
- `IH-GROUP` неугадываем (2⁻¹⁶⁰). Кто анонсируется под ним — либо наш член (имеет ключ),
  либо тот, кто **узнал хэш из наших же публичных анонсов** (паук/краулер). Случайных
  «невинных» там нет.

## 3. Состав

| Файл | Слой |
|---|---|
| `bencode.f` | строго-ограниченный bencode-кодер/декодер (защита от вредоносного ввода) |
| `dht.f` | ядро DHT-клиента: KRPC, BEP42 node id, shortlist, routing table (`RTAB`), `PEERS` |
| `dht-serve.f` | DHT-ответчик (ping/find_node/get_peers/announce), токены, наблюдение внешних endpoint'ов, захват сбойных пакетов |
| `swarm.f` | сессия: `SWARM-OPEN`, `CERT>KEY`/`SWARM-KEYS`, `SWARM-FIND` (повторяемый lookup) |
| `dtls.f` | DTLS 1.2 поверх OpenSSL 3.x (mem-BIO, verify-cb, cookie/HelloVerifyRequest) |
| `dtls-net.f` | мультиплекс DHT+DTLS на одном UDP-сокете, таблица пиров, негативный кэш, переанонс, dial-back |
| `persist.f` | тёплый старт через SQLite (`~ac/lib/lin/sql`): таблицы узлов и членов |
| `~ac/lib/asn1/der.f` | ограниченный DER-парсер (альтернатива OpenSSL для извлечения SPKI) |

## 4. Сетевая модель

Один UDP-сокет (порт 6881, при занятости 6882..6890; если все заняты — `-3300 THROW`,
а не эфемерный порт). Демультиплекс первого байта датаграммы в духе **RFC 7983**:
`'d'` → bencode/DHT, `0x14..0x17` → запись DTLS. Так DHT и DTLS сосуществуют на одном
порту, и входящий DTLS пробивает NAT тем же путём, что и DHT-трафик.

## 5. Идентичность узла и BEP42

Строгие узлы DHT (BEP42) ожидают, что node id выводится из внешнего IP. Поэтому:

- **Внешний IP берётся из DHT**, а не из конфига: узлы эхом возвращают наш адрес в поле
  `ip` ответов (`EXTIP-SEEN`). При первом наблюдении, если IP не задан, он **усыновляется**
  как идентичность: `ADOPT-EXTIP` = `MY-EXT-IP !` + `BEP42-NODE-ID` (id = BEP42 от IP).
  Хардкода внешнего IP в boot-скрипте больше нет.
- **Дрейф IP обрабатывается на лету** (без рестарта): `EXTIP-EXPIRE` → `EXTIP-READOPT` —
  если endpoint, от которого выведен `MY-ID`, устаревает, а есть **другой живой** endpoint,
  переусыновляем id с него; периодический переанонс публикует нас под новым id.
  Split-tunnel (несколько живых IP) не вызывает тряски (`EXTIP-HAS-IP?`).
- Если таблица endpoint'ов опустела от старения (нет **подтверждений** ≠ IP сменился),
  `MY-EXT-IP`/`MY-ID` **сохраняются** (не сбрасываются в 0) — иначе `BE-SELF` анонсировал бы
  нас как `0.0.0.0`.
- Идентичность **привязана к адресу**, не к паре (адрес,порт); при нескольких внешних
  endpoint'ах подпись выбирается **по получателю** (`SIGN-FOR`/`PEERMAP`): отвечаем пиру тем
  id, под которым он нас видит.

> Замечание из эксплуатации: большинство узлов возле `IH-GROUP` поле `ip` **не** эхуют
> (эхуют в основном bootstrap-роутеры на старте), поэтому `routes out: none observed yet` —
> нормальный устойчивый режим; на discovery это не влияет.

## 6. Discovery

1. **Анонс** `IH-GROUP` к K ближайшим узлам (`announce_peer`, `implied_port=1` → хранится
   реальный source-адрес, не `BE-SELF`). Переанонс периодически (`REANNOUNCE-SECS`).
2. **Lookup** `get_peers(IH-GROUP)`: параллельный (Kademlia-alpha), повторяемый
   (`FIND-RETRIES`), с корреляцией ответов по tid+endpoint (`OUTQ`).
3. **`HARVEST`** раскладывает ответ:
   - `values[]` (6-байтовые компактные пиры) → **`PEERS`** (кандидаты на наш DTLS-дозвон);
   - `nodes` (26-байтовые, с node id) → **shortlist** (`SL`) **и routing table** (`RTAB`).
   - `values` и `nodes` — **разные потоки**: анонсёров в `RTAB` не положить (в них нет id).
4. **`SWARM-DISCOVER-DIAL`** в конце раунда DTLS-верифицирует новые `PEERS`
   (пропуская себя / уже установленных / backed-off).
5. **Dial-back**: если входящий `get_peers`/`announce_peer` несёт **наш** ключ
   (`IH-GROUP`/`IH-SELF`, зарегистрированы через `SWARM-DIALBACK-KEY`) — дозваниваемся
   обратно (рукопожатие и есть проба; пробивает NAT встречного).

**Важно:** DTLS-дозвон идёт **только** к тем, кто связан с нашими ключами — к `values`
под нашим `IH-GROUP` и к queriers наших ключей. К анонсёрам чужих хэшей — никогда.

## 7. Взаимный DTLS

- Браузерного стиля EC (P-256), RFC-8827 cipher policy. Верификация двусторонняя
  (`VERIFY_MUTUAL`): пир обязан предъявить сертификат, подписанный нашим CA.
- При успехе — сверка identity-хэша (SHA1(SPKI)); при ожидании конкретного сервера —
  точное совпадение с `expect`.
- **Анти-amplification (RFC 6347)**: первый ClientHello от неизвестного источника
  проходит stateless-cookie (`DTLSv1_listen`, cookie = SHA1(секрет‖ip‖port)); состояние
  (SSL/слот) выделяется только после эхо cookie. Ответ меньше запроса — усиливать нечего.
- **Ловушка на чужие сертификаты**: пир, который **ответил** по DTLS, но предъявил
  сертификат **не нашего CA**, — не обычный DHT-узел (те по DTLS не отвечают вовсе), а
  пробер/импостер. Verify-cb логирует отдельной строкой
  `!!! FOREIGN DTLS cert -- from <ip:port> ... issuer=<> err=<>` и сохраняет его DER в
  корпус `<prefix><N>.der` (`SAVE-FCERT`) для разбора `openssl x509 -inform DER -text`.

## 8. Негативный кэш и escalating backoff

Узел становится «bad» **только** после неудачного нашего DTLS-дозвона; из DHT-поведения —
никогда. Записи имеют TTL:

- **cert-reject** (чужой CA / нет сертификата / mismatch / fatal alert) → `NCACHE-BAD-TTL` (10 мин);
- **таймаут рукопожатия** → **escalating**: первые `NCACHE-ESCALATE-AFTER`(=3) таймаута
  держат короткий `NCACHE-SLOW-TTL` (90 с, вдруг член за NAT), дальше — `NCACHE-DEAD-TTL`
  (10 мин, мёртвый мусор);
- `NCACHE-CLEAR` при успешной верификации сбрасывает счётчик (восстановившийся член).

Это гасит шторм дозвонов к публично-анонсированному `IH-GROUP` (мусор/краулеры) и
amplification со стороны отправителя.

## 9. Управление `PEERS`

`values` — открытый, засоряемый список. Два механизма не дают мусору вытеснять членов:

- **crowd-out фильтр**: `HARVEST` не кладёт в `PEERS` уже мёртвого/backed-off пира
  (`PEER-BAD?-XT` → `NCACHE-HAS?`);
- **eviction**: при полной таблице (`PEERS-MAX`) живой новичок **занимает слот первого
  мёртвого**, а не отбрасывается; если мёртвых нет — таблица законно полна.

Гражданскую роль в DHT несёт `RTAB` (отвечает на `find_node`/`get_peers`, вытесняет самый
несвежий при переполнении) — не `PEERS`.

## 10. Персистентность (тёплый старт)

SQLite-БД (`persist.f`, только штатные слова `~ac/lib/lin/sql/sqlite3.f`), **явные столбцы**,
ip — дотированная строка в порядке `C-IP`/`.IP4`:

- `dht_nodes(id TEXT, ip TEXT, port INT, seen INT)` — routing table; `SWARM-DB-LOAD-NODES`
  + `SEED-FROM-RTAB` кормят shortlist, так что меш поднимается даже при недоступных
  bootstrap-роутерах/DNS;
- `members(hash TEXT, ip TEXT, port INT, seen INT)` — где последний раз верифицирован член;
  дозваниваются при старте.
- **Периодический ре-дозвон saved-members** (`SWARM-REDIAL-MEMBERS`, хук `MEMBER-REDIAL-XT`
  в конце раунда): не раз при старте, а пока член не подключён (guard'ы self/known/backed-off) —
  чинит промах boot-дозвона и дрейф.

> `sqlite3.f` в кодировке **cp1251** — НЕ редактировать ASCII-инструментами (перекодирует
> кириллицу). `persist.f` обходится стоковыми словами (hex-TEXT в SQL, без bind-API).

## 11. Устойчивость к сбоям

- **DNS лёг** → discovery по DHT не зависит от DNS; узлы находят друг друга по инфохэшам.
- **Внешний IP дрейфанул** → наблюдение из DHT + авто-переусыновление id + переанонс (§5).
- **Мы сами перезагрузились** → тёплый старт из SQLite + дозвон saved-members + dial-back.
- **Пропали bootstrap-роутеры** → `SEED-FROM-RTAB` из сохранённых узлов.

## 12. Безопасность (пройденная закалка P0/P1)

- **Ограниченный bencode** (кодер и декодер): `BE-SETEND`, `B-ULEN` (беззнаковая длина,
  переполнение невозможно по построению), `BE-MAXDEPTH` против рекурсии, курсор зажат
  в `[BE-START,BE-END]`. Любой кривой ввод → `BE-BAD`, не выход за буфер.
- `get_peers` под **чужой** инфохэш отдаёт пустой `values` (не утекает флот), только `nodes`.
- `announce_peer` принимается лишь с верным токеном (`MK-TOKEN(source-ip)`).
- Admission: SSL/слот под входящий DTLS — только на реальный ClientHello и при
  `HS-COUNT < HS-MAX`; cookie-раунд против спуфинга источника.
- `PR-DRAIN-IN` вычитывает mem-BIO после рукопожатия; абсолютный кап `RBIO-CAP`.
- **Сбойные датаграммы** (`SAVE-BADPKT`) пишутся по одному в файл для последующего анализа
  (кап `BADPKT-MAX`).

Открытое (из ревью, не remote-memory-safety): токен обратим (IP XOR SECRET, без ротации);
`IH-GROUP` публично вычислим; SHA-1 identity без ротации ключа.

## 13. Параметры (ручки)

| Параметр | Значение | Смысл |
|---|---|---|
| `IDLEN` | 20 | длина node id / инфохэша |
| `MY-PORT` | 6881 (6882..6890) | слушающий UDP-порт |
| `PEERS-MAX` | 256 | кандидаты discovery на дозвон |
| `SL-MAX` | 64 | shortlist lookup'а |
| `RTAB-MAX` / `RT-K` | 160 / 8 | routing table / K ближайших в ответе |
| `MAXPEERS` | 64 | слоты DTLS-пиров |
| `MAX-QUERIES` | 40 | предел узлов на один lookup |
| `LOOKUP-ALPHA` | 3 | параллельных get_peers в полёте |
| `QUERY-TIMEOUT` | 2000 мс | пока запрос «в полёте» |
| `OUTQ` / `OUTQ-TTL` | 128 / 8000 мс | кольцо корреляции ответов |
| `FIND-RETRIES` | 4 | полных lookup-прогонов за `SWARM-FIND` |
| `ANNOUNCE-K` | 8 | анонс к K ближайшим |
| `REANNOUNCE-SECS` | 600 | интервал переанонса |
| `PING-INTERVAL` | 25000 мс | NAT-keepalive (<30 с) |
| `PEER-IDLE` | 90000 мс | тишина до реклейма установленного пира |
| `CONNECT-TIMEOUT` | 8000 мс | дедлайн рукопожатия |
| `NCACHE-BAD-TTL` | 600000 мс | бан по cert-reject |
| `NCACHE-SLOW-TTL` | 90000 мс | повтор после таймаута |
| `NCACHE-DEAD-TTL` | 600000 мс | бан мёртвого после эскалации |
| `NCACHE-ESCALATE-AFTER` | 3 | таймаутов подряд до перехода в DEAD |
| `/NCACHE` | 256 | ёмкость негативного кэша |
| `EXTIP-TTL` / `/EXTIP` | 900000 мс / 8 | старение / макс. внешних endpoint'ов |
| `HS-MAX` | 16 | незавершённых входящих рукопожатий |
| `RBIO-CAP` / `DRAIN-MAX` | 65536 / 32 | кап приёмного BIO / чтений за проход |
| `/PEER-DER` | 4096 | макс. DER сертификата пира |
| `PSTORE-MAX` / `MAX-REPLY-VALUES` | 256 / 100 | хранилище ответчика / кап `values` в ответе |
| `BADPKT-MAX` / `FCERT-MAX` | 100 / 50 | кап захвата сбойных пакетов / чужих сертификатов |
| `BE-MAXDEPTH` | 32 | предел вложенности bencode |

## 14. Эксплуатация

Boot-скрипт (per-machine, **не в репозитории**) грузит стек и запускает петлю:

```forth
REQUIRE SWARM-JOIN    ~ac/lib/net/dtls-net.f
REQUIRE SWARM-DB-OPEN ~ac/lib/net/persist.f
...
: DIAL-MEMBER ( ip port -- )  0 SWARM-DTLS-CONNECT DROP ;   \ expect=0: любой член нашего CA
: MAIN  C1 K1 CA SWARM-DTLS-CONFIG            \ .crt/.key/.crt CA (PEM для SSL_CTX)
   S" .../server1.cer"  IH1 CERT>KEY          \ DER .cer -> SHA1(SPKI)  (НЕ PEM!)
   S" .../swarm-ca.cer" IHG CERT>KEY
   SWARM-OPEN
   S" .../badpkt-"      SET-BADPKT-FILE        \ абсолютные пути!
   S" .../foreigncert-" SET-FCERT-FILE
   S" .../swarm.db3" SWARM-DB-OPEN IF
      SWARM-DB-LOAD-NODES . ."  nodes" CR
      ['] DIAL-MEMBER SWARM-DB-LOAD-MEMBERS . ."  members" CR THEN
   IHG SWARM-DIALBACK-KEY  IH1 SWARM-DIALBACK-KEY
   IHG SWARM-REANNOUNCE
   BEGIN 120 SWARM-DTLS-SERVE  SWARM-DB-SAVE-NODES  AGAIN ;
MAIN
```

- `CERT>KEY` принимает PEM `.crt` **и** DER `.cer`, но для хэша давать **DER `.cer`**
  (PEM отдаёт другой хэш молча). `SWARM-DTLS-CONFIG` хочет PEM `.crt`/`.key`.
- `SET-BADPKT-FILE`/`SET-FCERT-FILE` — **абсолютный** путь (относительный `CREATE-FILE`
  в контексте C-callback'а на Linux молча падает).
- Служба: systemd (на VPS `Restart=always`), логи в journald — не доверять `srv3.log`/
  `run.sh`, если это оставшийся мусор.
- Диагностика: `journalctl -u swarm-dtls`; строки `discovery: PEERS=N (new/known/bad/self)
  corr-hit=.. miss=..`, `keepalive ping -> ip:port`, `MEMBER verified`, `routes out`,
  `!!! FOREIGN DTLS cert`. На узле за тоннелем `tcpdump` может не видеть трафик — верить логу.

## 15. Тесты

`tests/` (в gitignore): `bencode-test.f` (tracked, рядом с исходником), `der-test.f`,
`ncache-escalate-test.f`, `peers-crowdout-test.f`, `peers-evict-test.f`,
`adopt-extip-test.f`, `extip-drift-test.f`, `foreigncert-test.f`, `persist-*-test.f`,
`badpkt-test.f`, `cookie-test.f`, `cookie-guard-test.f`. Запуск из `D:\PRO\spf`:
`spf64 tests\<имя>.f`.

### Прикладные данные DTLS (2026-10-02)

`dtls-net.f` предоставляет необязательные hooks `APP-UP-XT`
`(identity-a idx generation --)`, `APP-DATA-XT` `(a u idx generation --)`
и `APP-DOWN-XT` `(idx generation --)`. Они вызываются в сетевом потоке,
защищены CATCH; данные заимствованы только на время callback. Тяжёлую обработку
нужно передавать в ограниченную очередь. `MEMBER-UP-XT` продолжает работать.
`APP-HOOK-ERRORS` считает исключения новых hooks; UP/DATA-ошибка закрывает peer.

`PR-APP-SEND (a u idx generation -- ior)` копирует до 1024 байт в один
pending-буфер peer: 0 = принято, -3219 = занят, -3218 = неверный размер или
устаревшее/непроверенное соединение. `PR-APP-FLUSH` сохраняет буфер при
WANT_READ/WANT_WRITE и вызывается из обычного сетевого цикла. `PR-RELEASE`
закрывает peer с уведомлением DOWN; не освобождайте его SSL напрямую.
Поколение меняется при каждом использовании слота; никакая прикладная очередь
не должна адресоваться только индексом слота. Все эти слова принадлежат одному
сетевому владельцу и не вызываются одновременно из HTTP/рабочих потоков.

Фортовый SHA-1 доступен как `SWARM-SHA1 (a u dest --)`; внутренние вызовы
используют это имя, чтобы не путать его с C-экспортом SHA1 при интеграции с
acWEB64. Alias SHA1 сохранён для прежних standalone-приложений.
Проверки интеграции находятся в acWEB64: `tests/replication-swarm-test.f`,
`tests/replication-dtls-test.f`, Linux runner `tests/run-replication-dtls.sh`.

## 16. Известные ограничения

- Хост за симметричным/плавающим NAT сам обнаруживается слабее; флот держат публичные
  узлы-рандеву + saved-member дозвон + dial-back (проверено: связь жива сквозь дрейф и
  отказ DNS).
- `PEERS` держится у `PEERS-MAX` (eviction не сжимает список) — не баг, следствие открытого
  DHT-хэша; член при этом не голодает.
- Без гейта spf64 на Windows грузить DHT+persist вместе = known SO-NEW hang (на флоте Linux —
  не воспроизводится).
