--Tag Team Amazonian Warfare
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
local CARD_PET_LIGER_KING = 59353647
local CARD_AMAZONESS_AUGUSTA = 23965033
local CARD_PET_LIGER = 68507541
local CARD_AMAZONESS_SPY = 31102447
local CARD_AMAZONESS_QUEEN = 15951532

function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive,
        s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)

    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not re:GetHandler():IsCode(CARD_PET_LIGER_KING) end)

end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

    --Your Defence position "Amazoness" monsters and level 8 or higher "Amazoness" Warrior monsters are unaffected by the continuous effects of your "Amazoness" Warrior monsters, except their own.
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e,c)
        return (c:IsDefensePos() and c:IsSetCard(SET_AMAZONESS)) or (c:IsLevelAbove(8) and c:IsRace(RACE_WARRIOR) and c:IsSetCard(SET_AMAZONESS))
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

    --"If you control "Amazoness Queen" or a non-Beast monster that mentions it: you can send 2 "Amazoness" card from your field to the GY; set 1 "Amazoness" Continuous Trap from your hand, Deck or GY, it can be activated this turn. You can only use this effect of "Amazoness Pet Liger" once per turn.

    local ea1=Effect.CreateEffect(c)
    ea1:SetDescription(aux.Stringid(id,2))
    ea1:SetType(EFFECT_TYPE_IGNITION)
    ea1:SetRange(LOCATION_MZONE)
    ea1:SetCountLimit(1,{id,0})
    ea1:SetCost(s.petligercost)
    ea1:SetTarget(s.petligertg)
    ea1:SetOperation(s.petligerop)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(function(e,c) return c:IsCode(CARD_PET_LIGER) end)
    e5:SetLabelObject(ea1)
    Duel.RegisterEffect(e5,tp)

    --"Amazoness Augusta" you control cannot attack, except during the turn in which "Amazoness Pet Liger King" has activted its effect.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_CANNOT_ATTACK)
    e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetTarget(function(e,c) return c:IsCode(CARD_AMAZONESS_AUGUSTA) end)
    e6:SetCondition(function () return (Duel.GetCustomActivityCount(id,0,ACTIVITY_CHAIN)==0 and Duel.GetCustomActivityCount(id,1,ACTIVITY_CHAIN)==0) end)
    Duel.RegisterEffect(e6,tp)

    --"Amazoness Spy" your opponent controls that you own gain the following effect
    --"If your opponent Fusion Summons 1 "Amazoness" Fusion monster: this card immediately attacks 1 "Amazoness" monster your opponent controls. All battle damage from this battle becomes 1000, and this card's owner takes it instead.".
    local ea2 = Effect.CreateEffect(c)
    ea2:SetDescription(aux.Stringid(id,4))
    ea2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    ea2:SetCode(EVENT_SPSUMMON_SUCCESS)
    ea2:SetRange(LOCATION_MZONE)
    ea2:SetProperty(EFFECT_FLAG_DELAY)
    ea2:SetCondition(s.spycond)
    ea2:SetTarget(s.spytg)
    ea2:SetOperation(s.spyop)

    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e7:SetRange(LOCATION_MZONE)
    e7:SetTargetRange(0,LOCATION_MZONE)
    e7:SetTarget(function(e,c) return c:IsCode(CARD_AMAZONESS_SPY) and (c:GetOwner() ~=c:GetControler()) end)
    e7:SetLabelObject(ea2)
    Duel.RegisterEffect(e7,tp)

end

function s.placeablependfilter(c,tp)
    return c:IsMonster() and c:IsSetCard(SET_AMAZONESS) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and Duel.CheckPendulumZones(tp)
end

function s.givespyfilter(c)
    return c:IsCode(CARD_AMAZONESS_SPY) and c:IsControlerCanBeChanged()
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    if not aux.CanActivateSkill(tp) then return false end
    return Duel.IsExistingMatchingCard(s.placeablependfilter, tp, LOCATION_EXTRA|LOCATION_DECK, 0, 1, nil, tp) and Duel.IsExistingMatchingCard(s.givespyfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local tc=Duel.SelectMatchingCard(tp, s.givespyfilter, tp, LOCATION_MZONE, 0, 1, 1, false, nil)
    if #tc > 0 then
        Duel.GetControl(tc:GetFirst(), 1-tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local pg=Duel.SelectMatchingCard(tp, s.placeablependfilter, tp, LOCATION_EXTRA|LOCATION_DECK, 0, 1, 1, false, nil, tp)
    if #pg > 0 then
        local pc=pg:GetFirst()
        Duel.MoveToField(pc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end
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

function s.amazonesstogravefilter(c)
    return c:IsSetCard(SET_AMAZONESS) and c:IsAbleToGraveAsCost()
end

function s.petligercost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.amazonesstogravefilter,tp,LOCATION_ONFIELD,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.amazonesstogravefilter,tp,LOCATION_ONFIELD,0,2,2,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.condfilter(c)
    return c:IsFaceup() and (c:IsCode(CARD_AMAZONESS_QUEEN) or (c:ListsCode(CARD_AMAZONESS_QUEEN) and not c:IsRace(RACE_BEAST)))
end

function s.amazonesssetfilter(c)
    return c:IsSetCard(SET_AMAZONESS) and c:IsSSetable() and c:IsTrap() and c:IsType(TYPE_CONTINUOUS)
end

function s.petligertg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.condfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.amazonesssetfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,nil) end
end

function s.petligerop(e,tp,eg,ep,ev,re,r,rp)
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

function s.spycond(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c,tp) return c:IsFaceup() and c:IsSetCard(SET_AMAZONESS) and c:IsFusionSummoned() and c:GetSummonPlayer()~=tp end,1,nil,tp)
end

function s.spytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.spyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsSetCard(SET_AMAZONESS) and c:IsType(TYPE_MONSTER) end,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
        local tg=g:Select(tp,1,1,nil)
        if #tg>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
            Duel.RegisterEffect(e1,tp)

            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
            e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e2:SetTargetRange(1,1)
            e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
            e2:SetValue(1000)
            Duel.RegisterEffect(e2,tp)


            Duel.CalculateDamage(c,tg:GetFirst())
        end
    end
end