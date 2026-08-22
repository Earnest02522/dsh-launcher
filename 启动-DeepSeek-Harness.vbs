Option Explicit
Dim ws, fso, dir, bat
Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
dir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
bat = dir & ChrW(&H542F) & ChrW(&H52A8) & "-DeepSeek-Harness.bat"
If Not fso.FileExists(bat) Then
  MsgBox "Script file not found: " & bat, 16, "DeepSeek Harness Launcher"
  WScript.Quit 1
End If
' run from the script's own folder (defensive against shortcuts/other cwd)
ws.CurrentDirectory = dir
' /d ignores the registry AutoRun entry, which could otherwise interfere;
' show normal window (1), do not wait (False) - the bat opens the browser and closes its window itself
ws.Run "cmd /d /c " & Chr(34) & bat & Chr(34), 1, False
Set ws = Nothing