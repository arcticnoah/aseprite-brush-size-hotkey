; Very simple AHK script that tries to replicate the behaviour of WispY's AseBrush Java applet, as shown in
; AdamCYounis' awesome Aseprite Crash Course video! YouTube link here: https://youtu.be/59Y6OTzNrhk


; -= How to use this =-
; Hold the 'D' key and move your mouse/pen in either the X or Y axis (depending what you've set in the config below)
; to adjust the size of the brush!


; -= Config =-
; when true, it'll check the x axis of the mouse, if false, it'll instead use the y axis
check_x_axis := true

; the time interval for when the mouse position is checked (in milliseconds).
; lower means more sensitive/speedy and higher means less sensitive/speedy
tick_rate = 15

; amount of pixels the mouse moved during the hotkey being used, to check if the mouse moved
; less than this value, meaning it'll send the usual input
normal_key_threshold = 4

; -= Main Script =-
enable_hotkey := true
start_mouse_pos_x = 0
start_mouse_pos_y = 0
previous_tick_mouse_pos_x = 0
previous_tick_mouse_pos_y = 0

UpdateBrushSize()
{
    global check_x_axis
    global previous_tick_mouse_pos_x
    global previous_tick_mouse_pos_y

    MouseGetPos, current_tick_mouse_pos_x, current_tick_mouse_pos_y

    ; Mouse position difference since last tick
    If check_x_axis {
        ; Checking X axis
        mouse_pos_difference := current_tick_mouse_pos_x - previous_tick_mouse_pos_x
    }
    Else {
        ; Checking Y axis
        mouse_pos_difference := current_tick_mouse_pos_y - previous_tick_mouse_pos_y
    }

    If (mouse_pos_difference != 0 && mouse_pos_difference > 0)
        ; Mouse position has increased, increase brush size (CTRL + Scroll Wheel Down)
        SendInput {Text}+
    Else If (mouse_pos_difference != 0 && mouse_pos_difference < 0)
        ; Mouse position has decreased, decrease brush size (CTRL + Scroll Wheel Up)
        SendInput {Text}-
}

; CTRL + ALT + D shortcut to toggle pause the script's functionality
#IfWinActive ahk_exe Aseprite.exe
^!d up::
    global enable_hotkey

    enable_hotkey := !enable_hotkey
Return

; You can change this key to whatever you want, just make sure to change it on line 68 as well
#IfWinActive ahk_exe Aseprite.exe
d::
    global enable_hotkey

    If enable_hotkey {
        MouseGetPos, start_mouse_pos_x, start_mouse_pos_y
        MouseGetPos, previous_tick_mouse_pos_x, previous_tick_mouse_pos_y

        SetTimer, checkMousePos, %tick_rate%
    }
Return

; If you do change the key, make sure to keep the suffix 'up' and the 
d up::
    ; Disable hotkey timer
    SetTimer, checkMousePos, off

    ; Mouse position difference since start of hotkey
    If check_x_axis {
        ; Checking X axis
        mouse_pos_difference := Abs(start_mouse_pos_x - previous_tick_mouse_pos_x)
    }
    Else {
        ; Checking Y axis
        mouse_pos_difference := Abs(start_mouse_pos_y - previous_tick_mouse_pos_y)
    }

    ; Check if the mouse moved past the threshold whilst the key was pressed
    If (mouse_pos_difference < normal_key_threshold)
        ; Didn't move, send the key as per usual
        SendInput {Text}d
Return

; Hotkey timer tick function, called every tick whilst the hotkey is pressed
checkMousePos:
    global previous_tick_mouse_pos_x
    global previous_tick_mouse_pos_y

    UpdateBrushSize()

    MouseGetPos, local_x, local_y
    previous_tick_mouse_pos_x := local_x
    previous_tick_mouse_pos_y := local_y
Return
