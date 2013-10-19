#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

IfWinExist, 网上股票交易系统5.0

{
	WinClose, 网上股票交易系统5.0
	WinWaitClose, 网上股票交易系统5.0,,5
	;exit,0
}


Winactivate,模拟炒股(v8.10.44)
;WinWaitActive, 模拟炒股(v8.10.44)
sleep 100

;initialize
IfWinExist, 模拟炒股...
{
	winclose,模拟炒股...
}

;click 模拟炒股menu
MouseClick, left , 580, 10
sleep 100

;click 进入模拟交易区
MouseClick, left , 600, 27
WinWait,模拟炒股...

winactivate,模拟炒股...

sleep 500

MouseClick, left , 394, 167
;ControlClick, Button20, 模拟炒股(v8.10.44), , left


IfWinExist, 网上股票交易系统5.0

{
	exit,0
}


loop,3
{
sleep 2000


IfWinExist, 网上股票交易系统5.0

{
	exit,0
}


IfWinExist,模拟炒股...
{
	winactivate,模拟炒股...
	MouseClick, left , 394, 167
	exit,0

}
Else
{
	exit,0
 }
}
