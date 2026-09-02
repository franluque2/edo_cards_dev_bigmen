--Shackles of a Moonlit Reincarnation
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)

	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

end

local LUNALIGHT_TIGER = 83190280
local LUNALIGHT_PANTHER = 47705572
local LUNALIGHT_BLUE_CAT = 11439455
local LUNALIGHT_CAT_DANCER = 51777272
local LUNALIGHT_PANTHER_DANCER = 97165977
local LUNALIGHT_LEO_DANCER = 24550676

local CARDS_TO_REWRITE = {LUNALIGHT_TIGER, LUNALIGHT_PANTHER, LUNALIGHT_LEO_DANCER}



function s.counterfilter(c)
	return not (c:IsSummonLocation(LOCATION_EXTRA) and c:IsType(TYPE_FUSION))
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

    --rewrite cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecon)
    e1:SetOperation(s.rewriteop)
    Duel.RegisterEffect(e1, tp)

    --"Lunalight" Fusion monsters you own are unaffected by the effect of "Lunalight Blue Cat".
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(function(_,c) return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_LUNALIGHT) end)
    e2:SetValue(function(_,te) return te:GetHandler():IsOriginalCode(LUNALIGHT_BLUE_CAT) end)
    Duel.RegisterEffect(e2, tp)

    --"Lunalight Leo Dancer" you control is unaffected by your "Lunalight" cards' effects.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(function(_,c) return c:IsOriginalCode(LUNALIGHT_LEO_DANCER) end)
    e3:SetValue(function(_,te) return te:GetHandler():IsSetCard(SET_LUNALIGHT) and te:GetHandler():IsControler(tp) end)
    Duel.RegisterEffect(e3, tp)

    --If "Lunalight Cat Dancer" or "Lunalight Panther Dancer" you control activate their effects during the Main Phase, for the rest of this turn, all battle damage your opponent takes is halved
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAINING)
    e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        local rc=re:GetHandler()
        if rc:GetControler()~=tp then return false end
        return rc:IsOriginalCode(LUNALIGHT_CAT_DANCER,LUNALIGHT_PANTHER_DANCER) and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
    end)
    e4:SetOperation(s.reducedmgop)
    Duel.RegisterEffect(e4, tp)
end


function s.notrewrittencardfilter(c)
    return c:IsOriginalCode(table.unpack(CARDS_TO_REWRITE)) and c:GetFlagEffect(id)==0
end


function s.rewritecon(e)
    return Duel.IsExistingMatchingCard(s.notrewrittencardfilter, e:GetHandlerPlayer(), LOCATION_ALL, 0, 1, nil)
end

function s.matfilter(c,fc,sumtype,tp)
	return c:IsOriginalCode(97165977) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end

function s.rewriteop(e)
    local g = Duel.GetMatchingGroup(s.notrewrittencardfilter, e:GetHandlerPlayer(), LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)

        if tc:IsOriginalCode(LUNALIGHT_TIGER, LUNALIGHT_PANTHER) then
            local effs = {tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if Effect.IsHasType(eff, EFFECT_TYPE_IGNITION) then
                    eff:SetCountLimit(1, {tc:GetOriginalCode(),10})
                end
            end
        end

        if tc:IsOriginalCode(LUNALIGHT_LEO_DANCER) then
            local effs = {tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:GetCode()&EFFECT_FUSION_MATERIAL==EFFECT_FUSION_MATERIAL then
                    eff:Reset()
                end


            end

                Fusion.AddProcMixN(tc,false,false,s.matfilter,1,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_LUNALIGHT),2)
                local e3=Effect.CreateEffect(e:GetHandler())
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e3:SetCode(EFFECT_SPSUMMON_COST)
                e3:SetCost(function(_,_,tp) return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end)
                e3:SetOperation(s.spcostop)
                tc:RegisterEffect(e3)
        end
    end
end

function s.spcostop(e,tp,eg,ep,ev,re,r,rp)
	--Cannot Special Summon Fusion Monsters from the Extra Deck 
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
	--Cannot special summon fusions from extra deck
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end

function s.lizfilter(e,c)
	return c:IsOriginalType(TYPE_FUSION)
end

function s.reducedmgop(e,tp,eg,ep,ev,re,r,rp)
--for the rest of this turn, all battle damage your opponent takes is halved, also monsters you control cannot attack, except the monster that activated its effect.
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(0,1)
    e1:SetValue(HALF_DAMAGE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_OATH)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ftarget)
	e2:SetLabel(re:GetHandler():GetFieldID())
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end