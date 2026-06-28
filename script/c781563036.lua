--Nemesis ROMHack
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

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end
function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)


    		local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetDescription(aux.Stringid(id,0))
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_SUMMON_PROC)
        e3:SetTargetRange(LOCATION_HAND,0)
        e3:SetCondition(s.ntcon)
        e3:SetTarget(aux.FieldSummonProcTg(s.nttg))
        Duel.RegisterEffect(e3,tp)
        

            local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetTarget(aux.TargetBoolFunction(s.nstar))
	Duel.RegisterEffect(e2,tp)


        local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetCondition(s.changeplacescon)
    e3:SetOperation(s.changeplacesop)
    Duel.RegisterEffect(e3,tp)

end

function s.changeplacescon(e,tp,eg,ep,ev,re,r,rp)
    if not (re and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:GetHandler():IsCode(41516133)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g then return false end
    local tc=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	return tc and tc:IsLocation(LOCATION_ONFIELD) and tc:IsControler(1-tp) and ((Duel.GetLocationCount(1-tp, tc:GetLocation())>0) and not tc:IsLocation(LOCATION_FZONE))
end

function s.changeplacesop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g then return false end
    local tc=g:Filter(Card.IsControler,nil,1-tp):GetFirst()

    if tc and Duel.SelectYesNo(1-tp, aux.Stringid(id, 2)) then
        Duel.Hint(HINT_CARD, tp, id)
        local dis=tc:GetSequence()
		local zone=Duel.SelectDisableField(1-tp,1,tc:GetLocation(),0,0)
        local disval=0

		if zone then
            if tc:IsLocation(LOCATION_MZONE) 
            then
                disval=1<<(16+dis)
                Duel.MoveSequence(tc,math.floor(math.log(zone,2))) 

            else
                disval=1<<(24+dis)
                Duel.MoveSequence(tc,math.floor(math.log(zone,2))-8)
            end
            

        end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_DISABLE_FIELD)
        e1:SetLabel(disval)
        e1:SetOperation(s.disop)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(s.indesval)
		e2:SetReset(RESET_CHAIN)
		e2:SetLabelObject(re)
		tc:RegisterEffect(e2)

    end
end

function s.nstar(c)
    return c:IsSetCard(SET_BES) and c:IsAttributeExcept(ATTRIBUTE_DARK)
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsSetCard(SET_BES)
end


function s.indesval(e,re)
	return re==e:GetLabelObject()
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)


    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 04909946)
	if #g1 > 0 then
		Duel.MoveToDeckTop(g1:GetFirst())
	end
end



function s.torewritefilter(c)
    return c:IsOriginalCode(66947414) and c:GetFlagEffect(id) == 0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.torewritefilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.torewritefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)
        local effs={tc:GetOwnEffects()}

        for _, eff in ipairs(effs) do
            if eff:IsHasType(EFFECT_TYPE_ACTIVATE) then
                eff:SetCondition(aux.TRUE)
            end
            if eff:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) then
                eff:Reset()
            end
        end
    end
end

function s.disop(e,tp)
    return e:GetLabel()
end