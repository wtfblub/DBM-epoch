local mod	= DBM:NewMod("Onyxia", "DBM-Onyxia")
local L		= mod:GetLocalizedStrings()

local ONYXIA_CID = 45133

local FLAME_BREATH_ID = 18435
local FLAME_BREATH_CD = 13.3

local DEEP_BREATH_ID = 18584
local DEEP_BREATH_CD = 35
local DEEP_BREATH_CAST_TIME = 4

local FIREBALL_ID = 18392

mod:SetRevision("20251223004610")
mod:SetCreatureID(45133)
mod:RegisterCombat("combat")
mod:SetUsedIcons(1)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 18435 18584 18392",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_HEALTH"
)

local flyPhasePreWarn		= mod:NewPrePhaseAnnounce(2)
local flyPhaseWarn			= mod:NewPhaseAnnounce(2)
local groundPhaseWarn		= mod:NewPhaseAnnounce(1)

local flameBreathCD			= mod:NewCDTimer(FLAME_BREATH_CD, FLAME_BREATH_ID, nil, "Tank|Healer", 2, 5, nil, nil, true)

local deepBreathCD			= mod:NewCDTimer(DEEP_BREATH_CD, DEEP_BREATH_ID, nil, nil, nil, 3)
local deepBreathWarn		= mod:NewSpecialWarningSpell(DEEP_BREATH_ID, nil, nil, nil, 2, 2)
local deepBreathCastTimer	= mod:NewCastTimer(DEEP_BREATH_CAST_TIME, DEEP_BREATH_ID, nil, nil, nil, 3)

local fireballWarn			= mod:NewTargetNoFilterAnnounce(FIREBALL_ID, 2, nil, false)
local fireballYell			= mod:NewYell(FIREBALL_ID)

mod.vb.WarnedFly1 = false
mod.vb.WarnedFly2 = false

mod:AddSetIconOption("SetIconOnFireball", FIREBALL_ID, true, false, {1})

function mod:FireballTarget(targetName)
	if not targetName then return end
	fireballWarn:Show(targetName)
	if self.Options.SetIconOnFireball then
		self:SetIcon(targetName, 1, 3)
	end
	if targetName == UnitName("player") then
		fireballYell:Yell()
	end
end

function mod:OnCombatStart()
	flameBreathCD:Start()
end

function mod:SPELL_CAST_START(args)
	if args.spellId == FLAME_BREATH_ID then
		flameBreathCD:Start()
	-- One for each direction
	elseif args:IsSpellID(17086, 18351, 18564, 18576) or args:IsSpellID(18584, 18596, 18609, 18617) then
		deepBreathWarn:Show()
		deepBreathCastTimer:Start()
		deepBreathCD:Start()
	elseif args.spellId == FIREBALL_ID then
		self:BossTargetScanner(args.sourceGUID, "FireballTarget", 0.15, 12)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellP2_1 or msg:find(L.YellP2_1) or msg == L.YellP2_2 or msg:find(L.YellP2_2) then
		self:SendSync("Phase2")
	elseif msg == L.YellP3 or msg:find(L.YellP3) then
		self:SendSync("Phase1")
	end
end

function mod:UNIT_HEALTH(uId)
	local cId = self:GetUnitCreatureId(uId)
	if cId ~= ONYXIA_CID then
		return
	end

	if not self.vb.WarnedFly1 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.85 then
		self.vb.WarnedFly1 = true
		flyPhasePreWarn:Show()
	end

	if not self.vb.WarnedFly2 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.45 then
		self.vb.WarnedFly2 = true
		flyPhasePreWarn:Show()
	end
end

function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "Phase2" then
		flyPhaseWarn:Show()
		flameBreathCD:Stop()
		deepBreathCD:Start()
	elseif msg == "Phase1" then
		groundPhaseWarn:Show()
		deepBreathCD:Stop()
	end
end

function mod:debug()
	deepBreathWarn:Show()
	deepBreathCastTimer:Start()
end
function mod:debug2()
	fireballWarn:Show("wtfblub")
end
