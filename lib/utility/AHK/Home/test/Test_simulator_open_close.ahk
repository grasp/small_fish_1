#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

file := FileOpen("test_simulator_open_close.log", "w")
counter :=0

<<<<<<< HEAD
loop,5
=======
loop,30
>>>>>>> 63f630c0d37aa6eec026f5eec1496692ec403585
{

counter+=1


runwait, ../open_simulate.ahk

sleep 1000

IfWinExist, 网上股票交易系统5.0
{
log_string=%counter% open simulator pass`r`n
file.write(log_string)
}
else
{
log_string=%counter% open simulator fail`r`n
file.write(log_string)
Msgbox,,,open simulator fail,2
}

runwait, ../close_simulate.ahk
sleep 1000

IfWinNotExist, 网上股票交易系统5.0
{
log_string=%counter% close simulator pass`r`n
file.write(log_string)
}
else
{
log_string=%counter% close simulator fail`r`n
file.write(log_string)
Msgbox,,,close simulator fail,2
}
}

file.Close()
