\ www.forth.org.ru/~yz/lib/automation.f

\ Пример использования библиотеки
\ Переделка некоторой программы на VB (ее текст см. в конце файла)

REQUIRE :: ~yz/lib/automation.f

0 VALUE excel
0 VALUE chart

: make-excel-chart

  COM-init DROP

  " Excel.Application" create-object 
  IF ." Не могу запустить Excel" BYE THEN
  TO excel

  TRUE _bool excel :: Visible !
  
  arg() excel :: WorkBooks Add

  3 _int excel :: ActiveSheet Cells [1,1] Value !
  2 _int excel :: ActiveSheet Cells [2,1] Value !
  1 _int excel :: ActiveSheet Cells [3,1] Value !
\ Можно было сделать и с помощью Range, как в оригинале

  arg() excel :: Range ["A1:A3"] Select
  
  arg() excel :: Charts Add >
  DROP TO chart

  -4100 _int chart :: Type !

  180 30 DO  
    I _int chart :: Rotation !  
    50 PAUSE \ Форт и Бейсик - почувствуйте разницу :-)
  10 +LOOP

  1000 PAUSE

  arg( FALSE _bool )arg excel :: ActiveWorkbook Close
  arg() excel :: Quit

  chart release
  excel release

  COM-destroy ;

make-excel-chart

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

