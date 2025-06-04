--Ere-Wight the Withered Monarch
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Becomes Skull Servant in GY
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(CARD_SKULL_SERVANT)
	c:RegisterEffect(e0)

    --Normal Summon from GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetTarget(s.target)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)


    	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

end
s.listed_names={CARD_SKULL_SERVANT}

function s.releasefilter(c, tp)
    return c:IsReleasable() and (c:IsControler(tp) or c:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM))
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local min,max=e:GetHandler():GetTributeRequirement()
	if chk==0 then return e:GetHandler():IsSummonable(false,nil) and not Duel.IsPlayerAffectedByEffect(tp, EFFECT_NECRO_VALLEY)
        and Duel.IsExistingMatchingCard(s.releasefilter, tp, LOCATION_MZONE, LOCATION_MZONE, min, nil,tp) end
	Duel.SetOperationInfo(0, CATEGORY_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, e:GetHandler(), 1, 0, 0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local min,max=e:GetHandler():GetTributeRequirement()
    if not (aux.NecroValleyFilter(Card.IsSummonable,e:GetHandler(), false, nil, min) and Duel.IsExistingMatchingCard(s.releasefilter, tp, LOCATION_MZONE, LOCATION_MZONE, min, nil,tp)) then return end
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Summon(tp,e:GetHandler(),false,nil)
end



function s.drcfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(s.drcfilter,tp,LOCATION_HAND,0,1,nil) or (e:GetHandler():IsTributeSummoned() and Duel.IsExistingMatchingCard(s.drcfilter,tp,LOCATION_DECK,0,1,nil))) end
	local ft=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local g=Duel.GetMatchingGroup(s.drcfilter,tp,LOCATION_HAND,0,nil)
    if e:GetHandler():IsTributeSummoned() then
        local g2=Duel.GetMatchingGroup(s.drcfilter,tp,LOCATION_DECK,0,nil)
        g:Merge(g2)
    end
	local ct=math.min(ft,#g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,math.min(ct,2),nil)
	e:SetLabel(#sg)
	Duel.SendtoGrave(sg,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)

    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
end

function s.splimit(e,c)
	return c:GetRace()~=RACE_ZOMBIE
end