--Corrupted Demises
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
        e1:SetCountLimit(1)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


        if Duel.GetFlagEffect(0, id+1)==0 then
            
            Duel.RegisterFlagEffect(0,id+1,0,0,0)

            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
            e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
            e2:SetTargetRange(0xff,0xff)
            e2:SetValue(s.rmval)
            Duel.RegisterEffect(e2,0)

            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e3:SetCode(EVENT_ADJUST)
            e3:SetCondition(s.adcon)
            e3:SetOperation(s.adop)
            Duel.RegisterEffect(e3,0)

        end
	end
	e:SetLabel(1)
end

function s.adbackfilter(c)
    return c:GetFlagEffect(id)>0
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.adbackfilter, 0, LOCATION_ALL, LOCATION_ALL, 1, nil)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.adbackfilter, 0, LOCATION_ALL, LOCATION_ALL, nil)
    if g then
        for tc in g:Iter() do
            local label=tc:GetFlagEffectLabel(id)
            if label==0 then
                tc:ResetFlagEffect(id)
                Duel.RemoveCards(tc)
            elseif label==LOCATION_DECKBOT then
                tc:ResetFlagEffect(id)
                Duel.SendtoDeck(tc, tc:GetOwner(), SEQ_DECKBOTTOM, REASON_RULE)
            elseif label==LOCATION_DECKSHF then
                tc:ResetFlagEffect(id)
                Duel.SendtoDeck(tc, tc:GetOwner(), SEQ_DECKSHUFFLE, REASON_RULE)
            end
        end
    end
end

function s.rmval(e,c)
    Duel.RegisterFlagEffect(0, id, RESET_PHASE+PHASE_END, 0, 0)
    if Duel.GetFlagEffect(0, id)==1 then
        return LOCATION_REMOVED
    elseif Duel.GetFlagEffect(0, id)==2 then
        return LOCATION_HAND
    elseif Duel.GetFlagEffect(0, id)==3 then
        c:RegisterFlagEffect(id, 0, 0, 0)
        c:SetFlagEffectLabel(id, 0)
        return LOCATION_GRAVE
    elseif Duel.GetFlagEffect(0, id)==4 then
        c:RegisterFlagEffect(id, 0, 0, 0)
        c:SetFlagEffectLabel(id, LOCATION_DECKBOT)
        return LOCATION_GRAVE
    elseif Duel.GetFlagEffect(0, id)==5 then
        return LOCATION_GRAVE
    elseif Duel.GetFlagEffect(0, id)==6 then
        c:RegisterFlagEffect(id, 0, 0, 0)
        c:SetFlagEffectLabel(id, LOCATION_DECKSHF)
        return LOCATION_GRAVE
    elseif Duel.GetFlagEffect(0, id)==7 then
        return LOCATION_REMOVED
    end
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


end
