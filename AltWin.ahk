Menu, Tray, Icon, %A_ScriptDir%\AltWin.ico
;#NoTrayIcon

SetWinDelay,0
CoordMode,Mouse,Screen

;长按左边Alt键时拖动鼠标左键，鼠标下的窗口跟随鼠标移动
~LAlt & LButton::

StartTime := A_TickCount

MouseGetPos,x,y,win	;获取当前鼠标位置和鼠标下的窗口（延时后的所在窗口，不管是否当前窗口）
WinGetPos,x1,y1,,,ahk_id %win%	;获取鼠标下的窗口位置
WinGet, ismax, MinMax, ahk_id %win%	;检查是否是最大化窗口
WinGetClass, class, ahk_id %win%	;获取窗口id
if (class="MultitaskingViewFrame")	;如果窗口是Win10的任务切换窗口
{
	MouseGetPos,x,y,win
	Click, %x%,%y%	;发送点击，模拟不触发脚本的效果并退出
	return
}
;OutputDebug, #AHK#Windows max status is %ismax%
if ismax=1	;如果是最大化窗口，则退出
	return
a=%x1%		;存起窗口位置
b=%y1%

loop{

	MouseGetPos,x2,y2	;循环获取当前鼠标位置
	c=%x2%		;存起当前鼠标位置
	d=%y2%
	c-=%x%		;转换为与初始鼠标位置的差
	d-=%y%
	a+=%c%		;将窗口位置加上这个差，存起
	b+=%d%
	x=%x2%		;将新的鼠标位置存为初始位置
	y=%y2%
	WinMove,ahk_id %win%,,%a%,%b%	;移动该窗口到新位置

	GetKeyState,var1,LAlt,p   	;如果LAlt松开了，退出
	if var1=U
		return
	GetKeyState,var1,LButton,p   	;如果鼠标左键松开了，退出
	if var1=U
		return
	GetKeyState,var3,Tab,p   	;如果Tab按下（即Alt-Tab），退出
	if var3=D
		return

	Sleep,20	;延时20毫秒再跟踪下一次位置变动（即50帧分辨率）
	continue
}

return



;按住左边Alt键时拖动鼠标中键，根据鼠标初始位置选择窗口最近角，随鼠标移动改变窗口大小
;改版：自定义鼠标多“近”左／上才视为调整左／上边框的比例系数proximfactor
~LAlt & MButton::

minWidth:= 100
minHeight:= 32
proximfactor:= 1/3			;设为1/3表示靠左1/3窗口宽时调整左边框、靠上1/3窗口高时调整上边框

MouseGetPos,mx1,my1,win	;获取当前鼠标位置和鼠标下的窗口（点击位置下的窗口，不管是否当前窗口）
WinGetPos,winx,winy,winw,winh,ahk_id %win%	;获取鼠标下的窗口的位置和宽高
WinGet, ismax, MinMax, ahk_id %win%	;获取窗口最大化状态
if ismax=1	;如果窗口最大化，则退出（忽略）
	return
if (mx1 <= (winx + winw * proximfactor)){	;若点击时鼠标位置近左边
	xleft = 1
	wleft = -1
}
else
{
	xleft = 0
	wleft = 1
}
if (my1 <= (winy + winh * proximfactor)){	;若点击时鼠标位置近上边
	yup = 1
	hup = -1
}
else
{
	yup = 0
	hup = 1
}

loop{

	GetKeyState,var1,LAlt,p   	;循环获取LAlt状态，若松开则跳出
	if var1=U
		break
	GetKeyState,var1,MButton,p	;循环获取鼠标中键状态，若松开则跳出
	if var1=U
		break

	MouseGetPos,mx2,my2			;获取当前鼠标位置
	newx:= winx + (mx2 - mx1) * xleft	;窗口新x坐标
	newy:= winy + (my2 - my1) * yup		;窗口新y坐标
	neww:= Max(winw + (mx2 - mx1) * wleft, minWidth)	;窗口新宽度
	newh:= Max(winh + (my2 - my1) * hup, minHeight)		;窗口新高度
	WinMove, ahk_id %win%,, %newx%, %newy%, %neww%, %newh%	;以窗口新坐标新尺寸变动窗口

	Sleep,30	;循环延时30毫秒，相当于33帧
}

return


;按住左边Alt键时向下滚动鼠标滚轮，增加鼠标下方窗口透明度，变透明
~LAlt & WheelDown::
MouseGetPos, mx, my, mwin
WinGetClass, class, ahk_id %mwin%	;获取窗口id
;OutputDebug, % class="MultitaskingViewFrame"
if (class="MultitaskingViewFrame")	;如果窗口是Win10的任务切换窗口
{
	return							;不再进行透明度调整
}

WinGet, n, Transparent, ahk_id %mwin%
if (n = "")
{
	n := 255
}
;WinGetActiveStats, mt, mw, mh, X, Y
;if (my < 32 and my > 0 and mx > 0 and mx < mw and n > 26) ;仅在标题栏起作用
if (n > 26)
{
	n -= 13
	WinSet, Transparent, %n%, ahk_id %mwin%
}
return

;按住左边Alt键时向上滚动鼠标滚轮，减少鼠标下方窗口透明度，变不透明
~LAlt & WheelUp::
WinGet, n, Transparent, ahk_id %mwin%
WinGetClass, class, ahk_id %mwin%	;获取窗口id
;OutputDebug, % class="MultitaskingViewFrame"
if (class="MultitaskingViewFrame")	;如果窗口是Win10的任务切换窗口
{
	return							;不再进行透明度调整
}
;WinGetActiveStats, mt, mw, mh, X, Y
;if (my < 32 and my > 0 and mx > 0 and mx < mw and n < 255 and n <> "")
if (n < 255 and n <> "")
{
	n += 13
	if (n >= 255)
	{
		n := "off"
	}
	WinSet, Transparent, %n%, ahk_id %mwin%
}
return

;按住左边Alt键时按右键切换置顶
~LAlt & RButton::
MouseGetPos, mx, my, mwin
;WinGetPos, x, y, mw, , ahk_id %mwin%
;if (my > y and my < y + 32 and mx > x and mx < x + mw)
;{
	WinActivate ahk_id %mwin%
	WinGetTitle mwint, A
	If (StrLen(mwint)>20){
		mwint := SubStr(mwint, 1, 20) "…"
	}
	WinSet, AlwaysOnTop, Toggle, ahk_id %mwin%
	WinGet, isontop, ExStyle, ahk_id %mwin%
	if (isontop & 0x8){
		strontopp := "■ 窗口【"
		strontop := "】 已置顶"
	} else {
		strontopp := "□ 窗口〖"
		strontop := "〗 已取消置顶"
	}
	ToolTip, %strontopp% %mwint% %strontop%
	Sleep, 2000
	ToolTip
;}
return

