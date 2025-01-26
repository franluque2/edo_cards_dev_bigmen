--Sorcerer of Burning Friendship (CT)
local s,id=GetID()
Duel.LoadScript ("big_aux.lua")
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
    local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0)
local b2=#g2>=2 and aux.SelectUnselectGroup(g2,e,tp,2,2,aux.dncheck,0)
if chk==0 then return b1 or b2 end
local op=Duel.SelectEffect(tp,
    {b1,aux.Stringid(id,1)},
    {b2,aux.Stringid(id,2)})
e:SetLabel(op)
if op==1 then
    e:SetCategory(CATEGORY_SPECIAL_SUMMON)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
elseif op==2 then
    e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT) then
        local op=e:GetLabel()
        if op==1 then
    	--Special Summon 2 vanillas monster from your Deck
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
		local g=Duel.GetMatchingGroup(s.Summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
        if #g<2 then return end
        local thg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if #thg>0 then
			Duel.SpecialSummon(thg,0,tp,tp,true,false,POS_FACEUP)
		end
	elseif op==2 then
		--Search 1 "Toon" Spell/Trap
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
        if #g2<2 then return end
        local thg=aux.SelectUnselectGroup(g2,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
		if #thg>0 then
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,thg)
		end
	end
end
end

function s.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.Summonfilter,1,false,aux.ReleaseCheckMMZ,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.Summonfilter,1,1,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end

function s.Summonfilter(c)
	return ((((c:IsRace(RACE_FAIRY) and c:IsLevelBelow(4)) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsType(TYPE_NORMAL)))
end

function s.thfilter(c)
	return c:IsCTFriendship() and not c:IsCode(id)
end