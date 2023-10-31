--Seeds of Providence
Duel.LoadScript ("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	--skill
		--Activate
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--enable rush rules
		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)


		--At the start of the Duel, place 1 "Femtron" in your GY.
			local femtron=Duel.CreateToken(tp, 160202014)
			Duel.SendtoGrave(femtron, REASON_EFFECT, tp)


		-- shuffle seeds in ep
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(s.epcon)
		e5:SetOperation(s.epop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)

		--rewrite effs of yggdrago to work with the skill
		local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e0:SetCode(EVENT_ADJUST)
        e0:SetRange(0x5f)
        e0:SetOperation(s.makequickop)
        Duel.RegisterEffect(e0,tp)

		--Add effects to Yggdrago

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetCondition(s.immconmon)
		e2:SetTarget(s.maximumsummonedyggfilterprotec)
		e2:SetValue(s.efiltermon)
		Duel.RegisterEffect(e2,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetCondition(s.immconspel)
		e3:SetTarget(s.maximumsummonedyggfilterprotec)
		e3:SetValue(s.efilterspel)
		Duel.RegisterEffect(e3,tp)

		local e4=e2:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e4:SetCondition(s.notargetcon)
		e4:SetValue(s.efilternotmon)
		Duel.RegisterEffect(e4,tp)

		--no negate

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_CANNOT_INACTIVATE)
		e6:SetCondition(s.immconnonegate)
		e6:SetValue(s.effectfilter)
		Duel.RegisterEffect(e6,tp)
		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_CANNOT_DISEFFECT)
		e7:SetCondition(s.immconnonegate)
		e7:SetValue(s.effectfilter)
		Duel.RegisterEffect(e7,tp)



	end
	e:SetLabel(1)
end

function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsCode(160202011) and te:GetHandler():IsMaximumMode() and loc&LOCATION_ONFIELD~=0
end


function s.immconnonegate(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,160202013)
end

function s.notargetcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,160202015)
end

function s.efilternotmon(e,re,rp)
	local c=re:GetHandler()
	return c and not (c:IsMonster() and c:IsLevelAbove(10))
end


function s.immconspel(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,160203022)
end

function s.efilterspel(e,re,rp)
	local c=re:GetHandler()
	return c and c:IsSpell()
end


function s.immconmon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,160008001)
end

function s.efiltermon(e,re,rp)
	local c=re:GetHandler()
	return c and c:IsMonster() and not c:IsLevelAbove(10)
end

function s.maximumsummonedyggfilterprotec(_,c)
	return c:IsCode(160202011) and c:IsMaximumMode()
end


