Option Explicit
Dim ws, fso, dir, bat
Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
dir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
bat = dir & ChrW(&H505C) & ChrW(&H6B62) & "-Harness.bat"
If Not fso.FileExists(bat) Then
  MsgBox "Script file not found: " & bat, 16, "DeepSeek Harness Launcher"
  WScript.Quit 1
End If
' show normal window (1), wait until finished (True)
ws.Run "cmd /c " & Chr(34) & bat & Chr(34), 1, True
Set ws = Nothing