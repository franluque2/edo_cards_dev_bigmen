--Alex, Minecrafter
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfiltersum,1,1)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
    e1:SetCost(s.opccost)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)

	

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCost(s.opccost)
	e2:SetTarget(s.target)
	e2:SetCondition(function () return Duel.IsMainPhase() end)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MINECRAFT}


function s.eqfilter(c,tp)
	return (c:IsRace(RACE_ROCK) or c:IsSetCard(SET_MINECRAFT) ) and (c:IsOwner(tp) or c:IsAbleToChangeControler()) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
	end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc1=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		s.equipop(tc1,e,tp,tc,c)
	end
end

function s.equipop(c,e,tp,tc,owner)
	if not Duel.Equip(tp,tc,c) then return end
	local e2=Effect.CreateEffect(tc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(function(e,ec) return ec==c end)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)

	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(500)
	tc:RegisterEffect(e1)
end

function s.chainfilter(re,tp,cid)
	return re:IsActiveType(TYPE_MONSTER) and not (re:GetHandler():IsSetCard(SET_MINECRAFT) or re:GetHandler():IsRace(RACE_ROCK))
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end


function s.aclimit(e,re,tp)
	return re:IsMonsterEffect() and not (re:GetHandler():IsSetCard(SET_MINECRAFT) or (re:GetHandler():IsRace(RACE_ROCK)))
end

function s.opccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp, 5)
	if Duel.DiscardDeck(tp,5,REASON_EFFECT)>0 then
        local fg=g:Filter(Card.IsMonster,nil)
        if #fg>0 then
            local attrrs={}
            for tc in fg:Iter() do
                if not attrrs[tc:GetAttribute()] then
                    attrrs[tc:GetAttribute()]=true
                    local token=WbAux.GetMinecraftNormie(tp,tc:GetAttribute())
                    Duel.SendtoHand(token, tp, REASON_EFFECT)
                    Duel.ConfirmCards(1-tp, token)
                end
            end
        end
    end
end

function s.matfiltersum(c,lc,sumtype,tp)
	return (c:IsType(TYPE_NORMAL,lc,sumtype,tp) or c:IsRace(RACE_ROCK,lc,sumtype,tp)) and not c:IsType(TYPE_TOKEN,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end