function s.makequickop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --Yggdrago L
	local g=Duel.GetMatchingGroup(Card.IsOriginalCode,tp,LOCATION_ALL,0,nil,160202010)
	for tc in g:Iter() do
        if tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,0,0,0)
		local eff={tc:GetCardEffect()}
        for _,teh in ipairs(eff) do

            if teh:GetCategory()&CATEGORY_DESTROY~=0 and teh:GetType()&EFFECT_TYPE_IGNITION~=0 then
            	teh:Reset()
			end
        end
		
		

		
    end
	end

    --Yggdrago R
	g=Duel.GetMatchingGroup(Card.IsOriginalCode,tp,LOCATION_ALL,0,nil,160202012)
	for tc in g:Iter() do
        if tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,0,0,0)
		local eff={tc:GetCardEffect()}
        for _,teh in ipairs(eff) do
			if teh:GetCategory()&CATEGORY_POSITION~=0 and teh:GetType()&EFFECT_TYPE_IGNITION~=0  then
            	teh:Reset()
			end
        end
       



    end
	end

	--Yggdrago Center

	g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,0,nil,160202011)
	for tc in g:Iter() do
        if tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,0,0,0)
		
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetCondition(s.maxConNoHicotron)
		e1:SetCost(s.costYggL)
		e1:SetTarget(s.targetYggL)
		e1:SetOperation(s.operationYggL)
		tc:RegisterEffect(e1)

		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_DESTROY)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetCondition(s.maxConNoHicotronHighdron)
		e2:SetCost(s.costYggLFast)
		e2:SetTarget(s.targetYggLFast)
		e2:SetOperation(s.operationYggL)
		tc:RegisterEffect(e2)

		local e5=e2:Clone()
		e5:SetCode(EVENT_SPSUMMON_SUCCESS)
		tc:RegisterEffect(e5)

	

		local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_DESTROY)
		e3:SetDescription(aux.Stringid(id,0))
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetCondition(s.maxConHicotron)
		e3:SetCost(s.costYggL)
		e3:SetTarget(s.targetYggL)
		e3:SetOperation(s.operationYggLAll)
		tc:RegisterEffect(e3)

		local e4=Effect.CreateEffect(c)
		e4:SetCategory(CATEGORY_DESTROY)
		e4:SetDescription(aux.Stringid(id,2))
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e4:SetProperty(EFFECT_FLAG_DELAY)
		e4:SetCode(EVENT_SUMMON_SUCCESS)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCountLimit(1)
		e4:SetCondition(s.maxConHicotronHighdron)
		e4:SetCost(s.costYggLFast)
		e4:SetTarget(s.targetYggLFast)
		e4:SetOperation(s.operationYggLAll)
		tc:RegisterEffect(e4)

		local e6=e4:Clone()
		e6:SetCode(EVENT_SPSUMMON_SUCCESS)
		tc:RegisterEffect(e6)



		--change pos

		local e11=Effect.CreateEffect(c)
		e11:SetCategory(CATEGORY_POSITION)
		e11:SetDescription(aux.Stringid(id,1))
		e11:SetType(EFFECT_TYPE_IGNITION)
		e11:SetRange(LOCATION_MZONE)
		e11:SetCountLimit(1)
		e11:SetCondition(s.maxConNoHicotron)
		e11:SetCost(s.costYggL)
		e11:SetTarget(s.targetYggR)
		e11:SetOperation(s.operationYggR)
		tc:RegisterEffect(e11)

		local e12=Effect.CreateEffect(c)
		e12:SetCategory(CATEGORY_POSITION)
		e12:SetDescription(aux.Stringid(id,1))
		e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e12:SetProperty(EFFECT_FLAG_DELAY)
		e12:SetCode(EVENT_SUMMON_SUCCESS)
		e12:SetRange(LOCATION_MZONE)
		e12:SetCountLimit(1)
		e12:SetCondition(s.maxConNoHicotronHighdron)
		e12:SetCost(s.costYggLFast)
		e12:SetTarget(s.targetYggRFast)
		e12:SetOperation(s.operationYggR)
		tc:RegisterEffect(e12)

		local e15=e12:Clone()
		e15:SetCode(EVENT_SPSUMMON_SUCCESS)
		tc:RegisterEffect(e15)

	

		local e13=Effect.CreateEffect(c)
		e13:SetCategory(CATEGORY_POSITION)
		e13:SetDescription(aux.Stringid(id,1))
		e13:SetType(EFFECT_TYPE_IGNITION)
		e13:SetRange(LOCATION_MZONE)
		e13:SetCountLimit(1)
		e13:SetCondition(s.maxConHicotron)
		e13:SetCost(s.costYggL)
		e13:SetTarget(s.targetYggR)
		e13:SetOperation(s.operationYggRAll)
		tc:RegisterEffect(e13)

		local e14=Effect.CreateEffect(c)
		e14:SetCategory(CATEGORY_POSITION)
		e14:SetDescription(aux.Stringid(id,3))
		e14:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e14:SetProperty(EFFECT_FLAG_DELAY)
		e14:SetCode(EVENT_SUMMON_SUCCESS)
		e14:SetRange(LOCATION_MZONE)
		e14:SetCountLimit(1)
		e14:SetCondition(s.maxConHicotronHighdron)
		e14:SetCost(s.costYggLFast)
		e14:SetTarget(s.targetYggRFast)
		e14:SetOperation(s.operationYggRAll)
		tc:RegisterEffect(e14)

		local e16=e14:Clone()
		e16:SetCode(EVENT_SPSUMMON_SUCCESS)
		tc:RegisterEffect(e16)

		local e23=Effect.CreateEffect(c)
		e23:SetType(EFFECT_TYPE_SINGLE)
		e23:SetCode(EFFECT_ATTACK_ALL)
		e23:SetValue(s.atkfilter)
		tc:RegisterEffect(e23)

		local e24=Effect.CreateEffect(c)
		e24:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
		e24:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e24:SetCode(EVENT_BATTLE_START)
		e24:SetTarget(s.tgtg)
		e24:SetOperation(s.tgop)
		tc:RegisterEffect(e24)

		local e25=Effect.CreateEffect(c)
	e25:SetType(EFFECT_TYPE_SINGLE)
	e25:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e25:SetCondition(s.indcon)
	e25:SetValue(1)
	tc:RegisterEffect(e25)

	local e26=Effect.CreateEffect(c)
	e26:SetCategory(CATEGORY_TODECK)
	e26:SetProperty(EFFECT_FLAG_DELAY)
	e26:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e26:SetCode(EVENT_DAMAGE_STEP_END)
	e26:SetRange(LOCATION_MZONE)
	e26:SetCondition(s.atkcon)
	e26:SetOperation(s.atkop)
	tc:RegisterEffect(e26)
	
		end
	end
end

function s.atkfilter(e,c)
	return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160202016) and e:GetHandler():IsMaximumModeCenter()
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c==Duel.GetAttacker() and c:IsRelateToBattle()
		and (bc:IsAbleToDeck()) and Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160007019) and e:GetHandler():IsMaximumModeCenter()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsControler(1-tp) then
		Duel.SendtoDeck(bc, 1-tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
	end
end


function s.indcon(e)
	return e:GetHandler()==Duel.GetAttacker() and Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160007019)
