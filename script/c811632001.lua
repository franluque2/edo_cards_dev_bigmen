--What we do in the Shadows

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
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


	end
	e:SetLabel(1)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	s.maskmonsters(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.maskmonsters(e,tp,eg,ep,ev,re,r,rp)
    local mons=Duel.GetMatchingGroup(Card.IsMonster, tp, LOCATION_ALL-LOCATION_EXTRA, 0, nil)
    if mons then
        
        for card in mons:Iter() do
            
			s.maskcard(e,tp,card)
        end
        
    end

end

function s.maskcard(e,tp,card)
	local cardid=card:GetOriginalCode()
            local cardatk=card:GetBaseAttack()
            local carddef=card:GetBaseDefense()
            local cardlevel=Card.GetLevel(card)
			local istuner=card:IsType(TYPE_TUNER)
            
            Card.Recreate(card, id+1, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
            Card.RegisterFlagEffect(card, id, 0, 0, 0)
            Card.SetFlagEffectLabel(card, id, cardid)

            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_BASE_ATTACK)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetRange(LOCATION_MZONE)
            e2:SetCondition(s.atkcon)
            e2:SetValue(cardatk)
            card:RegisterEffect(e2)
            local e3=e2:Clone()
            e3:SetCode(EFFECT_SET_BASE_DEFENSE)
            e3:SetValue(carddef)
            card:RegisterEffect(e3)

			if card:HasLevel() then
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_CHANGE_LEVEL)
				e4:SetValue(cardlevel)
				card:RegisterEffect(e4)
			end

			if istuner then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_ADD_TYPE)
				e1:SetValue(TYPE_TUNER)
				card:RegisterEffect(e1)
			end

end

function s.unmaskcard(e,tp,card)
	local originalid=Card.GetFlagEffectLabel(card, id)
	Card.Recreate(card, originalid, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCondition(s.sumcon)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	card:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	card:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	card:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	card:RegisterEffect(e4)

	card:RegisterFlagEffect(id+1, 0,0,0)
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+1)~=0
end

function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
end

function s.shadowmonster(c)
	return c:IsCode(id+1)
end

function s.notshadowmonster(c)
	return c:IsMonster() and not s.shadowmonster(c)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	local b1=Duel.IsExistingMatchingCard(s.shadowmonster,tp,LOCATION_HAND,0,1,nil,tp)
						

	local b2=Duel.IsExistingMatchingCard(s.notshadowmonster,tp,LOCATION_HAND,0,1,nil,tp)

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local b1=Duel.IsExistingMatchingCard(s.shadowmonster,tp,LOCATION_HAND,0,1,nil,tp)
						

	local b2=Duel.IsExistingMatchingCard(s.notshadowmonster,tp,LOCATION_HAND,0,1,nil,tp)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})

	if op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local shadows=Duel.GetMatchingGroup(s.shadowmonster, tp, LOCATION_HAND, 0, nil)
	for mon in shadows:Iter() do
		s.unmaskcard(e,tp,mon)
	end


end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local shadows=Duel.GetMatchingGroup(s.notshadowmonster, tp, LOCATION_HAND, 0, nil)
	for mon in shadows:Iter() do
		s.maskcard(e,tp,mon)
		mon:ResetFlagEffect(id+1)
	end
end
