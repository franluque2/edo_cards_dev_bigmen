--Power of the Plana
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e2:SetValue(function (_,c) return not (c==Duel.GetAttacker()) end)
        e2:SetTargetRange(LOCATION_MZONE, 0)
        Duel.RegisterEffect(e2, tp)
	end
	e:SetLabel(1)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local vijam=Duel.CreateToken(tp, CARD_VIJAM)
    Duel.SpecialSummon(vijam, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
    vijam:NegateEffects(e:GetHandler())


    local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 3775068,4998619,77387463,78509901,40392714,41114306)
	if g and #g>0 then
		for tc in g:Iter() do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				
                local e1=Effect.CreateEffect(tc)
                e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
                e1:SetType(EFFECT_TYPE_QUICK_O)
                e1:SetCode(EVENT_FREE_CHAIN)
                e1:SetRange(LOCATION_HAND)
                e1:SetCountLimit(1)
                e1:SetLabel(tc:GetOriginalLevel()-1)
                e1:SetCondition(s.condition)
                e1:SetTarget(s.target)
                e1:SetOperation(s.operation)
                tc:RegisterEffect(e1)
		    end
	end
    end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsBattlePhase()
end
function s.filter(c,sc)
	return c:IsMonster() and c:IsSetCard(0xe3) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,e:GetLabel(),nil,e:GetHandler()) and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) end
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,e:GetLabel(),e:GetLabel(),nil,e:GetHandler())
    Duel.SendtoGrave(tg, REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
    local totalatk=(c:GetOriginalLevel()-1)*800
    if c:IsOriginalRace(RACE_BEAST) then
        totalatk=totalatk+((c:GetOriginalLevel()-1)*200)
    end
	if c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) then
		Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(totalatk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
        c:RegisterEffect(e1)
        c:CompleteProcedure()
	end
end