--The Academy's Amazonian Tag Tactics
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
local CARD_PET_LIGER_KING = 59353647
local CARD_AMAZONESS_AUGUSTA = 23965033
local CARD_PET_LIGER = 68507541
local CARD_AMAZONESS_SPY = 31102447
local CARD_AMAZONESS_QUEEN = 15951532

function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,
        nil, true, nil)
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

    --Your Defence position "Amazoness" monsters and Fusion "Amazoness" Warrior monsters are unaffected by the continuous effects of your "Amazoness" Warrior monsters, except their own.
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e,c)
        return (c:IsDefensePos() and c:IsSetCard(SET_AMAZONESS)) or (c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and c:IsSetCard(SET_AMAZONESS))
    end)
    e1:SetValue(function(e,re)
        local c=e:GetHandler()
        local rc=re:GetHandler()
        if re:IsActivated() then return false end
        return rc:IsSetCard(SET_AMAZONESS) and rc:IsRace(RACE_WARRIOR) and rc:IsControler(c:GetControler()) and rc~=c
    end)
    Duel.RegisterEffect(e1, tp)

    --During your Battle Phase or your opponent's turn, if you do not control a Beast "Amazoness" monster, negate the effects on the field of your level 6 or higher monsters that are "Amazoness Queen" or mention it in their text.
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetCondition(s.negcond)
    e2:SetTarget(s.negtarg)
    Duel.RegisterEffect(e2, tp)

    --Rewrite Amazoness Beast Monsters
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCondition(s.rewritebeastscond)
    e3:SetOperation(s.rewritebeastsop)
    Duel.RegisterEffect(e3, tp)

    --"Amazoness Augusta" you control gains the following effect

    --"Once per turn: if you gain LP, you can target 1 card on the field; destroy it".
    local ea0=Effect.CreateEffect(c)
	ea0:SetDescription(aux.Stringid(id,1))
	ea0:SetCategory(CATEGORY_DESTROY)
	ea0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	ea0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	ea0:SetCode(EVENT_RECOVER)
	ea0:SetRange(LOCATION_MZONE)
	ea0:SetCountLimit(1)
	ea0:SetCondition(s.descon)
	ea0:SetTarget(s.destg)
	ea0:SetOperation(s.desop)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(function(e,c) return c:IsCode(CARD_AMAZONESS_AUGUSTA) end)
    e4:SetLabelObject(ea0)
    Duel.RegisterEffect(e4,tp)
    
    --"Amazoness Pet Liger" you control gains the following effect

    --"If you control "Amazoness Queen" or a non-Beast monster that mentions it: you can target 2 "Amazoness" cards you control; destroy those targets, then you can set 1 "Amazoness" Continuous Trap from your hand, Deck or GY, it can be activated this turn. You can only use this effect of "Amazoness Pet Liger" once per turn.

    local ea1=Effect.CreateEffect(c)
    ea1:SetDescription(aux.Stringid(id,2))
    ea1:SetType(EFFECT_TYPE_IGNITION)
    ea1:SetCategory(CATEGORY_DESTROY)
    ea1:SetRange(LOCATION_MZONE)
    ea1:SetCountLimit(1,{id,0})
    ea1:SetTarget(s.petligertg)
    ea1:SetOperation(s.petligerop)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(function(e,c) return c:IsCode(CARD_PET_LIGER) end)
    e5:SetLabelObject(ea1)
    Duel.RegisterEffect(e5,tp)

    --"Amazoness Augusta" you control cannot attack, while you do not control Amazoness Pet Liger King.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_CANNOT_ATTACK)
    e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetTarget(function(e,c) return c:IsCode(CARD_AMAZONESS_AUGUSTA) end)
    e6:SetCondition( function (e) return not Duel.IsExistingMatchingCard(function(c) return c:IsCode(CARD_PET_LIGER_KING) end, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil) end)
    Duel.RegisterEffect(e6,tp)

end


