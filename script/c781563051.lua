--The Dark Magical Illusionist
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
            local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive, s.stacktotop, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
	
    aux.GlobalCheck(s, function()
		s.used_this_skill = {}
		s.used_this_skill[0] = false
		s.used_this_skill[1] = false
		aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false
		end)
	end)
end
local CARD_ECTOPLASMER=97342942

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCondition(function (_e) return Duel.GetTurnCount()<=2 and Duel.IsTurnPlayer(_e:GetHandlerPlayer()) end)
    e1:SetCountLimit(1)
    e1:SetOperation(s.placebackrow)
    Duel.RegisterEffect(e1,tp)

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_ADJUST)
    e0:SetCondition(s.rewritedmscon)
    e0:SetOperation(s.rewritedmsop)
    Duel.RegisterEffect(e0,tp)

    	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetTargetRange(LOCATION_HAND|LOCATION_GRAVE,0)
    e3:SetTarget(function(_,c) return c:IsCode(CARD_DARK_MAGICIAN) end)
    e3:SetLabelObject(e2)
    Duel.RegisterEffect(e3,tp)

        local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_FORCE_ACTIVATE_LOCATION)
	e4:SetValue(LOCATION_SZONE)
	e4:SetTarget(s.target2)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e5:SetTargetRange(LOCATION_GRAVE,0)
    e5:SetTarget(function(_,c) return c:IsCode(CARD_ECTOPLASMER) end)
    e5:SetLabelObject(e4)
    Duel.RegisterEffect(e5,tp)


        local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_ADJUST)
    e6:SetCondition(s.rewriteectoplasmersscon)
    e6:SetOperation(s.rewriteectoplasmerssop)
    Duel.RegisterEffect(e6,tp)
end

local cards_to_add={63391643, 511002532}


function s.notrewrittenectoplasmerfilter(c)
    return c:IsCode(CARD_ECTOPLASMER) and c:GetFlagEffect(id) == 0
end


function s.rewriteectoplasmersscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.notrewrittenectoplasmerfilter, tp, LOCATION_ALL, 0, 1, nil)
end


function s.rewriteectoplasmerssop(e,tp)

    local g=Duel.GetMatchingGroup(s.notrewrittenectoplasmerfilter, tp, LOCATION_ALL, 0, nil)
    if #g>0 then
        for tc in g:Iter() do
            tc:RegisterFlagEffect(id, 0, 0, 0)

            local effs={tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:GetCategory()==(CATEGORY_RELEASE+CATEGORY_DAMAGE)then

                    local neweff=eff:Clone()
                    neweff:SetOperation(s.newop)

                    eff:Reset()
                    tc:RegisterEffect(neweff)
                end
            end
        end
    end
end

function s.tributefilter(c)
    return c:IsReleasableByEffect() and c:IsFaceup() and (c:IsMonster() and c:IsType(TYPE_NORMAL))
end

function s.newop(e,tp,eg,ep,ev,re,r,rp)
	local turn_player=Duel.GetTurnPlayer()
	local sc=Duel.SelectReleaseGroup(turn_player,s.tributefilter,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.Release(sc,REASON_EFFECT)>0 then
		local atk=sc:GetTextAttack()/2
		if atk>0 then
			Duel.Damage(1-turn_player,atk,REASON_EFFECT)
		end
	end
end



function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,6,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,6,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            local code=Duel.SelectCardsFromCodes(tp,1,1,false,false,cards_to_add)
            local token=Duel.CreateToken(tp, code)
            Duel.SendtoHand(token, tp, REASON_RULE)
            Duel.ConfirmCards(1-tp, token)

		end
	end
end


function s.placebackrow(e,tp,eg,ep,ev,re,r,rp)
    local ectoplasmer=Duel.CreateToken(tp, CARD_ECTOPLASMER)
    Duel.SendtoHand(ectoplasmer, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, ectoplasmer)

    if Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        local cardtrader=Duel.CreateToken(tp, 48712195)
        Duel.MoveToField(cardtrader, tp, tp, LOCATION_SZONE, POS_FACEUP, true)

        local potofsloth=Duel.CreateToken(tp, 98476659)
        Duel.SendtoHand(potofsloth, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, potofsloth)
    end
end

function s.nottaggeddmfilter(c)
    return c:IsCode(CARD_DARK_MAGICIAN) and c:GetFlagEffect(id) == 0
end

function s.rewritedmscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.nottaggeddmfilter, tp, LOCATION_ALL, 0, 1, nil)
end


function s.rewritedmsop(e,tp)

    local g=Duel.GetMatchingGroup(s.nottaggeddmfilter, tp, LOCATION_ALL, 0, nil)
    if #g>0 then
        for tc in g:Iter() do
            tc:RegisterFlagEffect(id, 0, 0, 0)
            tc:EnableCounterPermit(COUNTER_SPELL,LOCATION_MZONE)
            local metatable=tc:GetMetatable()
        if metatable.counter_place_list and #metatable.counter_place_list>0 then
            table.insert(metatable.counter_place_list,COUNTER_SPELL)
        else
            metatable.counter_place_list={COUNTER_SPELL}
        end


        end
    end
end


function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
end

function s.stacktotop(e,tp,eg,ep,ev,re,r,rp)
    s.used_this_skill[tp] = true
    --Duel.Hint(HINT_CARD, tp, id)
    local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_DECK, 0, nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 6))
        local sg=g:Select(tp, 1, 1, nil)
		Duel.MoveSequence(sg:GetFirst(),0)
    end
end


function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
        return (not s.used_this_skill[e:GetHandlerPlayer()])  and aux.CanActivateSkill(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1

end