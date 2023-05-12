--Conscription of D-Boyz
--add archetype Template
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



--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--FIRE Fiends
function s.archetypefilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_FIRE)
end

--D-Boyz
function s.archetypefilter2(c)
    return c:IsOriginalCode(79279397)
  end



function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_CODE)
        e5:SetTargetRange(LOCATION_DECK,0)
        e5:SetTarget(aux.TargetBoolFunction(s.archetypefilter))
        e5:SetValue(79279397)
        Duel.RegisterEffect(e5,tp)
    
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(aux.TargetBoolFunction(s.archetypefilter2))
        e6:SetValue(ATTRIBUTE_FIRE)
        Duel.RegisterEffect(e6,tp)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(s.damval)
        Duel.RegisterEffect(e2,tp)


		local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.sumlimit)
	e3:SetValue(POS_FACEDOWN)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e4,tp)
	local e7=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e5,tp)

	
	local e9=Effect.CreateEffect(e:GetHandler())
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e9:SetTargetRange(LOCATION_HAND,0)
	e9:SetValue(0x1)
	Duel.RegisterEffect(e9, tp)

	local e8=Effect.CreateEffect(e:GetHandler())
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_DISABLE)
	e8:SetTargetRange(LOCATION_ONFIELD,0)
	e8:SetCondition(s.discon)
	e8:SetTarget(aux.TargetBoolFunction(Card.IsCode,32240937))
	Duel.RegisterEffect(e8, tp)


	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge:SetCode(EVENT_ADJUST)
		ge:SetOperation(s.adjustop)
		Duel.RegisterEffect(ge,0)
	end)


	end
	e:SetLabel(1)
end

function s.discon(e)
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end


function s.fufiendfilter(c)
	return c:IsFaceup() and c:IsCode(32240937)
end

function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local sg=Duel.GetMatchingGroup(s.fufiendfilter, tp, LOCATION_ONFIELD, 0, nil)
	local g1=Group.CreateGroup()
	local readjust=false
	if #sg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		g1:Merge(sg:Select(tp,#sg-1,#sg-1,nil))
	end
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE)
		readjust=true
	end
	if readjust then Duel.Readjust() end
end

function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local tp=sump
	if targetp then tp=targetp end
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,32240937),tp,LOCATION_MZONE,0,1,c) and c:IsCode(32240937)
end

function s.damval(e,re,val,r,rp,rc)
	if re:GetHandler():IsCode(79279397) then
		return 0
	end
	return val
end

function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.archetypefilter, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

