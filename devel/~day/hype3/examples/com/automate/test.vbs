Dim ForthObj
Set ForthObj = CreateObject("SPF.Example.Automate")

ForthObj.testVar = 12345
ForthObj.testMethod
MsgBox ForthObj.testVar
