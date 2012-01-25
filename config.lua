local addonName, addonData = ...;
local TankInfo = LibStub("AceAddon-3.0"):NewAddon("Broker_TankInfo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("TankInfo");
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigCmd = LibStub("AceConfigCmd-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
_G["TankInfo"] = TankInfo;

TankInfo.blizopt = {
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
		updopt = {
			name = L["Update settings"],
			desc = L["Configure automatic update of Broker display"],
			type = "group",
			args = {
				enable = {
					name = L["Enable automatic update"],
					desc = L["Enables automatic updates of Broker display. This may cause high CPU usage."],
					descStyle = "inline",
					type = "toggle",
					set = function(info, val) 
						if val then 
							TankInfo.updateInterval = TankInfo:ScheduleRepeatingTimer("UpdateLDB", TankInfo.db.char.updateinterval) 
						else
							TankInfo:CancelTimer(TankInfo.updateInterval)
						end
						TankInfo.db.char.autoupdate = val
					end,
					get = function(info) return TankInfo.db.char.autoupdate end
				},
				updateinterval = {
					name = L["Update interval"],
					desc = L["Sets the update interval of Broker display to given amount of seconds. Shorter periods increase CPU usage"],
					type = "range",
					step = 0.25,
					min = 1,
					max = 600,
					softMin = 2,
					softMax = 60,
					disabled = function(info) return not TankInfo.db.char.autoupdate end,
					get = function(info) return TankInfo.db.char.updateinterval end,
					set = function(info, val) TankInfo.db.char.updateinterval = val; TankInfo.updateInterval = TankInfo:ScheduleRepeatingTimer("UpdateLDB", TankInfo.db.char.updateinterval) end
				}
			}
		},
		reset = {
			name = L["Reset"],
			desc = L["Reset configuration to defaults"],
			type = "execute",
			func = function(info) TankInfo:ResetToDefaults(); end,
		},
	}
}

TankInfo.options = {};
TankInfo.options.type = "group";
TankInfo.options.args = table.copy(TankInfo.blizopt.args);
TankInfo.options.args.config = {
	name = L["Show Options"],
	desc = L["Shows the blizzard interface options panel"],
	type = "execute",
--	hidden = function(info) return true,true,true,false end,
	func = function(info) InterfaceOptionsFrame_OpenToCategory(addonName); end,
}
-- ]]

AceConfig:RegisterOptionsTable("TankInfo", TankInfo.options, { "/tinfo", "/tankinfo", "/ti" }); -- Options for slash command
AceConfigRegistry:RegisterOptionsTable(addonName, TankInfo.blizopt);
AceConfigCmd:CreateChatCommand("tinfo","TankInfo");
AceConfigCmd:CreateChatCommand("tankinfo","TankInfo");
AceConfigCmd:CreateChatCommand("ti","TankInfo");

TankInfo.BlizzOptions = AceConfigDialog:AddToBlizOptions(addonName, addonName);
--@debug@
print("Set addonName to " .. addonName);
--@end-debug@

function TankInfo:OnClick(self, button, down)
	if (button == "RightButton") then
		-- show options menu
		InterfaceOptionsFrame_OpenToCategory(addonName);
--[[	elseif (button == "LeftButton") then
		-- show blizzard options panel
		InterfaceOptionsFrame_OpenToCategory("Broker TankInfo"); ]]
	end;
end;

function TankInfo:ResetToDefaults()
	self.db:ResetProfile();
end;
