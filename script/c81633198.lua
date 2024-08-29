--Shackles of the Tainted Clear World
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
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_DISABLE)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetCondition(s.discon)
        e7:SetTarget(aux.TargetBoolFunction(Card.ListsCode,CARD_CLEAR_WORLD))
        Duel.RegisterEffect(e7, tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e8:SetCode(EVENT_LEAVE_FIELD)
        e8:SetCondition(s.descon)
        e8:SetOperation(s.desop)
        Duel.RegisterEffect(e8, tp)

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAINING)
		e5:SetCondition(s.discon2)
		e5:SetOperation(s.disop2)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)


	end
	e:SetLabel(1)
end

local CARD_CLEAR_WALL=06089145
local CARD_CLEAR_GOLEM=07102732
local CARD_CLEAR_VKNIGHT=70095046

function s.discon2(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()

	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(CARD_CLEAR_GOLEM)
end

function s.disop2(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	
end

function s.damval(e,rc)
	return HALF_DAMAGE
end


function s.clearworldfilter(c,tp)
	return c:IsCode(CARD_CLEAR_WORLD) and c:IsPreviousControler(tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.clearworldfilter,1,nil,tp)
end
function s.desclearwallfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_CLEAR_WALL) and c:IsDestructable()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD, tp, id)
    local g=Duel.GetMatchingGroup(s.desclearwallfilter, tp, LOCATION_ONFIELD, 0, nil)
	Duel.Destroy(g,REASON_RULE)
end


function s.cworldfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_CLEAR_WORLD)
end

function s.discon(e)
	return not Duel.IsExistingMatchingCard(s.cworldfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, CARD_CLEAR_VKNIGHT)
	if g and #g>0 then
		for tc in g:Iter() do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				local eff={tc:GetCardEffect()}
				for _,teh in ipairs(eff) do
					if teh:GetCode()&EFFECT_CANNOT_ACTIVATE==EFFECT_CANNOT_ACTIVATE then
						teh:Reset()
					end
				end
				local e3=Effect.CreateEffect(tc)
                e3:SetType(EFFECT_TYPE_FIELD)
                e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
                e3:SetCode(EFFECT_CANNOT_ACTIVATE)
                e3:SetRange(LOCATION_MZONE)
                e3:SetTargetRange(0,1)
                e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE) end)
                e3:SetValue(s.actlimval)
                tc:RegisterEffect(e3)
		end
	end
	end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.higheratkfilter(c, atk)
    return c:IsFaceup() and c:IsAttackAbove(atk) and not c:IsAttack(atk)
end

function s.actlimval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:GetAttack()<e:GetHandler():GetAttack() and rc:IsFaceup()
		and rc:IsLocation(LOCATION_MZONE) and not Duel.IsExistingMatchingCard(s.higheratkfilter, rc:GetControler(), LOCATION_MZONE, 0, 1, rc, rc:GetAttack())
end