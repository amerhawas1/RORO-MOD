; #FUNCTION# ====================================================================================================================
; Name ..........: Clan Games (V3)
; Description ...: This file contains the Clan Gmes algorithm
; Syntax ........: ---
; Parameters ....: ---
; Return values .: ---
; Author ........: ViperZ And Uncle Xbenk 01-2018
; Modified ......: ProMac 02/2018 [v2 and v3]
; Remarks .......: This file is part of MyBotRun. Copyright 2018
;                  MyBotRun is distributed under the terms of the GNU GPL
; Related .......: ---
; Link ..........: https://www.mybot.run
; Example .......: ---
;================================================================================================================================

; Main Loop Function
Func _ClanGames()

	; Check If this Feature is Enable on GUI.
	If Not $g_bChkClanGamesEnabled Then Return

	Local $sINIPath = StringReplace($g_sProfileConfigPath, "config.ini" , "ClanGames_config.ini")
	If Not FileExists($sINIPath) then ClanGamesChallenges("" , True, $sINIPath, $g_bChkClanGamesDebug)

	; A user Log and a Click away just in case
	ClickP($aAway, 1, 0, "#0000") ;Click Away to prevent any pages on top
	SetLog("فتح مبارات القبيلة...", $COLOR_INFO)
	If _Sleep(500) Then Return

	; Local and Static Variables
	Local $TabChallengesPosition[2] = [820, 130]
	Local $sTimeRemain = "", $sEventName = "", $getCapture = True
	Local Static $YourAccScore[8][2] = [[-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True], [-1, True]]

	; Check for BS/CoC errors just in case
	If isProblemAffect(True) Then checkMainScreen(False)

	; Enter on Clan Games window
	If Not IsClanGamesWindow() Then Return

	; Check if is a Clan or Builder Games Event
	If $g_bChkClanGamesOnly = 1 then
		If Not IsClanGamesEvent() Then Return
	EndIf

	; Let's get some information , like Remain Timer, Score and limit
	Local $ScoreLimits = GetTimesAndScores()
	If $ScoreLimits = -1 Or UBound($ScoreLimits) <> 2 Then Return

	; Small delay
	If _Sleep(3000) Then Return

	SetLog("نقاطك : " & Int($ScoreLimits[0]), $COLOR_INFO)
	If Int($ScoreLimits[0]) = Int($ScoreLimits[1]) Then
		SetLog("تم الوصول إلى حد النقاط الخاص بك...")
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return
	ElseIf Int($ScoreLimits[0]) + 200 > Int($ScoreLimits[1]) Then
		SetLog("تم الوصول إلى حد درجاتك تقريبًا...")
		If $g_bChkClanGamesStopBeforeReachAndPurge Then
			If CooldownTime() Then Return
			If IsEventRunning() Then Return
			SetLog("توقف قبل إكمال الحد الخاص بك")
			$sEventName = "Builder Base Challenges to Purge"
			If PurgeEvent($g_sImgPurge, $sEventName, True) Then $g_iPurgeJobCount[$g_iCurAccount] += 1
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			Return
		EndIf
	EndIf
	If $YourAccScore[$g_iCurAccount][0] = -1 Then $YourAccScore[$g_iCurAccount][0] = $ScoreLimits[0]

	; Check IF exist the Gem icon
	;check cooldown purge
	If CooldownTime() Then Return

	; Variable for Stop button
	If $g_bRunState = False Then Return

	If IsEventRunning() Then Return

	If $g_bRunState = False Then Return

	; Screen coordinates for ScreenCapture
	Local $x = 281, $y = 150, $x1 = 775, $y1 = 545

	If $g_bChkClanGamesDebug Then SetLog("مستوى التاون هول  " & $g_iTownHallLevel)

	; Check for BS/CoC errors just in case
	If isProblemAffect(True) Then checkMainScreen(False)
	
	;;;; Lets test the Loot Challenges
	If $g_bChkClanGamesLoot Then
		SetLog("التحقق من تحديثات الجمع", $COLOR_DEBUG)
		;[0] = Path Directory , [1] = Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
		Local $LootChallenges = ClanGamesChallenges("$LootChallenges" , False, $sINIPath, $g_bChkClanGamesDebug)

		; Sort by difficulty 1 to 5
		_ArraySort($LootChallenges, 0, 0, 0, 3)

		For $i = 0 To UBound($LootChallenges) - 1
			; Verify your TH level and Challenge kind
			If $g_iTownHallLevel < $LootChallenges[$i][2] Then ContinueLoop

			; Disable this event from INI File
			If $LootChallenges[$i][3] = 0 then ContinueLoop

			If QuickMIS("BC1", $LootChallenges[$i][0], $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
				SetLog("وجد " & $LootChallenges[$i][1] & " الحدث", $COLOR_SUCCESS)
				$sEventName = "Loot Event | " & $LootChallenges[$i][1]
				Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
				If _Sleep(1750) Then Return
				If ClickOnEvent($YourAccScore, $ScoreLimits, $sEventName, $getCapture) Then Return
				; Some error occurred let's click on Challenges Tab and proceeds
				ClickP($TabChallengesPosition, 2, 0, "#Tab")
			EndIf
			If _Sleep(50) Then Return
			If $g_bRunState = False Then Return
		Next
	EndIf
	
	;;;; Lets test the Battle Challenges
	If $g_bChkClanGamesBattle Then
		SetLog("التحقق من تحديات القتال او المعارك", $COLOR_DEBUG)
		;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
		Local $BattleChallenges = ClanGamesChallenges("$BattleChallenges" , False, $sINIPath, $g_bChkClanGamesDebug)

		; Sort by difficulty 1 to 5
		_ArraySort($BattleChallenges, 0, 0, 0, 3)

		For $i = 0 To UBound($BattleChallenges) - 1
			; Verify your TH level and Challenge
			If $g_iTownHallLevel < $BattleChallenges[$i][2] Then ContinueLoop

			; Disable this event from INI File
			If $BattleChallenges[$i][3] = 0 then ContinueLoop

			; If you are a TH11 , doesn't exist the TH12
			If $BattleChallenges[$i][1] = "Attack Up" And $g_iTownHallLevel = 11 then ContinueLoop
			; Check your Trophy Range
			If $BattleChallenges[$i][1] = "Slaying The Titans" And Int($g_aiCurrentLoot[$eLootTrophy]) < 4100 then ContinueLoop
			; Check if exist a probability to use any Spell
			If $BattleChallenges[$i][1] = "No-Magic Zone" And ($g_bSmartZapEnable = True Or ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1)) then ContinueLoop
			; Check if you are using Heroes
			If $BattleChallenges[$i][1] = "No Heroics Allowed" And ((Int($g_aiAttackUseHeroes[$DB]) > $eHeroNone And  $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) > $eHeroNone And $g_iMatchMode = $LB)) then ContinueLoop

			If QuickMIS("BC1", $BattleChallenges[$i][0], $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
				SetLog("وجد " & $BattleChallenges[$i][1] & " الحدث", $COLOR_SUCCESS)
				$sEventName = "Battle Event | " & $BattleChallenges[$i][1]
				Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
				If _Sleep(1750) Then Return

				; Exist 2 Similar Icons , let's check:
				; TODO , Test the image for a better tolerance and/or reduced region
				If $BattleChallenges[$i][1] = "Pile Of Victories" Then
					If QuickMIS("BC1", $g_sImgWStreakC, $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
						SetLog("الكشف عن الانتصار ، حدث خاطئ .. مستمر", $COLOR_WARNING)
						If $g_iTownHallLevel < 9 Then
							; Close the Start Window Event and continue the loop
							ClickP($TabChallengesPosition, 2, 0, "#Tab")
							ContinueLoop
						EndIf
						$sEventName = "Battle Event | Winning Streak"
					EndIf
				EndIf

				If ClickOnEvent($YourAccScore, $ScoreLimits, $sEventName, $getCapture) Then Return
				; Some error occurred let's click on Challenges Tab and proceeds
				ClickP($TabChallengesPosition, 2, 0, "#Tab")
			EndIf
			If _Sleep(50) Then Return
			If $g_bRunState = False Then Return
		Next
	EndIf

	;;;; Lets test the Destruction Challenges
	If $g_bChkClanGamesDestruction Then
		SetLog("التحقق من تحديات التدمير ", $COLOR_DEBUG)
		;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
		Local $DestructionChallenges = ClanGamesChallenges("$DestructionChallenges" , False, $sINIPath, $g_bChkClanGamesDebug)

		; Sort by difficulty 1 to 5
		_ArraySort($DestructionChallenges, 0, 0, 0, 3)

		For $i = 0 To UBound($DestructionChallenges) - 1
			; Verify your TH level and Challenge kind
			If $g_iTownHallLevel < $DestructionChallenges[$i][2] Then ContinueLoop

			; Disable this event from INI File
			If $DestructionChallenges[$i][3] = 0 then ContinueLoop

			; Check if you are using Heroes
			If $DestructionChallenges[$i][1] = "Hero Level Hunter" Or _
			   $DestructionChallenges[$i][1] = "King Level Hunter" Or _
			   $DestructionChallenges[$i][1] = "Queen Level Hunter" Or _
			   $DestructionChallenges[$i][1] = "Warden Level Hunter" And ((Int($g_aiAttackUseHeroes[$DB]) = $eHeroNone And $g_iMatchMode = $DB) Or (Int($g_aiAttackUseHeroes[$LB]) = $eHeroNone And $g_iMatchMode = $LB)) then ContinueLoop

			If QuickMIS("BC1", $DestructionChallenges[$i][0], $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
				SetLog("وجد " & $DestructionChallenges[$i][1] & " الحدث", $COLOR_SUCCESS)
				$sEventName = "Destruction Event | " & $DestructionChallenges[$i][1]
				Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
				If _Sleep(1750) Then Return
				If ClickOnEvent($YourAccScore, $ScoreLimits, $sEventName, $getCapture) Then Return
				; Some error occurred let's click on Challenges Tab and proceeds
				ClickP($TabChallengesPosition, 2, 0, "#Tab")
			EndIf
			If _Sleep(50) Then Return
			If $g_bRunState = False Then Return
		Next
	EndIf
	
	

	

	
	
	
	;;;; Lets test the Air Troops Challenges
	If $g_bChkClanGamesAirTroop Then
		SetLog("التحقق من تحديات القوات الجوية", $COLOR_DEBUG)
		;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
		Local $AirTroopChallenges = ClanGamesChallenges("$AirTroopChallenges" , False, $sINIPath, $g_bChkClanGamesDebug)

		For $i = 0 To UBound($AirTroopChallenges) - 1
			; Verify if the Troops exist in your Army Composition
			Local $TroopIndex = Int(Eval("eTroop" & $AirTroopChallenges[$i][1]))
			; If doesn't Exist the Troop on your Army
			If $g_aiCurrentTroops[$TroopIndex] < 1 Then
				If $g_bChkClanGamesDebug Then SetLog("[" & $AirTroopChallenges[$i][1] & "] لا " & $g_asTroopNames[$TroopIndex] & " على تكوين الجيش الخاص بك.")
				ContinueLoop
				; If Exist BUT not is required quantities
			ElseIf $g_aiCurrentTroops[$TroopIndex] > 0 And $g_aiCurrentTroops[$TroopIndex] < $AirTroopChallenges[$i][3] Then
				If $g_bChkClanGamesDebug Then SetLog("[" & $AirTroopChallenges[$i][1] & "] أنت في حاجة أكثر " & $g_asTroopNames[$TroopIndex] & " [" & $g_aiCurrentTroops[$TroopIndex] & "/" & $AirTroopChallenges[$i][3] & "]")
				ContinueLoop
			EndIf

			If QuickMIS("BC1", $AirTroopChallenges[$i][0], $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
				SetLog("وجد " & $AirTroopChallenges[$i][1] & " الحدث", $COLOR_SUCCESS)
				$sEventName = "Troops Event | " & $AirTroopChallenges[$i][1]
				Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
				If _Sleep(1750) Then Return
				If ClickOnEvent($YourAccScore, $ScoreLimits, $sEventName, $getCapture) Then Return
				; Some error occurred let's click on Challenges Tab and proceeds
				ClickP($TabChallengesPosition, 2, 0, "#Tab")
			EndIf
			If _Sleep(50) Then Return
			If $g_bRunState = False Then Return
		Next
	EndIf

	;;;; Lets test the Ground Troops Challenges
	If $g_bChkClanGamesGroundTroop Then
		SetLog("التحقق من تحديات القوات الارضية", $COLOR_DEBUG)
		;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Event Quantities
		Local $GroundTroopChallenges = ClanGamesChallenges("$GroundTroopChallenges" , False, $sINIPath, $g_bChkClanGamesDebug)

		For $i = 0 To UBound($GroundTroopChallenges) - 1
			;;;;; Verify if the Troops exist in your Army Composition
			Local $TroopIndex = Int(Eval("eTroop" & $GroundTroopChallenges[$i][1]))
			;;;;; If doesn't Exist the Troop on your Army
			If $g_aiCurrentTroops[$TroopIndex] < 1 Then
				If $g_bChkClanGamesDebug Then SetLog("[" & $GroundTroopChallenges[$i][1] & "] لا " & $g_asTroopNames[$TroopIndex] & " على تكوين الجيش الخاص بك.")
				ContinueLoop
				;;;;; If Exist BUT not is required quantities
			ElseIf $g_aiCurrentTroops[$TroopIndex] > 0 And $g_aiCurrentTroops[$TroopIndex] < $GroundTroopChallenges[$i][3] Then
				If $g_bChkClanGamesDebug Then SetLog("[" & $GroundTroopChallenges[$i][1] & "] أنت في حاجة أكثر " & $g_asTroopNames[$TroopIndex] & " [" & $g_aiCurrentTroops[$TroopIndex] & "/" & $GroundTroopChallenges[$i][3] & "]")
				ContinueLoop
			EndIf

			If QuickMIS("BC1", $GroundTroopChallenges[$i][0], $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
				SetLog("وجد " & $GroundTroopChallenges[$i][1] & " الحدث", $COLOR_SUCCESS)
				$sEventName = "Troops Event | " & $GroundTroopChallenges[$i][1]
				Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
				If _Sleep(1750) Then Return
				If ClickOnEvent($YourAccScore, $ScoreLimits, $sEventName, $getCapture) Then Return
				;;;;; Some error occurred let's click on Challenges Tab and proceeds
				ClickP($TabChallengesPosition, 2, 0, "#Tab")
			EndIf
			If _Sleep(50) Then Return
			If $g_bRunState = False Then Return
		Next
	EndIf

	

	; Lets test the Miscellaneous Challenges
	If $g_bChkClanGamesMiscellaneous Then
		SetLog("التحقق من التحديات البسيطة", $COLOR_DEBUG)
		;[0] = Path Directory , [1] = Event Name , [2] = TH level , [3] = Difficulty Level , [4] = Time to do it
		Local $MiscChallenges = ClanGamesChallenges("$MiscChallenges" , False, $sINIPath, $g_bChkClanGamesDebug)

		; Sort by difficulty 1 to 5
		_ArraySort($MiscChallenges, 0, 0, 0, 3)

		For $i = 0 To UBound($MiscChallenges) - 1
			; Disable this event from INI File
			If $MiscChallenges[$i][3] = 0 then ContinueLoop

			; Exceptions :
			; 1 - "Gardening Exercise" needs at least a Free Builder
			If $MiscChallenges[$i][1] = "Gardening Exercise" And $g_iFreeBuilderCount < 1 Then ContinueLoop

			; 2 - Verify your TH level and Challenge kind
			If $g_iTownHallLevel < $MiscChallenges[$i][2] Then ContinueLoop

			; 3 - If you don't Donate Troops
			If $MiscChallenges[$i][1] = "Helping Hand" And Not $g_iActiveDonate Then ContinueLoop

			; 4 - If you don't Donate Spells , $g_aiPrepDon[2] = Donate Spells , $g_aiPrepDon[3] = Donate All Spells [PrepareDonateCC()]
			If $MiscChallenges[$i][1] = "Donate Spells" And ($g_aiPrepDon[2] = 0 And $g_aiPrepDon[3] = 0) Then ContinueLoop

			If QuickMIS("BC1", $MiscChallenges[$i][0], $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
				SetLog("وجد " & $MiscChallenges[$i][1] & " الحدث", $COLOR_SUCCESS)
				$sEventName = "Miscellaneous Event | " & $MiscChallenges[$i][1]
				Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
				If _Sleep(1750) Then Return
				If ClickOnEvent($YourAccScore, $ScoreLimits, $sEventName, $getCapture) Then Return
				; Some error occurred let's click on Challenges Tab and proceeds
				ClickP($TabChallengesPosition, 2, 0, "#Tab")
			EndIf
			If _Sleep(50) Then Return
			If $g_bRunState = False Then Return
		Next
	EndIf

	;;;;; Lets test the Builder Base Challenges
	If $g_bChkClanGamesPurge Then
		If $g_iPurgeJobCount[$g_iCurAccount] + 1 < $g_iPurgeMax Or $g_iPurgeMax = 0 Then
			Local $Txt = $g_iPurgeMax
			If $g_iPurgeMax = 0 Then $Txt = "Unlimited"
			SetLog("Current Purge Jobs " & $g_iPurgeJobCount[$g_iCurAccount] + 1 & " at max of " & $Txt, $COLOR_INFO)
			$sEventName = "Builder Base Challenges to Purge"
			If PurgeEvent($g_sImgPurge, $sEventName, True) Then
				$g_iPurgeJobCount[$g_iCurAccount] += 1
			Else
				SetLog("لم يتم العثور على حدث من القرية الليلية", $COLOR_WARNING)
			EndIf
		EndIf
		Return
	EndIf

	SetLog("لم يتم العثور على أي حدث ، تحقق من إعداداتك", $COLOR_WARNING)
	ClickP($aAway, 1, 0, "#0000") ;Click Away
	If _Sleep(2000) Then Return
EndFunc   ;==>_ClanGames

Func IsClanGamesWindow($getCapture = True)
	If QuickMIS("BC1", $g_sImgCaravan, 200, 55, 300, 135, $getCapture, False) Then
		;If QuickMIS("BC1", $g_sImgCaravan, 236, 119, 270, 122, True) Then
		SetLog("العاب القبيلة متاحة... الدخول ل مبارات القبيلة...", $COLOR_SUCCESS)
		Click($g_iQuickMISX + 200, $g_iQuickMISY + 55)
		If _Sleep(2500) Then Return
		If QuickMIS("BC1", $g_sImgReward, 760, 480, 830, 570, $getCapture, $g_bChkClanGamesDebug) Then
			SetLog("مكافأتك جاهزة", $COLOR_INFO)
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			If _Sleep(2000) Then Return
			Return False
		EndIf
		If _ColorCheck(_GetPixelColor(384, 388, True), Hex(0xFFFFFF, 6), 5) Then ;
			Local $sTimeRemain = getOcrTimeGameTime(380, 461) ; read Clan Games waiting time
			SetLog("Clan Games will start in " & $sTimeRemain, $COLOR_INFO)
			; Update the Label on GUI
			GUICtrlSetData($g_hLblRemainTime, $sTimeRemain)
			GUICtrlSetState($g_hLblRemainTime, $GUI_ENABLE)
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			If _Sleep(2000) Then Return
			Return False
		EndIf
	Else
		SetLog("مباريات القبيلة غير متاحة في الوقت الحالي ...", $COLOR_WARNING)
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return False
	EndIf
	If _Sleep(2000) Then Return
	Return True
EndFunc   ;==>IsClanGamesWindow

Func IsClanGamesEvent($getCapture = True)
	If QuickMIS("BC1", $g_sImageBuilerGames, 20, 75, 110, 115, $getCapture, $g_bChkClanGamesDebug) Then
		SetLog("تم اكتشاف حدث من القرية الليلية!", $COLOR_INFO)
		If GUICtrlRead($g_hLblRemainTime) <> "BG Event" Then GUICtrlSetData($g_hLblRemainTime, "BG Event")
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		If _Sleep(2000) Then Return
		Return False
	EndIf
	Return True
EndFunc

Func GetTimesAndScores()

	Local $rest = -1, $YourScore = "", $ScoreLimits, $sTimeRemain

	;Ocr for game time remaining
	$sTimeRemain = StringReplace(getOcrTimeGameTime(50, 479), " ", "") ; read Clan Games waiting time
	; JUST IN CASE
	If Not _IsValideOCR($sTimeRemain) Then
		SetLog("الحصول على الوقت يبقى الخطأ!!!", $COLOR_WARNING)
		Return -1
	EndIf
	SetLog("الوقت المتبقي ل العاب القبيلة: " & $sTimeRemain, $COLOR_INFO)

	; Update the Label on GUI
	GUICtrlSetData($g_hLblRemainTime, $sTimeRemain)
	GUICtrlSetState($g_hLblRemainTime, $GUI_ENABLE)

	; This Loop is just to check if the Score is changing , when you complete a previous events is necessary to take some time...
	For $i = 0 To 10
		$YourScore = getOcrYourScore(55, 533) ;  Read your Score
		If $g_bChkClanGamesDebug Then SetLog("Your OCR score: " & $YourScore)
		$YourScore = StringReplace($YourScore, "#", "/")
		$ScoreLimits = StringSplit($YourScore, "/", $STR_NOCOUNT)
		If UBound($ScoreLimits) > 1 Then
			If $rest = Int($ScoreLimits[0]) Then ExitLoop
			$rest = Int($ScoreLimits[0])
		Else
			Return -1
		EndIf
		If _Sleep(800) Then Return
		If $i = 10 Then Return -1
	Next

	; Update the Label on GUI
	GUICtrlSetData($g_hLblYourScore, $YourScore)
	GUICtrlSetState($g_hLblYourScore, $GUI_ENABLE)

	Return $ScoreLimits
EndFunc   ;==>GetTimesAndScores

Func CooldownTime($getCapture = True)
	; Check IF exist the Gem icon
	;check cooldown purge
	If QuickMIS("BC1", $g_sImgCoolPurge, 480, 370, 570, 410, $getCapture, False) Then
		SetLog("Cooldown Purge Detected", $COLOR_INFO)
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return True
	EndIf
	Return False
EndFunc   ;==>CooldownTime

Func IsEventRunning()
	; Check if any event is running or not
	If Not _ColorCheck(_GetPixelColor(304, 257, True), Hex(0x53E050, 6), 5) Then ; Green Bar from First Position
		SetLog("حدث قيد التقدم بالفعل !", $COLOR_SUCCESS)
		If $g_bChkClanGamesDebug then SetLog("[0]: " & _GetPixelColor(304, 257, True))
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return True
	Else
		SetLog("لا يوجد حدث تحت التقدم ... دعنا نبحث عن واحد ...", $COLOR_INFO)
		Return False
	EndIf

EndFunc   ;==>IsEventRunning

Func ClickOnEvent(ByRef $YourAccScore, $ScoreLimits, $sEventName, $getCapture)
	If $YourAccScore[$g_iCurAccount][1] = False Then
		Local $Text = "", $color = $COLOR_SUCCESS
		If $YourAccScore[$g_iCurAccount][0] <> $ScoreLimits[0] Then
			$Text = "You Won " & $ScoreLimits[0] - $YourAccScore[$g_iCurAccount][0] & "pts in last Event"
		Else
			$Text = "You could not complete the last event!!"
			$color = $COLOR_WARNING
		EndIf
		SetLog($Text, $color)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - " & $Text)
	EndIf
	$YourAccScore[$g_iCurAccount][1] = False
	$YourAccScore[$g_iCurAccount][0] = $ScoreLimits[0]
	If $g_bChkClanGamesDebug then SetLog("ClickOnEvent $YourAccScore[" & $g_iCurAccount & "][1]: " & $YourAccScore[$g_iCurAccount][1])
	If $g_bChkClanGamesDebug then SetLog("ClickOnEvent $YourAccScore[" & $g_iCurAccount & "][0]: " & $YourAccScore[$g_iCurAccount][0])
	If Not StartsEvent($sEventName, False, $getCapture, $g_bChkClanGamesDebug) Then Return False
	ClickP($aAway, 1, 0, "#0000") ;Click Away
	Return True
EndFunc   ;==>ClickOnEvent

Func StartsEvent($sEventName, $g_bPurgeJob = False, $getCapture = True, $g_bChkClanGamesDebug = False)

	; Start an Event
	If $g_bRunState = False Then Return
	If QuickMIS("BC1", $g_sImgStart, 220, 150, 830, 580, $getCapture, $g_bChkClanGamesDebug) Then
		Local $Timer = GetEventTimeInMinutes($g_iQuickMISX + 220, $g_iQuickMISY + 150)
		SetLog("بدء الحدث" & " ["& $Timer & " دقيقة]", $COLOR_SUCCESS)
		Click($g_iQuickMISX + 220, $g_iQuickMISY + 150)
		GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - Starting " & $sEventName & " for " & $Timer & " min", 1)
		_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - Starting " & $sEventName & " for "& $Timer & " min")
		If $g_bPurgeJob Then
			If _Sleep(2000) Then Return
			; Click($g_iQuickMISX + 220, $g_iQuickMISY + 150)
			If QuickMIS("BC1", $g_sImgTrashPurge, 220, 150, 830, 580, $getCapture, $g_bChkClanGamesDebug) Then
				Click($g_iQuickMISX + 220, $g_iQuickMISY + 150)
				If _Sleep(1200) Then Return
				SetLog("انقر فوق المهملات", $COLOR_INFO)
				If QuickMIS("BC1", $g_sImgOkayPurge, 440, 400, 580, 450, $getCapture, $g_bChkClanGamesDebug) Then
					SetLog("انقر فوق موافق", $COLOR_INFO)
					Click($g_iQuickMISX + 440, $g_iQuickMISY + 400)
					SetLog("تطهير وظيفة على التقدم !", $COLOR_SUCCESS)
					GUICtrlSetData($g_hTxtClanGamesLog, @CRLF & _NowDate() & " " & _NowTime() & " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - Purging Event ", 1)
					_FileWriteLog($g_sProfileLogsPath & "\ClanGames.log", " [" & $g_sProfileCurrentName & "] - [" & $g_iPurgeJobCount[$g_iCurAccount] + 1 & "] - Purging Event ")
					ClickP($aAway, 1, 0, "#0000") ;Click Away
				Else
					SetLog("$g_sImgOkayPurge Issue!!!", $COLOR_WARNING)
					Return False
				EndIf
			Else
				SetLog("$g_sImgTrashPurge Issue!!!", $COLOR_WARNING)
				Return False
			EndIf
		EndIf
		Return True
	Else
		SetLog("لم تحصل على حدث زر البداية الخضراء!!", $COLOR_WARNING)
		If $g_bChkClanGamesDebug Then SetLog("[X: " & 220 & " Y:" & 150 & " X1: " & 830 & " Y1: " & 580 & "]", $COLOR_WARNING)
		ClickP($aAway, 1, 0, "#0000") ;Click Away
		Return False
	EndIf

EndFunc   ;==>StartsEvent

Func PurgeEvent($directoryImage, $sEventName, $getCapture = True)
	SetLog("التحقق من التحديات الأساسية منشئ للتطهير", $COLOR_DEBUG)
	; Screen coordinates for ScreenCapture
	Local $x = 281, $y = 150, $x1 = 775, $y1 = 545
	If QuickMIS("BC1", $directoryImage, $x, $y, $x1, $y1, $getCapture, $g_bChkClanGamesDebug) Then
		Click($g_iQuickMISX + $x, $g_iQuickMISY + $y)
		; Start and Purge at same time
		SetLog("بدء وظيفة مستحيلة لتطهير...", $COLOR_INFO)
		If _Sleep(1500) Then Return
		If StartsEvent($sEventName, True, $getCapture, $g_bChkClanGamesDebug) Then
			ClickP($aAway, 1, 0, "#0000") ;Click Away
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>PurgeEvent

Func _IsValideOCR($sString)

	If StringInStr($sString, "d") > 0 Or _
			StringInStr($sString, "h") > 0 Or _
			StringInStr($sString, "m") > 0 Or _
			StringInStr($sString, "s") > 0 Then Return True

	Return False
EndFunc   ;==>_IsValideOCR

Func Ocr2Minutes($StringOCR)

	If Not _IsValideOCR($StringOCR) Then Return 0

	Local $temp

	If StringInStr($StringOCR, "d") > 0 then
		$temp = StringSplit($StringOCR, "d" , $STR_NOCOUNT)
		Local $d = Int($temp[0])
		Local $h = Int(StringReplace($temp[1],"h" , ""))
		Return ($d * 24)* 60 + ($h * 60)
	ElseIf  StringInStr($StringOCR, "h") > 0 then
		$temp = StringSplit($StringOCR, "h" , $STR_NOCOUNT)
		Local $h = Int($temp[0])
		Local $m = Int(StringReplace($temp[1],"m" , ""))
		Return ($h * 60) + $m
	ElseIf StringInStr($StringOCR, "m") > 0 Then
		$temp = StringSplit($StringOCR, "m" , $STR_NOCOUNT)
		Return Int($temp[0])
	ElseIf StringInStr($StringOCR, "s") > 0 Then
		Return 1
	EndIf

	Return 0
EndFunc

Func GetEventTimeInMinutes($iXStartBtn , $iYStartBtn , $bIsStartBtn = True )

	Local $XAxis = $iXStartBtn - 163 	; Related to Start Button
	Local $YAxis = $iYStartBtn + 8 		; Related to Start Button

	If Not $bIsStartBtn then
		$XAxis = $iXStartBtn - 163 		; Related to Trash Button
		$YAxis = $iYStartBtn + 8 		; Related to Trash Button
	EndIf

	Local $Ocr = getOcrEventTime($XAxis, $YAxis)
	Return Ocr2Minutes($Ocr)

EndFunc

; Just for any button test
Func ClanGames($bTest = False)
	Local $bWasRunState = $g_bRunState
	$g_bRunState = True
	Local $Result = _ClanGames()
	$g_bRunState = $bWasRunState
	Return $Result
EndFunc   ;==>ClanGames

; Extra functions for OCR
Func getOcrTimeGameTime($x_start, $y_start) ;  -> Get the guard/shield time left, middle top of the screen
	Return getOcrAndCapture("coc-clangames", $x_start, $y_start, 116, 31, True)
EndFunc   ;==>getOcrTimeGameTime

Func getOcrYourScore($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCapture("coc-ms", $x_start, $y_start, 120, 18, True)
EndFunc   ;==>getOcrYourScore

Func getOcrEventTime($x_start, $y_start) ; -> Gets CheckValuesCost on Train Window
	Return getOcrAndCapture("coc-events", $x_start, $y_start, 80, 20, True)
EndFunc   ;==>getOcrYourScore

Func ClanGamesChallenges($sReturnArray, $makeIni = False , $sINIPath = "", $debug = False)

	Local $LootChallenges[6][5] = [ _
				[$g_sImgGold, 		"تحدي الذهب"		, 7, 5, 8], _ ; Loot 150,000 Gold from a single Multiplayer Battle				|8h 	|50
				[$g_sImgElixir, 	"التحدي الاكسير"		, 7, 4, 8], _ ; Loot 150,000 Elixir from a single Multiplayer Battle 			|8h 	|50
				[$g_sImgDark, 		"تحدي الاكسير الظلام"	, 8, 3, 8], _ ; Loot 1,500 Dark elixir from a single Multiplayer Battle			|8h 	|50
				[$g_sImgGoldG, 		"انتزاع الذهب"				, 3, 1, 1], _ ; Loot a total of 500,000 TO 1,500,000 from Multiplayer Battle 	|1h-2d 	|100-600
				[$g_sImgElixirE, 	"انتزاع الاكسير"	, 3, 1, 1], _ ; Loot a total of 500,000 TO 1,500,000 from Multiplayer Battle 	|1h-2d 	|100-600
				[$g_sImgDarkEH, 	"انتزاع اكسير الظلام"		, 9, 3, 1]]   ; Loot a total of 1,500 TO 12,500 from Multiplayer Battle 		|1h-2d 	|100-600

	Local $AirTroopChallenges[5][4] = [ _
				[$g_sImgMini, 		"Minion"			, 7, 20], _		; Earn 2-5 Stars from Multiplayer Battles using 20 Minions			|3h-8h	|40-100
				[$g_sImgBall, 		"Balloon"			, 4, 12], _		; Earn 2-5 Stars from Multiplayer Battles using 12 Balloons		|3h-8h	|40-100
				[$g_sImgDrag, 		"Dragon"			, 7,  6], _		; Earn 2-5 Stars from Multiplayer Battles using 6 Dragons			|3h-8h	|40-100
				[$g_sImgBabyD, 		"BabyDragon"		, 9,  4], _		; Earn 2-5 Stars from Multiplayer Battles using 4 Baby Dragons		|3h-8h	|40-100
				[$g_sImgLava, 		"Lavahound"			, 9,  3]]  		; Earn 2-5 Stars from Multiplayer Battles using 3 Lava Hounds		|3h-8h	|40-100

	Local $GroundTroopChallenges[14][4] = [ _
				[$g_sImgArch, 		"Archer"		, 1, 30], _				 ; Earn 2-5 Stars from Multiplayer Battles using 30 Barbarians		|3h-8h	|40-100
				[$g_sImgBarb, 		"Barbarian"		, 1, 30], _				 ; Earn 2-5 Stars from Multiplayer Battles using 30 Archers			|3h-8h	|40-100
				[$g_sImgGiant, 		"Giant"			, 1, 10], _				 ; Earn 2-5 Stars from Multiplayer Battles using 10 Giants			|3h-8h	|40-100
				[$g_sImgGobl, 		"Goblin"		, 2, 20], _				 ; Earn 2-5 Stars from Multiplayer Battles using 20 Goblins			|3h-8h	|40-100
				[$g_sImgWall, 		"WallBreaker"	, 3,  6], _				 ; Earn 2-5 Stars from Multiplayer Battles using 6 Wall Breakers	|3h-8h	|40-100
				[$g_sImgWiza, 		"Wizard"		, 5, 12], _				 ; Earn 2-5 Stars from Multiplayer Battles using 12 Wizards			|3h-8h	|40-100
				[$g_sImgHeal, 		"Healer"		, 6,  3], _				 ; Earn 2-5 Stars from Multiplayer Battles using 3 Healers			|3h-8h	|40-100
				[$g_sImgHogs, 		"HogRider"		, 7, 10], _				 ; Earn 2-5 Stars from Multiplayer Battles using 10 Hog Riders		|3h-8h	|40-100
				[$g_sImgMine, 		"Miner"			, 10, 8], _				 ; Earn 2-5 Stars from Multiplayer Battles using 8 Miners			|3h-8h	|40-100
				[$g_sImgPekka, 		"Pekka"			, 8,  2], _				 ; Earn 2-5 Stars from Multiplayer Battles using 2 P.E.K.K.As		|3h-8h	|40-100
				[$g_sImgWitch, 		"Witch"			, 9,  4], _				 ; Earn 2-5 Stars from Multiplayer Battles using 4 Witches			|3h-8h	|40-100
				[$g_sImgBowl, 		"Bowler"		, 10, 8], _				 ; Earn 2-5 Stars from Multiplayer Battles using 8 Bowlers			|3h-8h	|40-100
				[$g_sImgValk, 		"Valkyrie"		, 8,  8], _				 ; Earn 2-5 Stars from Multiplayer Battles using 8 Valkyries		|3h-8h	|40-100
				[$g_sImgGole, 		"Golem"			, 8,  2]] 				 ; Earn 2-5 Stars from Multiplayer Battles using 2 Golems			|3h-8h	|40-100

	Local $BattleChallenges[9][5] = [ _
				[$g_sImgStar, 		"جمع النجوم"		, 3, 4, 8], _ ; Collect a total of 6-18 stars from Multiplayer Battles			|8h-2d	|100-600
				[$g_sImgLordD, 		"تحدي نسبة التدمير"	, 3, 1, 8], _ ; Gather a total of 100%-500% destruction from Multi Battles		|8h-2d	|100-600
				[$g_sImgPileVict, 	"كومة من الانتصارات"		, 3, 3, 8], _ ; Win 2-8 Multiplayer Battles										|8h-2d	|100-600
				[$g_sImgHunt3, 		"تحدي الحصول على 3 نجوم"	, 10,3 ,8], _ ; Score a perfect 3 Stars in Multiplayer Battles					|8h 	|200
				[$g_sImgWStreak, 	"الفوز الانتصارات"		, 9, 5, 8], _ ; Win 2-8 Multiplayer Battles in a row							|8h-2d	|100-600
				[$g_sImgSlayingT, 	"يقتل العمالقة"	, 11,0, 5], _ ; Win 5 Multiplayer Battles In Tital LEague						|5h		|300
				[$g_sImgNoHeroics, 	"تحدي بدون استخدام الملوك"	, 3 ,1, 8], _ ; Win stars without using Heroes									|8h		|100
				[$g_sImgNoMagicZone,"تحدي بدون استخدام السبيلات"			, 3 ,1, 8], _ ; Win stars without using Spells									|8h		|100
				[$g_sImgAttUp,	 	"مهاجمة"				, 3 ,1, 8]]	  ; Gain 3 Stars Against Certain Town Hall							|8h		|200

	Local $DestructionChallenges[28][5] = [ _
				[$g_sImgCannon, 	"تحدي تدمير المدفع"				, 3, 2, 1], _ ; Destroy 5-25 Cannons in Multiplayer Battles					|1h-8h	|75-350
				[$g_sImgArcherT, 	"تحدي تدمير برج الارشر"			, 3, 3, 1], _ ; Destroy 5-20 Archer Towers in Multiplayer Battles			|1h-8h	|75-350
				[$g_sImgMortar, 	"تحدي تدمير مدفع الهاون"				, 3, 1, 1], _ ; Destroy 4-12 Mortars in Multiplayer Battles					|1h-8h	|40-350
				[$g_sImgAirDef, 	"تحدي تدمير المضاض الجوي"			, 7, 2, 1], _ ; Destroy 3-12 Air Defenses in Multiplayer Battles			|1h-8h	|40-350
				[$g_sImgWizard, 	"تحدي تدمير برج الساحر"			, 3, 3, 1], _ ; Destroy 4-12 Wizard Towers in Multiplayer Battles			|1h-8h	|40-350
				[$g_sImgAirS, 		"تحدي تدمير نافخ الهواء"			, 8, 2, 1], _ ; Destroy 2-6 Air Sweepers in Multiplayer Battles				|1h-8h	|40-350
				[$g_sImgTesla, 		"تحدي تدمير التيسلا"			, 7, 5, 1], _ ; Destroy 4-12 Hidden Teslas in Multiplayer Battles			|1h-8h	|50-350
				[$g_sImgBombT, 		"تحدي تدمير برج القنابل"			, 8, 2, 1], _ ; Destroy 2 Bomb Towers in Multiplayer Battles				|1h-8h	|50-350
				[$g_sImgXBow, 		"تحدي تدمير الاكس بو"				, 9, 0, 1], _ ; Destroy 3-12 X-Bows in Multiplayer Battles					|1h-8h	|50-350
				[$g_sImgInferno, 	"تحدي تدمير الانفيرنو"		, 11,0, 1], _ ; Destroy 2 Inferno Towers in Multiplayer Battles				|1h-2d	|50-600
				[$g_sImgEagle, 		"تحدي تدمير مدفع النسر"	, 11,0, 1], _ ; Destroy 1-7 Eagle Artillery in Multiplayer Battles			|1h-2d	|50-600
				[$g_sImgCCC, 		"تحدي تدمير فلعة القبيلة"			, 5, 2, 1], _ ; Destroy 1-4 Clan Castle in Multiplayer Battles				|1h-8h	|40-350
				[$g_sImgGoldRaid, 	"تحدي تدمير مخزن الذهب"				, 3, 2, 1], _ ; Destroy 3-15 Gold Storages in Multiplayer Battles			|1h-8h	|40-350
				[$g_sImgElixirR, 	"تحدي تدمير مخزن الاكسير"			, 3, 1, 1], _ ; Destroy 3-15 Elixir Storages in Multiplayer Battles			|1h-8h	|40-350
				[$g_sImgDESRaid, 	"تحدي تدمير مخزن اكسير الظلام"		, 8, 2, 1], _ ; Destroy 1-4 Dark Elixir Storage in Multiplayer Battles		|1h-8h	|40-350
				[$g_sImgGoldMM, 	"تحدي تدمير مستخرجات الذهب"				, 3, 4, 1], _ ; Destroy 6-20 Gold Mines in Multiplayer Battles				|1h-8h	|40-350
				[$g_sImgElixirPE, 	"تحدي تدمير مستخرجات الاكسير"		, 3, 4, 1], _ ; Destroy 6-20 Elixir Collectors in Multiplayer Battles		|1h-8h	|40-350
				[$g_sImgDarkEP, 	"تحدي تدمير مستخرجات الاكسير الظلام"			, 3, 4, 1], _ ; Destroy 2-8 Dark Elixir Drills in Multiplayer Battles		|1h-8h	|40-350
				[$g_sImgLab, 		"تحدي تدمير المختبر"				, 3, 5, 1], _ ; Destroy 2-6 Laboratories in Multiplayer Battles				|1h-8h	|40-200
				[$g_sImgSFact, 		"تحدي تدمير مصنع السحر"		, 3, 5, 1], _ ; Destroy 2-6 Spell Factories in Multiplayer Battles			|1h-8h	|40-200
				[$g_sImgDSFact, 	"تحدي تدمير مصنع سحر الظلام"	, 8, 5, 1], _ ; Destroy 2-6 Dark Spell Factories in Multiplayer Battles		|1h-8h	|40-200
				[$g_sImgBBAltar, 	"تحدي تدمير مكان الملك"	, 9, 5, 1], _ ; Destroy 2-5 Barbarian King Altars in Multiplayer Battles	|1h-8h	|50-150
				[$g_sImgAQAltar, 	"تحدي تدمير مكان الملكة"	, 10,5, 1], _ ; Destroy 2-5 Archer Queen Altars in Multiplayer Battles		|1h-8h	|50-150
				[$g_sImgGWAltar, 	"تحدي تدمير الامر الكبير"	, 11,5, 1], _ ; Destroy 2-5 Grand Warden Altars in Multiplayer Battles		|1h-8h	|50-150
				[$g_sImgHeroHunt, 	"تحدي قتل  الملوك والحصول على نسبة"				, 9, 3, 8], _ ; Knockout 125 Level Heroes on Multiplayer Battles			|8h		|100
				[$g_sImgKingHunt, 	"تحدي الحصول على نسبة من قتل الملك"				, 9, 1, 8], _ ; Knockout 50 Level King on Multiplayer Battles				|8h		|100
				[$g_sImgQueenHunt, 	"تحدي الحصور على نسبة من قتل الملكة"			, 10,1, 8], _ ; Knockout 50 Level Queen on Multiplayer Battles				|8h		|100
				[$g_sImgWardenHunt, "تحدي الحصول على نسبة من قتل الامر الكبير"			, 11,1, 8]]   ; Knockout 20 Level Warden on Multiplayer Battles				|8h		|100

	Local $MiscChallenges[3][5] = [ _
				[$g_sImgGard,	 	"تحدي ازالة الشجر من القرية ", 3, 5, 8], _ 	; Clear 5 obstacles from your Home Village or Builder Base		|8h	|50
				[$g_sImgDonS,	 	"تحدي نبرع السبيلات"		, 9, 3, 8], _ 	; Donate a total of 10 housing space worth of spells			|8h	|50
				[$g_sImgDonH,	 	"تحدي تبرع القوات"		, 6, 2, 8]]   	; Donate a total of 100 housing space worth of troops			|8h	|50


	; Just in Case
	Local $LocalINI = $sINIPath
	If $LocalINI = "" Then $LocalINI = StringReplace($g_sProfileConfigPath, "config.ini" , "ClanGames_config.ini")

	If $debug Then Setlog(" - Ini Path: " &  $LocalINI)

	; Variables to use
	Local $section[4] = ["Loot Challenges", "Battle Challenges", "Destruction Challenges" , "Misc Challenges"]
	Local $array[4] = [$LootChallenges, $BattleChallenges, $DestructionChallenges, $MiscChallenges]
	Local $ResultIni = "" , $TempChallenge , $tempXSector

	; Store variables
	If $makeIni = False Then

		Switch $sReturnArray
			Case "$AirTroopChallenges"
				Return $AirTroopChallenges
			Case "$GroundTroopChallenges"
				Return $GroundTroopChallenges
			Case "$LootChallenges"
				$TempChallenge = $array[0]
				$tempXSector = $section[0]
			Case "$BattleChallenges"
				$TempChallenge = $array[1]
				$tempXSector = $section[1]
			Case "$DestructionChallenges"
				$TempChallenge = $array[2]
				$tempXSector = $section[2]
			Case "$MiscChallenges"
				$TempChallenge = $array[3]
				$tempXSector = $section[3]
		EndSwitch
		; Read INI File
		If $debug then Setlog("[" & $tempXSector & "]")
		For $j = 0 to Ubound($TempChallenge) - 1
			$ResultIni = Int(IniRead($LocalINI, $tempXSector, $TempChallenge[$j][1], $TempChallenge[$j][3]))
			$TempChallenge[$j][3] = IsNumber($ResultIni) = 1 ? Int($ResultIni) : 0
			If $TempChallenge[$j][3] > 5 Then $TempChallenge[$j][3] = 5
			If $TempChallenge[$j][3] < 0 Then $TempChallenge[$j][3] = 0
			If $debug Then Setlog(" - " & $TempChallenge[$j][1] & ": " &  $TempChallenge[$j][3])
			If $TempChallenge[$j][3] = 0 And not $debug then Setlog(" - " & $TempChallenge[$j][1] & " was disabled by INI file.")
			$ResultIni = ""
		Next
		Return $TempChallenge
	Else

		; Write INI File
		Local $File = FileOpen($LocalINI,  $FO_APPEND)
		Local $HelpText = "; - MyBotRun 2018 - " & @CRLF & _
						  "; - 'Event name' = 'Priority' [1~5][easiest to the hardest] , '0' to disable the event" & @CRLF & _
						  "; - Remember on GUI you can enable/disable an entire Section" & @CRLF & _
						  "; - Do not change any event name" & @CRLF & _
						  "; - Deleting this file will restore the defaults values."&  @CRLF & @CRLF
		FileWrite($File, $HelpText)
		FileClose($File)
		For $i = 0 To UBound($array) -1
			$TempChallenge = $array[$i]
			If $debug Then Setlog("[" & $section[$i] & "]")
			For $j = 0 to UBound($TempChallenge) -1
				If IniWrite($LocalINI, $section[$i], $TempChallenge[$j][1], $TempChallenge[$j][3]) <> 1 Then SetLog("خطأ في :" & $section[$i] & "|" & $TempChallenge[$j][1], $COLOR_WARNING)
				If $debug Then Setlog(" - " & $TempChallenge[$j][1] & ": " &  $TempChallenge[$j][3])
				If _sleep(100) Then Return
			Next
			$TempChallenge = Null
		Next
	EndIf
EndFunc