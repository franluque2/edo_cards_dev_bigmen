--Subordinates of Zero
local s,id=GetID()
function s.initial_effect(c)

		--Activate
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

function s.value(e)
	return 0x1f<<16*e:GetHandlerPlayer()
end

function s.MainDeckFuckers(c)
    return  c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_FUSION|TYPE_XYZ|TYPE_SYNCHRO|TYPE_LINK)
end

function s.ExtraDeckFuckers(c)
    return c:IsType(TYPE_FUSION|TYPE_XYZ|TYPE_SYNCHRO|TYPE_LINK)
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
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
        e2:SetRange(LOCATION_PZONE)
        e2:SetCode(EFFECT_CHANGE_LSCALE)
        e2:SetValue(0)

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e5:SetTargetRange(LOCATION_SZONE,0)
        e5:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_PENDULUM))
        e5:SetLabelObject(e2)
		Duel.RegisterEffect(e5,tp)

        local e3=e2:Clone()
        e3:SetCode(EFFECT_CHANGE_RSCALE)
        e3:SetValue(13)

        local e6=e5:Clone()
        e6:SetLabelObject(e3)
        Duel.RegisterEffect(e6,tp)

        --add archetype changing shit here PURPLE

        



        -- LOCATION FOR ARCHETYPE CHANGING SHIT
        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_XYZ_LEVEL)
        e10:SetTargetRange(LOCATION_MZONE, 0)
        e10:SetTarget(function(_,c)  return c:IsMonster() and c:IsLevelBelow(4) end)
        e10:SetValue(s.xyzlv)
        Duel.RegisterEffect(e10,tp)

        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_SINGLE)
        e12:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e12:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
        e12:SetTargetRange(LOCATION_SZONE,0)
        e12:SetTarget(aux.TargetBoolFunction(Card.IsSpell))
        e12:SetValue(POS_FACEUP)

        local e15=Effect.CreateEffect(e:GetHandler())
        e15:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e15:SetTargetRange(LOCATION_HAND,0)
        e15:SetTarget(aux.TargetBoolFunction(s.monarchfilter,5))
        e15:SetLabelObject(e12)
		Duel.RegisterEffect(e15,tp)

        local e16=Effect.CreateEffect(e:GetHandler())
        e16:SetType(EFFECT_TYPE_FIELD)
        e16:SetCode(EFFECT_ADD_SETCODE)
        e16:SetTargetRange(LOCATION_ALL,0)
        e16:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e16:SetValue(0x10af)
        Duel.RegisterEffect(e16,tp)

        local e17=Effect.CreateEffect(e:GetHandler())
        e17:SetType(EFFECT_TYPE_FIELD)
        e17:SetCode(EFFECT_ADD_SETCODE)
        e17:SetTargetRange(LOCATION_ALL,0)
        e17:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e17:SetValue(0xa9)
        Duel.RegisterEffect(e17,tp)

        local e18=Effect.CreateEffect(e:GetHandler())
        e18:SetType(EFFECT_TYPE_FIELD)
        e18:SetCode(EFFECT_ADD_SETCODE)
        e18:SetTargetRange(LOCATION_ALL,0)
        e18:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e18:SetValue(0xba)
        Duel.RegisterEffect(e18,tp)

        local e19=Effect.CreateEffect(e:GetHandler())
        e19:SetType(EFFECT_TYPE_FIELD)
        e19:SetCode(EFFECT_ADD_SETCODE)
        e19:SetTargetRange(LOCATION_ALL,0)
        e19:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e19:SetValue(0x10af)
        Duel.RegisterEffect(e19,tp)

        local e20=Effect.CreateEffect(e:GetHandler())
        e20:SetType(EFFECT_TYPE_FIELD)
        e20:SetCode(EFFECT_ADD_SETCODE)
        e20:SetTargetRange(LOCATION_ALL,0)
        e20:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e20:SetValue(0xad)
        Duel.RegisterEffect(e20,tp)

        local e21=Effect.CreateEffect(e:GetHandler())
        e21:SetType(EFFECT_TYPE_FIELD)
        e21:SetCode(EFFECT_ADD_SETCODE)
        e21:SetTargetRange(LOCATION_ALL,0)
        e21:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e21:SetValue(0xba)
        Duel.RegisterEffect(e21,tp)


        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
        e4:SetCode(EVENT_BE_MATERIAL)
        e4:SetCondition(s.pencon)
        e4:SetOperation(s.penop)
		Duel.RegisterEffect(e4,tp)
	end
	e:SetLabel(1)
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
    local g=eg:Filter(s.cfilter, nil, tp)
    if g and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        for c in g:Iter() do
            Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
        Duel.RegisterFlagEffect(tp, id+1, 0,0,0)
    end
