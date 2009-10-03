TankInfo = LibStub("AceAddon-3.0"):NewAddon("Broker_TankInfo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("TankInfo");
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigCmd = LibStub("AceConfigCmd-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");

TankInfo.options = {
	type = "group",
	args = {
		enable = {
			name = L["Enable"],
			desc = L["En-/Disables the addon"],
			type = "toggle",
			set = function(info,val) TankInfo.db.char.enabled = val end,
			get = function(info) return TankInfo.db.char.enabled end
		},
		bosslvl = {
			name = L["Level of enemy"],
			desc = L["Change the level of the enemy for calculation"],
			type = "range",
			step = 1,
			min = 1,
			max = 93,
			get = function(info) return TankInfo.db.char.bosslvl end,
			set = function(info, val) TankInfo.db.char.bosslvl = val end
		},
		colopt = {
			name = L["Color settings"],
			desc = L["Chance the color of GameTooltip entries"],
			type = "group",
			args = {
				firstl = {
					name = L["First lines"],
					desc = L["Color of the first, third, fifth, etc. lines"],
					type = "color",
					get = function(info) return TankInfo.db.char.r1, TankInfo.db.char.g1, TankInfo.db.char.b1, 1.0 end,
					set = function(info,r,g,b,a) TankInfo.db.char.r1, TankInfo.db.char.g1, TankInfo.db.char.b1 = r,g,b end
				},
				secondl = {
					name = L["Second lines"],
					desc = L["Color of the second, fourth, sixth, etc. lines"],
					type = "color",
					get = function(info) return TankInfo.db.char.r2, TankInfo.db.char.g2, TankInfo.db.char.b2, 1.0 end,
					set = function(info,r,g,b,a) TankInfo.db.char.r2, TankInfo.db.char.g2, TankInfo.db.char.b2 = r,g,b end 
				}
			}
		},
		config = {
			name = L["Show Options"],
			desc = L["Shows the blizzard interface options panel"],
			type = "execute",
--			hidden = function(info) return true,true,true,false end,
			func = function(info) InterfaceOptionsFrame_OpenToCategory("Broker TankInfo"); end,
		}
	}
}

AceConfig:RegisterOptionsTable("TankInfo", TankInfo.options, { "/tinfo", "/tankinfo", "/ti" });
AceConfigCmd:CreateChatCommand("tinfo","TankInfo");
AceConfigCmd:CreateChatCommand("tankinfo","TankInfo");
AceConfigCmd:CreateChatCommand("ti","TankInfo");

TankInfo.BlizzOptions = AceConfigDialog:AddToBlizOptions("TankInfo", "Broker TankInfo");

function TankInfo:OnClick(self, button, down)
	if (button == "RightButton") then
		-- show options menu
		InterfaceOptionsFrame_OpenToCategory(self.BlizzOptions);
--[[	elseif (button == "LeftButton") then
		-- show blizzard options panel
		InterfaceOptionsFrame_OpenToCategory("Broker TankInfo"); ]]
	end;
end;
