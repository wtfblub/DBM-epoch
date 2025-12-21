local mod	= DBM:NewMod("Atressian", "DBM-Onyxia")
local L		= mod:GetLocalizedStrings()

local PYROBLAST_ID = 150038
local PYROBLAST_CAST_TIME = 6

local DRAGONKIN_SORCERY_ID = 150053
local DRAGONKIN_SORCERY_CD = 90

local SUMMON_DRAGONKIN_ID = 150121
local SUMMON_DRAGONKIN_CD = 50

local ARCANE_DECIMATE_ID = 150040
local ARCANE_DECIMATE_CAST_TIME = 2

local COLLAPSE_LAIR_ID = 150123
local COLLAPSE_LAIR_CAST_TIME = 30
local DRAGONKIN_CID = 300065 -- Onyxian Magmaweaver

mod:SetRevision("20251221132522")
mod:SetCreatureID(45125)
mod:SetUsedIcons(1)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 150038 150053 150121 150040 150123",
	"UNIT_DIED"
)

local manaGemsWarn				= mod:NewSpecialWarningSwitch(DRAGONKIN_SORCERY_ID, nil, nil, nil, 1, 2)
local manaGemsTimer				= mod:NewCDTimer(DRAGONKIN_SORCERY_CD, DRAGONKIN_SORCERY_ID, nil, nil, nil, 1)

local summonDragonkinWarn		= mod:NewSpecialWarningSwitch(SUMMON_DRAGONKIN_ID, nil, nil, nil, 1, 2)
local summonDragonkinTimer		= mod:NewCDTimer(SUMMON_DRAGONKIN_CD, SUMMON_DRAGONKIN_ID, nil, nil, nil, 1)

local arcaneDecimateWarn		= mod:NewTargetNoFilterAnnounce(ARCANE_DECIMATE_ID, 2)
local arcaneDecimateSay			= mod:NewYell(ARCANE_DECIMATE_ID)

local collpaseLairCastTimer		= mod:NewCastTimer(COLLAPSE_LAIR_CAST_TIME, COLLAPSE_LAIR_ID, nil, nil, nil, 2)
local collpaseLairWarn			= mod:NewSpecialWarningSpell(COLLAPSE_LAIR_ID, nil, nil, nil, 2, 2)

mod:AddSetIconOption("SetIconOnPyroblast", PYROBLAST_ID, true, false, {1})
mod:AddSetIconOption("SetIconOnArcaneDecimate", ARCANE_DECIMATE_ID, true, false, {1})

function mod:OnCombatStart()
	manaGemsTimer:Start()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == PYROBLAST_ID then
		if self.Options.SetIconOnPyroblast then
			self:SetIcon(args.destName, 1, PYROBLAST_CAST_TIME)
		end
	elseif args.spellId == DRAGONKIN_SORCERY_ID then
		manaGemsWarn:Show()
		manaGemsWarn:Play("mobsoon")
		summonDragonkinTimer:Start()
	elseif args.spellId == SUMMON_DRAGONKIN_ID then
		summonDragonkinWarn:Show()
		summonDragonkinWarn:Play("bigmob")
	elseif args.spellId == ARCANE_DECIMATE_ID then
		if self.Options.SetIconOnArcaneDecimate then
			self:SetIcon(args.destName, 1, ARCANE_DECIMATE_CAST_TIME)
		end
		arcaneDecimateWarn:Show(args.destName)
		if args:IsPlayer() then
			arcaneDecimateSay:Yell()
		end
	elseif args.spellId == COLLAPSE_LAIR_ID then
		collpaseLairCastTimer:Start()
		collpaseLairWarn:Show()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == DRAGONKIN_CID then
		collpaseLairCastTimer:Stop()
	end
end
