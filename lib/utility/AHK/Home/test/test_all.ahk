#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


file := FileOpen("test_tonghuashun_open_close.log", "w")
counter :=0

loop,5
{

counter+=1


runwait, ../open_hexin.ahk

sleep 1000

IfWinExist, 模拟炒股(v8.10.44)
{
log_string=%counter% open tong hua shun pass`r`n
file.write(log_string)
}
else
{
log_string=%counter% open tong hua shun fail`r`n
file.write(log_string)
Msgbox,,,open tonghus shun fail,1
}


;#################################################

file := FileOpen("test_simulator_open_close.log", "w")
counter :=0

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

file.Close()



;################################################

sleep 1000
runwait, ../close_hexin.ahk

;now close the tonghuashun
IfWinExist, 模拟炒股(v8.10.44)
{
	log_string=%counter% close tong hua shun fail`r`n
    file.write(log_string)
    Msgbox,,,close tonghus shun fail,1
}
Else
{
	log_string=%counter% close tong hua shun succ`r`n
    file.write(log_string)	
}

}

file.Close()