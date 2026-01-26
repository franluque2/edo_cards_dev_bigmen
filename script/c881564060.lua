--Zouken the Fated Master
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    -- Your opponent must also pay half their LP to activate "Dregs of Angra Mainju".

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ACTIVATE_COST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCost(s.costchk)
	e1:SetTarget(s.costtg)
	e1:SetOperation(s.costop)
	c:RegisterEffect(e1)

    -- If this card is Normal or Special Summoned: You can destroy 1 "Fated" Spirit monster you control or in your hand, and if you do, add 2 "Dregs of Angra Mainju" from Outside the Duel to your opponent's hand. 

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_CONJURE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,0})
    e2:SetTarget(s.adtarget)
    e2:SetOperation(s.adop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    -- If this card is sent to the GY, or banished, by an opponent's card effect: Banish exactly 2 other cards from each GY, and if you do, Special Summon this card, also it cannot be targetted for attacks for the rest of this turn.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.spgravecon)
    e4:SetTarget(s.spgravetg)
    e4:SetOperation(s.spgraveop)
    c:RegisterEffect(e4)

    local e5=e4:Clone()
    e5:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e5)
end
s.listed_names={CARD_DREGS_ANGRA_MAINYU}
s.listed_series={SET_FATED}


function s.costchk(e,te_or_c,tp)
	return Duel.CheckLPCost(tp, math.floor(Duel.GetLP(tp)/2))
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp, math.floor(Duel.GetLP(tp)/2))
end

function s.costtg(e,te,tp)
	if not te:IsActivated() then return false end
	local tc=te:GetHandler()
    if tc:IsCode(CARD_DREGS_ANGRA_MAINYU) then return true
	else return false end
end


function s.adfilter(c)
    return c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) and c:IsDestructable()
end

function s.adtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        WbAux.AddDregs(1-tp,2)
        Duel.Destroy(g,REASON_EFFECT)
    end
end

function s.spgravecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsReason(REASON_EFFECT) and rp==1-tp)
end

function s.spgravefilter(c)
    return c:IsAbleToRemove()
end

function s.spgravetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spgravefilter,tp,LOCATION_GRAVE,0,2,e:GetHandler())
        and Duel.IsExistingMatchingCard(s.spgravefilter,1-tp,LOCATION_GRAVE,0,2,e:GetHandler())
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,2,nil,tp) and sg:IsExists(Card.IsControler,2,nil,1-tp)
end

function s.spgraveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(s.spgravefilter, tp, LOCATION_GRAVE, 0, e:GetHandler())
    local g1=aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,1,tp,HINTMSG_REMOVE)
    if Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)>=4 then
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
            --Cannot be targeted for attacks this turn
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
            e1:SetValue(aux.imval1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end