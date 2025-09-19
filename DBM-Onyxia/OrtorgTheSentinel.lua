local mod	= DBM:NewMod("OrtorgTheSentinel", "DBM-Onyxia")
local L		= mod:GetLocalizedStrings()

local SILENCE_ID = 85598
local SILENCE_CD = 30

local EMBER_BONDS_ID = 85596
local CRIPPLING_BONDS_ID = 85595

local CRUMBLING_LAIR_ID = 85592

local LAVA_SLASH_ID = 85600
local LAVA_SLASH_HIGHSTACK = 2

mod:SetRevision("20250919120310")
mod:SetCreatureID(45059)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 85596 85595 85600",
	"SPELL_AURA_APPLIED_DOSE 85600",
	"SPELL_AURA_REMOVED 85596 85595",
	"SPELL_PERIODIC_DAMAGE 85592",
	"SPELL_PERIODIC_MISSED 85592"
)

local silenceCDTimer				= mod:NewCDTimer(SILENCE_CD, SILENCE_ID, nil, nil, nil, 2)

local emberBondsWarn				= mod:NewSpecialWarningTarget(EMBER_BONDS_ID, nil, nil, nil, 1, 2)
local emberBondsYell				= mod:NewYell(EMBER_BONDS_ID)
local emberBondsMove				= mod:NewSpecialWarningMoveAway(EMBER_BONDS_ID, nil, nil, nil, 4, 2)
local cripplingBondsFadesYell		= mod:NewShortFadesYell(CRIPPLING_BONDS_ID)

local crumblingLairWarnGTFO			= mod:NewSpecialWarningMove(CRUMBLING_LAIR_ID, nil, nil, nil, 1, 8)

local lavaSlashWarnStack			= mod:NewStackAnnounce(LAVA_SLASH_ID, 2, nil, "Tank|Healer")
local lavaSlashWarnHighStack		= mod:NewSpecialWarningStack(LAVA_SLASH_ID, nil, LAVA_SLASH_HIGHSTACK, nil, nil, 1, 6)

mod:AddRangeFrameOption(10, EMBER_BONDS_ID)
mod:AddSetIconOption("SetIconOnEmberBonds", EMBER_BONDS_ID, true, false, {1,2,3,4,5,6})

mod.vb.EmberBondsIcon = 1

function mod:OnCombatStart()
	self.vb.EmberBondsIcon = 1
	silenceCDTimer:Start()
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == EMBER_BONDS_ID then
		if self.Options.SetIconOnEmberBonds then
			self:SetIcon(args.destName, self.vb.EmberBondsIcon)
			self.vb.EmberBondsIcon = self.vb.EmberBondsIcon + 1
		end

		if args:IsPlayer() then
			emberBondsMove:Show()
			emberBondsMove:Play("runout")
			emberBondsYell:Yell()
			if self.Options.RangeFrame then
				DBM.RangeCheck:Show(10)
			end
		else
			emberBondsWarn:CombinedShow(0.3, args.destName)
		end
	elseif args.spellId == CRIPPLING_BONDS_ID then
		if args:IsPlayer() then
			cripplingBondsFadesYell:Countdown(args.spellId)
		end
	elseif args.spellId == LAVA_SLASH_ID then
		local amount = args.amount or 1
		if amount >= LAVA_SLASH_HIGHSTACK then
			if args:IsPlayer() then
				lavaSlashWarnHighStack:Show(amount)
				lavaSlashWarnHighStack:Play("stackhigh")
			else
				lavaSlashWarnStack:Show(args.destName, amount)
			end
		else
			lavaSlashWarnStack:Show(args.destName, amount)
		end
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == EMBER_BONDS_ID then
		if args:IsPlayer() and self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	elseif args.spellId == CRIPPLING_BONDS_ID then
		if self.Options.SetIconOnEmberBonds then
			self:SetIcon(args.destName, 0)
			self.vb.EmberBondsIcon = 1
		end

		if args:IsPlayer() then
			cripplingBondsFadesYell:Cancel()
		end
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, destGUID, _, _, spellId, spellName)
	if spellId == CRUMBLING_LAIR_ID and destGUID == UnitGUID("player") and self:AntiSpam(3, 1) then
		crumblingLairWarnGTFO:Show()
		crumblingLairWarnGTFO:Play("watchfeet")
	end
end

mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
