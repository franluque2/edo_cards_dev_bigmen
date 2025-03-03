--Shackles of the Academia's Sisters
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

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetTarget(s.defamazonessfilter)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

	end
	e:SetLabel(1)
end


function s.defamazonessfilter(e,c)

    return (c:IsDefensePos() and (c:IsType(TYPE_FUSION) or c:IsCode(10979723)) and c:IsSetCard(SET_AMAZONESS))
end

function s.efilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(15951532,4591250)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local augusta=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 23965033)
    for tc in augusta:Iter() do
        tc:SetUniqueOnField(1,0,23965033)
    end

    local tigers=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL,0, nil, 10979723, 68507541, 59353647)
	for tc in tigers:Iter() do
		if tc:GetFlagEffect(id)==0 then
			tc:RegisterFlagEffect(id,0,0,0)
			local eff={tc:GetCardEffect()}
			for _,teh in ipairs(eff) do
				if (Effect.GetType(teh)&EFFECT_TYPE_FIELD)==EFFECT_TYPE_FIELD then
					teh:Reset()
				end
			end
			
            local e3=Effect.CreateEffect(tc)
            e3:SetType(EFFECT_TYPE_FIELD)
            e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
            e3:SetRange(LOCATION_MZONE)
            e3:SetTargetRange(0,LOCATION_MZONE)
            e3:SetValue(s.atktg)
            tc:RegisterEffect(e3)
			
			local e2=Effect.CreateEffect(tc)
			e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
			e2:SetType(EFFECT_TYPE_IGNITION)
			e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCountLimit(1,id)
			e2:SetCost(s.spcost)
			e2:SetTarget(s.sptg)
			e2:SetOperation(s.spop)
			tc:RegisterEffect(e2)

			tc:RegisterFlagEffect(id,0,0,0)
	end
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	--Cannot attack this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x4) and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local tc1=tg:GetFirst()
	local tc2=tg:GetNext()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	if tc1 and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2 then
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x4) and not c:IsRace(RACE_BEAST)
end

