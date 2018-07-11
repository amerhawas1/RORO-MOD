
; #FUNCTION# ====================================================================================================================
; Name ..........: chkShieldStatus
; Description ...: Reads Shield & Personal Break time to update global values for user management of Personal Break
; Syntax ........: chkShieldStatus([$bForceChkShield = False[, $bForceChkPBT = False]])
; Parameters ....: $bForceChkShield     - [optional] a boolean value. Default is False.
; ...............; $bForceChkPBT        - [optional] a boolean value. Default is False.
; Return values .: None
; Author ........: MonkeyHunter (2016-02)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func chkShieldStatus($bChkShield = True, $bForceChkPBT = False)

	; skip shield data collection if force single PB, wait for shield, or close while training not enabled, or window is not on main base
	If ($g_bForceSinglePBLogoff = False And ($g_bChkBotStop = True And $g_iCmbBotCond >= 19) = False) And $g_bCloseWhileTrainingEnable = False And Not $g_bRequestTroopsEnableDefense Or Not (IsMainPage()) Then Return

	Local $Result, $iTimeTillPBTstartSec, $ichkTime = 0, $ichkSTime = 0, $ichkPBTime = 0

	If $bChkShield Or $g_asShieldStatus[0] = "" Or $g_asShieldStatus[1] = "" Or $g_asShieldStatus[2] = "" Or $g_sPBStartTime = "" Or $g_bGForcePBTUpdate = True Then ; almost always get shield information

		$Result = getShieldInfo() ; get expire time of shield

		If @error Then SetLog("chkShieldStatus Shield OCR error= " & @error & "Extended= " & @extended, $COLOR_ERROR)
		If _Sleep($DELAYRESPOND) Then Return

		If IsArray($Result) Then
			Local $iShieldExp = _DateDiff('n', $Result[2], _NowCalc())
			If Abs($iShieldExp) > 0 Then
				Local $sFormattedDiff = _Date_Difference(_NowCalc(), $Result[2], 4)
				SetLog("ينتهي الدرع في : " & $sFormattedDiff)
			Else
				SetLog("لا يوجد درع ")
			EndIf

			If _DateIsValid($g_asShieldStatus[2]) Then ; if existing global shield time is valid
				$ichkTime = Abs(Int(_DateDiff('s', $g_asShieldStatus[2], $Result[2]))) ; compare old and new time
				If $ichkTime > 60 Then ; test if more than 60 seconds different in case of attack while shield has reduced time
					$bForceChkPBT = True ; update PB time
					If $g_bDebugSetlog Then SetDebugLog("درع الوقت تغيرت: " & $ichkTime & " Sec, Force PBT OCR: " & $bForceChkPBT, $COLOR_WARNING)
				EndIf
			EndIf

			$g_asShieldStatus = $Result ; update ShieldStatus global values

			If $g_bChkBotStop = True And $g_iCmbBotCond >= 19 Then ; is Halt mode enabled and With Shield selected?
				If $g_asShieldStatus[0] = "shield" Then ; verify shield
					SetLog("وجدت الدرع ، وقف الهجوم الآن!", $COLOR_INFO)
					$g_bWaitShield = True
					$g_bIsClientSyncError = False ; cancel OOS restart to enable BotCommand to process Halt mode
					$g_bIsSearchLimit = False ; reset search limit flag to enable BotCommand to process Halt mode
				Else
					$g_bWaitShield = False
					If $g_bMeetCondStop = True Then
						SetLog("انتهت الدرع ، استئناف الهجوم", $COLOR_INFO)
						$g_bTrainEnabled = True
						$g_bDonationEnabled = True
						$g_bMeetCondStop = False
					Else
						If $g_bDebugSetlog Then SetDebugLog("Halt With Shield: Shield not found...", $COLOR_DEBUG)
					EndIf
				EndIf
			EndIf
		Else
			If $g_bDebugSetlog Then SetDebugLog("Bad getShieldInfo() return value: " & $Result, $COLOR_ERROR)
			If _Sleep($DELAYRESPOND) Then Return

			For $i = 0 To UBound($g_asShieldStatus) - 1 ; clear global shieldstatus if no shield data returned
				$g_asShieldStatus[$i] = ""
			Next

		EndIf
	EndIf

	If $g_bForceSinglePBLogoff = False Then Return ; return if force single PB feature not enabled.

	If _DateIsValid($g_sPBStartTime) Then
		$ichkPBTime = Int(_DateDiff('s', $g_sPBStartTime, _NowCalc())) ; compare existing shield date/time to now.
		If $ichkPBTime >= 295 Then
			$bForceChkPBT = True ; test if PBT date/time in more than 5 minutes past, force update
			If $g_bDebugSetlog Then SetDebugLog("Found old PB time= " & $ichkPBTime & " Seconds, Force update:" & $bForceChkPBT, $COLOR_WARNING)
		EndIf
	EndIf

	If $bForceChkPBT Or $g_bGForcePBTUpdate Or $g_sPBStartTime = "" Then

		$g_bGForcePBTUpdate = False ; Reset global flag to force PB update

		$Result = getPBTime() ; Get time in future that PBT starts

		If @error Then SetLog("chkShieldStatus getPBTime OCR error= " & @error & ", Extended= " & @extended, $COLOR_ERROR)
		;If $g_bDebugSetlog Then SetDebugLog("getPBTime() returned: " & $Result, $COLOR_DEBUG)
		If _Sleep($DELAYRESPOND) Then Return

		If _DateIsValid($Result) Then
			Local $iTimeTillPBTstartMin = Int(_DateDiff('n', $Result, _NowCalc())) ; time in minutes

			If Abs($iTimeTillPBTstartMin) > 0 Then
				Local $sFormattedDiff = _Date_Difference(_DateAdd("n", -1, _NowCalc()), $Result, 4)
				SetLog("يبدأ استراحة الشخصية في: " & $sFormattedDiff)
				Local $CorrectstringPB_GUI = StringReplace($sFormattedDiff, StringInStr($sFormattedDiff, " ساعات ") >= 1 ? " ساعات " : " ساعة ", "ساعة")
				$CorrectstringPB_GUI = StringReplace($CorrectstringPB_GUI, StringInStr($CorrectstringPB_GUI, " دقائق ") >= 1 ? " دقائق " : " دقيقة ", "'")
				$g_aiPersonalBreak[$g_iCurAccount] = $CorrectstringPB_GUI
			Else
				$g_aiPersonalBreak[$g_iCurAccount] = ""
			EndIf

			If $iTimeTillPBTstartMin < -(Int($g_iSinglePBForcedEarlyExitTime)) Then
				$g_sPBStartTime = _DateAdd('دn', -(Int($g_iSinglePBForcedEarlyExitTime)), $Result) ; subtract GUI time setting from PB start time to set early forced break time
			ElseIf $iTimeTillPBTstartMin < 0 Then ; Might have missed it if less 15 min, but try anyway
				$g_sPBStartTime = $Result
			Else
				$g_sPBStartTime = "" ; clear value, can not log off ealy.
			EndIf
			If $g_bDebugSetlog Then SetDebugLog("وقت تسجيل الخروج المبكر=" & $g_sPBStartTime & ", في " & _DateDiff('n', $g_sPBStartTime, _NowCalc()) & " دقائق", $COLOR_DEBUG)
		Else
			SetLog("Bad getPBTtime() return value: " & $Result, $COLOR_ERROR)
			$g_sPBStartTime = "" ; reset to force update next pass
			$g_aiPersonalBreak[$g_iCurAccount] = ""
		EndIf
	EndIf

	If checkObstacles() Then checkMainScreen(False) ; Check for screen errors

EndFunc   ;==>chkShieldStatus

; Returns formatted difference between two dates
; $iGrain from 0 To 5, to control level of detail that is returned
Func _Date_Difference($sStartDate, Const $sEndDate, Const $iGrain)
	Local $aUnit[6] = ["سنة", "شهر", "يوم", "ساعة", "دقيقة", "ثانية"]
	Local $aType[6] = ["سنة", "شهر", "يوم", "ساعة", "دقيقة", "ثانية"]
	Local $sReturn = "", $iUnit

	For $i = 0 To $iGrain
		$iUnit = _DateDiff($aUnit[$i], $sStartDate, $sEndDate)
		If $iUnit <> 0 Then
			$sReturn &= $iUnit & " " & $aType[$i] & ($iUnit > 1 ? "s" : "") & " "
		EndIf
		$sStartDate = _DateAdd($aUnit[$i], $iUnit, $sStartDate)
	Next

	Return $sReturn
EndFunc   ;==>_Date_Difference
