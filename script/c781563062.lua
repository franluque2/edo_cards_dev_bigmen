--Majesty of the King
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

    	aux.GlobalCheck(s,function()

		s.used_this_skill={}
		s.used_this_skill[0] = false
		s.used_this_skill[1] = false

	end)
end

local CARD_CRIMSON_GAIA = 98173209
local CARD_CONVERGING_WILLS_DRAGON = 00291414

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)

    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetCondition(s.placecardcon)
    e2:SetOperation(s.placecardop)
    Duel.RegisterEffect(e2, tp)
end

function s.rewritegaiafilter(c)
    return c:IsCode(CARD_CRIMSON_GAIA) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritegaiafilter, tp, LOCATION_ALL, 0, 1, nil)
end
    
function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rewritegaiafilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)

        local effs = {tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:IsHasCategory(CATEGORY_POSITION) then
                eff:SetOperation(s.posop)
            end
        end
    end
end

function s.poschangefilter(c)
    return c:IsMonster() and c:IsCanTurnSet() and c:IsPosition(POS_FACEUP_DEFENSE)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.poschangefilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end

function s.placecardcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp) and (s.used_this_skill[tp] == false) and (Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil):GetSum(Card.GetAttack) > Duel.GetLP(tp)) 
end

function s.placecardop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        s.used_this_skill[tp] = true

        Duel.Hint(HINT_CARD,tp, id)
        local token = Duel.CreateToken(tp, CARD_CONVERGING_WILLS_DRAGON)
        Duel.SendtoDeck(token, nil, SEQ_DECKTOP, REASON_RULE)
    end
end