end


function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk ==0 then return Duel.GetAttacker()==e:GetHandler() and d and d:IsDefensePos() and Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160203021) and e:GetHandler():IsMaximumModeCenter() end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,d,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(1-tp,1000,REASON_EFFECT)~=0 then
		local d=Duel.GetAttackTarget()
		if d:IsRelateToBattle() and d:IsDefensePos() then
			Duel.SendtoGrave(d,REASON_EFFECT)
		end
	end
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.maximumsummonedyggfilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local seeds=Duel.GetMatchingGroup(s.shuffleseedfilter, tp, LOCATION_GRAVE, 0, nil)
	if #seeds>0 then
		local cardnumber=Duel.GetRandomNumber(1, #seeds )
		local tc=seeds:GetFirst()
		while tc do
			if cardnumber==1 then
				Duel.Hint(HINT_CARD, tp, tc:GetCode())
				local g2=Group.Filter(seeds, Card.IsCode, nil, tc:GetCode())
				Duel.SendtoDeck(g2, tp, SEQ_DECKSHUFFLE, REASON_RULE)
			end
			cardnumber=cardnumber-1
			tc=seeds:GetNext()
		end
		
	end
end


function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.maximumsummonedyggfilter(c)
	return c:IsCode(160202011) and c:IsMaximumMode()
end

function s.shuffleseedfilter(c)
	return c:IsCode(160008001,160203022,160421013,160203021,160007019,160202013,160202015,160202016,160204035) and c:IsAbleToDeckOrExtraAsCost()
end



function s.tronfilter(c)
	return c:IsCode(160202014) or c:IsCode(160202015) or c:IsCode(160202016) or c:IsCode(160202017)
end

function s.addfilter(c,e,tp,fc)
	return c:IsAbleToHand() and c:IsType(TYPE_MAXIMUM) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id+2)>0 then return end
	--
-- Once per duel, you can add any number of LIGHT Maximum Monster's from your GY
--to your hand up to the number of "Femtron", "Attron", "Zeptron", and "Yoctron" with different names in your GY.
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.tronfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_GRAVE,0,1,nil)


	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Once per duel, you can add any number of LIGHT Maximum Monster's from your GY
	--to your hand up to the number of "Femtron", "Attron", "Zeptron", and "Yoctron" with different names in your GY.

	local trons=Duel.GetMatchingGroup(s.tronfilter, tp, LOCATION_GRAVE, 0, nil)
	local tronscount= trons:GetClassCount(Card.GetCode)
	Duel.Hint(HINT_MESSAGE, tp, HINTMSG_ATOHAND)
	local yggpieces=Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_GRAVE, 0, 1, tronscount, false, nil)
	Duel.SendtoHand(yggpieces, tp, REASON_EFFECT)
	Duel.ConfirmCards(1-tp, yggpieces)
	Duel.RegisterFlagEffect(tp, id+2, 0, 0, 0)
end




----



function s.maxConNoHicotron(e)
	return e:GetHandler():IsMaximumModeCenter() and not Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160204035)
end
function s.maxConNoHicotronHighdron(e)
	return e:GetHandler():IsMaximumModeCenter() and Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160421013)
			 and not Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160204035)
end
function s.maxConHicotron(e)
	return e:GetHandler():IsMaximumModeCenter() and Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160204035)
end
function s.maxConHicotronHighdron(e)
	return e:GetHandler():IsMaximumModeCenter() and Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160204035)
	and Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 1, nil, 160421013)
end

function s.costYggL(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
end

function s.costYggLFast(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,5,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,5,5,REASON_COST+REASON_DISCARD)
end

function s.desfilter(c)
	return c:IsFaceup() and (c:IsLevelBelow(8) or not c:HasLevel())
end
function s.targetYggL(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return e:GetHandler():IsMaximumMode() and #dg>0 end
end

function s.fastfilter(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and (not c:IsControler(tp))
		and (not c:IsSummonPlayer(tp))
end

function s.fastfilterR(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and (not c:IsControler(tp))
		and (not c:IsSummonPlayer(tp)) and c:IsDefensePos()
end

function s.targetYggLFast(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		 return eg:IsExists(s.fastfilter,1,nil,e,tp) and e:GetHandler():IsMaximumMode() and #eg>0 end
end

function s.operationYggL(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)>0 then
		--Effect

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,e:GetHandler())

		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end

function s.operationYggLAll(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)>0 then
		--Effect
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,e:GetHandler())
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

-- ygg R

function s.targetYggR(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end

function s.targetYggRFast(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.fastfilterR,1,nil,e,tp) and e:GetHandler():IsMaximumMode() and #eg>0 end
end

function s.operationYggR(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)>0 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
			Duel.HintSelection(g)
			if #g>0 then
				Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end


function s.operationYggRAll(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)>0 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local g=Duel.GetMatchingGroup(Card.IsDefensePos, tp, 0, LOCATION_MZONE, nil)
			if #g>0 then
				Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end