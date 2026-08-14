Option Explicit
Dim ws, dir, bat
Set ws = CreateObject("WScript.Shell")

dir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
bat = dir & "ֹͣ-Harness.bat"

ws.Run "cmd /c """ & bat & """" , 0, False

Set ws = Nothing
