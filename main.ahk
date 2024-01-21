#NoEnv
#SingleInstance Force

#Include ShinsOverlayClass.ahk

initialise:
{
    global sensitivity := 68.0
    global window_name := "THE FINALS on GeForce NOW"

    global yaw :=  sensitivity * 0.00101
    global m11 := [LoadPattern("M11.txt"), 60, "M11"]
    global xp54 := [LoadPattern("XP54.txt"), 68, "XP54"]
    global akm := [LoadPattern("AKM.txt"), 99, "AKM"]
    global fcar := [LoadPattern("FCAR.txt"), 111, "FCAR"]
    global m60 := [LoadPattern("M60.txt"), 100, "M60"]
    global lewisgun := [LoadPattern("LGUN.txt"), 114, "LGUN"]

    global weapon_list := [m11, xp54, akm, fcar, m60, lewisgun]

    global selected_weapon := 1
    global weapon := weapon_list[selected_weapon]
    global recoil := weapon[1]
    global interval := weapon[2]

    global overlay := new ShinsOverlayClass()
    overlay.AttachToWindow(window_name)

    DrawGUI()
}

~$*LButton::
{

    ;Check for ADS
    If (!GetKeyState("RButton"))
        Return

    ;Loop trough the recoil values
    lMax := recoil.MaxIndex()
    Loop{

        ;Stop if not shooting anymore or pattern ended
        If (!GetKeyState("LButton", "P") || A_Index > (lmax))
            Return

        pattern := recoil[A_Index]

        x := Round(pattern[1])
        y := Round(pattern[2])

        SmoothMove(x, y, interval, 1)
    }
}

;s can be used to smooth mouse movements but can also cause issues due to moving small values
SmoothMove(x, y, t, s)
{
    Loop, % s
    {
        DllCall("mouse_event", uint, 1, int, x/s, int, y/s)
        Sleep, t/s
    }
    Return
}

CycleWeapon(direction)
{
    selected_weapon := (selected_weapon + direction)

    ;Cycle trough gun array
    if (selected_weapon == 0)
    {
        selected_weapon := weapon_list.Length()
    }
    else if (selected_weapon == (weapon_list.Length()+1))
    {
        selected_weapon := 1
    }

    ;Change the weapon variables
    weapon := weapon_list[selected_weapon]
    recoil := weapon[1]
    interval := weapon[2]

    ;Update GUI
    DrawGUI()
}

End::
{
	ExitApp
}

LoadPattern(filename)
{
    FileRead, patternStr, %A_ScriptDir%\patterns\%filename%
    patterns := []
    Loop, Parse, patternStr, `n, `, , `" ,`r
    {

        if StrLen(A_LoopField) == 0
            break

        pattern := StrSplit(A_LoopField, ", ")

        pattern[1] := Round(pattern[1]/yaw)
        pattern[2] := Round(pattern[2]/yaw)

        patterns.Insert(pattern)
    }

    return patterns
}

Right::
Down::
{
    CycleWeapon(1)
    return
}

Left::
Up::
{
    CycleWeapon(-1)
    return
}

DrawGUI()
{
    menu_pos := [50, 50]
    menu_background = 0xFF555555
    text_size := 15
    text_colour := 0xFFFFFFFF
    text_selected := 0xFF00FF00
    text_font := "Arial"

    total_items := weapon_list.Length()

    if (overlay.BeginDraw())
    {

        if (overlay.attachHwnd)
        {
            ; Base rectangle
            overlay.FillRectangle(menu_pos[1], menu_pos[2], 50, text_size*total_items, 0xFF555555)

            ; Dynamic creation based on number of guns
            Loop, % total_items
            {
                c := text_colour
                if (A_Index == selected_weapon)
                {
                    c := text_selected
                }
                overlay.DrawText(weapon_list[A_Index][3], menu_pos[1], menu_pos[2] + text_size * (A_Index - 1),size:=text_size,color:=c,fontName:=text_font)
            }
        }

        overlay.EndDraw()
    }
}