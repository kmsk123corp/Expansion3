-- TurnsRemaining
-- Author: ebeach
-- DateCreated: 1/20/2011 9:35:24 AM
--------------------------------------------------------------
-- Global Variables
--------------------------------------------------------------
ChinaKoreaCities = {
	{  -- China
		X = 13,
		Y = 3,
	},
	{
		X = 11,
		Y = 6,
	},
	{
		X = 1,
		Y = 12,
	},
	{
		X = 10,
		Y = 13,
	},
	{
		X = 5,
		Y = 21,
	},
	{
		X = 11,
		Y = 21,
	},
	{  --  Beijing
		X = 4,
		Y = 31,
	},
	{
		X = 11,
		Y = 33,
	},
	{
		X = 14,
		Y = 35,
	},
	{
		X = 19,
		Y = 37,
	},
	{  -- Korea
		X = 28,
		Y = 12,
	},
	{
		X = 34,
		Y = 14,
	},
	{
		X = 30,
		Y = 16,
	},
	{
		X = 33,
		Y = 18,
	},
	{ -- Seoul
		X = 30,
		Y = 22,
	},
	{
		X = 34,
		Y = 22,
	},
	{
		X = 27,
		Y = 24,
	},
	{
		X = 27,
		Y = 28,
	},
	{
		X = 30,
		Y = 30,
	},
	{
		X = 24,
		Y = 31,
	},
};
local iChinaCitiesStart = 1; -- Lua counts starting at 1, not 0
local iChinaCitiesEnd = 10; -- inclusive
local iBeijingIndex = 7;
local iSeoulIndex = 15;
local iKyotoX = 49;
local iKyotoY = 15;
local iFeAlaX = 30;
local iFeAlaY = 41;
local iScenarioMaxTurns = 100;
--------------------------------------------------------------

function GetVictoryPlayers()
	local iJapan;
	local iKorea;
	local iChina;
	local iManchu;
	-- Find out who the players are
	for iPlayer = 0, 3, 1 do

		local pPlayer = Players[iPlayer];
		local playerStartPlot = pPlayer:GetStartingPlot();
		
		if (playerStartPlot:GetX() == iKyotoX and playerStartPlot:GetY() == iKyotoY) then
			iJapan = iPlayer;
		elseif (playerStartPlot:GetX() == iFeAlaX and playerStartPlot:GetY() == iFeAlaY) then
			iManchu = iPlayer;
		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iSeoulIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iSeoulIndex].Y) then
			iKorea = iPlayer;
		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iBeijingIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iBeijingIndex].Y) then
			iChina = iPlayer;
		end
	end

	--	print ("Japan: " .. tostring(iJapan));
	--	print ("Manchu: " .. tostring(iManchu));
	--	print ("Korea: " .. tostring(iKorea));
	--	print ("China: " .. tostring(iChina));
	
	return iJapan, iManchu, iKorea, iChina;
end

