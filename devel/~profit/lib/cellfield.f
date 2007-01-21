: __ CELL -- ; \ Ячейка в структуре
: __ALIGN CELL /MOD SWAP IF 1+ THEN CELL * ; \ Выравнивание по ячейке в структуре