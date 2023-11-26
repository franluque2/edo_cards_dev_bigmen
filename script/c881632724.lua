--Legendary Questionnaire
Duel.LoadScript ("big_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
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
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CUSTOM+81632500)
		e2:SetCondition(s.sscon)
		e2:SetOperation(s.ssef)
		Duel.RegisterEffect(e2, tp)





	end
	e:SetLabel(1)
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp, LOCATION_DECK,0)>0 and Duel.GetFieldGroupCount(1-tp, LOCATION_DECK,0)>0
end
function s.ssef(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)


	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local opt=(Duel.SelectOption(1-tp,70,71,72))
	local tc=Duel.GetDecktopGroup(tp, 1):GetFirst()

	Duel.ConfirmDecktop(tp, 1)



	if (opt==0 and tc:IsMonster()) or (opt==1 and tc:IsSpell()) or (opt==2 and tc:IsTrap()) then
		if tc:IsType(TYPE_MONSTER) then
			Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, 1-tp, 1-tp, true, true, POS_FACEUP)
		else
			Duel.SSet(1-tp, tc)
		end
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	opt=(Duel.SelectOption(tp,70,71,72))
	tc=Duel.GetDecktopGroup(1-tp, 1):GetFirst()

	Duel.ConfirmDecktop(1-tp, 1)



	if (opt==0 and tc:IsMonster()) or (opt==1 and tc:IsSpell()) or (opt==2 and tc:IsTrap()) then
		if tc:IsType(TYPE_MONSTER) then
			Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
		else
			Duel.SSet(tp, tc)
		end
	end
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end
