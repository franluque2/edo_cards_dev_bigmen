--Dragonlord of the Shadows
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
        nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local CARD_RED_EYES_DARKNESS_DRAGON = 96561011

local redeyescounts={}
redeyescounts[0]={}
redeyescounts[1]={}



function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.registerredeyes(tp)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(2)
	Duel.RegisterEffect(e1,tp)

    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_MOVE)
    e2:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK) end)
    e2:SetOperation(s.completeredeyes)
    Duel.RegisterEffect(e2,tp)

    s.completeredeyes(nil, tp, nil, nil, nil, nil, nil, nil)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_ADD_SETCODE)
    e3:SetTargetRange(LOCATION_ALL, 0)
    e3:SetTarget(function(_,c) return c:IsOriginalSetCard(SET_RED_EYES) and c:IsMonster() end)
    e3:SetValue(SET_HIERATIC)
    Duel.RegisterEffect(e3,tp)

    local e4=e3:Clone()
    e4:SetTarget(function(_,c) return c:IsOriginalSetCard(SET_HIERATIC) and c:IsSpellTrap() end)
    e4:SetValue(SET_RED_EYES)
    Duel.RegisterEffect(e4,tp)

        local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SUMMON_PROC)
	e5:SetTargetRange(LOCATION_HAND,0)
	e5:SetCondition(s.otcon)
	e5:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
	e5:SetOperation(s.otop)
	e5:SetValue(SUMMON_TYPE_TRIBUTE)
    Duel.RegisterEffect(e5,tp)

    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_ADJUST)
    e6:SetCondition(s.rewritedarknessdragoncon)
    e6:SetOperation(s.rewritedarknessdragonop)
    Duel.RegisterEffect(e6,tp)

	local e7a=Effect.CreateEffect(c)
	e7a:SetDescription(aux.Stringid(id,1))
	e7a:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e7a:SetType(EFFECT_TYPE_QUICK_O)
	e7a:SetCode(EVENT_CHAINING)
	e7a:SetRange(LOCATION_MZONE)
	e7a:SetCondition(s.discon)
	e7a:SetCost(s.relscost)
	e7a:SetTarget(s.distg)
	e7a:SetOperation(s.disop)


    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e7:SetTarget(s.fudarknessdragonfilter)
    e7:SetLabelObject(e7a)
    e7:SetTargetRange(LOCATION_MZONE,0)
    Duel.RegisterEffect(e7,tp)

	local e8a=Effect.CreateEffect(c)
	e8a:SetDescription(aux.Stringid(id,2))
	e8a:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e8a:SetType(EFFECT_TYPE_QUICK_O)
	e8a:SetCode(EVENT_CHAINING)
	e8a:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e8a:SetRange(LOCATION_MZONE)
	e8a:SetCountLimit(1,id)
    e8a:SetCost(s.discost)
	e8a:SetCondition(s.negcon)
	e8a:SetTarget(s.negtg)
	e8a:SetOperation(s.negop)
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e8:SetTarget(s.fudarknessdragonfilter)
    e8:SetLabelObject(e8a)
    e8:SetTargetRange(LOCATION_MZONE,0)
    Duel.RegisterEffect(e8,tp)
end

function s.registerredeyes(tp)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_ALL-LOCATION_EXTRA,0,nil,SET_RED_EYES)
    for tc in g:Iter() do
        if tc:IsMonster() then
            
        
        local code=tc:GetOriginalCode()
        if not redeyescounts[tp][code] then
            redeyescounts[tp][code]=0
        end
        redeyescounts[tp][code]=redeyescounts[tp][code]+1
    end
    end

end

function s.completeredeyes(e,tp,eg,ep,ev,re,r,rp)
    for code, count in pairs(redeyescounts[tp]) do
        local num=Duel.GetMatchingGroupCount(Card.IsOriginalCode, tp, LOCATION_DECK, 0, nil, code)
        if count>num then
            for i=1, count-num do
                local token=Duel.CreateToken(tp, code)
                Duel.SendtoDeck(token, nil, SEQ_DECKBOTTOM, REASON_RULE)
            end
        end
    end
end

function s.releasefilter(c)
    return c:IsMonster() and c:IsRace(RACE_DRAGON) and c:IsReleasable()
end

function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.releasefilter, tp, LOCATION_HAND, 0, 1, c)
        end
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi>1 and c:IsLevelAbove(5)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,_,c)
    local mg=Duel.GetMatchingGroup(s.releasefilter,tp,LOCATION_HAND,0,c)
    local sg=aux.SelectUnselectGroup(mg,e,tp,1,1,nil,1,tp,HINTMSG_RELEASE,nil,nil,Duel.IsSummonCancelable())
    if sg and #sg>0 then
        e:SetLabelObject(sg)
        return true
    end
    return false
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if sg and #sg>0 then
        c:SetMaterial(sg)
        Duel.Release(sg,REASON_SUMMON|REASON_MATERIAL)
    end
end


function s.darknessdragonfilter(c)
    return c:IsOriginalCode(CARD_RED_EYES_DARKNESS_DRAGON) and c:GetFlagEffect(id)==0
end

function s.rewritedarknessdragoncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.darknessdragonfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritedarknessdragonop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.darknessdragonfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))

        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_SPSUMMON_CONDITION then
                eff:Reset()
            end
        end


    end
end


function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(c) and Duel.IsChainDisablable(ev)
end
function s.relscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsRace,1,false,nil,e:GetHandler(),RACE_DRAGON) end
	local sg=Duel.SelectReleaseGroupCost(tp,Card.IsRace,1,1,false,nil,e:GetHandler(),RACE_DRAGON)
	Duel.Release(sg,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.fudarknessdragonfilter(_,c)
    return c:IsCode(CARD_RED_EYES_DARKNESS_DRAGON) and c:IsFaceup()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep~=tp and re:IsSpellEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil)
end