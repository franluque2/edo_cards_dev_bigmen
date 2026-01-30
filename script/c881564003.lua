--Shirou the Fated Master
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If this card is Normal or Special Summoned: You can Special Summon 1 "Fated Noble Knight - Saber" from your Hand or Deck, or 1 "Fated" monster from your GY, also you cannot Special Summon monsters that started the Duel in your Main Deck for the rest of this turn, except "Fated" monsters. 
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,{id,0})
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    --During your Main Phase: You can, immediately after this effect resolves, Normal Summon a monster.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
    c:RegisterEffect(e3)

    --While you control a "Fated" Spirit monster, if a card(s) you control would be destroyed, they are not Destroyed. You can only use this effect of "Shirou the Fated Master" thrice per Duel. 
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e4:SetCountLimit(3)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_ONFIELD,0)
    e4:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsType,TYPE_SPIRIT)))
    e4:SetCondition(s.immcon)
    e4:SetValue(s.indct)
    --c:RegisterEffect(e4) Removed for balance concerns
    
    WbAux.RegisterStartedInDeckCards()
    WbAux.IncreaseFatedChantUses(c)

end
s.listed_series={SET_FATED}
s.listed_names={CARD_FATED_CHANT, 881564008} -- Fated Noble Knight - Saber

function s.spfilter(c,e,tp)
    return (c:IsCode(881564008) or (c:IsSetCard(SET_FATED) and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        --You cannot Special Summon monsters that started the Duel in your Main Deck for the rest of this turn, except "Fated" monsters.
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetLabel(id)
        e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
            return WbAux.IsStartedInDeck(c) and not c:IsSetCard(SET_FATED)
        end)
        Duel.RegisterEffect(e1,tp)
    end
end


function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if sc then
		Duel.Summon(tp,sc,true,nil)
	end
end

function s.immcon(e)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.indct(e,re,r,rp)
	if ((r&REASON_EFFECT==REASON_EFFECT) or (r&REASON_BATTLE==REASON_BATTLE)) and Duel.GetFlagEffect(e:GetHandlerPlayer(), id)<3 then
		Duel.RegisterFlagEffect(e:GetHandlerPlayer(), id, 0, 0, 1)
        return 1
    else return 0 end
end