--------------------------------------------------------------
ContextPtr:SetUpdate(function()

	if (Game.GetGameState() == GameplayGameStateTypes.GAMESTATE_ON) then
		local iTurnsRemaining = iScenarioMaxTurns - Game.GetGameTurn();
		local iCitiesToRegain = 0;
		local iBeijingOwner;
		local iSeoulOwner;
		
		local iJapan, iManchu, iKorea, iChina = GetVictoryPlayers();

		-- Find out who controls all the cities
		for i, city in ipairs(ChinaKoreaCities) do
		
			local pPlot = Map.GetPlot(ChinaKoreaCities[i].X, ChinaKoreaCities[i].Y);
			local pCity = pPlot:GetPlotCity();
			if (pCity ~= nil) then
				if (pCity:GetOwner() ~= iKorea and pCity:GetOwner() ~= iChina) then
					iCitiesToRegain = iCitiesToRegain + 1;
				end
			else
				print ("Scripting error.");
			end
		end

		iBeijingOwner = Map.GetPlot(ChinaKoreaCities[iBeijingIndex].X, ChinaKoreaCities[iBeijingIndex].Y):GetOwner();
		iSeoulOwner = Map.GetPlot(ChinaKoreaCities[iSeoulIndex].X, ChinaKoreaCities[iSeoulIndex].Y):GetOwner();
		iYear = Game.GetGameTurnYear();
	--	print ("Beijing Owner: " .. tostring(iBeijingOwner));
	--	print ("Seoul Owner: " .. tostring(iSeoulOwner));
	--	print ("Cities to Regain: " .. tostring(iCitiesToRegain));
	--	print ("Year" .. tostring(iYear));

		local turnsRemainingText = Locale.ConvertTextKey("TXT_KEY_KOREA_SCENARIO_TURNSREMAINING", iTurnsRemaining);
		local iActivePlayer = Game.GetActivePlayer();
		local szSecondLine;

		if (iActivePlayer == iManchu or iActivePlayer == iJapan) then
			szSecondLine = Locale.ConvertTextKey("TXT_KEY_KOREA_SCENARIO_NEED_TO_CONQUER");
			if (iSeoulOwner ~= iActivePlayer) then
				local szName = Map.GetPlot(ChinaKoreaCities[iSeoulIndex].X, ChinaKoreaCities[iSeoulIndex].Y):GetPlotCity():GetName();
				szSecondLine = szSecondLine .. " " .. szName;
			end
			if (iBeijingOwner ~= iActivePlayer) then
				local szName = Map.GetPlot(ChinaKoreaCities[iBeijingIndex].X, ChinaKoreaCities[iBeijingIndex].Y):GetPlotCity():GetName();
				szSecondLine = szSecondLine .. " " .. szName;
			end

		else
			if (iCitiesToRegain == 0) then
				szSecondLine = Locale.ConvertTextKey("TXT_KEY_KOREA_SCENARIO_HOLD_CITIES");
			else
				szSecondLine = Locale.ConvertTextKey("TXT_KEY_KOREA_SCENARIO_NEED_TO_REGAIN", iCitiesToRegain);
			end
		end
		turnsRemainingText = turnsRemainingText .. szSecondLine;
		Controls.TurnsRemainingLabel:LocalizeAndSetText(turnsRemainingText);
		Controls.Grid:DoAutoSize();
	else
		ContextPtr:ClearUpdate(); 
		ContextPtr:SetHide( true );
	end
end);

---------------------------------------------------------------------
function TestVictory()

	local iTurnsRemaining = iScenarioMaxTurns - Game.GetGameTurn();
	local iOtherLeadersAlive = 0;
	local iCitiesToRegain = 0;
	local iBeijingOwner;
	local iSeoulOwner;

	local iJapan, iManchu, iKorea, iChina = GetVictoryPlayers();

	-- Find out who controls all the cities
	for i, city in ipairs(ChinaKoreaCities) do
	
		local pPlot = Map.GetPlot(ChinaKoreaCities[i].X, ChinaKoreaCities[i].Y);
		local pCity = pPlot:GetPlotCity();
		if (pCity ~= nil) then
			if (pCity:GetOwner() ~= iKorea and pCity:GetOwner() ~= iChina) then
			    iCitiesToRegain = iCitiesToRegain + 1;
			end
		else
			print ("Scripting error.");
		end
	end

	iBeijingOwner = Map.GetPlot(ChinaKoreaCities[iBeijingIndex].X, ChinaKoreaCities[iBeijingIndex].Y):GetOwner();
	iSeoulOwner = Map.GetPlot(ChinaKoreaCities[iSeoulIndex].X, ChinaKoreaCities[iSeoulIndex].Y):GetOwner();
	iYear = Game.GetGameTurnYear();
