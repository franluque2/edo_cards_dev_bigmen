--Corrupted Chaos Incarnate
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



--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=0x8b

function s.archetypefilter(c)
  return (c:IsLevel(2) or c:IsRank(2)) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.backrowfilter(c)
	return c:IsCode(111011002,511000986,511001660,511001793,511001792,511001662,511000996,47660516)
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


    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_ADD_SETCODE)
    e3:SetTargetRange(LOCATIONS,0)
    e3:SetTarget(aux.TargetBoolFunction(s.archetypefilter))
    e3:SetValue(ARCHETYPE)
    Duel.RegisterEffect(e3,tp)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetTarget(aux.TargetBoolFunction(Card.IsOriginalSetCard,0x8b))
	Duel.RegisterEffect(e2,tp)


	local e9=Effect.CreateEffect(e:GetHandler())
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_ADJUST)
	e9:SetCondition(s.removeloccon)
	e9:SetOperation(s.removelocop)
	Duel.RegisterEffect(e9,tp)

	local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_ADD_SETCODE)
    e4:SetTargetRange(LOCATION_ALL,0)
    e4:SetTarget(aux.TargetBoolFunction(s.backrowfilter))
    e4:SetValue(0x181)
    Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_DESTROY_REPLACE)
		e5:SetTarget(s.desreptg)
		e5:SetValue(s.desrepval)
		e5:SetOperation(s.desrepop)
		Duel.RegisterEffect(e5,tp)


		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_CHAINING)
		e6:SetCondition(s.actcon)
		e6:SetOperation(s.actop)
		Duel.RegisterEffect(e6,tp)


	end
	e:SetLabel(1)
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.darkstormfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsCode(111011002) and ep==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end

function s.chainlm(e,rp,tp)
	return tp==rp
end


function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x1048) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:GetReasonPlayer()~=tp
end
function s.desfilter(c,e,tp)
	return c:IsCode(47660516) and c:IsAbleToRemove()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.cfilter(c)
	return c:IsCode(47660516) and c:IsAbleToRemove()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		Duel.HintSelection(sg)
		return true
	else return false end
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc, POS_FACEUP, REASON_EFFECT+REASON_REPLACE)
end



function s.removeloccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON)
end
function s.removelocop(e,tp,eg,ep,ev,re,r,rp)
	while Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON) and Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON):GetHandler():IsCode(54498517) do
        local ef=Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON)
        if ef:GetHandler():IsCode(54498517) then
            ef:Reset()
        end
	end
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)



	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.validdarkmistfilter(c)
	return c:IsCode(55727845) and c:IsFaceup() and c:GetOverlayCount()>0
end

function s.darkstormfilter(c)
	return c:IsCode(77205367) and c:IsFaceup()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.validdarkmistfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.darkstormfilter,tp,LOCATION_ONFIELD,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.validdarkmistfilter,tp,LOCATION_ONFIELD,0,1,nil)
				and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.darkstormfilter,tp,LOCATION_ONFIELD,0,1,nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,2)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    local dmist=Duel.GetMatchingGroup(s.validdarkmistfilter, tp, LOCATION_MZONE, 0, nil)
	if dmist then
		if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_RULE,dmist) then
			local bforce=Duel.CreateToken(tp, 47660516)
			Duel.SSet(tp, bforce)
		end

	end


	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

local normalnumbers={84013238,56051086,93568288,90126061,97403510,2407234} -- Disabled 3790062 Djinn Buster
local numbercs={69757518,20563387,32446630,66970002,47017574,511002866} --Disabled 49195710 King Overfiend
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local cfield=Duel.CreateToken(tp, 111011002)
	Duel.ActivateFieldSpell(cfield,e,tp,eg,ep,ev,re,r,rp)

	for i,card in ipairs(normalnumbers) do
		local mon=Duel.CreateToken(1-tp, card)
		Duel.SendtoDeck(mon, 1-tp, SEQ_DECKTOP, REASON_RULE)
	end

	for i,card in ipairs(numbercs) do
		local mon=Duel.CreateToken(tp, card)
		Duel.SendtoDeck(mon, tp, SEQ_DECKTOP, REASON_RULE)
		if card==511002866 then
			--disable number's rule
			local eff={mon:GetCardEffect()}
        	for _,effect in ipairs(eff) do
				if Effect.GetCode(effect)|EFFECT_INDESTRUCTABLE_BATTLE==EFFECT_INDESTRUCTABLE_BATTLE then
					effect:Reset()
				end
			end
			mon:RegisterFlagEffect(0,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))

		end
	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
