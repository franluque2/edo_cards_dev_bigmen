--Motor Kaiser (CT)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(s.thtg)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	--Once per turn, you can target 1 "Motor" Monster you control or in your GY;
	--equip that target to this card as an Equip Spell that makes this card gain its original attack

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c,s.eqcon,aux.TRUE,s.equipop,e3)


	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(id)
	e0:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e0)

	-- Normal Summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.nscon)
	e4:SetCost(s.nscost)
	e4:SetTarget(s.nstg)
	e4:SetLabelObject(e0)
	e4:SetOperation(s.nsop)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.tkcon)
	e5:SetTarget(s.tktg)
	e5:SetOperation(s.tkop)
	c:RegisterEffect(e5)

end

function s.eqfilter(c)
	return c:GetFlagEffect(id)~=0
end

function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() or (Duel.IsBattlePhase() and Duel.GetTurnPlayer()~=tp)
end

function s.enginetokenfilter(c)
	return c:IsCode(TOKEN_ENGINE) and c:IsReleasable()
end

function s.motorsummonfilter(c,tp)
	return (c:IsMotor() or c:IsCode(57793869)) and (not c:IsPublic()) and c:IsSummonable(true,nil) and c:IsLevelAbove(5)
	 	and ((c:IsCode(57793869) and Duel.IsExistingMatchingCard(s.enginetokenfilter, tp, LOCATION_MZONE, 0, 3 , nil))
		 or (not c:IsCode(57793869) and Duel.IsExistingMatchingCard(s.enginetokenfilter, tp, LOCATION_MZONE, 0, c:GetTributeRequirement(), nil)))
end

function s.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.motorsummonfilter, tp, LOCATION_HAND, 0, 1, nil,tp) end
end
function s.nsfilter(c)
	return (c:IsMotor() or c:IsCode(57793869)) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.motorsummonfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	local tc=Duel.SelectMatchingCard(tp,s.motorsummonfilter, tp, LOCATION_HAND, 0, 1, 1,false,nil,tp):GetFirst()
	local g=Duel.GetMatchingGroup(s.enginetokenfilter, tp, LOCATION_MZONE, 0, nil)
	local tg=nil
	if tc then
		if tc:IsCode(57793869) then
			tg=g:Select(tp, 3, 3, false)
			Duel.Release(tg, REASON_COST)
		else
			tg=g:Select(tp, tc:GetTributeRequirement(), tc:GetTributeRequirement())
			Duel.Release(tg, REASON_COST)
		end
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,tc,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.GetFirstTarget()
	local se=e:GetLabelObject()

	if g then
		if g:IsCode(57793869) then
			Duel.SpecialSummon(g, SUMMON_TYPE_NORMAL, tp, tp, true, true, POS_FACEUP_ATTACK)
		else
			Duel.Summon(tp,g,true,se)
		end
	end
end


function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsMotor,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsMotor,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	if not Card.EquipByEffectAndLimitRegister(c,e,tp,tc,id) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(tc:GetBaseAttack())
	tc:RegisterEffect(e2)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
end


--(Quick Effect): You can reveal this card in your Hand and Destroy 1 monster you control; Normal Summon this card without tributing.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and c:GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(Card.IsDestructable, tp, LOCATION_MZONE, 0, 1, nil) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	local tg=Duel.SelectMatchingCard(tp, Card.IsDestructable, tp, LOCATION_MZONE, 0, 1,1,false,nil)
	Duel.Destroy(tg, REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true, e)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	Duel.Summon(tp,c,true,e:GetLabelObject())
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.thfilter(c)
	return ((c:IsMotor() and c:IsType(TYPE_MONSTER) or (Card.ListsCodeWithArchetype(c, 0x537)) and
	(c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))) or
 c:IsCode(511002409) or c:IsCode(511002411)) and c:IsAbleToHand() and not c:IsCode(511002408)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp, s.thfilter, tp,LOCATION_DECK,0,1,1,false,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return --not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		 Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ENGINE,0,TYPES_TOKEN,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if not s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then return end
	for i=1,1 do
		local token=Duel.CreateToken(tp,TOKEN_ENGINE)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
	Duel.SpecialSummonComplete()
end
