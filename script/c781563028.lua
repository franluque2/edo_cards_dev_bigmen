--Applied Ancient Gear Thesis
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	
        aux.GlobalCheck(s, function()
        s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false
    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil, nil, true, nil)
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
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCountLimit(1)
    e1:SetCondition(s.grainlpcon)
    e1:SetOperation(s.gainlpop)
    Duel.RegisterEffect(e1,tp)

            local e2a=Effect.CreateEffect(c)
        e2a:SetDescription(aux.Stringid(id,0))
        e2a:SetType(EFFECT_TYPE_QUICK_O)
        e2a:SetCode(EVENT_FREE_CHAIN)
        e2a:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e2a:SetRange(LOCATION_MZONE)
        e2a:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
        e2a:SetCountLimit(1,id)
        e2a:SetCondition(s.condition)
        e2a:SetTarget(s.destg)
        e2a:SetOperation(s.desop)


    	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2b:SetTargetRange(LOCATION_MZONE,0)
	e2b:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(CARD_ANCIENT_GEAR_GOLEM) end)
	e2b:SetLabelObject(e2a)
	Duel.RegisterEffect(e2b,tp)



end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local tn=Duel.GetTurnPlayer()
    return tn~=tp and Duel.IsMainPhase()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local thisc=e:GetHandler()
    if not thisc:IsPosition(POS_FACEUP_ATTACK) then return end
    if tc:IsRelateToEffect(e) then
        Duel.CalculateDamage(e:GetHandler(), tc)
    end
end


function s.grainlpcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and not s.used_this_skill[tp]
end


function s.gainlpop(e,tp,eg,ep,ev,re,r,rp)
    s.used_this_skill[tp] = true
    if Duel.GetTurnCount()==1 then return end
    local c=e:GetHandler()

    Duel.Hint(HINT_CARD,tp,id)
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    local op=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))
    if op==0 then
        local lp=Duel.GetLP(1-tp)
        Duel.SetLP(1-tp, lp*3)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetDescription(aux.Stringid(id,5))
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e2:SetCode(EFFECT_CANNOT_ACTIVATE)
        e2:SetTargetRange(1,0)
        e2:SetValue(1)
        e2:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e2,1-tp)

    elseif op==1 then

        local lp=Duel.GetLP(1-tp)
        Duel.SetLP(1-tp, lp*2)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetDescription(aux.Stringid(id,5))
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e2:SetCode(EFFECT_CANNOT_ACTIVATE)
        e2:SetTargetRange(1,0)
		e2:SetValue(s.aclimit)
        e2:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e2,1-tp)
    end
end

function s.aclimit(e,re,tp)
	return re:IsMonsterEffect()
end