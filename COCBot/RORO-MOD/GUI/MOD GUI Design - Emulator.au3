; #FUNCTION# ====================================================================================================================
; Name ..........: War Preparation
; Description ...: This file Includes GUI Design
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Demen
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Global $g_EmulatorSubTab = 0

Func CreateEmulatorSubTab()

	
	Local $x = 15, $y = 40
	GUICtrlCreateGroup("War preration", $x - 10, $y - 15, $g_iSizeWGrpTab3, $g_iSizeHGrpTab3)

   $y = 60

$g_EmulatorSubTab = "My Bot is brought to you by a worldwide team of open source" & @CRLF & _
			"programmers and a vibrant community of forum members!"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 8, $y - 10, 400, 35, $SS_CENTER)
	GUICtrlSetFont(-1, 10, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_NAVY)

	$y += 30
	$g_EmulatorSubTab = "MEMU 2.7.2 :"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 44, $y, 180, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	$g_EmulatorSubTab = GUICtrlCreateLabel("http://cutt.us/SkY9c", $x + 223, $y, 150, 20)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_INFO)	
	
	$y += 20
	$g_EmulatorSubTab = "MEMU  3.6.2.0  :"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 44, $y, 180, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	$g_EmulatorSubTab = GUICtrlCreateLabel("http://cutt.us/9qUTY", $x + 223, $y, 150, 20)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_INFO)
	
	$y += 20
	$g_EmulatorSubTab = "MEMU 2.9.6.1 :"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 44, $y, 180, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	$g_EmulatorSubTab = GUICtrlCreateLabel("http://cutt.us/I6j5J", $x + 223, $y, 150, 20)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_INFO)
	
	$y += 20
	$g_EmulatorSubTab = "MEMU 2.9.3 :"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 44, $y, 180, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	$g_EmulatorSubTab = GUICtrlCreateLabel("http://cutt.us/pByXx", $x + 223, $y, 150, 20)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_INFO)
	
	
	$y += 20
	$g_EmulatorSubTab = "MEMU 2.7.2 :"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 44, $y, 180, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	$g_EmulatorSubTab = GUICtrlCreateLabel("http://cutt.us/SkY9c", $x + 223, $y, 150, 20)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_INFO)
	
	
	$y += 20
	$g_EmulatorSubTab = "MEMU 2.8.6 :"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 44, $y, 180, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	$g_EmulatorSubTab = GUICtrlCreateLabel("http://cutt.us/haxTL", $x + 223, $y, 150, 20)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_INFO)
	
	
	$y += 20
	$g_EmulatorSubTab = "MEMU 2.7.0 :"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 44, $y, 180, 30, $SS_CENTER)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	$g_EmulatorSubTab = GUICtrlCreateLabel("http://cutt.us/E5AyP", $x + 223, $y, 150, 20)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 9.5, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_INFO)
	

EndFunc   ;==>CreateEmulatorSubTab

