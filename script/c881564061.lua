--The Fated Reptillianne Rider
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)
    	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)

    --Your opponent cannot activate the effects of monsters with 0 ATK.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)

    --You can reveal this card in your Hand; add 1 "Sakura the Fated Master" from your Deck or GY to your hand, then discard a card, also during your Main Phase this turn, you can Normal Summon 1 "Sakura the Fated Master" in addition to your Normal Summon/Set (you can only gain this effect once per turn). 
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_HAND)
    e3:SetCost(Cost.SelfReveal)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.adtar)
    e3:SetOperation(s.adop)
    c:RegisterEffect(e3)

    --(Quick Effect): You can target 2 face-up monsters on the field, including a monster you control; their ATK/DEF becomes 0 until the End Phase.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.redtarg)
    e4:SetOperation(s.redoper)
    c:RegisterEffect(e4)

end
s.listed_series={SET_FATED}
s.listed_names={881564064} --Sakura the Fated Master

function s.splimit(e,se,sp,st)
    return se:GetHandler():IsSetCard(SET_FATED)
end

function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return rc:IsMonster() and rc:GetAttack()==0
end

function s.adfilter(c)
    return c:IsCode(881564064) and c:IsAbleToHand()
end

function s.adtar(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.adfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.adfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.BreakEffect()
        Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
        --Normal Summon 1 "Sakura the Fated Master" in addition to your Normal Summon/Set this turn.
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetTarget(function(e,c) return c:IsCode(881564064) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp)
end

function s.reducefilter(c,e)
    return c:IsFaceup() and c:IsCanBeEffectTarget(e) and (c:IsAttackAbove(0) or c:IsDefenseAbove(0))
end

function s.redtarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.reducefilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_FACEUP)
    Duel.SetTargetCard(tg)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tg,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,tg,2,0,0)
end

function s.redoper(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    for tc in g:Iter() do
        if tc:IsFaceup() and tc:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)

            local e2=e1:Clone()
            e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
            tc:RegisterEffect(e2)
        end
    end
end