; #FUNCTION# ====================================================================================================================
; Name ..........: VillageReport
; Description ...: This function will report the village free and total builders, gold, elixir, dark elixir and gems.
;                  It will also update the statistics to the GUI.
; Syntax ........: VillageReport()
; Parameters ....: None
; Return values .: None
; Author ........: Hervidero (2015-feb-10)
; Modified ......: Safar46 (2015), Hervidero (2015), KnowJack (June-2015) , ProMac (2015), Sardo 2015-08, MonkeyHunter(6-2106)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func VillageReport($bBypass = False, $bSuppressLog = False)
	PureClickP($aAway, 1, 0, "#0319") ;Click Away
	If _Sleep($DELAYVILLAGEREPORT1) Then Return

	Switch $bBypass
		Case False
			If Not $bSuppressLog Then SetLog("تقرير عن القرية", $COLOR_INFO)
		Case True
			If Not $bSuppressLog Then SetLog("تحديث قيم موارد القرية", $COLOR_INFO)
		Case Else
			If Not $bSuppressLog Then SetLog("قرية تقرير خطأ ، لقد كنت مبرمجا BAD!", $COLOR_ERROR)
	EndSwitch

	getBuilderCount($bSuppressLog) ; update builder data
	If _Sleep($DELAYRESPOND) Then Return

	; Builder Status - Team AiO MOD++
	If Not $bBypass Then getBuilderTime()

	$g_aiCurrentLoot[$eLootTrophy] = getTrophyMainScreen($aTrophies[0], $aTrophies[1])
	If Not $bSuppressLog Then SetLog(" [كؤؤس]: " & _NumberFormat($g_aiCurrentLoot[$eLootTrophy]), $COLOR_SUCCESS)

	If _CheckPixel($aVillageHasDarkElixir, $g_bCapturePixel) Then ; check if the village have a Dark Elixir Storage
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(696, 23)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(696, 74)
		$g_aiCurrentLoot[$eLootDarkElixir] = getResourcesMainScreen(728, 123)
		$g_iGemAmount = getResourcesMainScreen(740, 171)
		If Not $bSuppressLog Then SetLog(" [ذهب]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [اكسير]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [اكسير الدارك]: " & _NumberFormat($g_aiCurrentLoot[$eLootDarkElixir]) & " [الجواهر]: " & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
	Else
		$g_aiCurrentLoot[$eLootGold] = getResourcesMainScreen(701, 23)
		$g_aiCurrentLoot[$eLootElixir] = getResourcesMainScreen(701, 74)
		$g_iGemAmount = getResourcesMainScreen(719, 123)
		If Not $bSuppressLog Then SetLog(" [ذهب]: " & _NumberFormat($g_aiCurrentLoot[$eLootGold]) & " [اكسير]: " & _NumberFormat($g_aiCurrentLoot[$eLootElixir]) & " [الجواهر]: " & _NumberFormat($g_iGemAmount), $COLOR_SUCCESS)
		If ProfileSwitchAccountEnabled() Then $g_aiCurrentLoot[$eLootDarkElixir] = "" ; prevent applying Dark Elixir of previous account to current account
	EndIf
	If ProfileSwitchAccountEnabled() Then
		$g_aiFreeBuilderCountAcc[$g_iCurAccount] = $g_iFreeBuilderCount
		$g_aiTotalBuilderCountAcc[$g_iCurAccount] = $g_iTotalBuilderCount
		$g_aiTrophyCurrentAcc[$g_iCurAccount] = $g_aiCurrentLoot[$eLootTrophy]
		$g_aiGoldCurrentAcc[$g_iCurAccount] = $g_aiCurrentLoot[$eLootGold]
		$g_aiElixirCurrentAcc[$g_iCurAccount] = $g_aiCurrentLoot[$eLootElixir]
		$g_aiDarkCurrentAcc[$g_iCurAccount] = $g_aiCurrentLoot[$eLootDarkElixir]
		$g_aiGemAmountAcc[$g_iCurAccount] = $g_iGemAmount
    EndIf
	If $bBypass = False Then ; update stats
		UpdateStats()
	EndIf

	Local $i = 0
	While _ColorCheck(_GetPixelColor(819, 39, True), Hex(0xF8FCFF, 6), 20) = True ; wait for Builder/shop to close
		$i += 1
		If _Sleep($DELAYVILLAGEREPORT1) Then Return
		If $i >= 20 Then ExitLoop
	WEnd

EndFunc   ;==>VillageReport

; Builder Status - Team AiO MOD++
Func getBuilderTime()
	Local $iBuilderTime = -1
	Static $sBuilderTimeLastCheck = ""
	Static $asBuilderTimeLastCheck[8] = ["", "", "", "", "", "", "", ""]

	If ProfileSwitchAccountEnabled() Then
		$g_sNextBuilderReadyTime = $g_asNextBuilderReadyTime[$g_iCurAccount]
		$sBuilderTimeLastCheck = $asBuilderTimeLastCheck[$g_iCurAccount]
	EndIf

	If _DateIsValid($sBuilderTimeLastCheck) And _DateIsValid($g_sNextBuilderReadyTime) And Not $g_bFirstStart Then
		Local $iTimeFromLastCheck = Int(_DateDiff('n', $sBuilderTimeLastCheck, _NowCalc())) ; elapse time in minutes
		Local $iTimeTillNextBuilderReady = Int(_DateDiff('n', _NowCalc(), $g_sNextBuilderReadyTime)) ; builder time in minutes

		SetDebugLog("Next Builder will be ready in " & $iTimeTillNextBuilderReady & "m, (" & $g_sNextBuilderReadyTime & ")")
		SetDebugLog("It has been " & $iTimeFromLastCheck & "m since last check (" & $sBuilderTimeLastCheck & ")")

		If $iTimeFromLastCheck <= 6 * 60 And $iTimeTillNextBuilderReady > 0 Then
			SetDebugLog("Next time to check: " & _Min(360 - Number($iTimeFromLastCheck), Number($iTimeTillNextBuilderReady)) & "m")
			Return
		EndIf
	EndIf

	If $g_iFreeBuilderCount >= $g_iTotalBuilderCount Then Return

	SetLog("Getting builder time")

	If IsMainPage() Then Click(293, 32) ; click builder's nose for poping out information
	If _Sleep(1000) Then Return

	Local $sBuilderTime = QuickMIS("OCR", @ScriptDir & "\imgxml\BuilderTime", 335, 102, 335 + 124, 102 + 14, True)
	If $sBuilderTime <> "none" Then
		$iBuilderTime = ConvertOCRLongTime("Builder Time", $sBuilderTime, False)
		SetDebugLog("$sResult QuickMIS OCR: " & $sBuilderTime & " (" & Round($iBuilderTime,2) & " minutes)")
	EndIf

	If $iBuilderTime > 0 Then
		$g_sNextBuilderReadyTime = _DateAdd("n", $iBuilderTime, _NowCalc())
		$sBuilderTimeLastCheck = _NowCalc()
	Else
		$g_sNextBuilderReadyTime = ""
		$sBuilderTimeLastCheck = ""
	EndIf

	If ProfileSwitchAccountEnabled() Then
		$g_asNextBuilderReadyTime[$g_iCurAccount] = $g_sNextBuilderReadyTime
		$asBuilderTimeLastCheck[$g_iCurAccount] = $sBuilderTimeLastCheck
	EndIf

	ClickP($aAway, 2, 0, "#0000") ;Click Away
EndFunc   ;==>getBuilderTime

Func ConvertOCRLongTime($WhereRead, $ToConvert, $bSetLog = True) ; Convert longer time with days - hours - minutes - seconds

	Local $iRemainTimer = 0, $aResult, $iDay = 0, $iHour = 0, $iMinute = 0, $iSecond = 0

	If $ToConvert <> "" Then
		If StringInStr($ToConvert, "d") > 1 Then
			$aResult = StringSplit($ToConvert, "d", $STR_NOCOUNT)
			; $aResult[0] will be the Day and the $aResult[1] will be the rest
			$iDay = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "h") > 1 Then
			$aResult = StringSplit($ToConvert, "h", $STR_NOCOUNT)
			$iHour = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "m") > 1 Then
			$aResult = StringSplit($ToConvert, "m", $STR_NOCOUNT)
			$iMinute = Number($aResult[0])
			$ToConvert = $aResult[1]
		EndIf
		If StringInStr($ToConvert, "s") > 1 Then
			$aResult = StringSplit($ToConvert, "s", $STR_NOCOUNT)
			$iSecond = Number($aResult[0])
		EndIf

		$iRemainTimer = Round($iDay * 24 * 60 + $iHour * 60 + $iMinute + $iSecond / 60, 2)
		If $iRemainTimer = 0 And $g_bDebugSetlog Then SetLog($WhereRead & ": Bad OCR string", $COLOR_ERROR)

		If $bSetLog Then SetLog($WhereRead & " time: " & StringFormat("%.2f", $iRemainTimer) & " min", $COLOR_INFO)

	Else
		If $g_bDebugSetlog Then SetLog("Can not read remaining time for " & $WhereRead, $COLOR_ERROR)
	EndIf
	Return $iRemainTimer
EndFunc   ;==>ConvertOCRLongTime