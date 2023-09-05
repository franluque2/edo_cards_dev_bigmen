--Lets Get Gaukuting! Destinguished Sogetsu Style!
Duel.LoadScript("big_aux.lua")


local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        --set ruler backrow
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCondition(s.setcon)
		e2:SetOperation(s.setop)
		Duel.RegisterEffect(e2,tp)

        --celestial warriors become warriors
        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetTargetRange(LOCATION_ONFIELD,0)
		e3:SetTarget(aux.TargetBoolFunction(s.celestialwarriorfilter))
		e3:SetValue(RACE_WARRIOR)
		Duel.RegisterEffect(e3,tp)

		--name changing time

		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CHANGE_CODE)
		e4:SetTargetRange(LOCATION_GRAVE,0)
		e4:SetTarget(aux.TargetBoolFunction(Card.IsOriginalCode,160007036))
		e4:SetValue(160001029)
		Duel.RegisterEffect(e4,tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_CHANGE_CODE)
		e5:SetTargetRange(LOCATION_GRAVE,0)
		e5:SetTarget(aux.TargetBoolFunction(Card.IsOriginalCode,160008036))
		e5:SetValue(160004020)
		Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_CHANGE_CODE)
		e6:SetTargetRange(LOCATION_GRAVE,0)
		e6:SetTarget(aux.TargetBoolFunction(Card.IsOriginalCode,160421011))
		e6:SetValue(160007017)
		Duel.RegisterEffect(e6,tp)


		--summon with 1 tribute
		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetDescription(aux.Stringid(id, 1))
		e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e8:SetType(EFFECT_TYPE_SINGLE)
		e8:SetCode(EFFECT_SUMMON_PROC)
		e8:SetCondition(s.otcon)
		e8:SetOperation(s.otop)
		e8:SetValue(SUMMON_TYPE_TRIBUTE)

		local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e9:SetTargetRange(LOCATION_HAND,0)
		e9:SetTarget(s.eftg2)
		e9:SetLabelObject(e8)
		Duel.RegisterEffect(e9,tp)

	end
	e:SetLabel(1)
end

function s.otcon(e,c,minc)
	if c==nil then return true end
	return c:GetLevel()>6 and minc<=1 and Duel.CheckTribute(c,1)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end

function s.eftg2(_,c)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(8)
end


function s.celestialwarriorfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CELESTIALWARRIOR)
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local hermit=Duel.CreateToken(tp, 160201006)
	Duel.SendtoGrave(hermit, REASON_RULE)

	local hermit2=Duel.CreateToken(tp, 160201006)
	Duel.SendtoGrave(hermit2, REASON_RULE)

	local hermit3=Duel.CreateToken(tp, 160201006)
	Duel.SendtoGrave(hermit3, REASON_RULE)
    
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.lowlevelfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(6) and c:IsFaceup()
end

function s.addfusionfilter(c)
	return c:IsCode(160204050) and c:IsAbleToHand()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--Once per turn, if you control "Valkyrian Sewkyrie", you can send the top 3 cards of your Deck to your GY, add 1 "Fusion" from your Deck or GY to your Hand.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160007001),tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsPlayerCanDiscardDeckAsCost(tp, 3)
						and Duel.IsExistingMatchingCard(s.addfusionfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160007001),tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsPlayerCanDiscardDeckAsCost(tp, 3)
			and Duel.IsExistingMatchingCard(s.addfusionfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1,nil)


		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    if Duel.DiscardDeck(tp, 3, REASON_EFFECT) then
        local tc=Duel.SelectMatchingCard(tp, s.addfusionfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, false,nil)
        if tc then
            Duel.SendtoHand(tc, tp, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, tc)
        end
    end


	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.eftg(e,c)
	return c:IsLevelAbove(7) and c:IsSummonableCard() and c:IsRace(RACE_WARRIOR)
end


function s.ishighlevelwarrfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(8) and c:IsFaceup()
end

function s.rulerbackrowfilter(c)
    return c:IsRulerBackrow() and c:IsSSetable()
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetFlagEffect(tp,id+2)>0) then return false end
	local g=Duel.IsExistingMatchingCard(s.ishighlevelwarrfilter, tp, LOCATION_ONFIELD, 0, 1,nil)
	return Duel.GetTurnPlayer()==tp and g and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and Duel.IsExistingMatchingCard(s.rulerbackrowfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)

    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.rulerbackrowfilter),tp,LOCATION_GRAVE,0,nil)

		local sg=aux.SelectUnselectGroup(tg,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_TARGET)
		if #sg>0 then
		Duel.Hint(HINT_CARD, tp, id)

			
		local g=sg:GetFirst()

        while g do
			
            Duel.SSet(tp, g)
            --Banish it if it leaves the field
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(3301)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_DECKBOT)
            g:RegisterEffect(e1)
			
			g=sg:GetNext()
        end
		
		end

	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