--	print ("Beijing Owner: " .. tostring(iBeijingOwner));
--	print ("Seoul Owner: " .. tostring(iSeoulOwner));
--	print ("Cities to Regain: " .. tostring(iCitiesToRegain));
--	print ("Year" .. tostring(iYear));

	-- Loop through all the Majors checking for victory
	for iPlayerLoop = 0, 3, 1 do
		local player = Players[iPlayerLoop];
		if (player:IsAlive()) then	
			iOtherLeadersAlive = iOtherLeadersAlive + 1;
		end
	end

	PreGame.SetGameOption("GAMEOPTION_NO_EXTENDED_PLAY", true);	-- No extended play allowed
	
	if (iTurnsRemaining < 1 or Game.GetGameState() == GameplayGameStateTypes.GAMESTATE_EXTENDED) then
		Game.SetGameState(GameplayGameStateTypes.GAMESTATE_OVER);
		GameEvents.GameCoreTestVictory.Remove(TestVictory);

	elseif (iOtherLeadersAlive == 0) then
		Game.SetWinner(Players[Game.GetActivePlayer()]:GetTeam(), GameInfo.Victories["VICTORY_DOMINATION"].ID);
		GameEvents.GameCoreTestVictory.Remove(TestVictory);

	elseif (iBeijingOwner == iManchu and iSeoulOwner == iManchu) then
		Game.SetWinner(Players[iManchu]:GetTeam(), GameInfo.Victories["VICTORY_DOMINATION"].ID);
		GameEvents.GameCoreTestVictory.Remove(TestVictory);

	elseif (iBeijingOwner == iJapan and iSeoulOwner == iJapan) then
		Game.SetWinner(Players[iJapan]:GetTeam(), GameInfo.Victories["VICTORY_DOMINATION"].ID);
		GameEvents.GameCoreTestVictory.Remove(TestVictory);

	elseif (iYear >= 1600 and iCitiesToRegain < 1) then
		Game.SetWinner(Players[iKorea]:GetTeam(), GameInfo.Victories["VICTORY_DOMINATION"].ID);
		GameEvents.GameCoreTestVictory.Remove(TestVictory);
		
	end
		
end
GameEvents.GameCoreTestVictory.Add(TestVictory);

---------------------------------------------------------------------
function OnBriefingButton()
    UI.AddPopup( { Type = ButtonPopupTypes.BUTTONPOPUP_TEXT,
                   Data1 = 800,
                   Option1 = true,
                   Text = "TXT_KEY_KOREA_SCENARIO_CIV5_DAWN_KOREA_TEXT" } );
end
Controls.BriefingButton:RegisterCallback( Mouse.eLClick, OnBriefingButton );

---------------------------------------------------------------------
function OnEnterCityScreen()
    ContextPtr:SetHide( true );
end
Events.SerialEventEnterCityScreen.Add( OnEnterCityScreen );

---------------------------------------------------------------------
function OnExitCityScreen()

	if (Game:GetGameState() ~= GameplayGameStateTypes.GAMESTATE_EXTENDED) then 
    		ContextPtr:SetHide( false );
	end
end
Events.SerialEventExitCityScreen.Add( OnExitCityScreen );

-------------------------------------------------
-- UnitKilledInCombat
-------------------------------------------------
GameEvents.UnitKilledInCombat.Add(function(iPlayer, iKilledPlayer) 

	-- Unit killed from a major civ?
	if (iKilledPlayer < 4) then
 		Players[iPlayer]:ChangeScoreFromFutureTech(50);
	end
end);

-------------------------------------------------
-- CityCaptureComplete
-------------------------------------------------
GameEvents.CityCaptureComplete.Add(function(iOldOwner, bIsCapital, iX, iY, iNewOwner)

	local plot = Map.GetPlot(iX, iY);
	local cCity = plot:GetPlotCity();
	local iNewOwner = cCity:GetOwner();
	
	-- Is the capturer the Manchu?
	local pNewOwner = Players[iNewOwner];
	local playerStartPlot = pNewOwner:GetStartingPlot();
	if (playerStartPlot:GetX() == iFeAlaX and playerStartPlot:GetY() == iFeAlaY) then
		-- Manchu captured a city, so check achievement
		CheckManchuAchievement(iNewOwner);
	end
	
	if (iX == ChinaKoreaCities[iSeoulIndex].X and iY == ChinaKoreaCities[iSeoulIndex].Y) then

		Players[iOldOwner]:ChangeScoreFromTechs(-5000);
		Players[iNewOwner]:ChangeScoreFromTechs(5000);
 
	elseif (iX == ChinaKoreaCities[iBeijingIndex].X and iY == ChinaKoreaCities[iBeijingIndex].Y) then

		Players[iOldOwner]:ChangeScoreFromTechs(-5000);
		Players[iNewOwner]:ChangeScoreFromTechs(5000);

	end
end);
-------------------------------------------------
-- PlayerDoTurn
-------------------------------------------------
GameEvents.PlayerDoTurn.Add(function(iPlayer) 

	local pPlayer = Players[iPlayer];
	local playerStartPlot = pPlayer:GetStartingPlot();
	local savedData = Modding.OpenSaveData();

	local iValue = savedData.GetValue("NextGuerillaTurn");  
	if (iValue ~= nil) then

		if (Game.GetGameTurn() == iValue) then
		
			-- Korea
			if (playerStartPlot:GetX() == ChinaKoreaCities[iSeoulIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iSeoulIndex].Y) then
				AddKoreaGuerillas();
				iValue = iValue + Game.Rand(6, "Next guerilla arrival") + 7;
				savedData.SetValue("NextGuerillaTurn", iValue);
				print ("New Guerilla Turn: " .. tostring(iValue));
			end
		end
	end

	if (iPlayer > 0 and iPlayer < 4) then
		local iValue = savedData.GetValue("NextAIBonusTurn");
		if (iValue ~= nil) then

			if (Game.GetGameTurn() == iValue) then	
				AddUnitsPerDifficulty(iPlayer);
			end

			-- Reset on last major power's turn
			if (Game.GetGameTurn() == iValue and iPlayer == 3) then
				local iHandicap = Game:GetHandicapType();
				iValue = iValue + Game.Rand(4, "Next AI bonus turn") + 16 - (2 * iHandicap);
				savedData.SetValue("NextAIBonusTurn", iValue);
				print ("New AI Bonus Turn: " .. tostring(iValue));
			end
		end
	end
end);

