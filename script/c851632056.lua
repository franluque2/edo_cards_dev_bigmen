--Frieslas Rezeptbuch (Friesla's Recipe Book)
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FRIESLA}
s.listed_names={30243636}


function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsCode(30243636)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.flipfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_FLIP) and c:IsCanTurnSet()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.flipfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,30243636), tp, LOCATION_MZONE, 0, 1, nil) and
        Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil)
     end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)

end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,s.flipfilter,tp,LOCATION_MZONE,0,1,1,nil,false,nil):GetFirst()
	if tc and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
            if Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) then
                local burger=Duel.SelectMatchingCard(tp, aux.FaceupFilter(Card.IsCode,30243636), tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
                local tc2=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
                if burger and tc2 and not tc2:IsImmuneToEffect(e) then
                    Duel.HintSelection(tc2)
                    Duel.HintSelection(burger)
                    Duel.Overlay(burger,tc2,true)
	end
            end
        end
	end
end

function s.filter(c)
	return not c:IsType(TYPE_TOKEN) and c:IsAbleToChangeControler()
end