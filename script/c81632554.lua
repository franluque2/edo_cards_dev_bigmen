--Stone Giant (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Each Ancient Spell get protected once, each turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.AncientSpells)
	e1:SetValue(s.indct)
	c:RegisterEffect(e1)

    --def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.AncientMonster)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
    --atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.AncientMonster)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)

    	--Recursion
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end

function s.AncientSpells(c)
	return c:IsFaceup() and c:IsCode(511000124, 511000125, 511000123)
end

function s.AncientMonster(c)
	return c:IsFaceup() and c:IsCode(511000126, 511000127, 38520918, 511000128, 76232340, 47986555, 32012841)
end

function s.indct(e,re,r,rp)
	if r&REASON_EFFECT==REASON_EFFECT then
		return 1
	else return 0 end
end

function s.atkfilter(c)
	return c:IsFaceup() and c:IsSpell()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end

function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsRace(RACE_ROCK))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hasbox=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511000122),tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,hasbox) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local fossil_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,511000122)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,fossil_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc)
			return fossil_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)
end