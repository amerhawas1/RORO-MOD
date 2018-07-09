; #FUNCTION# ====================================================================================================================
; Name ..........: Boost any sstructure (King, Queen, Warden, Barracks, Spell Factory)
; Description ...:
; Syntax ........: BoostStructure($sName, $sOcrName, $aPos, ByRef $icmbBoostValue, $cmbBoostCtrl)
; Parameters ....:
; Return values .: True if boosted, False if not
; Author ........: Cosote Oct. 2016
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostStructure($sName, $sOcrName, $aPos, ByRef $icmbBoostValue, $cmbBoostCtrl)
	Local $boosted = False
	Local $ok = False

	If UBound($aPos) > 1 And $aPos[0] > 0 And $aPos[1] > 0 Then
		BuildingClickP($aPos, "#0462")
		If _Sleep($DELAYBOOSTHEROES2) Then Return
		ForceCaptureRegion()
		Local $aResult = BuildingInfo(242, 520 + $g_iBottomOffsetY)
		If $aResult[0] > 1 Then
			Local $sN = $aResult[1] ; Store bldg name
			Local $sL = $aResult[2] ; Sotre bdlg level
			If $sOcrName = "" Or StringInStr($sN, $sOcrName, $STR_NOCASESENSEBASIC) > 0 Then
				; Structure located
				SetLog("تسريع " & $sN & " (لفل " & $sL & ") تقع في " & $aPos[0] & ", " & $aPos[1])
				$ok = True
			Else
				SetLog("لا يمكن التسريع " & $sN & " (لفل " & $sL & ") تقع في  " & $aPos[0] & ", " & $aPos[1], $COLOR_ERROR)
			EndIf
		EndIf
	EndIf

	If $ok = True Then
		Local $Boost = findButton("BoostOne")
		If IsArray($Boost) Then
			If $g_bDebugSetlog Then SetDebugLog("Boost Button X|Y = " & $Boost[0] & "|" & $Boost[1], $COLOR_DEBUG)
			Click($Boost[0], $Boost[1], 1, 0, "#0463")
			If _Sleep($DELAYBOOSTHEROES1) Then Return
			$Boost = findButton("GEM")
			If IsArray($Boost) Then
				Click($Boost[0], $Boost[1], 1, 0, "#0464")
				If _Sleep($DELAYBOOSTHEROES4) Then Return
				If IsArray(findButton("EnterShop")) Then
					SetLog("لا يوجد جواهر كافية للتسريع " & $sName, $COLOR_ERROR)
				Else
					If $icmbBoostValue <= 24 Then
						$icmbBoostValue -= 1
						SetLog($sName & ' اكتمل التسريع . باقي التكرار: ' & $icmbBoostValue, $COLOR_SUCCESS)
						_GUICtrlComboBox_SetCurSel($cmbBoostCtrl, $icmbBoostValue)
					Else
						SetLog($sName & ' اكتمل التسريع ..بافي عدد المرات عير محدود', $COLOR_SUCCESS)
					EndIf
					$boosted = True
				EndIf
			Else
				SetLog($sName & " حاليا التسريع يعمل", $COLOR_SUCCESS)
			EndIf
			If _Sleep($DELAYBOOSTHEROES3) Then Return
			ClickP($aAway, 1, 0, "#0465")
		Else
			SetLog($sName & " لا يمكن العثور على نافذة التسريع", $COLOR_ERROR)
			If _Sleep($DELAYBOOSTHEROES4) Then Return
		EndIf
	Else
		SetLog("تسريع سيء " & $sName & ", الموقع سيء", $COLOR_ERROR)
	EndIf

	Return $boosted
EndFunc   ;==>BoostStructure

Func AllowBoosting($sName, $icmbBoost)

	If ($g_bTrainEnabled = True And $icmbBoost > 0) = False Then Return False

	Local $hour = StringSplit(_NowTime(4), ":", $STR_NOCOUNT)
	If $g_abBoostBarracksHours[$hour[0]] = False Then
		SetLog("تسريع " & $sName & " لم يتم تخطيطه وتخطي ...", $COLOR_SUCCESS)
		Return False
	EndIf

	Return True

EndFunc   ;==>AllowBoosting

