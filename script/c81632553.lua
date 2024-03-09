--Ancient Giant (CT)
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,511000126)
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
	e2:SetValue(s.defval)
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
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4,false)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)

    --damage
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_REPEAT+EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetCondition(s.damcon)
	e6:SetTarget(s.damtg)
	e6:SetOperation(s.damop)
	e6:SetLabel(0)
	c:RegisterEffect(e6)
	--check
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_BATTLED)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetOperation(s.chkop)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetCode(EVENT_ADJUST)
	e8:SetCountLimit(1)
	e8:SetRange(LOCATION_MZONE)
	e8:SetOperation(s.clear)
	e8:SetLabelObject(e6)
	c:RegisterEffect(e8)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and e:GetLabel()==0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.chkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	if a~=c or not tc or tc:IsControler(tp) then return end
	e:GetLabelObject():SetLabel(1)
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end

function s.AncientSpells(e,c)
	return c:IsFaceup() and c:IsCode(511000124, 511000125, 511000123)
end

function s.AncientMonster(e,c)
	return c:IsFaceup() and c:IsCode(511000126, 511000127, 38520918, 511000128, 76232340, 47986555, 32012841)
end

function s.indct(e,re,r,rp)
	if r&REASON_EFFECT==REASON_EFFECT then
		return 1
	else return 0 end
end

function s.atkfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_SZONE,0,nil)*200
end

function s.deffilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
function s.defval(e,c)
	return Duel.GetMatchingGroupCount(s.deffilter,c:GetControler(),LOCATION_SZONE,0,nil)*200
end

function s.thfilter(c,e,tp,field_chk)
    return (c:IsAbleToHand() or (field_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) ) and (c:IsRace(RACE_ROCK) or c:IsCode(76232340, 47986555, 32012841))
end

function s.FieldSpell(c)
	return c:IsFaceup() and c:IsCode(511000122)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local fossil_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.FieldSpell,tp,LOCATION_FZONE,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,fossil_chk) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local fossil_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.FieldSpell,tp,LOCATION_FZONE,0,1,nil)
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
