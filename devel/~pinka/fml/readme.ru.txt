
make-xslt.cmd      -- процесс генерации движка ForthML на базе XSLT
make-core-forth.cmd  -- процесс генерации базовых обработчиков для движка ForthML на базе форт-системы
make-all.cmd       -- обновить все авто-сгенереное
clear-all.cmd      -- удалить сгенереные файлы (кроме forthml-rules.f)

Выходные файлы:
  tmp/             -- временные файлы, для разбора или вникания ;)
  forthml.xsl      -- транслятор из ForthML в простейший форт-текст,
  forthml-core.f   -- движок ForthML (набор правил) на простейшем форте.

Поддерживаемая разметка -- см. src/rules-*.xml

SaxonB8 берется на saxon.sourceforge.net

saxonB8.cmd -- батник типа
  @java -cp \your\path\saxon8.jar net.sf.saxon.Transform %*
(положить его куда-удобно в %PATH% )
