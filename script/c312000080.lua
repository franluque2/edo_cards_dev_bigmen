--Healing Wind (CT)
Duel.LoadScript ("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
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
s.listed_names={CARD_ANCIENT_FAIRY_DRAGON}
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local num=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,10321588), tp, LOCATION_ONFIELD, 0, nil)
	if chk==0 then return num>0 and Duel.IsExistingMatchingCard(s.equipfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil) end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp,s.equipfilter,tp,LOCATION_DECK+LOCATION_GRAVE, 0, 1,1,false,nil)
    if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc:GetFirst(),0)
		Duel.ConfirmDecktop(tp,1)
    end
end
function s.equipfilter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_EQUIP)
end

function s.addpixiefilter(c)
    return c:IsAbleToHand() and (c:IsMonster() and c:ListsCode(CARD_ANCIENT_FAIRY_DRAGON))
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
    end
end
