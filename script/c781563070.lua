--Mastermind of the Shadows
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
        nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
    aux.GlobalCheck(s, function()
    s.summoned_sacred_beasts = {}
    s.summoned_sacred_beasts[0] = {}
    s.summoned_sacred_beasts[1] = {}
    end)

end
local CARD_FALLEN_PARADISE_OF_THE_SACRED_BEASTS = 65861210
local CARD_INFINITY_OF_THE_SACRED_BEASTS_RAVIEL_LORD_OF_PHANTASMS = 96345184

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

        --rewrite cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)

    Duel.SetLP(tp, 1000)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.sumlimit)
	e3:SetValue(POS_FACEDOWN)
	Duel.RegisterEffect(e3, tp)


    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(s.immunityrepcon)
    e4:SetOperation(s.immunityrepop)
    Duel.RegisterEffect(e4, tp)


    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetCondition(s.lpcondition)
    e5:SetOperation(s.lpop)
    Duel.RegisterEffect(e5, tp)

    --Before resolving the destruction effect of "Infinity of the Sacred Beasts - Raviel, Lord of Phantasms", your opponent can choose 1 monster they control to be unaffected by that effect.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_CHAIN_SOLVING)
    e6:SetCondition(s.ravieldestructioncon)
    e6:SetOperation(s.ravieldestructionop)
    Duel.RegisterEffect(e6, tp)
end


function s.rewritecardfilter(c)
    return c:IsSetCard(SET_SACRED_BEAST) and c:IsOriginalLevel(10) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritecardfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.rewritecardfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)
        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:GetRange()==LOCATION_MZONE and (eff:IsHasType(EFFECT_TYPE_QUICK_O)) then
                eff:SetType(EFFECT_TYPE_IGNITION)
                eff:SetCountLimit(1,{tc:GetOriginalCode(), 20})
            end
            if tc:IsOriginalCode(50251045) and eff:GetCode()==EVENT_DESTROYED then
                eff:SetCountLimit(1,{tc:GetOriginalCode(), 20},EFFECT_COUNT_CODE_DUEL)
            end
        end
    end
end


function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local tp=sump
	if targetp then tp=targetp end
    local totalatk = Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetAttack)
	return totalatk + c:GetTextAttack() > Duel.GetLP(tp)
end


function s.immunityrepcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:GetHandler():IsOriginalCode(CARD_FALLEN_PARADISE_OF_THE_SACRED_BEASTS)
end

function s.immunityrepop(e,tp,eg,ep,ev,re,r,rp)
    for tc in eg:Iter() do
        local effs={Card.GetCardEffect(tc)}
        for _, eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_IMMUNE_EFFECT then
                    eff:Reset()

                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetDescription(aux.Stringid(id,0))
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
                    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
                    e1:SetCountLimit(1)
                    e1:SetValue(s.indesval)
			        e1:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN)
                    tc:RegisterEffect(e1)
            end
        end
    end
end

function s.indesval(e,re,rp)
	return re:IsSpellTrapEffect()
end

function s.sacredbeastsummonfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_SACRED_BEAST) and c:IsOriginalLevel(10) and c:GetAttack() > 0 and s.summoned_sacred_beasts[c:GetControler()][c:GetOriginalCode()] == nil
end


function s.lpcondition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.sacredbeastsummonfilter, 1, nil)
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)
    for tc in eg:Iter() do
        if s.sacredbeastsummonfilter(tc) then
            Duel.Recover(tp, tc:GetAttack(), REASON_EFFECT)
            s.summoned_sacred_beasts[tc:GetControler()][tc:GetOriginalCode()] = true
        end
    end
end


function s.ravieldestructioncon(e,tp,eg,ep,ev,re,r,rp)
    local oc=re:GetOwner()
    local rc=re:GetHandler()
    return oc and rc and oc:IsOriginalCode(CARD_INFINITY_OF_THE_SACRED_BEASTS_RAVIEL_LORD_OF_PHANTASMS) and rc:IsControler(tp)
        and re:IsHasCategory(CATEGORY_DESTROY)
end

function s.ravieldestructionop(e,tp,eg,ep,ev,re,r,rp)

    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if #g>0 and Duel.SelectYesNo(1-tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tc=g:Select(1-tp,1,1,nil):GetFirst()
        if tc then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
            tc:RegisterEffect(e1)
        end
    end
end