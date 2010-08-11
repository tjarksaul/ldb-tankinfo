local addonName, addonData = ...;
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");

local L = LibStub("AceLocale-3.0"):GetLocale("TankInfo");
local TankInfo = TankInfo

-- creating ldb data object
local doTable = {
	type = "data source", 
	text = '|c0066ff00'..L["Avoidance: "]..'|r|c00ff0000'.."UNKNOWN|r", 
	label = 'Broker TankInfo', 
	icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
	OnClick = TankInfo.OnClick(),
}
TankInfo.dataobj = ldb:NewDataObject("tankinfo", doTable)

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
			enabled = true,
			bosslvl = UnitLevel('player') + 3,
			r1, g1, b1 = 0,0.4,1,
			r2, g2, b2 = 0,1,0,
			already_launched = false;
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
  return (adef + bdef - self.db.char.bosslvl * 5) * 0.04
end


function TankInfo:getArmor()
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
	return effectiveArmor;
end;

function TankInfo:getCritReduce()
	local reduce = GetDodgeBlockParryChanceFromDefense();



	return reduce;
end;

function TankInfo:Values()
	level = UnitLevel("player");
	bosslvl = self.db.char.bosslvl;
	dodge = GetDodgeChance();
	parry = GetParryChance();
	block = floor(GetBlockChance() * 100 + 0.5) / 100;
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
	avoidance = floor((enemymiss + dodge + parry + 5) * 100 + 0.5) / 100;
	mitigation = avoidance + block;
	enemycrit = 5 + (bosslvl - level) * .2;



	enemycrit = enemycrit - self:getCritReduce();
	if (enemycrit < 0) then enemycrit = 0 end;

	normalhit = 100 - mitigation;
	if (normalhit < 0) then normalhit = 0 end;
end;

function TankInfo:UpdateLDB()
	self:Values();
	TankInfo.dataobj.text = '|c000066ff'..L["Avoidance: "]..'|r|c0000ff00'..avoidance.."%|r";
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
	local r1, g1, b1 = TankInfo.db.char.r1, TankInfo.db.char.g1, TankInfo.db.char.b1
	local r2, g2, b2 = TankInfo.db.char.r2, TankInfo.db.char.g2, TankInfo.db.char.b2
	TankInfo:UpdateLDB(); -- updating values before showing tooltip
	self:AddLine(L['Defense Stats'],1,1,1);
	self:AddDoubleLine(L['Enemymiss']..': ',(enemymiss + 5)..'%',r1, g1, b1,r1, g1, b1); -- adds enemymiss line
	self:AddDoubleLine(L['Dodge']..': ',floor(dodge * 100 + 0.5) / 100 ..'%',r2, g2, b2,r2, g2, b2); -- adds dodge line
	self:AddDoubleLine(L['Parry']..': ',floor(parry * 100 + 0.5) / 100 ..'%',r1, g1, b1,r1, g1, b1); -- adds parry line
	self:AddDoubleLine(L['Avoidance']..': ',avoidance..'%',r2, g2, b2,r2, g2, b2); -- adds avoidance line
	self:AddDoubleLine(L['dwAvoid']..': ',(avoidance + 24)..'%',r1, g1, b1,r1, g1, b1); -- adds dw avoidance line
	self:AddDoubleLine(L['Block Chance']..': ',block..'%',r2, g2, b2,r2, g2, b2); -- adds block chance line
	self:AddDoubleLine(L['Block Value']..': ',blockvalue,r1, g1, b1,r1, g1, b1); -- adds block value line
	self:AddDoubleLine(L['Mitigation']..': ',mitigation..'%',r2, g2, b2,r2, g2, b2); -- adds mitigation line
	self:AddDoubleLine(L['dwMitigation']..': ',(mitigation + 24)..'%',r1, g1, b1,r1, g1, b1) -- adds dw mitigation line
	self:AddDoubleLine(L['NormalHit']..': ',normalhit..'%',r2, g2, b2,r2, g2, b2); -- adds line for chance to get a normal hit
	self:AddDoubleLine(L['GetCrit']..': ',enemycrit..'%',r1, g1, b1,r1, g1, b1); -- adds line for chance to get critically hit
	self:AddLine(' '); -- adds empty line
	self:AddDoubleLine(L['Health']..': ',health,r1, g1, b1,r1, g1, b1); -- adds health line
	self:AddDoubleLine(L['ArmorDR']..': ',floor(armorDR * 10000 + 0.5) / 100 ..'%',r2, g2, b2,r2, g2, b2); -- adds line for damage reduction by armor
	self:AddDoubleLine(L['EH']..': ',eh,r1, g1, b1,r1, g1, b1); -- adds line for effective health
	self:AddLine(' '); -- adds empty line
	self:AddDoubleLine(L['Enemy is level'],(bosslvl or "UNKNOWN"),1,1,1,1,1,1);
end;

-- happens when the mouse joins the ldb dataobject
function TankInfo.dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	GameTooltip:ClearLines();
	TankInfo.OnTooltipShow(GameTooltip);
	GameTooltip:Show();
end;

--happens when the mouse leaves the DO
function TankInfo.dataobj:OnLeave()
	GameTooltip:Hide();
end;

-- OnInitialize
function TankInfo:OnInitialize()
--@debug@
	self:Print('OnInitialize');
--@end-debug@
	self.db = LibStub("AceDB-3.0"):New("TankInfoDB", defaults, "char");
	StaticPopupDialogs["BROKER_TANKINFO_FIRSTLAUNCH"] = {
		text = L["FirstLaunch"],
		button1 = OKAY,
		whileDead = true,
		timeout = 0,
		hideOnEscape = true,
		OnAccept = function()
			self.db.char.already_launched = true;
		end,
		OnCancel = function()
			self.db.char.already_launched = true;
		end,
		notClosableByLogout = true,
	}
end;

-- OnEnable
function TankInfo:OnEnable()
--@debug@
    self:Print('OnEnable');
--@end-debug@
	-- registering events
	self:RegisterEvent("PLAYER_LEVEL_UP", "levelup");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "Values");
	self:RegisterEvent("UNIT_AURA", "Aura");
	-- getting/updating values
	self:Values();
	self.updateInterval = self:ScheduleRepeatingTimer("UpdateLDB", 5);
	self:UpdateLDB();
	self.db.char.enabled = true;
	if not self.db.char.already_launched then
		StaticPopup_Show("BROKER_TANKINFO_FIRSTLAUNCH");
	end;
end;

--OnDisable
function TankInfo:OnDisable()
--@debug@
    TankInfo:Print('OnDisable');
--@end-debug@
	self:UnregisterEvent("PLAYER_LEVEL_UP");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("UNIT_AURA");
	self:CancelTimer(self.updateInterval);
	self.db.char.enabled = false;
	end;