-------------------------------------------------
-- CheckManchuAchievement
-------------------------------------------------
function CheckManchuAchievement(iManchuPlayer)
	print("Checking for Manchu achievement");
	if (Players[iManchuPlayer]:IsHuman()) then
		-- Loop through all original Chinese cities to check if Manchu has captured them
		for iCity = iChinaCitiesStart, iChinaCitiesEnd do
			local pPlot = Map.GetPlot(ChinaKoreaCities[iCity].X, ChinaKoreaCities[iCity].Y);
			local pCity = pPlot:GetPlotCity();
			if (pCity ~= nil) then
				if (pCity:GetOwner() ~= iManchuPlayer) then
					return;
				end
				print("Manchu owns " .. pCity:GetName() .. " (" .. iCity .. "/" .. iChinaCitiesEnd .. ")");
			else
				return;
			end
		end
		-- Looped through all the cities, so unlock the achievement
		UI.UnlockAchievement("ACHIEVEMENT_SCENARIO_05_QING_TAKES_MING");
	end
end
---------------------------------------------------------
function AddUnitsForAI()
	
	local iHandicap = Game:GetHandicapType();

	-- Loop through all the Majors
	for iPlayerLoop = 0, 3, 1 do
		local pPlayer = Players[iPlayerLoop];
		local playerStartPlot = pPlayer:GetStartingPlot();

		if (playerStartPlot:GetX() == iKyotoX and playerStartPlot:GetY() == iKyotoY) then

			-- Japan
			if (iPlayerLoop ~= 0) then
				iUnitID = GameInfoTypes["UNIT_JAPANESE_SAMURAI"];
				unit = pPlayer:InitUnit (iUnitID, 35, 22, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				unit = pPlayer:InitUnit (iUnitID, 35, 21, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				unit = pPlayer:InitUnit (iUnitID, 36, 20, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				unit = pPlayer:InitUnit (iUnitID, 35, 19, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				iUnitID = GameInfoTypes["UNIT_MUSKETMAN"];
				unit = pPlayer:InitUnit (iUnitID, 36, 22, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				unit = pPlayer:InitUnit (iUnitID, 36, 21, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				unit = pPlayer:InitUnit (iUnitID, 36, 18, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				unit = pPlayer:InitUnit (iUnitID, 36, 19, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				iUnitID = GameInfoTypes["UNIT_TREBUCHET"];
				unit = pPlayer:InitUnit (iUnitID, 37, 18, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);				
				unit = pPlayer:InitUnit (iUnitID, 37, 20, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
				unit:SetEmbarked(true);
				unit:SetDeployFromOperationTurn(1);	
				pPlayer:AddTemporaryDominanceZone (34, 22)		
				
				local pPlot = Map.GetPlot(35, 7);
				pPlot:SetImprovementType(GameInfoTypes["IMPROVEMENT_WAJO"]);
				local pPlot = Map.GetPlot(35, 9);
				pPlot:SetImprovementType(GameInfoTypes["IMPROVEMENT_WAJO"]);
				local pPlot = Map.GetPlot(34, 11);
				pPlot:SetImprovementType(GameInfoTypes["IMPROVEMENT_WAJO"]);
				local pPlot = Map.GetPlot(33, 12);
				pPlot:SetImprovementType(GameInfoTypes["IMPROVEMENT_WAJO"]);
				local pPlot = Map.GetPlot(33, 14);
				pPlot:SetImprovementType(GameInfoTypes["IMPROVEMENT_WAJO"]);
				local pPlot = Map.GetPlot(34, 15);
				pPlot:SetImprovementType(GameInfoTypes["IMPROVEMENT_WAJO"]);
			
				local pPlayerTeam = Teams[pPlayer:GetTeam()];
				iTechID = GameInfoTypes["TECH_ASTRONOMY"];
				pPlayerTeam:SetHasTech (iTechID, true);

				print ("Japanese AI invasion force added.");	
			end

		elseif (playerStartPlot:GetX() == iFeAlaX and playerStartPlot:GetY() == iFeAlaY) then

			-- Manchu
			if (iPlayerLoop ~= 0) then
			end

		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iSeoulIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iSeoulIndex].Y) then

			-- Korea: Remove units if human or allied with human
			if (iPlayerLoop == 0 or Players[0]:GetStartingPlot():GetX() == ChinaKoreaCities[iBeijingIndex].X) then
	
				if (iHandicap > 3) then
					pPlot = Map.GetPlot(28,22);
					pPlot:GetUnit(0):Kill(true, -1);  
				end

				if (iHandicap > 4) then
					pPlot = Map.GetPlot(28,25);
					pPlot:GetUnit(0):Kill(true, -1);  
				end

				if (iHandicap > 5) then
					pPlot = Map.GetPlot(30,22);
					pPlot:GetUnit(0):Kill(true, -1);  
				end

				if (iHandicap > 6) then
					pPlot = Map.GetPlot(27,22);
					pPlot:GetUnit(0):Kill(true, -1);  
				end
			end

		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iBeijingIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iBeijingIndex].Y) then

			-- China: Remove units if human or allied with human
			if (iPlayerLoop == 0 or Players[0]:GetStartingPlot():GetX() == ChinaKoreaCities[iSeoulIndex].X) then
	
				if (iHandicap > 3) then
					pPlot = Map.GetPlot(15,24);
					pPlot:GetUnit(0):Kill(true, -1);  
					pPlot = Map.GetPlot(11,21);
					pPlot:GetUnit(0):Kill(true, -1);  
				end

				if (iHandicap > 4) then
					pPlot = Map.GetPlot(11,33);
					pPlot:GetUnit(0):Kill(true, -1);  
					pPlot = Map.GetPlot(1,12);
					pPlot:GetUnit(0):Kill(true, -1);  
				end

				if (iHandicap > 5) then
					pPlot = Map.GetPlot(11,34);
					pPlot:GetUnit(0):Kill(true, -1);  
					pPlot = Map.GetPlot(11,6);
					pPlot:GetUnit(0):Kill(true, -1);  
				end

				if (iHandicap > 6) then
					pPlot = Map.GetPlot(19,37);
					pPlot:GetUnit(0):Kill(true, -1);  
					pPlot = Map.GetPlot(13,3);
					pPlot:GetUnit(0):Kill(true, -1);  
				end
			end
		end
	end
end
---------------------------------------------------------
function AddUnitsPerDifficulty(iPlayer)
	
	local pPlayer = Players[iPlayer];
	local playerStartPlot = pPlayer:GetStartingPlot();
	local bJapanReinforced = false;

	if (playerStartPlot:GetX() == iKyotoX and playerStartPlot:GetY() == iKyotoY) then
		
		-- Japan
		iUnitID = GameInfoTypes["UNIT_MUSKETMAN"];
		unit = pPlayer:InitUnit (iUnitID, 42, 12, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();
		unit = pPlayer:InitUnit (iUnitID, 43, 12, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();
		
		local pPlot = Map.GetPlot(33, 14);
		if (pPlot:GetImprovementType() == GameInfoTypes["IMPROVEMENT_WAJO"]) then
			unit = pPlayer:InitUnit (iUnitID, 33, 14, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			unit = pPlayer:InitUnit (iUnitID, 33, 14, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			bJapanReinforced = true;
		end

		
		local pPlot = Map.GetPlot(34, 15);
		if (pPlot:GetImprovementType() == GameInfoTypes["IMPROVEMENT_WAJO"]) then
			unit = pPlayer:InitUnit (iUnitID, 34, 15, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			unit = pPlayer:InitUnit (iUnitID, 34, 15, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			bJapanReinforced = true;
		end

		if (bJapanReinforced) then
			local popupInfo = {
				Data1 = 500,
				Type = ButtonPopupTypes.BUTTONPOPUP_TEXT,
				Text = Locale.ConvertTextKey("TXT_KEY_KOREA_SCENARIO_WAJO_REINFORCEMENTS");
			}
			UI.AddPopup(popupInfo);
		end
		
		iUnitID = GameInfoTypes["UNIT_CARAVEL"];
		unit = pPlayer:InitUnit (iUnitID, 43, 11, UNITAI_ATTACK_SEA, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();
		unit = pPlayer:InitUnit (iUnitID, 42, 11, UNITAI_ATTACK_SEA, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();

	elseif (playerStartPlot:GetX() == iFeAlaX and playerStartPlot:GetY() == iFeAlaY) then

		-- Manchu
		if (Game.GetGameTurn() < 40) then
			iUnitID = GameInfoTypes["UNIT_PIKEMAN"];
		else
			iUnitID = GameInfoTypes["UNIT_MUSKETMAN"];		
		end
		unit = pPlayer:InitUnit (iUnitID, 25, 48, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();
		unit = pPlayer:InitUnit (iUnitID, 26, 48, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();
		iUnitID = GameInfoTypes["UNIT_CROSSBOWMAN"];
		unit = pPlayer:InitUnit (iUnitID, 27, 48, UNITAI_RANGED, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();
		unit = pPlayer:InitUnit (iUnitID, 24, 48, UNITAI_RANGED, DirectionTypes.DIRECTION_WEST);
		unit:JumpToNearestValidPlot();

		-- Add a clan with these units if less than Turn 20
		if (Game.GetGameTurn() < 20) then
			iUnitID = GameInfoTypes["UNIT_SETTLER"];
			unit = pPlayer:InitUnit (iUnitID, 26, 48);	
			unit:JumpToNearestValidPlot();
		end

		print ("Manchu adds extra AI units based on difficulty.");	

	elseif (playerStartPlot:GetX() == ChinaKoreaCities[iSeoulIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iSeoulIndex].Y) then

		-- Korea (none, they get Guerillas)	

	elseif (playerStartPlot:GetX() == ChinaKoreaCities[iBeijingIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iBeijingIndex].Y) then

		-- China

		-- Don't grant units if allied with human
		if (Players[0]:GetStartingPlot():GetX() ~= ChinaKoreaCities[iSeoulIndex].X) then
			iUnitID = GameInfoTypes["UNIT_MUSKETMAN"];
			unit = pPlayer:InitUnit (iUnitID, 4, 23, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			unit = pPlayer:InitUnit (iUnitID, 4, 22, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			unit = pPlayer:InitUnit (iUnitID, 4, 16, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			unit = pPlayer:InitUnit (iUnitID, 4, 15, UNITAI_DEFENSE, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			iUnitID = GameInfoTypes["UNIT_CARAVEL"];
			unit = pPlayer:InitUnit (iUnitID, 13, 14, UNITAI_ATTACK_SEA, DirectionTypes.DIRECTION_WEST);
			unit:JumpToNearestValidPlot();
			print ("China adds extra AI units based on difficulty.");	
		end
	end
end
---------------------------------------------------------
function SetInitialPolicies()
	
	-- Loop through all the Majors
	for iPlayerLoop = 0, 3, 1 do
		local pPlayer = Players[iPlayerLoop];
		local playerStartPlot = pPlayer:GetStartingPlot();

		if (playerStartPlot:GetX() == iKyotoX and playerStartPlot:GetY() == iKyotoY) then

			-- Japan
			if (iPlayerLoop ~= 0) then
				pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_PIETY"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_ORGANIZED_RELIGION"].ID, true);
				pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_HONOR"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_DISCIPLINE"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_MILITARY_CASTE"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_PROFESSIONAL_ARMY"].ID, true);
				pPlayer:SetJONSCulture(0);
			end

		elseif (playerStartPlot:GetX() == iFeAlaX and playerStartPlot:GetY() == iFeAlaY) then

			-- Manchu (do nothing, policy choice not crital)

		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iSeoulIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iSeoulIndex].Y) then

			-- Korea
			if (iPlayerLoop ~= 0) then
				pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_PIETY"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_ORGANIZED_RELIGION"].ID, true);
				pPlayer:SetJONSCulture(1740);
	
			end
			

			--   Also set score for Seoul
			pPlayer:ChangeScoreFromTechs(5000);

		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iBeijingIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iBeijingIndex].Y) then

			-- China
			if (iPlayerLoop ~= 0) then
				pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_PIETY"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_ORGANIZED_RELIGION"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_CITIZENSHIP"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_MERITOCRACY"].ID, true);
				pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_HONOR"].ID, true);
				pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_DISCIPLINE"].ID, true);
				pPlayer:SetJONSCulture(0);
			end

			--   Also set score for Beijing
			pPlayer:ChangeScoreFromTechs(5000);
		end
	end
end
---------------------------------------------------------
function SetInitialCityBuilds()

	local pCity;

	print ("In SetInitialCityBuilds");

	for iPlayer = 0, 3, 1 do

		local pPlayer = Players[iPlayer];
		local playerStartPlot = pPlayer:GetStartingPlot();

		if (playerStartPlot:GetX() == iKyotoX and playerStartPlot:GetY() == iKyotoY) then

			-- Japan
			pCity = Map.GetPlot(36,6):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_MUSKETMAN"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(45,9):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_MUSKETMAN"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(43,12):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_MUSKETMAN"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(49,15):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_MUSKETMAN"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(53,15):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_MUSKETMAN"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(60,18):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_JAPANESE_SAMURAI"].ID, -1, 0, false, false);
		
		elseif (playerStartPlot:GetX() == iFeAlaX and playerStartPlot:GetY() == iFeAlaY) then

			-- Manchu
			pCity = Map.GetPlot(iFeAlaX ,iFeAlaY):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_SETTLER"].ID, -1, 0, false, false);

		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iSeoulIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iSeoulIndex].Y) then
			
			-- Korea
			pCity = Map.GetPlot(28,12):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_TRIREME"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(34,14):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_CONSTRUCT, GameInfo.Buildings["BUILDING_WALLS"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(30,16):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_CONSTRUCT, GameInfo.Buildings["BUILDING_WALLS"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(33,18):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_CONSTRUCT, GameInfo.Buildings["BUILDING_WALLS"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(30,22):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_KOREAN_HWACHA"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(34,22):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_TRIREME"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(27,24):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_KOREAN_TURTLE_SHIP"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(27,28):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_KOREAN_HWACHA"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(30,30):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_KOREAN_TURTLE_SHIP"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(24,31):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_CONSTRUCT, GameInfo.Buildings["BUILDING_WALLS"].ID, -1, 0, false, false);

		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iBeijingIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iBeijingIndex].Y) then

			-- China
			pCity = Map.GetPlot(13,3):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_HORSEMAN"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(11,6):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_HORSEMAN"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(1,12):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_CHINESE_CHUKONU"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(10,13):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_TRIREME"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(5,21):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_CHINESE_CHUKONU"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(11,21):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_CARAVEL"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(4,31):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_CONSTRUCT, GameInfo.Buildings["BUILDING_FORGE"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(11,33):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_CHINESE_CHUKONU"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(14,35):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_CHINESE_CHUKONU"].ID, -1, 0, false, false);
			pCity = Map.GetPlot(19,37):GetPlotCity();
			pCity:PushOrder (OrderTypes.ORDER_TRAIN, GameInfo.Units["UNIT_CHINESE_CHUKONU"].ID, -1, 0, false, false);
		end	
	end
