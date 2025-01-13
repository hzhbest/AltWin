;#NoTrayIcon

SetWinDelay,0
CoordMode,Mouse,Screen

;长按左边Alt键时拖动鼠标左键，鼠标下的窗口跟随鼠标移动
~LWin & LButton::

StartTime := A_TickCount
;loop{	;启动延时，超过0.4秒之后才开始移动窗口，避免影响其他Alt键键击
;if A_TickCount - StartTime > 400
;break
;}
MouseGetPos,x,y,win	;获取当前鼠标位置和鼠标下的窗口（延时后的所在窗口，不管是否当前窗口）
WinGetPos,x1,y1,,,ahk_id %win%	;获取鼠标下的窗口位置
WinGet, ismax, MinMax, ahk_id %win%	;检查是否是最大化窗口
WinGetClass, class, ahk_id %win%	;获取窗口id
;OutputDebug, % class="MultitaskingViewFrame"
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

	GetKeyState,var1,LWin,p   	;如果LWin松开了，退出
	GetKeyState,var1,LButton,p   	;如果鼠标左键松开了，退出
	if var1=U
		return
	GetKeyState,var3,Tab,p   	;如果Tab按下（即Alt-Tab），退出
	if var3=D
		return
	; setting ⭐
	Sleep,1   ;延时跟踪下一次位置变动，数字越小越流畅越吃性能
	continue
}

return



;按住左边Alt键时拖动鼠标中键，根据鼠标初始位置随鼠标变动窗口最近角的位置从而改变窗口大小
~LWin & RButton::

minWidth:= 100
minHeight:= 32
; setting ⭐
scaleFactor:= 1.5  ; 添加放大倍数，可以根据需要调整，更大的数字意味着更灵敏的调整

MouseGetPos,mx1,my1,win	;获取当前鼠标位置和鼠标下的窗口（延时后的所在窗口，不管是否当前窗口）
WinGetPos,winx,winy,winw,winh,ahk_id %win%	;获取鼠标下的窗口的位置和宽高
WinGet, ismax, MinMax, ahk_id %win%	;获取窗口最大化状态
;OutputDebug, #AHK#Windows max status is %ismax%
if ismax=1	;如果最大化了，则退出
	return
if (mx1 <= (winx + winw / 2)){	;若点击时鼠标位置位于左半边
	xleft = 1
	wleft = -1
}
else
{
	xleft = 0
	wleft = 1
}
if (my1 <= (winy + winh / 2)){	;若点击时鼠标位置位于上半边
	yup = 1
	hup = -1
}
else
{
	yup = 0
	hup = 1
}

loop{

	GetKeyState,var1,LWin,p   	;循环获取LWin状态，若松开则跳出
	GetKeyState,var1,RButton,p	;循环获取鼠标中键状态，若松开则跳出
	if var1=U
		break

	MouseGetPos,mx2,my2			;获取当前鼠标位置
	newx:= winx + ((mx2 - mx1) * scaleFactor) * xleft	;窗口新x坐标
	newy:= winy + ((my2 - my1) * scaleFactor) * yup		;窗口新y坐标
	neww:= Max(winw + ((mx2 - mx1) * scaleFactor) * wleft, minWidth)	;窗口新宽度
	newh:= Max(winh + ((my2 - my1) * scaleFactor) * hup, minHeight)		;窗口新高度
	WinMove, ahk_id %win%,, %newx%, %newy%, %neww%, %newh%	;以窗口新坐标新尺寸变动窗口

	Sleep,4    ;循环延时4毫秒，相当于240帧
}

return

