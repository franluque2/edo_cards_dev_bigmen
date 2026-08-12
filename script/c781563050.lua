--Machinations of the Fourth Card Professor
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

	local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownop)
    c:RegisterEffect(e3)


        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local CARD_COMMANDER_COVINGTON=22666164
local CARD_MACHINA_FORCE=58054262

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)


    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 86852702)
	if #g1 > 0 then
		Duel.MoveToDeckTop(g1:GetFirst())
	end
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

	s.placemonsters(e,tp)
	-- You can Normal Summon 1 "Commander Covington" in addition to your Normal Summon / Set. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id, 1))
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(function(_, _c) return _c:IsCode(CARD_COMMANDER_COVINGTON) end)
	Duel.RegisterEffect(e1, tp)

	--"Commander Covington" is treated as a "Machina" monster while in your Hand, Deck or GY.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetTargetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode, CARD_COMMANDER_COVINGTON))
	e2:SetValue(SET_MACHINA)
	Duel.RegisterEffect(e2, tp)

	    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCondition(s.rewritecardscon)
    e3:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e3, tp)

	--Before an opponent's activated effect resolves, you can detach 1 material from a "Machina Force" you control to make cards you control unaffected by that effect.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetCondition(s.immcon)
	e4:SetOperation(s.immop)
	Duel.RegisterEffect(e4, tp)

	local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_LEAVE_FIELD_P)
    e5:SetCondition(s.gainlpprepcon)
    e5:SetOperation(s.gainlpprepop)
    Duel.RegisterEffect(e5,tp)

	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetLabelObject(e5)
	e6:SetCondition(s.gainlpcon)
	e6:SetOperation(s.gainlpop)
	Duel.RegisterEffect(e6,tp)

end

local machines_to_place= {60999392,23782705,96384007}

function s.placemonsters(e,tp)
	for i,code in ipairs(machines_to_place) do
		local token=Duel.CreateToken(tp,code)
		Duel.SendtoGrave(token, REASON_RULE)
	end
end


function s.mforcefilter(c)
    return c:IsCode(CARD_MACHINA_FORCE) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetMatchingGroupCount(s.mforcefilter,tp,LOCATION_EXTRA,0,nil)>0)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.mforcefilter,tp,LOCATION_EXTRA,0,nil)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,0,0,0)

        tc:SetUniqueOnField(1,0,CARD_MACHINA_FORCE)
	end
end

function s.machinaforcewithmatfilter(c)
	return c:IsCode(CARD_MACHINA_FORCE) and c:IsFaceup() and c:GetOverlayCount()>0
end

function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsExistingMatchingCard(s.machinaforcewithmatfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.machinaforcewithmatfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.Hint(HINT_CARD, 0, id)
		local tc=g:GetFirst()
		if tc then
			tc:RemoveOverlayCard(tp,1,1,REASON_COST)
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetTargetRange(LOCATION_ONFIELD,0)
			e1:SetValue(s.efilter)
			e1:SetLabelObject(re)
			e1:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e1,tp)


		end
	end
end

function s.efilter(e,re)
	return re==e:GetLabelObject()
end


function s.machinaforcepreleavefilter(c,tp)
    return c:IsCode(CARD_MACHINA_FORCE) and c:IsMonster() and c:IsControler(tp) and c:GetOverlayCount()>0
end

function s.machinaforcepostleavefilter(c)
	return c:IsCode(CARD_MACHINA_FORCE) and c:IsMonster()
end

function s.gainlpprepcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.machinaforcepreleavefilter,1,nil,tp)
end

function s.gainlpprepop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.machinaforcepreleavefilter,nil,tp)
    local lp=0
    for tc in g:Iter() do
        lp=lp+tc:GetOverlayCount()*500
    end
	e:SetLabel(lp)
end

function s.gainlpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.machinaforcepostleavefilter, 1, nil) and e:GetLabelObject():GetLabel()>0
end

function s.gainlpop(e,tp,eg,ep,ev,re,r,rp)
	local lp=e:GetLabelObject():GetLabel()
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Recover(tp,lp,REASON_EFFECT)
end