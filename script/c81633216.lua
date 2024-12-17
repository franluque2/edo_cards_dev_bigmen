--Shackles for the Academia's Rabid Beast
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

local FLAVIUS_ARENA=05063379
local DAREIOS=72246674

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    



        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_DISABLE)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetCondition(s.discon)
        e7:SetTarget(aux.TargetBoolFunction(Card.IsCode,DAREIOS))
        Duel.RegisterEffect(e7, tp)


	end
	e:SetLabel(1)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


    local flavius=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL,LOCATION_ALL, nil, FLAVIUS_ARENA)
	for tc in flavius:Iter() do
		if tc:GetFlagEffect(id)==0 then
			local eff={tc:GetCardEffect()}
			for _,teh in ipairs(eff) do
                if teh:GetCode()==EVENT_ATTACK_ANNOUNCE then
                    teh:Reset()
                end

			end


            local e2=Effect.CreateEffect(tc)
            e2:SetDescription(aux.Stringid(tc:GetOriginalCode(),1))
            e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
            e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
            e2:SetCode(EVENT_ATTACK_ANNOUNCE)
            e2:SetRange(LOCATION_FZONE)
            e2:SetCountLimit(1,{id,1})
            e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
            e2:SetTarget(s.sptg)
            e2:SetOperation(s.spop)
            tc:RegisterEffect(e2)


            tc:RegisterFlagEffect(id,0,0,0)

	end
    end

end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if sc  then
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.discon(e)
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end