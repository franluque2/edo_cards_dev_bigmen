--Forbidden Armor Ninjitsu Techniques
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

    aux.GlobalCheck(s, function()
        s.used_this_skill_active = {}
        s.used_this_skill_active[0] = false
        s.used_this_skill_active[1] = false


        s.used_this_skill_passive = {}
        s.used_this_skill_passive[0] = false
        s.used_this_skill_passive[1] = false
    aux.AddValuesReset(function()
        s.used_this_skill_passive[0] = false
        s.used_this_skill_passive[1] = false

        s.used_this_skill_active[0] = false
        s.used_this_skill_active[1] = false
		end)

    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive, s.flipopactive, true, nil)
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


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetTarget(aux.TargetBoolFunction(s.nstar))
	Duel.RegisterEffect(e2,tp)

    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_PREDRAW)
    e5:SetOperation(s.loselpop)
    Duel.RegisterEffect(e5,tp)

    --Once per turn, before resolving an activated effect that targets a face-up "Ninja" card you control (and no other cards), you can Special Summon 1 of the monsters that is attached to your cards as material, and if you do, change the target to it.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetCondition(s.redirectcon)
    e3:SetOperation(s.redirectop)
    Duel.RegisterEffect(e3,tp)

    --If you activate a Continuous, Equip or Field "Ninjitsu Art" Spell/Trap Card during your turn, you can attach 1 "Ninja" monster from your GY to it as Xyz material.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAIN_SOLVED)
    e4:SetCondition(s.attachcon)
    e4:SetOperation(s.attachop)
    Duel.RegisterEffect(e4,tp)


    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_DISABLE)
    e7:SetTargetRange(LOCATION_ONFIELD,0)
    e7:SetCondition(function () return Duel.IsBattlePhase() end)
    e7:SetTarget(aux.TargetBoolFunction(Card.IsCode,37354507))
    Duel.RegisterEffect(e7, tp)

end

function s.loselpop(e,tp,eg,ep,ev,re,r,rp)
    local num=Duel.GetOverlayCount(tp,LOCATION_MZONE,0)
    if num>0 then
        Duel.Hint(HINT_CARD,tp,id)
        Duel.SetLP(tp,Duel.GetLP(tp)-num*1000)

    end
end

function s.attachninjafilter(c)
    return c:IsSetCard(SET_NINJA) and c:IsMonster() and aux.nvfilter(c)
end

function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
    if not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(SET_NINJITSU_ART)) then return false end
    return re:GetHandler():IsType(TYPE_EQUIP|TYPE_CONTINUOUS|TYPE_FIELD) and re:GetHandler():GetControler()==tp and Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(s.attachninjafilter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
    Duel.Hint(HINT_CARD, tp, id)
    local g=Duel.GetMatchingGroup(s.attachninjafilter, tp, LOCATION_GRAVE, 0, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local sg=g:Select(tp, 1, 1, nil)
    local tc=sg:GetFirst()
    if tc then
        Duel.Overlay(re:GetHandler(), Group.FromCards(tc))
    end
    end
end

function s.spninjafilter(c,e,tp)
    return c:IsSetCard(SET_NINJA) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.hasspmatfilter(c,e,tp)
    return c:GetOverlayGroup() and c:GetOverlayGroup():IsExists(s.spninjafilter, 1, nil, e, tp)
end
function s.redirectcon(e,tp,eg,ep,ev,re,r,rp)
    if not (re and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
    local tc=g:GetFirst()
    local hasmat=Duel.GetMatchingGroup(s.hasspmatfilter, tp, LOCATION_MZONE+LOCATION_SZONE, 0, nil, e, tp)
    local spg=Group.CreateGroup()
    for tc2 in hasmat:Iter() do
        spg:Merge(tc2:GetOverlayGroup():Filter(s.spninjafilter, nil, e, tp))
    end
	return tc:IsFaceup() and tc:IsLocation(LOCATION_ONFIELD) and tc:IsSetCard(SET_NINJA) and tc:IsControler(tp) and #spg>0 and Duel.GetMZoneCount(tp)>0 and not s.used_this_skill_passive[tp]
end

function s.redirectop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
    s.used_this_skill_passive[tp] = true
    Duel.Hint(HINT_CARD, tp, id)
    local hasmat=Duel.GetMatchingGroup(s.hasspmatfilter, tp, LOCATION_MZONE+LOCATION_SZONE, 0, nil, e, tp)
    local spg=Group.CreateGroup()
    for tc2 in hasmat:Iter() do
        spg:Merge(tc2:GetOverlayGroup():Filter(s.spninjafilter, nil, e, tp))
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sg=spg:Select(tp, 1, 1, nil)
    local tc=sg:GetFirst()
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        Duel.ChangeTargetCard(ev,Group.FromCards(tc))
    end
    Duel.SpecialSummonComplete()
end
end

function s.xyzlv(e,c,rc)
	if rc:IsSetCard(SET_NINJA) then
		return 4,5,e:GetHandler():GetLevel()
	else
		return e:GetHandler():GetLevel()
	end
end
function s.nstar(c)
    return c:IsSetCard(SET_NINJA) and c:IsAttributeExcept(ATTRIBUTE_DARK)
end

function s.setbackrowfilter(c)
    return c:IsSetCard(SET_NINJITSU_ART) and c:IsSpellTrap() and c:IsSSetable()
end

function s.sendninjafilter(c)
    return c:IsSetCard(SET_NINJA) and c:IsMonster() and c:IsAbleToGraveAsCost()
end

function s.hasmatfilter(c)
    return c:GetOverlayGroup() and c:GetOverlayGroup():IsExists(s.sendninjafilter, 1, nil)
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.GetMatchingGroup(s.setbackrowfilter, tp, LOCATION_DECK, 0, nil)
    local sendg=Duel.GetMatchingGroup(s.sendninjafilter, tp, LOCATION_HAND, 0, nil)
    local hasmat=Duel.GetMatchingGroup(s.hasmatfilter, tp, LOCATION_MZONE+LOCATION_SZONE, 0, nil)
    for tc in hasmat:Iter() do
        sendg:AddCard(tc:GetOverlayGroup():Filter(s.sendninjafilter, nil))
    end
    return (not s.used_this_skill_active[e:GetHandlerPlayer()])  and aux.CanActivateSkill(tp) and Duel.GetLocationCount(tp, LOCATION_SZONE)>1 and g:GetClassCount(Card.GetCode, nil)>=1
        and sendg:GetClassCount(Card.GetAttribute, nil)>1
end

function s.rescon(sg,e,tp,mg)
	return sg:GetBinClassCount(Card.GetAttribute)==#sg,sg:GetBinClassCount(Card.GetAttribute)~=#sg
end

function s.setcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)>=#sg
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill_active[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()

    local g=Duel.GetMatchingGroup(s.setbackrowfilter, tp, LOCATION_DECK, 0, nil)
    local sendg=Duel.GetMatchingGroup(s.sendninjafilter, tp, LOCATION_HAND, 0, nil)
    local hasmat=Duel.GetMatchingGroup(s.hasmatfilter, tp, LOCATION_MZONE+LOCATION_SZONE, 0, nil)
    for tc in hasmat:Iter() do
        sendg:AddCard(tc:GetOverlayGroup():Filter(s.sendninjafilter, nil))
    end
    local tg=aux.SelectUnselectGroup(sendg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
    if #tg>0 then
        Duel.SendtoGrave(tg, REASON_RULE)
    end

    local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.setcheck,1,tp,HINTMSG_SET)

    Duel.SSet(tp, sg)

end