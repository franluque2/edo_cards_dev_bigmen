--Conscription into the Spirit World
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

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetCondition(function(_e) return not (Duel.GetTurnPlayer()~=_e:GetHandlerPlayer() and Duel.GetCurrentPhase()==PHASE_END) end)
        e7:SetTargetRange(0,LOCATION_MZONE)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)


	end
	e:SetLabel(1)
end

function s.efilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(05414777)
end


function s.dragonandlowlevelfairyfilter(c)
    return c:IsCode(02403771,25165047) or (c:IsRace(RACE_BEAST|RACE_PLANT|RACE_FAIRY) and c:IsLevelBelow(4) and c:IsType(TYPE_EFFECT))
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g2=Duel.GetMatchingGroup(s.dragonandlowlevelfairyfilter, tp, LOCATION_ALL, 0, nil)


    for tc in g2:Iter() do
        local metatable=tc:GetMetatable()
        if metatable.listed_names and #metatable.listed_names>0 then
            table.insert(metatable.listed_names,CARD_ANCIENT_FAIRY_DRAGON)
        else
            metatable.listed_names={TOKEN_ADVENTURER,CARD_ANCIENT_FAIRY_DRAGON}
        end
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

