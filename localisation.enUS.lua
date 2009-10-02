local L = LibStub("AceLocale-3.0"):NewLocale("TankInfo", "enUS", true);

if L then
	-- translations enUS
	-- example function:
	L['Added X DKP to player Y.'] = function(X,Y)
		return 'Added ' .. X .. ' DKP for player ' .. Y .. '.';
	end;
	L["Armor"] = "Armor"
	L["ArmorDmgReduce"] = "Percent of damage reduced by armor"
	L["Avoidance"] = "Avoidance"
	L["Avoidance: "] = "Avoidance: "
	L["dwAvoid"] = 'Avoidance vs Dual Wield enemy';
	L["Block"] = "Block"
	L["BlockValue"] = "Block Value"
	L["Dodge"] = "Dodge"
	L["Eternal Earthstorm Diamond"] = "Eternal Earthstorm Diamond"
	L["HP"] = "Life"
	L["Parry"] = "Parry"
	L["Shield Mastery"] = "Shield Mastery"
	L["Shield Specialization"] = "Shield Specialization"
	L["Enemy is level X"] = function(bosslevel)
		if not bosslevel then return 'UNKNOWN' end;
		return 'Enemy is level ' .. bosslevel .. '.';
	end;
	L['Defense Stats'] = true;
	L['Enemymiss'] = 'The enemy\'s chance to miss you';
	L['Block Chance'] = true;
	L['Block Value'] = true;
	L['Mitigation'] = true;
	L['dwMitigation'] = 'Mitigation vs Dual Wield enemy';
	L['NormalHit'] = 'Chance to receive a normal hit';
	L['GetCrit'] = 'Chance to get critically hit';
	L['Health'] = true;
	L['ArmorDR'] = 'Damage reduction by armor';
	L['EH'] = 'Effective Health';
	L['Eternal Earthsiege Diamond'] = true;
end;