end

---------------------------------------------------------
function AddKoreaGuerillas()

	local iKoreanCitiesCapturedByJapan = 0;
	local iJapan;
	local iKorea;
	local pPlayer;
	local iUnitID;
	local unit;

	-- Find Japan
	for iPlayerLoop = 0, 3, 1 do
		pPlayer = Players[iPlayerLoop];
		local playerStartPlot = pPlayer:GetStartingPlot();

		if (playerStartPlot:GetX() == iKyotoX and playerStartPlot:GetY() == iKyotoY) then
			iJapan = iPlayerLoop;
		elseif (playerStartPlot:GetX() == ChinaKoreaCities[iSeoulIndex].X and playerStartPlot:GetY() == ChinaKoreaCities[iSeoulIndex].Y) then
			iKorea = iPlayerLoop;
		end
	end


	-- Find out who controls all the cities
	for i, city in ipairs(ChinaKoreaCities) do

		-- Korea only
		if (ChinaKoreaCities[i].X > 23) then
	
			local pPlot = Map.GetPlot(ChinaKoreaCities[i].X, ChinaKoreaCities[i].Y);
			local pCity = pPlot:GetPlotCity();
			if (pCity ~= nil) then
				if (pCity:GetOwner() == iJapan) then
			    		iKoreanCitiesCapturedByJapan = iKoreanCitiesCapturedByJapan + 1;
				end
			else
				print ("Scripting error.");
			end
		end
	end

	-- One-third of units are Turtle Ships, Two-thirds guerillas
	local iTurtleShips = iKoreanCitiesCapturedByJapan / 3;
	local iGuerillas = iKoreanCitiesCapturedByJapan - iTurtleShips;

	pPlayer = Players[iKorea];
	local iX, iY, iRand;
	for iLoop = 1, iTurtleShips, 1 do
		iUnitID = GameInfoTypes["UNIT_KOREAN_TURTLE_SHIP"];
		iRand = Game.Rand(4, "Turtle ship start");
		if (iRand == 0) then
			iX = 23;
			iY = 29;
		elseif (iRand == 1) then
			iX = 18;
			iY = 27;
		elseif (iRand == 2) then
			iX = 28;
			iY = 8;
		else
			iX = 33;
			iY = 31;
		end
		unit = pPlayer:InitUnit (iUnitID, iX, iY);
		unit:JumpToNearestValidPlot();
	end

	for iLoop = 1, iGuerillas, 1 do
		iRand = iLoop % 6;
		if (iRand == 1) then
			iX = 31;
			iY = 17;
		elseif (iRand == 2) then
			iX = 31;
			iY = 16;
		elseif (iRand == 3) then
			iX = 32;
			iY = 24;
		elseif (iRand == 4) then
			iX = 32;
			iY = 23;
		elseif (iRand == 5) then
			iX = 29;
			iY = 20;
		else
			iX = 28;
			iY = 19;
		end
		iRand = Game.Rand(4, "Unit type");
		if (iRand < 2) then
			iUnitID = GameInfoTypes["UNIT_ARCHER"];
		elseif (iRand == 2) then
			iUnitID = GameInfoTypes["UNIT_PIKEMAN"];
		else
			iUnitID = GameInfoTypes["UNIT_MUSKETMAN"];
		end

		unit = pPlayer:InitUnit (iUnitID, iX, iY);
		-- unit:JumpToNearestValidPlot(); -- NO, want them behind enemy lines!
		if (iUnitID == GameInfoTypes["UNIT_ARCHER"]) then
			local iPromotionID = GameInfoTypes["PROMOTION_GUERILLA_WITHDRAW"];
			unit:SetHasPromotion(iPromotionID, true);
		end
	end
	
	-- Put up dialog box
	local popupInfo = {
		Data1 = 500,
		Type = ButtonPopupTypes.BUTTONPOPUP_TEXT,
		Text = Locale.ConvertTextKey("TXT_KEY_KOREA_SCENARIO_GUERILLAS_SPAWNED");
	}
	UI.AddPopup(popupInfo);

	print ("Finished adding Korean guerillas (Turtle Ships, Melee): (" .. tostring(iTurtleShips) .. ", " .. tostring(iGuerillas) .. ")");
end

---------------------------------------------------------------------
-- INITIAL INITIALIZATION
---------------------------------------------------------------------

local savedData = Modding.OpenSaveData();
local iValue = savedData.GetValue("NextAIBonusTurn");

if (iValue == nil) then

	print ("In Initial Initialization");
	savedData.SetValue("NextGuerillaTurn", 10);

	local iHandicap = Game:GetHandicapType();
	savedData.SetValue("NextAIBonusTurn", 18 - (2 * iHandicap));
	
	-- Add AI At Start Forces
	AddUnitsForAI();

	-- Set initial policies
	SetInitialPolicies();
	
	-- What will our cities build?
	SetInitialCityBuilds();
end
