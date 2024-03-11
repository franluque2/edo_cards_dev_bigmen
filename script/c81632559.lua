--Yoshitsune the Goblin of Beauty (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

    --Battle
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_POSITION)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLE_CONFIRM)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCondition(s.batcon)
    e4:SetTarget(s.battg)
    e4:SetOperation(s.batop)
    c:RegisterEffect(e4)

    --OPT Cannot die if in DEF
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetCountLimit(1)
	e5:SetValue(s.valcon)
	c:RegisterEffect(e5)
end

function s.batcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    return a:IsControler(1-tp)
end

function s.battg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
function s.batop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(1-tp,600,REASON_EFFECT)
    if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
    end
end

function s.valcon(e,re,r,rp)
	return e:GetHandler():IsDefensePos() and (r&REASON_BATTLE)~=0
end

function s.filter(c)
	return c:IsCode(511000717, 511002142) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
