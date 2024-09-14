--Neo Flamvell Archfellow
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	
end
s.listed_series={SET_FLAMVELL}

function s.spcon(e,c)
	if c==nil then return true end
    if c:IsLocation(LOCATION_GRAVE) then
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
    end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_FLAMVELL),tp,LOCATION_MZONE,0,1,nil)
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local poun=Duel.CreateToken(tp,28332833)
    if Duel.SpecialSummon(poun, SUMMON_TYPE_SPECIAL, tp, 1-tp, false, false, POS_FACEDOWN_DEFENSE) and
	Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_FLAMVELL),tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
		local tc=Duel.SelectMatchingCard(tp, aux.FaceupFilter(Card.IsSetCard,SET_FLAMVELL), tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
		if tc then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
    end

end