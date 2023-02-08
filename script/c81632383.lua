--Engage and Strike! (CT)
local s,id=GetID()
function s.initial_effect(c)
	-- Inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(_,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.LowerLevelFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.LowerLevelFilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		Duel.Damage(1-tp,tc:GetLevel()*100+tc:GetRank()*100+tc:GetLink()*100,REASON_EFFECT)
	end
end
function s.LowerLevelFilter(c)
    return c:IsFaceup() and (Card.HasLevel or Card.HasRank or Card.HasLink)
end