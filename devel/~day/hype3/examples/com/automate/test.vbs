Dim ForthObj
Set ForthObj = CreateObject("SPF.Example.Automate")


MsgBox "A string from forth word: " & ForthObj.testMethod1
MsgBox "A signed byte from forth word: " & ForthObj.testMethod2
MsgBox "A result of forth math function: " & ForthObj.testMethod3(3.14, 3.14)
MsgBox "Forth string concatenation: " & ForthObj.testMethod4("Forth","+","automation")

ForthObj.testVar = 12345
MsgBox "A 16 bit value, stored in forth variable: " & ForthObj.testVar
