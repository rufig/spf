\ Ю. Жиловец http://www.forth.org.ru/~yz

\ Пример использования библиотеки Automate в режиме компиляции
\ Переделка некоторой программы на VB (ее текст см. в конце файла)

REQUIRE [[ ~yz/lib/automate.f

0 VALUE excel
0 VALUE chart

: rotate-excel { adr uu }

ComInit DROP
" Excel.Application" CreateObject . TO excel

excel [[ Visible = TRUE ]]
excel [[ Workbooks Add ]] release
excel [[ ActiveSheet Cells ( 1 , 1 ) Value = 3 ]]
excel [[ ActiveSheet Cells ( 2 , 1 ) Value = 2 ]]
excel [[ ActiveSheet Cells ( 3 , 1 ) Value = 1 ]]
excel [[ Range ( " A1:A3" ) Select ]] DROP
excel [[ Charts Add ]] TO chart
chart [[ Type = -4100 ]]

180 30 DO
  chart [[ Rotation = I ]]
  70 PAUSE
10 +LOOP

1000 PAUSE

excel [[ ActiveWorkBook Close ( FALSE ) ]] DROP
excel [[ Quit ]]

chart release
excel release

ComDestroy
;

S" ActiveSheet" rotate-excel
BYE

\ А вот так это выглядело в Визуальном Бейсике:

\    Dim ExcelApp As Object
\    Dim ExcelChart As Object
\    Dim CharTypeVal As Integer
\    Dim i as Integer
\
\    '-4100 is the value for the Excel constant xl3DColumn. Visual
\    'Basic does not understand Excel constants, so the value must be
\    'used instead.
\    ChartTypeVal = -4100
\
\    'Creates OLE object to Excel
\    Set ExcelApp = CreateObject("excel.application")
\
\    'Sending VB Applications Edition commands to Excel via the new OLE
\    'object to create a new workbook fill in numbers, create the chart, and
\    'rotate the chart.
\
\    ExcelApp.Visible = True
\    ExcelApp.Workbooks.Add
\    ExcelApp.Range("a1").Value = 3
\    ExcelApp.Range("a2").Value = 2
\    ExcelApp.Range("a3").Value = 1
\    ExcelApp.Range("a1:a3").Select
\    Set ExcelChart = ExcelApp.Charts.Add()
\    ExcelChart.Type = ChartTypeVal
\    For i = 30 To 180 Step 10
\        ExcelChart.Rotation = i
\    Next
\
\    ExcelApp.ActiveWorkbook.Close (False)
\    ExcelApp.Quit
\    Set ExcelChart = Nothing
\    Set ExcelApp = Nothing
\    End
\ End Sub

