--So as I pray, Unlimited Blade Works

Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_CONJURE)
        e1:SetType(EFFECT_TYPE_ACTIVATE)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCondition(s.confunc)
        e1:SetTarget(s.target)
        e1:SetOperation(s.activate)
        c:RegisterEffect(e1)


        --WbAux.UpdateFatedChantStatus(c)

    	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsCode(CARD_FATED_CHANT)) end)

        WbAux.RegisterStartedInDeckCards()
end
s.listed_names={CARD_FATED_CHANT,id+1}
s.listed_series={SET_FATED}

function s.confunc(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id-6,tp,ACTIVITY_CHAIN)<(1+WbAux.GetFatedChantUses(tp)) and e:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,0)
    Duel.SetTargetPlayer(1-tp)
end

function s.filterfunc(c)
    return not WbAux.IsIgnoreStaple(c)
end

function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)

    --WbAux.IncreaseFatedChantStatus(c,tp)

    --Place 1 "The Fated Reality Marble - Unlimited Blade Works" (id+1) from Outside the Duel face-up in your Field Zone
    local c=e:GetHandler()
    local fz=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
    if fz then
        Duel.SendtoGrave(fz,REASON_RULE)
    end
    local token=Duel.CreateToken(tp, id+1)
    Duel.MoveToField(token, tp, tp, LOCATION_FZONE, POS_FACEUP, true)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return c:GetFlagEffect(CARD_FATED_CHANT-1)>0 and not (c:IsSetCard(SET_FATED)) end)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)

end