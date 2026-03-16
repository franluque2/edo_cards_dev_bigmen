--Moze of the Shadow Hand
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        c:SetUniqueOnField(1,0,id)

	--If this face-up card would leave the field, banish it instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)

    --You can banish this card from your Hand; Special Summon 1 monster from your Extra Deck that mentions "Followup Token".
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST) end)
    e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA) end)
    e2:SetOperation(s.splinkoper)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)

    	--Count summons and attacks
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)

        		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_BATTLED)
		ge3:SetOperation(function(_,_,_,ep) Duel.RegisterFlagEffect(1,id,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge3,0)

	end)


    --During the Main Phase, if 2 or more monsters have battled this turn, while this card is banished (Quick Effect); You can target 1 face-up monster your opponent controls; Special Summon this card (also its ATK becomes 800* the number of "Followup Token" that were Special Summoned this turn until the End Phase), and if you do, it immediately attacks that target and proceed with damage calculation.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(function() return Duel.GetFlagEffect(1,id)>=2 and Duel.IsMainPhase() end)
    e3:SetTarget(s.sptarg)
    e3:SetOperation(s.spoper)
    e3:SetCountLimit(1,{id,0})
    c:RegisterEffect(e3)
end
s.listed_names={TOKEN_FOLLOWUP}


function s.spfilter(c,e,tp)
    return c:ListsCode(TOKEN_FOLLOWUP) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end


function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsCode,nil,TOKEN_FOLLOWUP)
	for tc in g:Iter() do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
end

function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
        if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) and e:GetHandler():IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false,POS_FACEUP_ATTACK) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.spoper(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local tc=Duel.GetFirstTarget()
        if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c, SUMMON_TYPE_SPECIAL, tp, tp, false, false,POS_FACEUP_ATTACK) then
            local ct=Duel.GetFlagEffect(0,id)

            c:CompleteProcedure()
            if tc:IsRelateToEffect(e) and tc:IsFaceup() then
                            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetRange(LOCATION_MZONE)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e1:SetValue(-ct*800)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e1)
            Duel.AdjustInstantly(tc)
                Duel.CalculateDamage(c,tc)
            end
        end
end

function s.splinkoper(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then

        Duel.SpecialSummonComplete()
    end
end