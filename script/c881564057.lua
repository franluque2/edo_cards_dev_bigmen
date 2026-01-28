--The Fated Reality Marble - Unlimited Blade Works
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    
    --When your opponent's card effect resolves, you can send 1 card with the same original name from your hand to the GY, and if you do, negate that effect.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.negcon)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)


    --Once per turn, if your opponent adds a card(s) from their deck to their hand, except by drawing: You can add copies of those cards to your hand from Outside the Duel.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_HAND)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCategory(CATEGORY_CONJURE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp~=tp and eg:IsExists(function(c,tp) return c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW) end,1,nil,tp) end)
    e3:SetTarget(s.adtarget)
    e3:SetOperation(s.adoperation)
    c:RegisterEffect(e3)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,re:GetHandler():GetOriginalCode()) and Duel.IsChainDisablable(ev)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
    local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND,0,nil,rc:GetOriginalCode())

	if not (#g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler())) then return end

    Duel.Hint(HINT_CARD,0,id)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=g:Select(tp,1,1,nil)
    if #tc>0 and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
        Duel.NegateEffect(ev)
    end
end

function s.adtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,0)
end

function s.adoperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local p=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER)
    local g=eg:Filter(function(c,tp) return c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW) end,nil,p)
    local seen = {}
    local cardstoconjure={}
    for card in g:Iter() do
        local code = card:GetOriginalCode()
        if not seen[code] then
            seen[code] = true
            table.insert(cardstoconjure, code)
        end
    end

    if #cardstoconjure==0 then return end
    local tokens=Group.CreateGroup()
    for _,code in ipairs(cardstoconjure) do
        local token=Duel.CreateToken(tp, code)
        Duel.SendtoHand(token, tp, REASON_EFFECT)
        tokens:AddCard(token)
    end
    Duel.ConfirmCards(1-tp, tokens)
end