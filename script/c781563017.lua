--The Ancient Bloodline Rises!
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		nil, nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

    aux.GlobalCheck(s, function()
        s.used_this_skill_opd = {false, false}
		s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false

        aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false
		end)

    end)
end
function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCountLimit(1)
    e1:SetCondition(s.opdcon)
    e1:SetOperation(s.sendcard)
    Duel.RegisterEffect(e1, tp)


    s.rewritegenesisfilter(e, tp)


    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.descon)
	e5:SetOperation(s.desop)
    Duel.RegisterEffect(e5, tp)
end

function s.opdcon(e, tp, eg, ep, ev, re, r, rp)
    return s.used_this_skill_opd[tp + 1] == false
end

function s.sendcard(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill_opd[tp + 1] = true

    local vampfamiliar=Duel.CreateToken(tp,34250214)
    local vampretainer=Duel.CreateToken(tp,70645913)
    local g=Group.FromCards(vampfamiliar,vampretainer)
    Duel.SendtoGrave(g, REASON_RULE)
end

function s.banishfilter(c)
    return c:IsAbleToRemoveAsCost() and (c:GetControler()~=c:GetOwner())
end

function s.genesisfilter(c)
    return c:IsCode(22056710) and c:GetFlagEffect(id)==0
end

function s.rewritegenesisfilter(e,tp)
    local g=Duel.GetMatchingGroup(s.genesisfilter, tp, LOCATION_ALL, LOCATION_ALL, nil)
    if #g>0 then
        for tc in g:Iter() do
            --You can also Special Summon "Vampire Genesis" (from your Hand or GY) by banishing 1 Card you control that is owned by your opponent.
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetDescription(aux.Stringid(id, 0))
            e1:SetCode(EFFECT_SPSUMMON_PROC)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
            e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
            e1:SetCondition(s.selfspcon)
            e1:SetTarget(s.selfsptg)
            e1:SetOperation(s.selfspop)
            tc:RegisterEffect(e1)

            tc:RegisterFlagEffect(id, 0, 0, 0)
        end
    end
end


function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_ONFIELD,0,nil)
	return #g>0 and Duel.GetMZoneCount(tp,g)>0 and Duel.GetFlagEffect(tp, id) > 0
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_ONFIELD,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end


function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp) and re:GetOwner() and re:GetOwner():IsSetCard(SET_VAMPIRE) and s.used_this_skill[e:GetHandlerPlayer()] == false
end

function s.setfilter(c,e,tp)
        if (c:IsMonster() and
			not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
            then return true
           elseif (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
			and c:IsSSetable() then
                return true
            else
            return false
            end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.cfilter, nil, 1-tp)
    if g then
        local g2=g:Filter(s.setfilter, nil, e, tp)
        if #g2>0 and Duel.SelectYesNo(tp, aux.Stringid(id,1)) then
            Duel.Hint(HINT_CARD,tp, id)
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
            local sg=g2:Select(tp, 1, 1, nil)
            local tc=sg:GetFirst()
            if tc:IsSpellTrap() then
                Duel.SSet(tp, tc)
            else
                Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
                Duel.ConfirmCards(1-tp, tc)
            end
            s.used_this_skill[e:GetHandlerPlayer()] = true
        end
    end
end

