--Healing Wind (CT)
Duel.LoadScript ("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
    e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)

    --stack
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local num=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,10321588), tp, LOCATION_ONFIELD, 0, nil)
	if chk==0 then return num>0 and Duel.IsExistingMatchingCard(Card.IsSpellTrap, tp, LOCATION_DECK, 0, 1, nil) end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp, Card.IsSpellTrap, tp, LOCATION_DECK, 0, 1,1,false,nil)
    if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc:GetFirst(),0)
		Duel.ConfirmDecktop(tp,1)
    end
end


function s.addpixiefilter(c)
    return c:IsAbleToHand() and c:IsSpellTrap() and (c:IsFairy() or c:IsPixie())
end

function s.specialsummonbeastfilter(c,e,tp)
    return c:IsCode(10321588,20210570) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL, tp, false, false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetTargetPlayer(tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local num=Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE,LOCATION_MZONE,nil)*200
    local recoveredlp=Duel.Recover(tp, num, REASON_EFFECT)
    if recoveredlp>0 then
        if recoveredlp>=200 and Duel.IsExistingMatchingCard(s.addpixiefilter, tp, LOCATION_DECK, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            local tc=Duel.SelectMatchingCard(tp, s.addpixiefilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
            if tc then
                Duel.SendtoHand(tc, tp, REASON_EFFECT)
                Duel.ConfirmCards(1-tp, tc)
            end
        end

        if recoveredlp>=400 and Duel.IsExistingMatchingCard(s.specialsummonbeastfilter, tp, LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK, 0, 1, nil, e,tp) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            local tc=Duel.SelectMatchingCard(tp, s.specialsummonbeastfilter, tp, LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK, 0, 1,1,false,nil,e,tp)
            if tc then
                if Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                    local tc1=tc:GetFirst()

                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CHANGE_LEVEL)
                e1:SetValue(3)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                tc1:RegisterEffect(e1)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_ADD_TYPE)
				e3:SetValue(TYPE_TUNER)
				tc1:RegisterEffect(e3)
                end
            end
        end

        if recoveredlp>=1000 and Duel.GetMatchingGroupCount(Card.IsFaceup, tp, LOCATION_MZONE,0,nil)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3))  then
            local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	        local tc=g:GetFirst()
	        for tc in aux.Next(g) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(recoveredlp)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
                tc:RegisterEffect(e1)

                local e2=e1:Clone()
                e2:SetCode(EFFECT_UPDATE_DEFENSE)
                tc:RegisterEffect(e2)
	        end
            
        end
    end
end
