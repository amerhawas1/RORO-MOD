; #FUNCTION# ====================================================================================================================
; Name ..........: SwitchBetweenBases
; Description ...: Switches Between Normal Village and Builder Base
; Syntax ........: SwitchBetweenBases()
; Parameters ....:
; Return values .: True: Successfully switched Bases  -  False: Failed to switch Bases
; Author ........: Fliegerfaust (05-2017)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func SwitchBetweenBases($bCheckMainScreen = True)
	Local $sSwitchFrom, $sSwitchTo, $bIsOnBuilderBase = False, $aButtonCoords
	Local $sTile, $sTileDir, $sRegionToSearch

	If Not $g_bRunState Then Return

	If isOnBuilderBase(True) Then
		$sSwitchFrom = "القرية الليليلة"
		$sSwitchTo = "القرية الأم"
		$bIsOnBuilderBase = True
		$sTile = "قارب القرية الليلية"
		$sTileDir = $g_sImgBoatBB
		$sRegionToSearch = "487,44,708,242"
	Else
		$sSwitchFrom = "القرية الأم"
		$sSwitchTo = "القرية الليلية"
		$bIsOnBuilderBase = False
		$sTile = "قارب القرية الأم"
		$sTileDir = $g_sImgBoat
		$sRegionToSearch = "66,432,388,627"
	EndIf

	ZoomOut() ; ensure bot is visible
	$aButtonCoords = decodeSingleCoord(findImageInPlace($sTile, $sTileDir,  $sRegionToSearch))
	If UBound($aButtonCoords) > 1 Then
		SetLog("الذهاب الى " & $sSwitchTo, $COLOR_INFO)
		ClickP($aButtonCoords)
		If _Sleep($DELAYSWITCHBASES1) Then Return

		; switch can take up to 2 Seconds, check for 3 additional Seconds...
		Local $hTimerHandle = __TimerInit()
		Local $bSwitched = False
		While __TimerDiff($hTimerHandle) < 3000 And Not $bSwitched
			_Sleep(250)
			ForceCaptureRegion()
			$bSwitched = isOnBuilderBase(True) <> $bIsOnBuilderBase
		WEnd

		If $bSwitched Then
			;SetLog("Successfully went" & $sBack & " to the " & $sSwitchTo, $COLOR_SUCCESS)
			If $bCheckMainScreen Then checkMainScreen(True, Not $bIsOnBuilderBase)
			Return True
		Else
			SetLog("فشل في الذهاب إلى " & $sSwitchTo, $COLOR_ERROR)
		EndIf
	Else
		If $bIsOnBuilderBase Then
			SetLog("لا يمكن العثور على قارب على الساحل", $COLOR_ERROR)
		Else
			SetLog("لا يمكن العثور على قارب على الساحل. ربما لا تزال مكسورة أو غير مرئية", $COLOR_ERROR)
		EndIf
	EndIf

	Return False
EndFunc   ;==>SwitchBetweenBases
