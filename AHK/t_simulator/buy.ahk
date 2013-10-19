#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;some times , long time open will have to input password
;#################################################
SendMode Input


;msgbox,%1%
ifwinnotexist,模拟炒股(v8.10.44)
{
	runwait, open_hexin.ahk
}

;ifwinnotexist,网上股票交易系统5.0
;{
	runwait, open_simulate.ahk
;}
;################################################

Winactivate,模拟炒股(v8.10.44)

Winactivate,网上股票交易系统5.0

;WinMaximize, 网上股票交易系统5.0
WinWaitActive, 网上股票交易系统5.0,,3
;################################################
SetKeyDelay ,100,10

ControlSendRaw, [ Control, Keys, WinTitle, WinText, ExcludeTitle, ExcludeText]

send,{F1} 
WinWaitActive, 网上股票交易系统5.0,,3
;ControlGetText,abc,Edit1,网上股票交易系统5.0
;msgbox,1%abc%
;ControlClick, Edit1,网上股票交易系统5.0
MouseClick, left, 300, 123
SendInput,{BS}{BS}{BS}{BS}{BS}{BS}{BS}{BS}{BS}%1%
sleep 1000
ControlGetText,stock_code,Edit1,网上股票交易系统5.0
;sleep 1000

MouseClick, left, 285, 160
;sleep 300
SendInput ,{BS}{BS}{BS}{BS}{BS}{BS}%2%
sleep 1000
ControlGetText,price,Edit2,网上股票交易系统5.0

;sleep 1000
MouseClick, left, 283, 194
;sleep 300
SendInput ,{BS}{BS}{BS}{BS}{BS}{BS}{raw}%3%
sleep 1000
ControlGetText,totalnumber,Edit3,网上股票交易系统5.0

;msgbox,%stock_code%,%price%,%totalnumber%

if ((stock_code != %1%) or (price != %2% )or (totalnumber != %totalnumber%))
{
	ControlSend, Button8, {Enter},网上股票交易系统5.0
}
Else
{
	;msgbox, %stock_code%,%price%,%totalnumber% failed
	exit,1
}

WinWait, ahk_class #32770, , 5

;sleep 1000
ControlSend, Button1, {Enter},ahk_class #32770
WinWait, ahk_class #32770, , 5
ControlSend, Static1, {Enter},ahk_class #32770

exit,0