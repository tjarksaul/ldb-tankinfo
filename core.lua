local ldb = LibStub:GetLibrary("LibDataBroker-1.1");

TankInfo = LibStub("AceAddon-3.0"):NewAddon("Broker_TankInfo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("TankInfo");

-- creating ldb data source
local dataobj = ldb:NewDataObject("tankinfo", {type = "data source", text = L["Avoidance: "].."UNKNOWN"})

-- creating variables
local level, bosslvl, dodge, block, parry, blockvalue, armor, health, eh, avoidance, enemymiss, mitigation, enemycrit, armorDR;

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
  if gem and gem == L['Eternal Earthstorm Diamond'] then
    bval_mod = bval_mod + 0.1
  end

  -- get block value modifier in talents
  local numTabs = GetNumTalentTabs();
  local _, clss = UnitClass("player")
  for t=1, numTabs do
    local numTalents = GetNumTalents(t);
    for i=1, numTalents do
      local nameTalent, _, _, _, currRank, _ = GetTalentInfo(t,i);
      if nameTalent == L["Shield Mastery"] or (nameTalent == L["Shield Specialization"] and clss ~= "WARRIOR") then
        if clss == "SHAMAN" then
          bval_mod = bval_mod + currRank * 5 / 100 -- rank is 1..5, values are 5%, 10%, 15%, 20%, 25%
        else
          bval_mod = bval_mod + currRank / 10 -- rank is 1, 2, 3, values are: 10%, 20%, 30% => / 10 is equivalent to * 10 / 100
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
	block = GetBlockChance();
	blockvalue = self:getBlockval();
	enemymiss = self:getBasicMiss();
	armor = self:getArmor();
	if (bosslvl < 60) then
		armorDR = armor / (armor + 400 + 85 * bosslvl);
	else
		armorDR = armor / (armor + 400 + 85 * (bosslvl + 4.5 * (bosslvl - 59)));
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
end;

function TankInfo:UpdateLDB()
	self:Values();
	dataobj.text = L["Avoidance: "]..avoidance.."%";
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

-- OnInitialize
function TankInfo:OnInitialize()
	self:Print('OnInitialize');
	self.db = LibStub("AceDB-3.0"):New("MyAddonDB")
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
end;

--OnDisable
function TankInfo:OnDisable()
    TankInfo:Print('OnDisable');
	self:UnregisterEvent("PLAYER_LEVEL_UP");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("UNIT_AURA");
end;