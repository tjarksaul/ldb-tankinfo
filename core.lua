local ldb = LibStub:GetLibrary("LibDataBroker-1.1");

TankInfo = LibStub("AceAddon-3.0"):NewAddon("Broker_TankInfo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("TankInfo");
local TankInfo = TankInfo

-- creating ldb data object
local doTable = {
	type = "data source", 
	text = '|c0066ff00'..L["Avoidance: "]..'|r|c00ff0000'.."UNKNOWN|r", 
	label = 'Broker TankInfo', 
	icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance"
}
local dataobj = ldb:NewDataObject("tankinfo", doTable)

-- creating variables
local level, bosslvl;
local enemymiss, dodge, block, parry;
local blockvalue;
local armor, health, eh, armorDR;
local avoidance, mitigation;
local enemycrit, normalhit;
local defaults;

-- default values for db
do
	defaults = {
		char = {
			bosslvl = UnitLevel('player') + 3,
			r1, g1, b1 = 0,0.4,1,
			r2, g2, b2 = 0,1,0,
			enabled = true;
		}
	}
end;

--[[
function TankInfo:TankInfoSlash(input)
	if input == 'config' then
		InterfaceOptionsFrame_OpenToCategory(frame.name);
	end;
end;
--]]

-- stolen from TankInfosFu
function TankInfo:getBlockval()
  local link = GetInventoryItemLink("player",GetInventorySlotInfo("HeadSlot"))
  local bval = GetShieldBlock()
  local gem  = nil
  local bval_mod = 1
  local _, clss = UnitClass("player");

  if link then
    gem = GetItemGem(link,1)
  end

  bval_unmodified = bval
  if gem and (gem == L['Eternal Earthstorm Diamond'] or gem == L['Eternal Earthsiege Diamond']) then
    bval_mod = bval_mod + 0.05
  end

  -- get block value modifier in talents
  local numTabs = GetNumTalentTabs();
  for t=1, numTabs do
    local numTalents = GetNumTalents(t);
    for i=1, numTalents do
      local nameTalent, _, _, _, currRank, _ = GetTalentInfo(t,i);
      if nameTalent == L["Shield Mastery"] or (nameTalent == L["Shield Specialization"] and clss ~= "WARRIOR") then
        if clss == "SHAMAN" then
          bval_mod = bval_mod + currRank * 5 / 100 -- rank is 1..5, values are 5%, 10%, 15%, 20%, 25%
        else
          bval_mod = bval_mod + currRank * 15 / 100 -- rank is 1, 2 values are: 15%, 30%
        end

        break
      end
    end
  end

  return bval, floor(bval_unmodified / bval_mod)
end

function TankInfo:getBasicMiss()
  local bdef, adef = UnitDefense("player")
  return (adef + bdef - bosslvl * 5) * 0.04
end

function TankInfo:getArmor()
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
	return effectiveArmor;
end;

function TankInfo:getCritReduce()
	local defenseskill = GetCombatRating(CR_DEFENSE_SKILL);
	local relevant = defenseskill - (level * 5);
	local reduce = relevant * 0.04;
	return reduce;
end;

function TankInfo:Values()
	level = UnitLevel("player");
	bosslvl = level + 3;
	dodge = GetDodgeChance();
	parry = GetParryChance();
	block = floor(GetBlockChance() * 100) / 100;
	blockvalue = self:getBlockval();
	enemymiss = self:getBasicMiss();
	armor = self:getArmor();
	if (bosslvl < 60) then
		armorDR = armor / (armor + 400 + 85 * bosslvl);
	else
		armorDR = (armor / ((467.5 * bosslvl) + armor - 22167.5));
	end;
	health = UnitHealth("player");
	eh = floor(health / (1 - armorDR));
	avoidance = floor((enemymiss + dodge + parry + 5) * 100) / 100;
	mitigation = avoidance + block;
	if (self:getCritReduce() > 5.6) then
		enemycrit = 0;
	else
		enemycrit = 5.6 - self:getCritReduce();
	end;
	normalhit = 100 - mitigation;
end;

function TankInfo:UpdateLDB()
	self:Values();
	dataobj.text = '|c000066ff'..L["Avoidance: "]..'|r|c0000ff00'..avoidance.."%|r";
end;

function TankInfo:Aura(unit)
	if (unit == "player") then
		self:UpdateLDB();
	end;
end;

function TankInfo:levelup(arg1)
	level = arg1;
	self:UpdateLDB();
end;

-- what will be printed in the tooltip
function TankInfo:OnTooltipShow()
	self:AddLine(L['Defense Stats'],1,1,1);
	self:AddDoubleLine(L['Enemymiss']..': ',(enemymiss + 5)..'%',0,0.4,1,0,0.4,1); -- adds enemymiss line
	self:AddDoubleLine(L['Dodge']..': ',floor(dodge * 100) / 100 ..'%',0,1,0,0,1,0); -- adds dodge line
	self:AddDoubleLine(L['Parry']..': ',floor(parry * 100) / 100 ..'%',0,0.4,1,0,0.4,1); -- adds parry line
	self:AddDoubleLine(L['Avoidance']..': ',avoidance..'%',0,1,0,0,1,0); -- adds avoidance line
	self:AddDoubleLine(L['dwAvoid']..': ',(avoidance + 24)..'%',0,0.4,1,0,0.4,1); -- adds dw avoidance line
	self:AddDoubleLine(L['Block Chance']..': ',block..'%',0,1,0,0,1,0); -- adds block chance line
	self:AddDoubleLine(L['Block Value']..': ',blockvalue,0,0.4,1,0,0.4,1); -- adds block value line
	self:AddDoubleLine(L['Mitigation']..': ',mitigation..'%',0,1,0,0,1,0); -- adds mitigation line
	self:AddDoubleLine(L['dwMitigation']..': ',(mitigation + 24)..'%',0,0.4,1,0,0.4,1) -- adds dw mitigation line
	self:AddDoubleLine(L['NormalHit']..': ',normalhit..'%',0,1,0,0,1,0); -- adds line for chance to get a normal hit
	self:AddDoubleLine(L['GetCrit']..': ',enemycrit..'%',0,0.4,1,0,0.4,1); -- adds line for chance to get critically hit
	self:AddLine(' '); -- adds empty line
	self:AddDoubleLine(L['Health']..': ',health,0,0.4,1,0,0.4,1); -- adds health line
	self:AddDoubleLine(L['ArmorDR']..': ',floor(armorDR * 10000) / 100 ..'%',0,1,0,0,1,0); -- adds line for damage reduction by armor
	self:AddDoubleLine(L['EH']..': ',eh,0,0.4,1,0,0.4,1); -- adds line for effective health
	self:AddLine(' '); -- adds empty line
	self:AddLine(L['Enemy is level X'](bosslvl),1,1,1);
end;

-- happens when the mouse joins the ldb dataobject
function dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	GameTooltip:ClearLines();
	TankInfo.OnTooltipShow(GameTooltip);
	GameTooltip:Show();
end;

--happens when the mouse leaves the DO
function dataobj:OnLeave()
	GameTooltip:Hide();
end;

-- OnInitialize
function TankInfo:OnInitialize()
	self:Print('OnInitialize');
	self.db = LibStub("AceDB-3.0"):New("TankInfoDB", defaults, true);
end;

-- OnEnable
function TankInfo:OnEnable()
    self:Print('OnEnable');
	-- registering events
	self:RegisterEvent("PLAYER_LEVEL_UP", "levelup");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "Values");
	self:RegisterEvent("UNIT_AURA", "Aura");
	-- getting/updating values
	self:Values();
	self.updateInterval = self:ScheduleRepeatingTimer("UpdateLDB", 0.5);
	self:UpdateLDB();
	self.db.char.enabled = true;
end;

--OnDisable
function TankInfo:OnDisable()
    TankInfo:Print('OnDisable');
	self:UnregisterEvent("PLAYER_LEVEL_UP");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("UNIT_AURA");
	self:CancelTimer(self.updateInterval);
	self.db.char.enabled = false;
	end;