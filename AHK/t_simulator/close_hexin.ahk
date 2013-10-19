#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

IfWinNotExist,模拟炒股(v8.10.44)
{
	exit,0
}

WinClose ,模拟炒股(v8.10.44)
WinWaitClose,模拟炒股(v8.10.44),5

sleep 3000

IfWinExist, 模拟炒股(v8.10.44)
{
	exit,1
}

exit,0