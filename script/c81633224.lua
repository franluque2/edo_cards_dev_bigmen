--Mirages of the Sun God
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

local MYSTICAL_BEAST_SERKET=89194033

-- fill in once the cards come out in edo
local MAN_WITH_THE_MARK=100410001
local DIVINE_SERPENT_APOPHIS=100410004
local MERCILESS_SCORPION_OF_SERKET=100410002

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
        local c=e:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e2:SetDescription(aux.Stringid(id,0))
        e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,MYSTICAL_BEAST_SERKET))
        Duel.RegisterEffect(e2,tp)

        local e6=Effect.CreateEffect(c)
        e6:SetDescription(aux.Stringid(id,1))
        e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e6:SetType(EFFECT_TYPE_IGNITION)
        e6:SetRange(LOCATION_SZONE)
        e6:SetCountLimit(1,{id,1})
        e6:SetCost(s.cost)
        e6:SetTarget(s.target)
        e6:SetOperation(s.operation)
        local e7=Effect.CreateEffect(c)
        e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e7:SetTargetRange(LOCATION_SZONE,0)
        e7:SetTarget(s.eftg2)
        e7:SetLabelObject(e6)
        Duel.RegisterEffect(e7,tp)

        --local e3=Effect.CreateEffect(e:GetHandler())
        --e3:SetType(EFFECT_TYPE_FIELD)
        --e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        --e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
        --e3:SetTargetRange(0,LOCATION_MZONE)
        --e3:SetValue(s.sumlimit)
        --Duel.RegisterEffect(e3,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_DISABLE)
        e8:SetTargetRange(LOCATION_MZONE,0)
        e8:SetCondition(function (ef) return Duel.GetTurnPlayer()~=ef:GetHandlerPlayer() end)
        e8:SetTarget(function (_,c) return c:IsOriginalCode(MAN_WITH_THE_MARK) end)
        Duel.RegisterEffect(e8, tp)


        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EVENT_CHAINING)
        e5:SetCondition(s.discon)
        e5:SetOperation(s.disop)
        Duel.RegisterEffect(e5,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_CANNOT_TRIGGER)
        e9:SetTargetRange(LOCATION_MZONE,0)
        e9:SetCondition(s.discon2)
        e9:SetTarget(s.actfilter)
        Duel.RegisterEffect(e9, tp)


        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_CANNOT_TRIGGER)
        e10:SetTargetRange(LOCATION_MZONE,0)
        e10:SetCondition(function (ef) return Duel.GetTurnPlayer()~=ef:GetHandlerPlayer() end)
        e10:SetTarget(aux.TargetBoolFunction(Card.IsCode,MERCILESS_SCORPION_OF_SERKET))
        Duel.RegisterEffect(e10, tp)

        local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e11:SetCode(EVENT_PHASE+PHASE_END)
		e11:SetCondition(s.epcon)
		e11:SetOperation(s.epop)
        e11:SetCountLimit(1)
		Duel.RegisterEffect(e11,tp)
	end
	e:SetLabel(1)
end

function s.fuscorpfilter(c)
    return c:IsCode(MERCILESS_SCORPION_OF_SERKET) and c:IsFaceup()
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.fuscorpfilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.fuscorpfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    for tc in g:Iter() do
        local atk=tc:GetBaseAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		tc:RegisterEffect(e1)
    end
end

function s.discon2(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+1)>0
end

function s.actfilter(e,c)
	return c:IsCode(DIVINE_SERPENT_APOPHIS)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(DIVINE_SERPENT_APOPHIS) and (Duel.GetFlagEffect(tp,id+1)==0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end

function s.cfilter(c,e,tp,rp)
	if c:IsFacedown() or not c:IsCode(89194033) or not c:IsAbleToGraveAsCost() then return false end
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE|LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp,rp,Group.FromCards(c,e:GetHandler()))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp,rp)
	g:AddCard(e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c,e,tp,rp,sg)
	if not c:IsCanBeSpecialSummoned(e,0,tp,true,true) then return false end
    return c:IsCode(CARD_RA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_HAND|LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE|LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp,rp)
	if #g>0 then
		local tc=g:GetFirst()
        if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK)
            e1:SetValue(4000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_SET_DEFENSE)
            tc:RegisterEffect(e2)


            local e5=Effect.CreateEffect(e:GetHandler())
            e5:SetType(EFFECT_TYPE_SINGLE)
            e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
            e5:SetReset(RESET_EVENT+RESETS_STANDARD)
            e5:SetValue(1)
            tc:RegisterEffect(e5)
        
        end
        Duel.SpecialSummonComplete()

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetCode(EVENT_PHASE+PHASE_END)
        e3:SetCountLimit(1)
        e3:SetLabelObject(tc)
        e3:SetCondition(s.descon)
        e3:SetOperation(s.desop)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)>0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end

function s.eftg2(e,c)
	return c:IsOriginalCode(29762407,511000821)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


end