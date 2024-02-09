--Tag Duels are Dumb and they need a Filler
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetLabel(0)
    e1:SetRange(LOCATION_ALL)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

end



function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		
        Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)

        if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
            Duel.Draw(tp, 1, REASON_EFFECT)
        end

	end
	e:SetLabel(1)
end