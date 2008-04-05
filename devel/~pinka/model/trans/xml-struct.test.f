REQUIRE EMBODY    ~pinka/spf/forthml/index.f


`../data/list-plain.f.xml       EMBODY
\ `../data/event-plain.f.xml      EMBODY
\ `../data/events-common.f.xml    EMBODY

`xml-struct.f.xml EMBODY

  
  \ startup FIRE-EVENT
  xml-struct-hidden::start

  `xml-struct.test.f.xml EMBODY

\EOF

ToDo
  В оригинале объявления xi:model локальны в пределах любого 
  родительского элемента, а здесь -- только в пределах 
  элементов f:forth, xi:include и xi:model (которые сохраняют
  чистоту по эффекту на список _list). 
  Надо бы подправить (привязать списко к родительскому элементу),
  или наложить ограничение.

  Поддержка атрибута advice для xi:model
  