--Perpetual Employment
Duel.LoadScript("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

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

        local c=e:GetHandler()

        		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
        e1:SetCountLimit(1)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e2:SetCode(EVENT_MOVE)
            e2:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA) end)
            e2:SetOperation(s.completeExtra)
            Duel.RegisterEffect(e2,tp)

            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e3:SetCode(EVENT_MOVE)
            e3:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_GRAVE) end)
            e3:SetOperation(s.completeGraveyard)
            Duel.RegisterEffect(e3,tp)


    end
end


function s.completeExtra(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsPreviousControler,nil,tp)
    local gfacedown=g:Filter(Card.IsPreviousPosition,nil,POS_FACEDOWN)
    for tc in gfacedown:Iter() do
        local token=Duel.CreateToken(tp, tc:GetOriginalCode())
        Duel.SendtoDeck(token, nil, SEQ_DECKBOTTOM, REASON_RULE)
    end

    local gfaceup=g:Filter(Card.IsPreviousPosition,nil,POS_FACEUP)
    for tc in gfaceup:Iter() do
        local token=Duel.CreateToken(tp, tc:GetOriginalCode())
        Duel.SendtoExtraP(token, tp, REASON_RULE)
    end
end

function s.completeGraveyard(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsPreviousControler,nil,tp)
    for tc in g:Iter() do
        local token=Duel.CreateToken(tp, tc:GetOriginalCode())
        Duel.SendtoGrave(token, REASON_RULE)
    end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


end
