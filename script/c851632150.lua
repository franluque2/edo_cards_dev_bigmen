--Frightfur Jumpscare
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_SZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.thcond)
	e2:SetTarget(s.thtg)
    e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EVENT_CHAIN_DISABLED)
    c:RegisterEffect(e3)

    local e4=e2:Clone()
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.confunc)
    c:RegisterEffect(e4)

end
s.listed_names={CARD_POLYMERIZATION,70245411, 34773082}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCode(id) end
    if e:IsHasType(EFFECT_TYPE_IGNITION) then
		Duel.SetChainLimit(aux.FALSE)
	end

end

function s.confunc(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:HasFlagEffect(id)
end

function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if re:GetHandler()==e:GetHandler() and rp==tp and dp~=tp then
        e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
        return true
    end
    return false
end

function s.thfilter(c)
	return c:IsCode(CARD_POLYMERIZATION,70245411, 34773082) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
    if e:IsHasType(EFFECT_TYPE_TRIGGER_O) then
		Duel.SetChainLimit(aux.FALSE)
	end
     end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

local changenames={CARD_POLYMERIZATION,70245411, 34773082}

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local res=Duel.SelectCardsFromCodes(tp,1,1,false,false,changenames)
    if res then
        Card.Recreate(c, res, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
        c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
        if res==CARD_POLYMERIZATION then
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(1170)
            e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
            e1:SetType(EFFECT_TYPE_ACTIVATE)
            e1:SetCode(EVENT_FREE_CHAIN)
            e1:SetTarget(Fusion.SummonEffTG(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,extratg,mincount,maxcount,sumpos))
            e1:SetOperation(s.drawop)
            e1:SetReset(EVENT_LEAVE_FIELD+EVENT_REMOVE+EVENT_TO_GRAVE)
            c:RegisterEffect(e1)
        elseif res==70245411 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_ACTIVATE)
            e1:SetCode(EVENT_FREE_CHAIN)
            e1:SetOperation(s.drawop2)
            e1:SetReset(EVENT_LEAVE_FIELD+EVENT_REMOVE+EVENT_TO_GRAVE)
            c:RegisterEffect(e1)
        elseif res==34773082 then
            local e1=Effect.CreateEffect(c)
            e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
            e1:SetType(EFFECT_TYPE_ACTIVATE)
            e1:SetCode(EVENT_FREE_CHAIN)
            e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
            e1:SetTarget(s.target2)
            e1:SetOperation(s.drawop)
            e1:SetReset(EVENT_LEAVE_FIELD+EVENT_REMOVE+EVENT_TO_GRAVE)
            c:RegisterEffect(e1)
        
        end

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_LEAVE_FIELD_P)
        e2:SetOperation(s.retop)
        c:RegisterEffect(e2)

        local e3=e2:Clone()
        e3:SetCode(EVENT_TO_GRAVE)
        e3:SetCondition(function (_e) return not _e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
        c:RegisterEffect(e3)

        local e4=e2:Clone()
        e4:SetCode(EVENT_REMOVE)
        e4:SetCondition(function (_e) return not _e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
        c:RegisterEffect(e4)

    end
    Duel.ShuffleHand(tp)
end


function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Card.Recreate(e:GetHandler(), id, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

function s.drawop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
    Duel.SendtoGrave(e:GetHandler(), REASON_RULE)
end