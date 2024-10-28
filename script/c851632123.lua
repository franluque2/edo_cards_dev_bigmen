--The Wight House
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetValue(CARD_SKULL_SERVANT)
	c:RegisterEffect(e2)


    local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(0,EFFECT_FLAG2_FORCE_ACTIVATE_LOCATION)
	e3:SetValue(LOCATION_FZONE)
	e3:SetTarget(s.target)
    e3:SetCost(s.cost)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)



    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(s.con)
	e4:SetValue(s.tg)
	c:RegisterEffect(e4)



    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCost(s.costfunc)
	e5:SetCondition(s.condition)
	e5:SetTarget(s.target2)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)


end

s.listed_names={CARD_SKULL_SERVANT,36021814}


function s.con(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,36021814),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.filter(c)
	return not  (c:IsFaceup() and c:IsCode(36021814))
end
function s.tg(e,c)
	return s.filter(c)
end


function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
		return c:GetActivateEffect():IsActivatable(tp,true,true)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(3300)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
    e1:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e1,true)

end



function s.cfilter(c,e,tp)
	return c:IsCode(36021814) and c:IsMonster() and (c:GetReason()&0x41)==0x41
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp,false,false)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.cfilter, nil,e, tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=eg:Filter(s.cfilter, nil,e, tp)
    local tc=g:GetFirst()
    if tc then
        Duel.HintSelection(tc)
        Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)
    end
end



function s.costfilter(c,tp)
	return c:IsCode(CARD_SKULL_SERVANT,id) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true) 
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5))
end
function s.costfunc(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.cfilter, nil,e, tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,g:GetFirst(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,g:GetFirst(),tp)
	Duel.Remove(g2,POS_FACEUP,REASON_COST)
end