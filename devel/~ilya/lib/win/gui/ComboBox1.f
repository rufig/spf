REQUIRE ComboBox  ~nn/lib/win/controls/combobox.f
ComboBox REOPEN
M: Find ( z n -- n )
\ где n - item before start of search
CB_FINDSTRING SendMessage 
;

M: Insert ( a u idx ) NIP CB_INSERTSTRING SendMessage DROP ;
;CLASS

ComboBoxEdit REOPEN
	var OnKillFocus
	var OnSetFocus
C: CBN_KILLFOCUS OnKillFocus GoParent ;
C: CBN_SETFOCUS  OnSetFocus GoParent ;
M: Insert ( a u idx ) NIP CB_INSERTSTRING SendMessage DROP ;
M: Find ( z n -- n )
\ где n - item before start of search
CB_FINDSTRING SendMessage 
;
;CLASS