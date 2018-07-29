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
Global $g_sLibIconPathMOD = 0
  Global $idPic = 0
Func CreateEmulatorSubTab()

	
	Local $x = 15, $y = 40
	GUICtrlCreateGroup("محاكيات", $x - 10, $y - 15, $g_iSizeWGrpTab3, $g_iSizeHGrpTab3)
   $y = 30
   $g_EmulatorSubTab = "البرامج الاساسية لتشغل البوت بشكل صحيح" & @CRLF & _
			"وبعض المحاكيات التي تدعم البوت بشكل صحيح وجيد جدا" & @CRLF & _
			                   "RORO-MOD مقدم من مطورين"
	GUICtrlCreateLabel($g_EmulatorSubTab, $x + 8, $y + 30  - 10, 400, 50, $SS_CENTER)
	GUICtrlSetFont(-1, 10, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_NAVY)
	
	 
	 Local const $icon = @ScriptDir & "\images\RORO2.bmp"
		GUICtrlCreatePic($icon, $x + 300, $y + 120 , 120, 120, $SS_CENTERIMAGE)
	 
	$g_EmulatorSubTab = " البرامج الاساسية"
   GUICtrlCreateLabel($g_EmulatorSubTab, $x + 125 , $y + 100  - 10, 150, 15, $SS_CENTER)
   GUICtrlSetFont(-1, 10, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_NAVY)
   
   GUICtrlCreateLabel( " VC 2010 ", $x + 20 , $y + 110, 250, 15)
   GUICtrlSetFont(-1, 10, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_NAVY)
   
     $g_EmulatorSubTab = GUICtrlCreateInput("http://v.ht/ROROMOD3", $x + 10, $y + 130, 300, 20, $SS_CENTER)
		 
		 GUICtrlCreateLabel( "NET Framework 4.5  ", $x + 20 , $y + 150, 250, 15)
   GUICtrlSetFont(-1, 10, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_NAVY)
   
     $g_EmulatorSubTab = GUICtrlCreateInput("http://v.ht/ROROMOD1", $x + 10, $y + 165, 300, 20, $SS_CENTER)
		 
		 GUICtrlCreateLabel( "AUTOIT  ", $x + 20 , $y + 185, 250, 15)
   GUICtrlSetFont(-1, 10, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_NAVY)
   
     $g_EmulatorSubTab = GUICtrlCreateInput("http://v.ht/ROROMOD", $x + 10, $y + 200, 300, 20, $SS_CENTER)
		 
		 
		 
		 
		 
		 $g_EmulatorSubTab = " المحاكيات"
   GUICtrlCreateLabel($g_EmulatorSubTab, $x + 125 , $y + 240  - 10, 150, 15, $SS_CENTER)
		 GUICtrlSetFont(-1, 10, $FW_BOLD, Default, "Arial")
	GUICtrlSetColor(-1, $COLOR_NAVY)

	Local const $icon2 = @ScriptDir & "\images\RORO3.bmp"
		GUICtrlCreatePic($icon2, $x + 300, $y + 250 , 120, 120, $SS_CENTERIMAGE)

	

EndFunc   ;==>CreateEmulatorSubTab

