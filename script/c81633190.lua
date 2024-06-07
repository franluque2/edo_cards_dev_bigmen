--The Supreme King's Awakening
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
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
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_DESTROY_REPLACE)
		e7:SetTarget(s.desreptg)
		e7:SetValue(s.desrepval)
        e7:SetCountLimit(1)
		e7:SetOperation(s.desrepop)
		Duel.RegisterEffect(e7,tp)





	end
	e:SetLabel(1)
end

function s.higherlevelfilter(c,lv)
    return c:IsFaceup() and c:IsLevelAbove(lv+1)
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:HasLevel() and c:IsFaceup() and
         not Duel.IsExistingMatchingCard(s.higherlevelfilter, tp, LOCATION_MZONE, 0, 1, c, c:GetLevel())
end
function s.desfilter(c,e,tp)
	return c:IsAbleToRemoveAsCost()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
        and c:IsMonster()

end
function s.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsMonster()
end 
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
    local sg=Group.RandomSelect(g, tp, 1, nil)
    e:SetLabelObject(sg:GetFirst())
    Duel.HintSelection(sg)
    return true
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)

	local tc=e:GetLabelObject()
    Duel.Remove(tc, POS_FACEUP, REASON_COST+REASON_REPLACE)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end
