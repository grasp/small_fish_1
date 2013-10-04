#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;#######################################################
;msgbox,%1%
ifwinnotexist,模拟炒股(v8.10.44)
{
	runwait, open_hexin.ahk
}

;make sure close and reopen 
	runwait, open_simulate.ahk

;########################################################

Winactivate,模拟炒股(v8.10.44)

Winactivate,网上股票交易系统5.0
;#########################################################

ControlSendRaw, [ Control, Keys, WinTitle, WinText, ExcludeTitle, ExcludeText]

send,{F2} 

ControlClick, Edit8,网上股票交易系统5.0
<<<<<<< HEAD
SendInput,{BS}{BS}{BS}{BS}{BS}{BS}{BS}{BS}{BS}{raw}%1%
sleep 1000
ControlGetText,stock_code,Edit8,网上股票交易系统5.0


ControlClick, Edit9,网上股票交易系统5.0
SendInput,{BS}{BS}{BS}{BS}{BS}{BS}{raw}%2%
sleep 1000
ControlGetText,price,Edit9,网上股票交易系统5.0



ControlClick, Edit10,网上股票交易系统5.0
SendInput,{BS}{BS}{BS}{BS}{BS}{BS}{raw}%3%
sleep 1000
ControlGetText,totalnumber,Edit10,网上股票交易系统5.0


if ((stock_code != %1%) or (price <> %2%) or (totalnumber != %totalnumber%))
{
   ControlSend, Button26, {Enter},网上股票交易系统5.0
}
Else
{
	;msgbox, %stock_code%,%price%,%totalnumber% failed
	exit,1
}

WinWaitActive, ahk_class #32770
sleep 500

;MouseClick, left ,181,163
MouseClick, left ,95,168

sleep 500

#IfWinExist, ahk_class #32770,委托确认
{
;MouseClick, left ,181,163
MouseClick, left ,95,168
}

sleep 100
MouseClick, left ,180,160
