#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2


;username and password must be saved in login window before run this!!!

;dont open if already exsit
IfWinExist, 模拟炒股(v8.10.44)
{
 ;exit,0
 winclose,模拟炒股(v8.10.44)
 WinWaitClose,模拟炒股(v8.10.44),,3
 sleep 2000
}

start_hexin()
{
;close exsisted window
  if winexist,登录到中国电信行情主站
  {
    winclose,登录到中国电信行情主站
    WinWaitClose,登录到中国电信行情主站,,3
    sleep 2000
  }

  run C:\同花顺软件\同花顺免费模拟炒股软件\hexin.exe
  ;wait 5 second
  WinWaitActive, 登录到中国电信行情主站,,5	

  IfWinNotExist, 登录到中国电信行情主站
  {
  	; try run TryAgain
  	run C:\同花顺软件\同花顺免费模拟炒股软件\hexin.exe
  ;wait 5 second
    WinWaitActive, 登录到中国电信行情主站,,5

	;this will fail? is not accetable
	;Exit,1
  }
}

control_click()
{
ControlClick , Button2, 登录到中国电信行情主站, , left, 1

WinWaitActive, 模拟炒股(v8.10.44), , 5


sleep 2000

IfWinNotExist, 模拟炒股(v8.10.44)
{
	;try click again if miss in the first Time
	loop 3
	{
	ControlClick , Button2, 登录到中国电信行情主站, , left, 1
	WinWaitActive, 模拟炒股(v8.10.44), , 3
	IfWinExist, 模拟炒股(v8.10.44)
    {
      exit,0
    }
     }
     ;this is not accetable
	 ;Exit,1
}
;exit with success
IfWinExist, 模拟炒股(v8.10.44)
{
 exit,0
}

}


start_hexin()
control_click()


IfWinExist, 模拟炒股(v8.10.44)
{
 exit,0
}
Else
{
;we hope not to here, but for sure, we can try to open again
start_hexin()
control_click()
}

;at last , we have to report fail
IfWinNotExist, 模拟炒股(v8.10.44)
{
	exit,1
}
