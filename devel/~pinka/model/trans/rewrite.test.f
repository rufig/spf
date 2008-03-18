REQUIRE EMBODY    ~pinka/spf/forthml/index.f

\ библиотеки
`../data/list-plain.f.xml EMBODY
`../data/event-plain.f.xml EMBODY

\ объекты
`../data/events-common.f.xml EMBODY \ создан местный домен событий

`rewrite.L2.f.xml EMBODY \ создан экземпляр объекта

  ( Подобные простые объекты должны использоваться однопоточно.
  При многопоточной работе каждый рабочий имеет свой экземпляр объекта,
  или берет объект на временное пользование из пула,
  или обращается к хозяину объекта с просьбой выполнить запрос
  -- в зависимости от выбранной схемы.
  )
  
  `abc rewrite TYPE CR  \ --> abc  \ т.к. правил еще нету, то сработает и без startup
  
  `C:/WinXP/system32/           `spf://win32-dll/             advice-rewrite-head
  
  `spf://win32-dll/libxml2.dll  `http://xmlsoft.org/libxml2   advice-rewrite-head
  `spf://win32-dll/libxslt.dll  `http://xmlsoft.org/libxslt   advice-rewrite-head
  
  \ "rewrite-head" говорит о том, что переписывается начало строки (голова). 
  \ Здесь порядок:  ( значение ключ ), -- такой же, как у слов "!", "HASH!"
  \ Тогда для порядка ( ключ значение ) будет "advice-rewrite-head-"
  
  
  startup FIRE-EVENT 
  \ объект rewrite переведен в рабочее состояние,
  \ распределена область данных для его работы

  `http://xmlsoft.org/libxml2 rewrite TYPE CR
  `http://xmlsoft.org/libxslt rewrite TYPE CR
  `abc rewrite TYPE CR \ возвращается без изменений, т.к. никакое правило не сработало.
  
  cleanup FIRE-EVENT 
  \ занятое место освобождено и готово к повторному использованию
  