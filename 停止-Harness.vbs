Option Explicit
Dim ws, dir, bat
Set ws = CreateObject("WScript.Shell")
On Error Resume Next
dir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
bat = dir & "ֹͣ-Harness.bat"
' show normal window (1), wait until finished (True)
ws.Run "cmd /c " & Chr(34) & bat & Chr(34), 1, True
Set ws = Nothing
