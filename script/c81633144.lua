--Mark of the Lizard
Duel.LoadScript ("big_aux.lua")

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

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetTargetRange(LOCATION_ONFIELD,0)
        e2:SetTarget(function (_,c) return not (c:IsSetCard(SET_EARTHBOUND_IMMORTAL) and c:IsMonster() and c:IsFaceup()) end)
		e2:SetValue(s.efilter)
		Duel.RegisterEffect(e2,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_CANNOT_TRIGGER)
        e8:SetTargetRange(LOCATION_HAND,0)
        e8:SetCondition(s.discon)
        e8:SetTarget(s.actfilter)
        Duel.RegisterEffect(e8, tp)

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_DRAW)
        e4:SetCondition(s.placecon)
        e4:SetCountLimit(1)
        e4:SetOperation(s.placeop)
        Duel.RegisterEffect(e4, tp)

	end
	e:SetLabel(1)
end

function s.placecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_DRAW and r==REASON_RULE
end
function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0 and c:CheckUniqueOnField(p)
		and not c:IsForbidden()
end

function s.pl2filter(c)
	local p=c:GetOwner()
	return c:IsSpellTrap() and Duel.GetLocationCount(p,LOCATION_SZONE)>0 and c:CheckUniqueOnField(p)
		and not c:IsForbidden()
end

function s.placeop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.ConfirmCards(tp, eg)
        Duel.ConfirmCards(1-tp, eg)

        if eg:IsExists(Card.IsMonster, 1, nil) and Duel.IsExistingMatchingCard(s.plfilter, tp, LOCATION_GRAVE, 0,1,nil) then

            local g=Duel.SelectMatchingCard(tp, s.plfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
            if g then
                local tc=g:GetFirst()
                if Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
                    --Treated as a Continuous Spell
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e1:SetCode(EFFECT_CHANGE_TYPE)
                    e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
                    e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
                    tc:RegisterEffect(e1)
	            end
            end

        end

        if eg:IsExists(Card.IsSpellTrap, 1, nil) and Duel.IsExistingMatchingCard(s.pl2filter, tp, LOCATION_GRAVE, 0,1,nil) then
            local g=Duel.SelectMatchingCard(tp, s.pl2filter, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
            if g then
                local tc=g:GetFirst()
                if Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
                    --Treated as a Continuous Spell
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e1:SetCode(EFFECT_CHANGE_TYPE)
                    e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
                    e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
                    tc:RegisterEffect(e1)
	            end
            end
        end
end
end

function s.fuimmortalfilter(c)
    return c:IsFaceup() and c:IsCode(79798060)
end

function s.discon(e)
	return not Duel.IsExistingMatchingCard(s.fuimmortalfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.actfilter(e,c)
	return c:IsCode(42090294)
end


function s.efilter(e,re,rp)
	return (e:GetHandlerPlayer()==rp) and (re:GetHandler() and not re:GetHandler():IsCode(17000165))
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.activate_field(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 79798060)
	if g and #g>0 then
		for tc in g:Iter() do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				local eff={tc:GetCardEffect()}
				for _,teh in ipairs(eff) do
					if teh:GetCode()&EFFECT_CANNOT_BE_BATTLE_TARGET==EFFECT_CANNOT_BE_BATTLE_TARGET then
						teh:Reset()
					end
				end
				local e3=Effect.CreateEffect(tc)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
				e3:SetRange(LOCATION_MZONE)
				e3:SetValue(1)
				tc:RegisterEffect(e3)
		end
	end
	end

    local queens=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 80513550)
    if queens and #queens>0 then
        for tc in queens:Iter() do
			local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
            e1:SetValue(s.effcon)
            tc:RegisterEffect(e1)
		end

        
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.field_filter(c)
	return c:IsType(TYPE_FIELD)
end
function s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	local field=Duel.SelectMatchingCard(tp,s.field_filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if #field>0 then
		Duel.ActivateFieldSpell(field:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.high_level_filter(c)
	return c:HasLevel() and c:IsLevelAbove(5) and c:IsFaceup()
end

function s.fucontspellfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SPELL) and not c:IsType(TYPE_FIELD)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp, id+2) then return end
	--Boolean checks for the activation condition: b1, b2, b3
	local b1=Duel.GetFlagEffect(tp, id+1)==0
    and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
    and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

    local b2=Duel.GetFlagEffect(tp, id+2)==0
    and Duel.GetMatchingGroupCount(s.fucontspellfilter, tp, LOCATION_SZONE, 0, nil)>2

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp, id+1)==0
    and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
    and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

    local b2=Duel.GetFlagEffect(tp, id+2)==0
    and Duel.GetMatchingGroupCount(s.fucontspellfilter, tp, LOCATION_SZONE, 0, nil)>2



	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
                                     {b2,aux.Stringid(id,1)})
	op=op-1 

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    elseif op==1 then
        s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local cearth=Duel.CreateToken(tp, 100000307)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local dqueen=Duel.CreateToken(tp, 80513550)
	Duel.SendtoHand(dqueen, tp, REASON_RULE)

    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
    e1:SetValue(s.effcon)
    dqueen:RegisterEffect(e1)

    Duel.ConfirmCards(1-tp, dqueen)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.effcon(e, c)
	return c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
end
