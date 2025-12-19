--Icejade Litemite
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetCountLimit(1,{id,0})
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(Cost.Discard())
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)

    -- If a Face-up WATER monster you control is destroyed by battle or card effect, while this card is in your GY: You can banish this card; Special Summon 1 "Icejade" monster from your Deck or banishment, except "Icejade Litemite". You can only use each effect of "Icejade Litemite" once per turn.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,4))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return eg:IsExists(function(c,tp) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsControler(tp) end,1,nil,tp)
    end)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.spicetarget)
    e3:SetOperation(s.spopice)
    c:RegisterEffect(e3)
end
s.listed_series={SET_ICEJADE}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return not (r&REASON_DRAW)~=0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    -- Cannot Special Summon monsters from the Extra Deck for the rest of this turn, except WATER monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetLabel(Duel.GetTurnPlayer())
    e1:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetLabel() end)
    e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
        return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_WATER)
    end)
    Duel.RegisterEffect(e1,tp)
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,18494512,0,TYPES_TOKEN,0,0,3,RACE_AQUA,ATTRIBUTE_WATER) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,18494512,0,TYPES_TOKEN,0,0,3,RACE_AQUA,ATTRIBUTE_WATER) then return end
    local token=Duel.CreateToken(tp,18494512)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		--Cannot Special Summon non-WATER monsters from Extra Deck
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_WATER) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		--Clock Lizard check
		local e2=aux.createContinuousLizardCheck(e:GetHandler(),LOCATION_MZONE,function(_,c) return not c:IsAttribute(ATTRIBUTE_WATER) end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
end


function s.spicetarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(function(c,e,tp) return c:IsSetCard(SET_ICEJADE) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
            tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end

function s.spopice(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,function(c,e,tp) return c:IsSetCard(SET_ICEJADE) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
        tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end