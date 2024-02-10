--Cruel Shackles of Heartland
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
        
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_DISABLE)
        e8:SetTargetRange(LOCATION_MZONE,0)
		e8:SetCondition(function (ef) return Duel.GetTurnPlayer()~=ef:GetHandlerPlayer() end)
        e8:SetTarget(function (_,c) return c:IsOriginalCode(72006609) end)
        Duel.RegisterEffect(e8, tp)


        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(0,LOCATION_ONFIELD)
        e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_CANNOT_TRIGGER)
        e9:SetTargetRange(LOCATION_GRAVE,0)
        e9:SetTarget(s.actfilter)
        Duel.RegisterEffect(e9, tp)


	end
	e:SetLabel(1)
end


function s.actfilter(e,c)
	return c:IsCode(39752820)
end

function s.efilter(e,te, c)
	return e:GetHandler()~=te:GetHandler() and c~=te:GetHandler() and te:GetHandler():IsLocation(LOCATION_ONFIELD) and c:GetColumnGroup():IsContains(te:GetHandler()) and te:GetHandler():IsCode(98935722,62530723,02930675)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


    local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 35546670)
	if g and #g>0 then
		for tc in g:Iter() do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				local eff={tc:GetCardEffect()}
				for _,teh in ipairs(eff) do
					if teh:GetCategory()&CATEGORY_TOGRAVE==CATEGORY_TOGRAVE then
						teh:Reset()
					end
				end
		end
	end
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
