#Requires AutoHotkey v2.0
TraySetIcon A_ScriptDir "\AltWin.ico"
SetWinDelay(0), CoordMode("Mouse","Screen")

; 移动窗口
~LAlt & LButton::{
    MouseGetPos(&x,&y,&win), WinGetPos(&x1,&y1,,,"ahk_id " win)
    if WinGetMinMax("ahk_id " win)=1 or WinGetClass("ahk_id " win)="MultitaskingViewFrame"
        return
    a:=x1, b:=y1
    Loop {
        MouseGetPos(&x2,&y2)
        WinMove(a+=x2-x, b+=y2-y,,,"ahk_id " win), x:=x2, y:=y2
        if !GetKeyState("LAlt","P") or !GetKeyState("LButton","P") or GetKeyState("Tab","P")
            return
        Sleep(20)
    }
}

; 调整窗口大小
~LAlt & MButton::{
    minW:=100, minH:=32, proximfactor:=1/3
    MouseGetPos(&mx1,&my1,&win), WinGetPos(&wx,&wy,&ww,&wh,"ahk_id " win)
    if WinGetMinMax("ahk_id " win)=1
        return
    xLeft := mx1 <= wx+ww*proximfactor ? 1 : 0, wLeft := xLeft ? -1 : 1
    yUp   := my1 <= wy+wh*proximfactor ? 1 : 0, hUp   := yUp   ? -1 : 1
    Loop {
        if !GetKeyState("LAlt","P") or !GetKeyState("MButton","P")
            break
        MouseGetPos(&mx2,&my2)
        WinMove(wx + (mx2-mx1)*xLeft, wy + (my2-my1)*yUp,
                Max(ww + (mx2-mx1)*wLeft, minW), Max(wh + (my2-my1)*hUp, minH),
                "ahk_id " win)
        Sleep(30)
    }
}

; 变透明 (WheelDown)
~LAlt & WheelDown::{
    MouseGetPos(,,&mwin)
    n := WinGetTransparent("ahk_id " mwin)
    if n = "" || n = "off"
        n := 255
    if n > 26
        WinSetTransparent(n-13, "ahk_id " mwin)
}

; 变不透明 (WheelUp)
~LAlt & WheelUp::{
    MouseGetPos(,,&mwin)
    n := WinGetTransparent("ahk_id " mwin)
    if n = "" || n = "off"
        n := 255
    if n < 255 {
        n += 13
        WinSetTransparent(n>=255 ? "off" : n, "ahk_id " mwin)
    }
}

; 切换置顶
~LAlt & RButton::{
    MouseGetPos(,,&mwin), WinActivate("ahk_id " mwin)
    title := WinGetTitle("A")
    if StrLen(title)>20
        title := SubStr(title,1,20) "…"
    WinSetAlwaysOnTop(-1, "ahk_id " mwin)
    isOnTop := WinGetExStyle("ahk_id " mwin) & 0x8
    ToolTip("【" title "】窗口 " (isOnTop ? "已置顶" : "已取消置顶"))
    Sleep(2000), ToolTip()
}
