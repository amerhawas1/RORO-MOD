; #FUNCTION# ====================================================================================================================
; Name ..........: AttackReport
; Description ...: This function will report the loot from the last Attack: gold, elixir, dark elixir and trophies.
;                  It will also update the statistics to the GUI (Last Attack).
; Syntax ........: AttackReport()
; Parameters ....: None
; Return values .: None
; Author ........: Hervidero (02-2015), Sardo (05-2015), Hervidero (12-2015)
; Modified ......: Sardo (05-2015), Hervidero (05-2015), Knowjack (07-2015)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2018
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func AttackReport()
	Static $iBonusLast = 0 ; last attack Bonus percentage
	Local $g_asLeagueDetailsShort = ""
	Local $iCount

	$iCount = 0 ; Reset loop counter
	While _CheckPixel($aEndFightSceneAvl, True) = False ; check for light gold pixle in the Gold ribbon in End of Attack Scene before reading values
		$iCount += 1
		If _Sleep($DELAYATTACKREPORT1) Then Return
		If $g_bDebugSetlog Then SetDebugLog("تقرير الهجوم جاهز, " & ($iCount / 2) & " ثواني.", $COLOR_DEBUG)
		If $iCount > 30 Then ExitLoop ; wait 30*500ms = 15 seconds max for the window to render
	WEnd
	If $iCount > 30 Then SetLog("نهاية الهجوم, قد لا تكون قيم الهجوم صحيحة", $COLOR_INFO)

	$iCount = 0 ; reset loop counter
	While getResourcesLoot(290, 289 + $g_iMidOffsetY) = "" ; check for gold value to be non-zero before reading other values as a secondary timer to make sure all values are available
		$iCount += 1
		If _Sleep($DELAYATTACKREPORT1) Then Return
		If $g_bDebugSetlog Then SetDebugLog("تقرير الهجوم جاهز, " & ($iCount / 2) & " ثواني.", $COLOR_DEBUG)
		If $iCount > 20 Then ExitLoop ; wait 20*500ms = 10 seconds max before we have call the OCR read an error
	WEnd
	If $iCount > 20 Then SetLog("نهاية الهجوم, قد لا تكون قيم الهجوم صحيحة", $COLOR_INFO)

	If _ColorCheck(_GetPixelColor($aAtkRprtDECheck[0], $aAtkRprtDECheck[1], True), Hex($aAtkRprtDECheck[2], 6), $aAtkRprtDECheck[3]) Then ; if the color of the DE drop detected
		$g_iStatsLastAttack[$eLootGold] = getResourcesLoot(290, 289 + $g_iMidOffsetY)
		If _Sleep($DELAYATTACKREPORT2) Then Return
		$g_iStatsLastAttack[$eLootElixir] = getResourcesLoot(290, 328 + $g_iMidOffsetY)
		If _Sleep($DELAYATTACKREPORT2) Then Return
		$g_iStatsLastAttack[$eLootDarkElixir] = getResourcesLootDE(365, 365 + $g_iMidOffsetY)
		If _Sleep($DELAYATTACKREPORT2) Then Return
		$g_iStatsLastAttack[$eLootTrophy] = getResourcesLootT(403, 402 + $g_iMidOffsetY)
		If _ColorCheck(_GetPixelColor($aAtkRprtTrophyCheck[0], $aAtkRprtTrophyCheck[1], True), Hex($aAtkRprtTrophyCheck[2], 6), $aAtkRprtTrophyCheck[3]) Then
			$g_iStatsLastAttack[$eLootTrophy] = -$g_iStatsLastAttack[$eLootTrophy]
		EndIf
		SetLog("النهب: [ذهب]: " & _NumberFormat($g_iStatsLastAttack[$eLootGold]) & " [اكسير]: " & _NumberFormat($g_iStatsLastAttack[$eLootElixir]) & " [اكسير الدارك]: " & _NumberFormat($g_iStatsLastAttack[$eLootDarkElixir]) & " [الكؤؤس]: " & $g_iStatsLastAttack[$eLootTrophy], $COLOR_SUCCESS)
	Else
		$g_iStatsLastAttack[$eLootGold] = getResourcesLoot(290, 289 + $g_iMidOffsetY)
		If _Sleep($DELAYATTACKREPORT2) Then Return
		$g_iStatsLastAttack[$eLootElixir] = getResourcesLoot(290, 328 + $g_iMidOffsetY)
		If _Sleep($DELAYATTACKREPORT2) Then Return
		$g_iStatsLastAttack[$eLootTrophy] = getResourcesLootT(403, 365 + $g_iMidOffsetY)
		If _ColorCheck(_GetPixelColor($aAtkRprtTrophyCheck[0], $aAtkRprtTrophyCheck[1], True), Hex($aAtkRprtTrophyCheck[2], 6), $aAtkRprtTrophyCheck[3]) Then
			$g_iStatsLastAttack[$eLootTrophy] = -$g_iStatsLastAttack[$eLootTrophy]
		EndIf
		$g_iStatsLastAttack[$eLootDarkElixir] = ""
		SetLog("النهب: [ذهب]: " & _NumberFormat($g_iStatsLastAttack[$eLootGold]) & " [اكسير]: " & _NumberFormat($g_iStatsLastAttack[$eLootElixir]) & " [الكؤؤس]: " & $g_iStatsLastAttack[$eLootTrophy], $COLOR_SUCCESS)
	EndIf

	If $g_iStatsLastAttack[$eLootTrophy] >= 0 Then
		$iBonusLast = Number(getResourcesBonusPerc(570, 309 + $g_iMidOffsetY))
		If $iBonusLast > 0 Then
			SetLog("نسبة المكافأة: " & $iBonusLast & "%")
			Local $iCalcMaxBonus = 0, $iCalcMaxBonusDark = 0

			If _ColorCheck(_GetPixelColor($aAtkRprtDECheck2[0], $aAtkRprtDECheck2[1], True), Hex($aAtkRprtDECheck2[2], 6), $aAtkRprtDECheck2[3]) Then
				If _Sleep($DELAYATTACKREPORT2) Then Return
				$g_iStatsBonusLast[$eLootGold] = getResourcesBonus(590, 340 + $g_iMidOffsetY)
				$g_iStatsBonusLast[$eLootGold] = StringReplace($g_iStatsBonusLast[$eLootGold], "+", "")
				If _Sleep($DELAYATTACKREPORT2) Then Return
				$g_iStatsBonusLast[$eLootElixir] = getResourcesBonus(590, 371 + $g_iMidOffsetY)
				$g_iStatsBonusLast[$eLootElixir] = StringReplace($g_iStatsBonusLast[$eLootElixir], "+", "")
				If _Sleep($DELAYATTACKREPORT2) Then Return
				$g_iStatsBonusLast[$eLootDarkElixir] = getResourcesBonus(621, 402 + $g_iMidOffsetY)
				$g_iStatsBonusLast[$eLootDarkElixir] = StringReplace($g_iStatsBonusLast[$eLootDarkElixir], "+", "")

				If $iBonusLast = 100 Then
					$iCalcMaxBonus = $g_iStatsBonusLast[$eLootGold]
					SetLog("المكافاة [ذهب]: " & _NumberFormat($g_iStatsBonusLast[$eLootGold]) & " [اكسير]: " & _NumberFormat($g_iStatsBonusLast[$eLootElixir]) & " [اكسير الدارك]: " & _NumberFormat($g_iStatsBonusLast[$eLootDarkElixir]), $COLOR_SUCCESS)
				Else
					$iCalcMaxBonus = Ceiling($g_iStatsBonusLast[$eLootGold] / ($iBonusLast / 100))
					$iCalcMaxBonusDark = Ceiling($g_iStatsBonusLast[$eLootDarkElixir] / ($iBonusLast / 100))

					SetLog("المكافاة [ذهب]: " & _NumberFormat($g_iStatsBonusLast[$eLootGold]) & " بعيدا " & _NumberFormat($iCalcMaxBonus) & " [اكسير]: " & _NumberFormat($g_iStatsBonusLast[$eLootElixir]) & " بعيدا " & _NumberFormat($iCalcMaxBonus) & " [اكسير الدراك]: " & _NumberFormat($g_iStatsBonusLast[$eLootDarkElixir]) & " بعيدا " & _NumberFormat($iCalcMaxBonusDark), $COLOR_SUCCESS)
				EndIf
			Else
				If _Sleep($DELAYATTACKREPORT2) Then Return
				$g_iStatsBonusLast[$eLootGold] = getResourcesBonus(590, 340 + $g_iMidOffsetY)
				$g_iStatsBonusLast[$eLootGold] = StringReplace($g_iStatsBonusLast[$eLootGold], "+", "")
				If _Sleep($DELAYATTACKREPORT2) Then Return
				$g_iStatsBonusLast[$eLootElixir] = getResourcesBonus(590, 371 + $g_iMidOffsetY)
				$g_iStatsBonusLast[$eLootElixir] = StringReplace($g_iStatsBonusLast[$eLootElixir], "+", "")
				$g_iStatsBonusLast[$eLootDarkElixir] = 0

				If $iBonusLast = 100 Then
					$iCalcMaxBonus = $g_iStatsBonusLast[$eLootGold]
					SetLog("المكافاة [ذهب]: " & _NumberFormat($g_iStatsBonusLast[$eLootGold]) & " [اكسير]: " & _NumberFormat($g_iStatsBonusLast[$eLootElixir]), $COLOR_SUCCESS)
				Else
					$iCalcMaxBonus = Number($g_iStatsBonusLast[$eLootGold] / ($iBonusLast / 100))
					SetLog("المكافاة [ذهب]: " & _NumberFormat($g_iStatsBonusLast[$eLootGold]) & " بعيدا " & _NumberFormat($iCalcMaxBonus) & " [اكسير]: " & _NumberFormat($g_iStatsBonusLast[$eLootElixir]) & " بعيدا " & _NumberFormat($iCalcMaxBonus), $COLOR_SUCCESS)
				EndIf
			EndIf

			$g_asLeagueDetailsShort = "--"
			For $i = 1 To 21 ; skip 0 = Bronze III, see "No Bonus" else section below
				If _Sleep($DELAYATTACKREPORT2) Then Return
				If $g_asLeagueDetails[$i][0] = $iCalcMaxBonus Then
					SetLog("مستوى ترتيب الكؤؤس: " & $g_asLeagueDetails[$i][1])
					$g_asLeagueDetailsShort = $g_asLeagueDetails[$i][3]
					ExitLoop
				EndIf
			Next
		Else
			SetLog("لا مكافأة")

			$g_asLeagueDetailsShort = "--"
			If $g_aiCurrentLoot[$eLootTrophy] + $g_iStatsLastAttack[$eLootTrophy] >= 400 And $g_aiCurrentLoot[$eLootTrophy] + $g_iStatsLastAttack[$eLootTrophy] < 500 Then ; Bronze III has no League bonus
				SetLog("مستوى ترتيب الكؤؤس: " & $g_asLeagueDetails[0][1])
				$g_asLeagueDetailsShort = $g_asLeagueDetails[0][3]
			EndIf
		EndIf
		;Display League in Stats ==>
		GUICtrlSetData($g_hLblLeague, "")

		If StringInStr($g_asLeagueDetailsShort, "1") > 1 Then
			GUICtrlSetData($g_hLblLeague, "1")
		ElseIf StringInStr($g_asLeagueDetailsShort, "2") > 1 Then
			GUICtrlSetData($g_hLblLeague, "2")
		ElseIf StringInStr($g_asLeagueDetailsShort, "3") > 1 Then
			GUICtrlSetData($g_hLblLeague, "3")
		EndIf
		_GUI_Value_STATE("HIDE", $g_aGroupLeague)
		If StringInStr($g_asLeagueDetailsShort, "B") > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueBronze], $GUI_SHOW)
		ElseIf StringInStr($g_asLeagueDetailsShort, "S") > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueSilver], $GUI_SHOW)
		ElseIf StringInStr($g_asLeagueDetailsShort, "G") > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueGold], $GUI_SHOW)
		ElseIf StringInStr($g_asLeagueDetailsShort, "c", $STR_CASESENSE) > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueCrystal], $GUI_SHOW)
		ElseIf StringInStr($g_asLeagueDetailsShort, "M") > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueMaster], $GUI_SHOW)
		ElseIf StringInStr($g_asLeagueDetailsShort, "C", $STR_CASESENSE) > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueChampion], $GUI_SHOW)
		ElseIf StringInStr($g_asLeagueDetailsShort, "T") > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueTitan], $GUI_SHOW)
		ElseIf StringInStr($g_asLeagueDetailsShort, "LE") > 0 Then
			GUICtrlSetState($g_ahPicLeague[$eLeagueLegend], $GUI_SHOW)
		Else
			GUICtrlSetState($g_ahPicLeague[$eLeagueUnranked], $GUI_SHOW)
		EndIf
		;==> Display League in Stats
	Else
		$g_iStatsBonusLast[$eLootGold] = 0
		$g_iStatsBonusLast[$eLootElixir] = 0
		$g_iStatsBonusLast[$eLootDarkElixir] = 0
		$g_asLeagueDetailsShort = "--"
	EndIf

	; check stars earned
	$starsearned = 0
	If _ColorCheck(_GetPixelColor($aWonOneStarAtkRprt[0], $aWonOneStarAtkRprt[1], True), Hex($aWonOneStarAtkRprt[2], 6), $aWonOneStarAtkRprt[3]) Then $starsearned += 1
	If _ColorCheck(_GetPixelColor($aWonTwoStarAtkRprt[0], $aWonTwoStarAtkRprt[1], True), Hex($aWonTwoStarAtkRprt[2], 6), $aWonTwoStarAtkRprt[3]) Then $starsearned += 1
	If _ColorCheck(_GetPixelColor($aWonThreeStarAtkRprt[0], $aWonThreeStarAtkRprt[1], True), Hex($aWonThreeStarAtkRprt[2], 6), $aWonThreeStarAtkRprt[3]) Then $starsearned += 1
	SetLog("Stars earned: " & $starsearned)

	If $starsearned >= 1 Then
		$eWinlose = "VICTORY"
	Else
		$eWinlose = "DEFEAT"
	EndIf
	SetLog("RESULT: " & $eWinlose)
	Local $AtkLogTxt
	$AtkLogTxt = "  " & String($g_iCurAccount + 1) & "|" & _NowTime(4) & "|"
	$AtkLogTxt &= StringFormat("%4d", $g_aiCurrentLoot[$eLootTrophy]) & "|"
	$AtkLogTxt &= StringFormat("%3d", $g_iSearchCount) & "|"
	Local $l_iTotalSearchTime = 0
	If $g_iTotalSearchTime > 60 Then
		$l_iTotalSearchTime = $g_iTotalSearchTime/60
		$AtkLogTxt &= StringFormat("%4d", StringFormat("%.1f",$l_iTotalSearchTime)) & "h|"
	Else
		$AtkLogTxt &= StringFormat("%4d", StringFormat("%.1f",$g_iTotalSearchTime)) & "m|"
	EndIf

	$AtkLogTxt &= StringFormat("%2d", $eTHLevel) & "|"
	$AtkLogTxt &= StringFormat("%2d", $g_iSearchTrophy) & "|"
	If ($eLootPerc = 100) Then
		$AtkLogTxt &= StringFormat("%3d", $eLootPerc) & "|"
	Else
		$AtkLogTxt &= StringFormat("%2d", $eLootPerc) & "%|"
	EndIf
	$AtkLogTxt &= StringFormat("%3d", $g_iStatsLastAttack[$eLootTrophy]) & "|"
	$AtkLogTxt &= StringFormat("%1d", $starsearned) & "|"
	$AtkLogTxt &= StringFormat("%3d", ($g_iStatsLastAttack[$eLootGold]/1000)) & "K|"
	$AtkLogTxt &= StringFormat("%3d", ($g_iStatsLastAttack[$eLootElixir]/1000)) & "K|"
	$AtkLogTxt &= StringFormat("%4d", $g_iStatsLastAttack[$eLootDarkElixir]) & "|"

	$AtkLogTxt &= StringFormat("%3d", ($g_iStatsBonusLast[$eLootGold]/1000)) & "K|"
	$AtkLogTxt &= StringFormat("%3d", ($g_iStatsBonusLast[$eLootElixir]/1000)) & "K|"
	$AtkLogTxt &= StringFormat("%4d", $g_iStatsBonusLast[$eLootDarkElixir]) & "|"
	$AtkLogTxt &= $g_asLeagueDetailsShort & "|"
	If ProfileSwitchAccountEnabled() Then
		$AtkLogTxt &= $g_sProfileCurrentName
	EndIf

	Local $AtkLogTxtExtend
	$AtkLogTxtExtend = "|"
	$AtkLogTxtExtend &= $g_CurrentCampUtilization & "/" & $g_iTotalCampSpace & "|"
	If Int($g_iStatsLastAttack[$eLootTrophy]) >= 0 Then
		If $g_bColorfulAttackLog Then
			If ($starsearned = 0) Then
				SetAtkLog($AtkLogTxt, $AtkLogTxtExtend, $COLOR_ERROR)
			ElseIf ($starsearned = 1) Then
				SetAtkLog($AtkLogTxt, $AtkLogTxtExtend, $COLOR_ORANGE)
			ElseIf ($starsearned = 2) Then
				SetAtkLog($AtkLogTxt, $AtkLogTxtExtend, $COLOR_INFO)
			ElseIf ($starsearned = 3) Then
				SetAtkLog($AtkLogTxt, $AtkLogTxtExtend, $COLOR_SUCCESS1)
			EndIf
		Else
			SetAtkLog($AtkLogTxt, $AtkLogTxtExtend, $COLOR_BLACK)
		EndIf
	Else
		SetAtkLog($AtkLogTxt, $AtkLogTxtExtend, $COLOR_ERROR)
	EndIf

	; rename or delete zombie
	If $g_bDebugDeadBaseImage Then
		setZombie($g_iStatsLastAttack[$eLootElixir])
	EndIf

	; Share Replay
	If $g_bShareAttackEnable Then
		If (Number($g_iStatsLastAttack[$eLootGold]) >= Number($g_iShareMinGold)) And (Number($g_iStatsLastAttack[$eLootElixir]) >= Number($g_iShareMinElixir)) And (Number($g_iStatsLastAttack[$eLootDarkElixir]) >= Number($g_iShareMinDark)) Then
			SetLog("وصلت الى الحد الادنى لقيم النهب")
			$g_bShareAttackEnableNow = True
		Else
			SetLog("وصلت الى الحد الادنى لقيم النهب")
			$g_bShareAttackEnableNow = False
		EndIf
	EndIf

	If $g_iFirstAttack = 0 Then $g_iFirstAttack = 1
	$g_iStatsTotalGain[$eLootGold] += $g_iStatsLastAttack[$eLootGold] + $g_iStatsBonusLast[$eLootGold]
	$g_aiTotalGoldGain[$g_iMatchMode] += $g_iStatsLastAttack[$eLootGold] + $g_iStatsBonusLast[$eLootGold]
	$g_iStatsTotalGain[$eLootElixir] += $g_iStatsLastAttack[$eLootElixir] + $g_iStatsBonusLast[$eLootElixir]
	$g_aiTotalElixirGain[$g_iMatchMode] += $g_iStatsLastAttack[$eLootElixir] + $g_iStatsBonusLast[$eLootElixir]
	If $g_iStatsStartedWith[$eLootDarkElixir] <> "" Then
		$g_iStatsTotalGain[$eLootDarkElixir] += $g_iStatsLastAttack[$eLootDarkElixir] + $g_iStatsBonusLast[$eLootDarkElixir]
		$g_aiTotalDarkGain[$g_iMatchMode] += $g_iStatsLastAttack[$eLootDarkElixir] + $g_iStatsBonusLast[$eLootDarkElixir]
	EndIf
	$g_iStatsTotalGain[$eLootTrophy] += $g_iStatsLastAttack[$eLootTrophy]
	$g_aiTotalTrophyGain[$g_iMatchMode] += $g_iStatsLastAttack[$eLootTrophy]
	If $g_iMatchMode = $TS Then
		If $starsearned > 0 Then
			$g_iNbrOfTHSnipeSuccess += 1
		Else
			$g_iNbrOfTHSnipeFails += 1
		EndIf
	EndIf
	$g_aiAttackedVillageCount[$g_iMatchMode] += 1
	If ProfileSwitchAccountEnabled() Then
		$g_aiGoldTotalAcc[$g_iCurAccount] += $g_iStatsLastAttack[$eLootGold] + $g_iStatsBonusLast[$eLootGold]
		$g_aiElixirTotalAcc[$g_iCurAccount] += $g_iStatsLastAttack[$eLootElixir] + $g_iStatsBonusLast[$eLootElixir]
		If $g_iStatsStartedWith[$eLootDarkElixir] <> "" Then
			$g_aiDarkTotalAcc[$g_iCurAccount] += $g_iStatsLastAttack[$eLootDarkElixir] + $g_iStatsBonusLast[$eLootDarkElixir]
		EndIf
		$g_aiTrophyLootAcc[$g_iCurAccount] += $g_iStatsLastAttack[$eLootTrophy]
		$g_aiAttackedCountAcc[$g_iCurAccount] += 1
		SetSwitchAccLog(" - الحساب. " & $g_iCurAccount + 1 & ", الهجوم: " & $g_aiAttackedCountAcc[$g_iCurAccount])
	EndIf

	UpdateStats()
	$g_iActualTrainSkip = 0

EndFunc   ;==>AttackReport
