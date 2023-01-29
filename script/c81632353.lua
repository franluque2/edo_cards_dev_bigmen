--Topologina Sassabee (CT)
local s, id = GetID()
function s.initial_effect(c)
    --Link Summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x57b), 2)
    c:EnableReviveLimit()

    --add back mats
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_LEAVE_GRAVE + CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.addcon)
    e1:SetTarget(s.addtg)
    e1:SetCountLimit(1, id)
    e1:SetOperation(s.addop)
    c:RegisterEffect(e1)
end

function s.addcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_LINK)
end

function s.addfilter(c)
    return c:IsSetCard(0x57b) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
        and c:IsAbleToHand()
end

function s.addtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = c:GetMaterial():Filter(s.addfilter, nil)
    if chk == 0 then return #g > 0 end
end

function s.addop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetMaterial():Filter(s.addfilter, nil)

    if Duel.SendtoHand(g, tp, REASON_EFFECT) then

        Duel.ConfirmCards(1-tp, g)

    end

end
