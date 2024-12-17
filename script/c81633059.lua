--Inadequate Excuses for Gladiators
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

--add archetype setcode here
local ARCHETYPE=0x1186

local FLAVIUS_ARENA=05063379
--add the conditions for the archetype swap here
function s.archetypefilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR)
end





function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCountLimit(1)
        e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e2:SetCondition(s.adcon)
        e2:SetOperation(s.adop)
        Duel.RegisterEffect(e2,tp)
    

		--other passive duel effects go here

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0)
        e5:SetTarget(function(_,c)  return c:IsType(TYPE_FUSION) end)
        e5:SetValue(0x19)
        Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_RACE)
        e6:SetCondition(s.changecon1)
        e6:SetTargetRange(LOCATION_HAND,0)
        e6:SetTarget(function(_,c)  return c:IsMonster() end)
        e6:SetValue(RACE_BEAST)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetCondition(s.changecon2)
        e7:SetTargetRange(LOCATION_DECK,0)
        e7:SetTarget(function(_,c)  return c:IsMonster() end)
        e7:SetValue(SET_PREDAPLANT)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetCondition(s.changecon3)
        e8:SetTargetRange(LOCATION_DECK,0)
        e8:SetTarget(function(_,c)  return c:IsCode(08730435,25407406,52496105,99013397) end)
        e8:SetValue(SET_PREDAP)
        Duel.RegisterEffect(e8,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_SETCODE)
        e9:SetCondition(s.changecon4)
        e9:SetTargetRange(LOCATION_MZONE,0)
        e9:SetTarget(function(_,c)  return c:IsMonster() end)
        e9:SetValue(0xdf)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_SETCODE)
        e10:SetCondition(s.changecon5)
        e10:SetTargetRange(LOCATION_MZONE,0)
        e10:SetTarget(function(_,c)  return c:IsMonster() end)
        e10:SetValue(0x4)
        Duel.RegisterEffect(e10,tp)

        local e11=e10:Clone()
        e11:SetCondition(s.changecon6)
        Duel.RegisterEffect(e11,tp)


        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_ADD_CODE)
        e12:SetCondition(s.changecon7)
        e12:SetTargetRange(LOCATION_GRAVE,0)
        e12:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e12:SetValue(15951532)
        Duel.RegisterEffect(e12,tp)

        local e13=Effect.CreateEffect(e:GetHandler())
        e13:SetType(EFFECT_TYPE_FIELD)
        e13:SetCode(EFFECT_ADD_CODE)
        e13:SetCondition(s.changecon8)
        e13:SetTargetRange(LOCATION_GRAVE,0)
        e13:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e13:SetValue(83104731)
        Duel.RegisterEffect(e13,tp)
    
	end
	e:SetLabel(1)
end

function s.changecon1(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil, 07243511)
end
function s.changecon2(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, nil, 66309175)
end

function s.changecon3(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, nil, 66309175)
end
function s.changecon4(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil, 51777272)
end
function s.changecon5(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil, 04591250)
end
function s.changecon6(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil, 68507541)
end
function s.changecon7(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ALL, 0, 1, nil, 04591250)
end
function s.changecon8(e)
    return Duel.IsExistingMatchingCard(Card.IsOriginalCode, e:GetHandlerPlayer(), LOCATION_ALL, 0, 1, nil, 12652643)
end



function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

local table_not_glads={{36256625,03897065},
                        {76263644,69394324},
                        {91998119,58859575},
                        {27134689,07243511},
                        {25586143,66309175},
                        {51777272,97165977},
                        {04591250,68507541},
                        {83866861,10383554},
                        {12652643,511001540},
                        {03779662,48156348}}

function s.getcard()
    return table_not_glads[ Duel.GetRandomNumber(1, #table_not_glads ) ]
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=s.getcard()
    local token=Duel.CreateToken(tp, g[1])
    local token2=Duel.CreateToken(tp, g[2])

    Duel.SendtoDeck(token,tp,SEQ_DECKTOP,REASON_RULE)
    Duel.SendtoDeck(token2,tp,SEQ_DECKTOP,REASON_RULE)
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

    local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 30864377)

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

    local flavius=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL,LOCATION_ALL, nil, FLAVIUS_ARENA)
	for tc in flavius:Iter() do
		if tc:GetFlagEffect(id)==0 then
			local eff={tc:GetCardEffect()}
			for _,teh in ipairs(eff) do
                if teh:GetCode()==EVENT_ATTACK_ANNOUNCE then
                    teh:Reset()
                end

			end


            local e2=Effect.CreateEffect(tc)
            e2:SetDescription(aux.Stringid(tc:GetOriginalCode(),1))
            e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
            e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
            e2:SetCode(EVENT_ATTACK_ANNOUNCE)
            e2:SetRange(LOCATION_FZONE)
            e2:SetCountLimit(1,{id,1})
            e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
            e2:SetTarget(s.sptg)
            e2:SetOperation(s.spop)
            tc:RegisterEffect(e2)


            tc:RegisterFlagEffect(id,0,0,0)

	end
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
    return c:IsLocation(LOCATION_HAND)
end


function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if sc  then
        Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.discon(e)
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end