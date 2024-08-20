--Unyielding Shackles of Bonds
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
        
        local e15=Effect.CreateEffect(e:GetHandler())
        e15:SetType(EFFECT_TYPE_FIELD)
        e15:SetCode(EFFECT_CANNOT_TRIGGER)
        e15:SetTargetRange(LOCATION_MZONE,0)
        e15:SetCondition(s.discon)
        e15:SetTarget(s.actfilter)
        Duel.RegisterEffect(e15, tp)

	end
	e:SetLabel(1)
end




function s.discon(e)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.actfilter(e,c)
	return c:IsCode(CARD_BLACK_ROSE_DRAGON)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local bigdargon=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 35952884,21123811,37442336)
    if #bigdargon>0 then
	local tc=bigdargon:GetFirst()
	while tc do
      if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				local eff={tc:GetCardEffect()}
				for _,teh in ipairs(eff) do
					if teh:GetCode()&EFFECT_SPSUMMON_PROC==EFFECT_SPSUMMON_PROC then
						teh:Reset()
					end
        end
        Synchro.AddProcedure(tc,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),4,4)

        local e3=Effect.CreateEffect(tc)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e3:SetCode(EFFECT_SPSUMMON_CONDITION)
        e3:SetValue(s.splimit)
        tc:RegisterEffect(e3)
    

      end

		tc=bigdargon:GetNext()
		end
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.splimit(e,se,sp,st)
	return not se:GetHandler():IsCode(CARD_CRIMSON_DRAGON)
end