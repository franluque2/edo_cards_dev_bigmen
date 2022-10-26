--Schmaden Schmooki
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
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--grant effect
		local e6=Fusion.CreateSummonEff(e:GetHandler(),aux.FilterBoolFunction(Card.IsSetCard,0x3008),nil,s.fextra)
		e6:SetDescription(aux.Stringid(id,0))

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e5:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,0)
		e5:SetTarget(s.eftg)
		e5:SetLabelObject(e6)
		Duel.RegisterEffect(e5,tp)

	end
	e:SetLabel(1)
end

function s.eftg(e,c)
	return c:IsCode(CARD_POLYMERIZATION)
end


function s.chkfilter(c,tp,fc)
	return c:IsSetCard(0x3008,fc,SUMMON_TYPE_FUSION,tp) and c:IsControler(tp)
end
function s.fcheck(tp,sg,fc,mg)
	if sg:IsExists(Card.IsControler,1,nil,1-tp) then
		return sg:IsExists(s.chkfilter,1,nil,tp,fc) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(Card.IsSetCard,1,nil,0x3008,nil,SUMMON_TYPE_FUSION,tp) then
		local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToGrave),tp,0,LOCATION_MZONE,nil)
		if g and #g>0 then
			return g,s.fcheck
		end
	end
	return nil
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1,tp)


	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

function s.atohand(code,tp)
	local token=Duel.CreateToken(tp, code)
	Duel.SendtoHand(token, tp, REASON_RULE)
end

function s.wingedkuribohfilter(c)
	return c:IsCode(57116033)
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp, id+1)==0 and eg:IsExists(s.wingedkuribohfilter,1,nil)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_CARD,tp,id)

	s.atohand(513000057,tp) --Sabatiel

	Duel.RegisterFlagEffect(ep,id+1,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
