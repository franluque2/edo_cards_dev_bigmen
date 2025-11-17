--Advanced Crystal Beast Rainbow Dark Dragon
local s,id=GetID()
function s.initial_effect(c)	

    	--Place itself in the Spell & Trap Zone as a Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetCondition(s.repcon)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE|LOCATION_HAND)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.spthtg)
	e3:SetOperation(s.spthop)
	c:RegisterEffect(e3)

    --if an "Advanced Dark" you control would be destroyed, you can banish this card from your GY or Spell/Trap Zone instead
    local e4=Effect.CreateEffect(c)
    e4:SetCountLimit(1,{id,2})
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetRange(LOCATION_GRAVE|LOCATION_SZONE)
    e4:SetTarget(s.reptg)
    e4:SetValue(s.repval)
    c:RegisterEffect(e4)

end
s.listed_series={SET_ADVANCED_CRYSTAL_BEAST,SET_ULTIMATE_CRYSTAL}
s.listed_names={CARD_ADVANCED_DARK,79407975} -- Rainbow Dark Dragon

function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Treated as a Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
	c:RegisterEffect(e1)
	Duel.RaiseEvent(c,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
end

function s.spthfilter(c,e,tp)
    return c:IsSetCard(SET_ADVANCED_CRYSTAL_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.addfilter(c)
    return c:IsCode(79407975) and c:IsAbleToHand()
end

function s.spthtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spthfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spthop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)
        or not Duel.IsExistingMatchingCard(s.spthfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g1>0 and Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g1)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g2=Duel.SelectMatchingCard(tp,s.spthfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g2>0 then
            local tc=g2:GetFirst()
            if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
                if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ADVANCED_DARK),tp,LOCATION_ONFIELD,0,1,nil) then
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_DISABLE)
                    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                    local e2=Effect.CreateEffect(e:GetHandler())
                    e2:SetType(EFFECT_TYPE_SINGLE)
                    e2:SetCode(EFFECT_DISABLE_EFFECT)
                    e2:SetReset(RESET_EVENT|RESETS_STANDARD)
                    tc:RegisterEffect(e2)
                end
            Duel.SpecialSummonComplete()
            end
        end
    end
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(function(tc)
        return tc:IsFaceup() and tc:IsControler(tp) and tc:IsCode(CARD_ADVANCED_DARK)
            and not tc:IsReason(REASON_REPLACE)
    end,1,nil) and c:IsAbleToRemove() end
    return Duel.SelectEffectYesNo(tp,c,96)
end

function s.repval(e,c)
    return c:IsFaceup() and c:IsControler(e:GetHandlerPlayer()) and c:IsCode(CARD_ADVANCED_DARK)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end