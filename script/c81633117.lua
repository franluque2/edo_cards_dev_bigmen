--Conscription of a Harmonious Bracelet Girl
--add archetype Template
Duel.LoadScript("big_aux.lua")
Duel.LoadScript("c420.lua")

Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)


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
end




function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_CANNOT_TRIGGER)
        e8:SetTargetRange(LOCATION_MZONE,0)
        e8:SetCondition(s.discon)
        e8:SetTarget(s.actfilter)
        Duel.RegisterEffect(e8, tp)

	end
	e:SetLabel(1)
end


function s.discon(e)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.actfilter(e,c)
	return c:IsCode(57594700)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ALL, 0, nil)

	if #g>0 then
		local tc=g:GetFirst()
		while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BATTLE_INDES)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(s.batval)
		tc:RegisterEffect(e1)


			tc=g:GetNext()
		end
	end

	local etoiles=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL,0, nil, 83793721)
	for tc in etoiles:Iter() do
		if tc:GetFlagEffect(id)==0 then
			tc:RegisterFlagEffect(id,0,0,0)
			local eff={tc:GetCardEffect()}
			for _,teh in ipairs(eff) do
				if (Effect.GetType(teh)&EFFECT_TYPE_QUICK_O)==EFFECT_TYPE_QUICK_O then
					teh:Reset()
				end
			end
			
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
			e1:SetType(EFFECT_TYPE_IGNITION)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1)
			e1:SetTarget(s.rmtg)
			e1:SetOperation(s.rmop)
			tc:RegisterEffect(e1)

			tc:RegisterFlagEffect(id,0,0,0)
	end
end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.rmfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MELODIOUS) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.IsExistingMatchingCard(Card.IsAbleToHand, tp, 0, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.HintSelection(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_MZONE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
		and tc:IsLocation(LOCATION_REMOVED) then
		local thg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg=thg:Select(tp,1,#Duel.GetOperatedGroup(),nil)
		Duel.HintSelection(sg,true)
		Duel.BreakEffect()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end


function s.batval(e,re,c)
	return Duel.IsExistingMatchingCard(Card.IsCode, re:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil, 40502912) and not re:GetHandler():IsCode(84988419)
end
