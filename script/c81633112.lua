--Shaman Bandit's Space Poem
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


		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e2:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
        e2:SetTargetRange(LOCATION_SZONE,0)
        e2:SetTarget(aux.TargetBoolFunction(Card.IsEquipSpell))
        e2:SetValue(POS_FACEUP)

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e5:SetTargetRange(LOCATION_HAND,0)
        e5:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
        e5:SetLabelObject(e2)
		Duel.RegisterEffect(e5,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e3:SetCode(EFFECT_FUSION_SUBSTITUTE)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e6:SetTargetRange(LOCATION_MZONE,0)
        e6:SetTarget(function(_,c) return c:GetEquipCount()>0 end)
        e6:SetLabelObject(e3)
		Duel.RegisterEffect(e6,tp)


        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e7:SetCode(EVENT_TO_HAND)
        e7:SetProperty(EFFECT_FLAG_DELAY)
        e7:SetCondition(s.damcon)
        e7:SetOperation(s.damop)
		Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e8:SetCode(EFFECT_DESTROY_REPLACE)
		e8:SetTarget(s.desreptg)
		e8:SetValue(s.desrepval)
		e8:SetOperation(s.desrepop)
		Duel.RegisterEffect(e8,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_CHAINING)
		e9:SetCondition(s.drawflagcon)
		e9:SetOperation(s.drawflagop)
		Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e10:SetCode(EVENT_PHASE+PHASE_DRAW)
		e10:SetCondition(s.drawcon)
		e10:SetOperation(s.drawop)
        e10:SetCountLimit(1)
		Duel.RegisterEffect(e10,tp)


	end
	e:SetLabel(1)
end

function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp, id+1)>0 and Duel.GetTurnPlayer()~=tp
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    local pl=Duel.GetTurnPlayer()
    local num=0
    if Duel.GetFieldGroupCount(pl,LOCATION_HAND,0) < 5 then
		num=3-Duel.GetFieldGroupCount(pl,LOCATION_HAND,0)
	end
    if not (num>0) then return end
    Duel.Hint(HINT_CARD,tp,id)
    Duel.Draw(pl, num, REASON_RULE)

end


function s.drawflagcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()

	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(160011024) and (Duel.GetFlagEffect(tp,id+1)==0)
end

function s.drawflagop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,0)
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsMonster() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_PSYCHIC) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
	return c:IsEquipSpell() and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.repdesfilter(c)
	return c:IsEquipSpell() and c:IsDestructable()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.repdesfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 0)) then
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
    Duel.Hint(HINT_CARD,tp,id)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc, REASON_REPLACE)
end



function s.cfilter(c,tp)
    if (c:GetReasonEffect()==nil or c:GetReasonEffect():GetHandler()==nil) then return false end
    local rc=c:GetReasonEffect():GetHandler()
	return c:IsControler(1-tp) and rc and rc:GetOwner()==tp
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)
	local g=eg:Filter(s.cfilter, nil, tp)

    for tc in g:Iter() do
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetValue(function(e,re,tp) return re:GetHandler():IsCode(tc:GetCode()) end)
		e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
		Duel.RegisterEffect(e2,tp)
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

function s.discardequipfilter(c)
    return c:IsEquipSpell() and c:IsDiscardable(REASON_RULE)
end

function s.addfilter(c)
    return c:IsCode(160015014,160015012,160015051) and c:IsAbleToHand()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0  then return end
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.discardequipfilter,tp,LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)

	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)


	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.discardequipfilter,tp,LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)})

	if op==1 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    if Duel.DiscardHand(tp, s.discardequipfilter, 1,1, REASON_RULE, nil) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tc=Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
        if tc then
            Duel.SendtoHand(tc, tp, REASON_RULE)
            Duel.ConfirmCards(1-tp, tc)
        end
    end

	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end