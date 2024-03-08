--Stone Giant (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by battle or card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(s.maidenfilter,tp))
    e1:SetCondition(s.incon)
    e1:SetValue(1)
    Duel.RegisterEffect(e1,tp)

end
function s.incon(e)
	return  Duel.IsExistingMatchingCard(s.defmaidenfilter, tp, LOCATION_SZONE, 0, 1, nil)
end

function s.maidenfilter(c,tp)
	return c:IsCode(511000126, 511000127, 38520918, 511000128, 76232340, 47986555, 32012841) and c:IsFaceup()
end

function s.defmaidenfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsFaceup()
end