function s.negcond(e)
    local tp = e:GetHandlerPlayer()
    return (Duel.IsBattlePhase() or (Duel.GetTurnPlayer() ~= tp)) and not Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsSetCard(SET_AMAZONESS) and c:IsRace(RACE_BEAST)
    end, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.negtarg(e,c)
    return c:IsLevelAbove(6) and (c:IsCode(CARD_AMAZONESS_QUEEN) or c:ListsCode(CARD_AMAZONESS_QUEEN))
end

function s.rewritebeastamazonessfilter(c)
    return c:IsMonster() and c:IsRace(RACE_BEAST) and c:GetFlagEffect(id)==0
end

function s.rewritebeastscond(e,tp)
    return Duel.IsExistingMatchingCard(s.rewritebeastamazonessfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritebeastsop(e,tp)
    local g=Duel.GetMatchingGroup(s.rewritebeastamazonessfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 1)

        local effs={tc:GetOwnEffects()}
        local needstogetneweff = false
        for _,eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_CANNOT_SELECT_BATTLE_TARGET then
                eff:Reset()
                needstogetneweff = true
            end
        end

        if needstogetneweff then
            --"Your opponent's monsters cannot attack, except to attack the "Amazoness" Beast monster(s) you control with the higher level."
            local e1=Effect.CreateEffect(tc)
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
            e1:SetRange(LOCATION_MZONE)
            e1:SetTargetRange(0, LOCATION_MZONE)
            e1:SetValue(s.atklimit)
            tc:RegisterEffect(e1)

            tc:RegisterFlagEffect(0,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id, 0))

        end
    end
end

function s.fubeastamazonessfilter(c)
    return c:IsMonster() and c:IsRace(RACE_BEAST) and c:IsSetCard(SET_AMAZONESS)
end

function s.atklimit(e,c)
	local g=Duel.GetMatchingGroup(s.fubeastamazonessfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local tg=g:GetMaxGroup(Card.GetLevel)
	return not tg:IsContains(c) or c:IsFacedown()
end


function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g then Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end


function s.condfilter(c)
    return c:IsFaceup() and (c:IsCode(CARD_AMAZONESS_QUEEN) or (c:ListsCode(CARD_AMAZONESS_QUEEN) and not c:IsRace(RACE_BEAST)))
end

function s.amazonesssetfilter(c)
    return c:IsSetCard(SET_AMAZONESS) and c:IsSSetable() and c:IsTrap() and c:IsType(TYPE_CONTINUOUS)
end

function s.destructligerfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_AMAZONESS) and c:IsDestructable()
end

--you can target 2 "Amazoness" cards you control; destroy those targets, then 
function s.petligertg(e,tp,eg,ep,ev,re,r,rp,chk, chkc)

    if chkc then return chkc:IsControler(tp) and s.destructligerfilter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return Duel.IsExistingMatchingCard(s.condfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.destructligerfilter,tp,LOCATION_ONFIELD,0,2,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.destructligerfilter,tp,LOCATION_ONFIELD,0,2,2,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
    Duel.HintSelection(g)
end

function s.petligerop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if g and #g>0 then
        local dg=g:Filter(Card.IsRelateToEffect,nil,e)
        if #dg>0 then
            if Duel.Destroy(dg,REASON_EFFECT)>0 and 
            Duel.IsExistingMatchingCard(s.amazonesssetfilter, tp, LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE, 0, 1, nil) 
            and Duel.SelectYesNo(tp, aux.Stringid(id, 5))
            then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
                    local g=Duel.SelectMatchingCard(tp,s.amazonesssetfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
                    if g:GetCount()>0 then
                        Duel.SSet(tp,g:GetFirst())

                        local e1=Effect.CreateEffect(e:GetHandler())
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
                        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                        e1:SetReset(RESETS_STANDARD_PHASE_END)
                        g:GetFirst():RegisterEffect(e1)

                    end

            end
        end
    end


end