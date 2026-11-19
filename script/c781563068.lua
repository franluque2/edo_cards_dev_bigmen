--Forbidden Cyberdark Arts
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
        nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local CARD_CYBERDARKNESS_DRAGON = 18967507
local CARD_CYBERDARK_END_DRAGON = 37542782


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
	e1:SetValue(s.value)
    Duel.RegisterEffect(e1,tp)

    --Once per duel, if your Deck has 5 or fewer cards remaining, add 1 "Cyberdark End Dragon" from Outside the Duel to your Extra Deck.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_MOVE)
    e2:SetCondition(s.addextracon)
    e2:SetOperation(s.addextraop)
    e2:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
    Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCondition(s.rewritecyberdarknessdragoncon)
    e3:SetOperation(s.rewritecyberdarknessdragonop)
    Duel.RegisterEffect(e3,tp)
end
function s.addextracon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) <= 5
end

function s.addextraop(e,tp,eg,ep,ev,re,r,rp)
    local token=Duel.CreateToken(tp, CARD_CYBERDARK_END_DRAGON)
    Duel.SendtoDeck(token, tp, SEQ_DECKTOP, REASON_RULE)
end


function s.togravefilter(c)
    return c:IsSetCard(SET_CYBERDARK) and c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.value(e)
        local damp=0
        if Duel.GetBattleDamage(0)==0 then
            damp=1
        end
        if damp~=e:GetHandlerPlayer() then
            return -1
        end
		local val=Duel.GetBattleDamage(damp)
        local cyberdarks_in_top_deck=false
		if (val>0) and (Duel.GetFieldGroupCount(e:GetOwnerPlayer(), LOCATION_DECK,0)>1) then
			if Duel.GetFlagEffect(damp, id-500)~=0 then
                return Duel.GetFlagEffectLabel(damp, id-500)==1 and 0 or -1
            end

            local top_deck=Duel.GetDecktopGroup(e:GetOwnerPlayer(), math.ceil(val/200))
            if top_deck:IsExists(s.togravefilter, 1, nil) then
                cyberdarks_in_top_deck=true
            end
			Duel.RegisterFlagEffect(damp, id-500, RESET_PHASE+PHASE_DAMAGE, 0, 0, cyberdarks_in_top_deck and 1 or 0)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_ADJUST)
			e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
			e1:SetLabel(math.ceil(val/200))
			e1:SetOperation(s.millop)
			Duel.RegisterEffect(e1,damp)
            
            if cyberdarks_in_top_deck then
                return 0
            else
                return -1
            end

		else
            return -1

        end

end


function s.millop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()
	if val>0 then
        Duel.Hint(HINT_CARD, tp, id)
		e:SetLabel(0)
		Duel.DiscardDeck(tp, val, REASON_EFFECT)
		e:Reset()
	end
end


function s.cyberdarknessdragonfilter(c)
    return c:IsOriginalCode(CARD_CYBERDARKNESS_DRAGON) and c:GetFlagEffect(id)==0
end

function s.rewritecyberdarknessdragoncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cyberdarknessdragonfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritecyberdarknessdragonop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.cyberdarknessdragonfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))

        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:IsHasCategory(CATEGORY_NEGATE) then
                eff:SetCountLimit(2,{id,1})
            end
        end


    end
end