end

function s.cfilter(c,tp)
	return c:GetOwner()==tp and c:IsType(TYPE_PENDULUM) and (c:GetReason()&0x40008)==0x40008
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.GetFlagEffect(tp, id+1)==0
end

function s.monarchfilter(c)
    return c:IsLevelAbove(5) and c:IsDefense(1000) and (c:IsAttack(2800) or c:IsAttack(2400))
end

function s.xyzlv(e,c,rc)
    if rc:IsSetCard(0xba) then
        return 4 , c:GetLevel()
    else return c:GetLevel()
    end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end


function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.IsDuelType(0x2000) then
	--link zones
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_BECOME_LINKED_ZONE)
		e6:SetRange(LOCATION_FZONE)
		e6:SetValue(s.value)
		Duel.RegisterEffect(e6,tp)

	end

    local g=Duel.GetMatchingGroup(s.MainDeckFuckers, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    g=Duel.GetMatchingGroup(s.ExtraDeckFuckers, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+1)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end


end

function s.highlevelddd(c)
    return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(10) and c:IsSetCard(0x10af)
end

function s.monarchtributefilter(c)
    return c:IsFaceup() and c:IsDefense(1000) and c:IsAttack(2800)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+2)>0  then return end
	local b1=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.highlevelddd, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_MZONE, 0, 1, nil, TYPE_XYZ)
        and Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_MZONE, 0, 1, nil, TYPE_FUSION)
        and Duel.IsExistingMatchingCard(s.monarchtributefilter, tp, LOCATION_MZONE, 0, 1, nil)



	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local b1=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.highlevelddd, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_MZONE, 0, 1, nil, TYPE_XYZ)
        and Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_MZONE, 0, 1, nil, TYPE_FUSION)
        and Duel.IsExistingMatchingCard(s.monarchtributefilter, tp, LOCATION_MZONE, 0, 1, nil)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})

	if op==1 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.hasoverlay(c)
    return c:GetOverlayCount()>0
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    local to_tribute=Group.CreateGroup()

    local xyz=Duel.SelectMatchingCard(tp, Card.IsType, tp, LOCATION_MZONE, 0, 1, 1, false, nil, TYPE_XYZ)
    to_tribute:AddCard(xyz)

    local fusion=Duel.SelectMatchingCard(tp, Card.IsType, tp, LOCATION_MZONE, 0, 1, 1, false, nil, TYPE_FUSION)
    to_tribute:AddCard(fusion)

    local monarch=Duel.SelectMatchingCard(tp, s.monarchtributefilter, tp, LOCATION_MZONE, 0, 1, 1, false, nil)
    to_tribute:AddCard(monarch)

    Duel.Release(to_tribute, REASON_RULE)

    local highlevelddd=Duel.GetMatchingGroup(s.highlevelddd, tp, LOCATION_MZONE, 0, nil)

    local to_delete=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, highlevelddd)
    local xyztoremovemats=Group.Filter(to_delete, s.hasoverlay, nil)
    for card in xyztoremovemats:Iter() do
        local og1=card:GetOverlayGroup()
        Duel.SendtoGrave(og1, REASON_RULE)
    end
    Duel.RemoveCards(to_delete)


	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end