--Revengeance of the Desperados
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.qphandcon)
	c:RegisterEffect(e2)

    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)

end
s.listed_names={id, 881565005} --Revengeance of the Desperados, Armstrong Marshall Mastermind

function s.adfilter(c)
    return c:IsMonster() and c:ListsCode(id) and c:IsAbleToHand()
end

function s.banishfilter(c)
    return c:IsLevel(5) and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

function s.spsumfilter(c,e,tp)
    return c:IsCode(881565005) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end


function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--Add 1 monster that mentions Revengeance of the Desperados from your Deck to your hand
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK,0,1,nil)
	--Banish 2 Level 5 Tuner monsters from your Field or GY, and if you do, Special Summon 1 "Armstrong, Marshall Mastermind" from your Hand, Deck or GY, ignoring its summoning conditions.
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,nil)
        and Duel.IsExistingMatchingCard(s.spsumfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
        --For the rest of this turn, your opponent cannot activate cards or effects in response to the activation of the effects of your Level 5 Tuner monsters.
	local b3=not Duel.HasFlagEffect(tp,id+2) 
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_MZONE+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	elseif op==3 then
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
        --but if you control a monster when this card resolves, you cannot Special Summon monsters with the same name as the added monster for the rest of this turn.
        if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetTarget(function(_,c) return c:IsCode(g:GetFirst():GetCode()) end)
            e1:SetReset(RESET_PHASE|PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
	elseif op==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rg=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,nil)
        if #rg==2 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.spsumfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
            end
        end
	elseif op==3 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetValue(s.aclimit)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
	end
end

function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return re:IsActiveType(TYPE_MONSTER) and rc:IsLevel(5) and rc:IsType(TYPE_TUNER) and rc:IsControler(e:GetHandlerPlayer())
end

--If your opponent activated 10 or more cards or effects this turn, you can activate this from your hand during their turn.
function s.qphandcon(e)
    return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>9

end