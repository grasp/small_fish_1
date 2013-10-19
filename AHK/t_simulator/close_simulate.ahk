#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


ifwinnotexist, 网上股票交易系统5.0
{
	exit,0s
}

winactivate, 模拟炒股(v8.10.44)
sleep 1000

IfWinExist, 网上股票交易系统5.0
{
 WinClose, 网上股票交易系统5.0
}

 
