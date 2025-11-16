--Full-Armed Barrelled Doom Dragon
local s,id=GetID()
function s.initial_effect(c)
    	c:EnableReviveLimit()
    --Set 1 "Metalmorph" Trap from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp) return Duel.IsMainPhase() end)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
s.max_metalmorph_stats={99,-1}
s.listed_names={CARD_MAX_METALMORPH, id}
s.listed_series={SET_METALMORPH}
s.toss_coin=true

function s.setfilter(c)
	return c:IsSetCard(SET_METALMORPH) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

function s.desfilter(c)
    return c:IsFaceup() and not c:ListsCode(CARD_MAX_METALMORPH)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    local ct=#g
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,ct)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    local todes=Group.CreateGroup()
    for tc in g:Iter() do
        Duel.HintSelection(tc)
        local coin=Duel.TossCoin(tp,1)
        if coin==COIN_HEADS then
            todes:AddCard(tc)
        end
    end
    if #todes>0 then
        Duel.Destroy(todes,REASON_EFFECT)
    end
end

--rewriting Max Metalmorph so it can tribute properly

--max Metalmorph
if not c89812483 then
	c89812483 = {}
	setmetatable(c89812483, Card)
	rawset(c89812483,"__index",c89812483)


    function c89812483.initial_effect(c)
        --Special Summon 1 monster that cannot be Normal Summoned/Set and mentions "Max Metalmorph" from your hand/Deck/GY
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(89812483,0))
        e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
        e1:SetType(EFFECT_TYPE_ACTIVATE)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetCountLimit(1,89812483,EFFECT_COUNT_CODE_OATH)
        e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
        e1:SetCost(c89812483.cost)
        e1:SetTarget(c89812483.target)
        e1:SetOperation(c89812483.activate)
        c:RegisterEffect(e1)
    end
    c89812483.listed_names={CARD_MAX_METALMORPH}
    function c89812483.costfilter(c,e,tp)
        return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
            and Duel.IsExistingMatchingCard(c89812483.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetRace(),c.toss_coin and 1 or 0)
    end
    function c89812483.spfilter(c,e,tp,cost_lv,cost_race,tosscoin)
        if not (c:IsMonster() and not c:IsSummonableCard() and c:ListsCode(CARD_MAX_METALMORPH)) then return false end
        if c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c.max_metalmorph_stats==nil then return true end
        if not (c:IsCanBeSpecialSummoned(e,0,tp,true,true) and cost_lv and cost_race) then return false end
        local lv,race=table.unpack(c.max_metalmorph_stats)
        if race==-1 then
            return tosscoin~=0
        else
            return cost_lv>=lv and cost_race&race>0
        end
    end
    function c89812483.cost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then
            local res=Duel.CheckReleaseGroupCost(tp,c89812483.costfilter,1,false,nil,nil,e,tp)
            if res then e:SetLabel(1) end
            return res
        end
        local rc=Duel.SelectReleaseGroupCost(tp,c89812483.costfilter,1,1,false,nil,nil,e,tp):GetFirst()
        e:SetLabel(rc:GetLevel(),rc:GetRace(),rc.toss_coin and 1 or 0)
        Duel.Release(rc,REASON_COST)
    end
    function c89812483.target(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then
            local res=e:GetLabel()==1 or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
                and Duel.IsExistingMatchingCard(c89812483.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp))
            e:SetLabel(0)
            return res
        end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
        Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
    end
    function c89812483.activate(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        local c=e:GetHandler()
        local cost_lv,cost_race,toss_coin=e:GetLabel()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c89812483.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,cost_lv,cost_race,toss_coin):GetFirst()
        if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0 then
            tc:CompleteProcedure()
            if not (c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(89812483,1))) then return end
            c:CancelToGrave(true)
            Duel.BreakEffect()
            if not tc:EquipByEffectAndLimitRegister(e,tp,c,nil,true) then return end
            --Equip limit
            local e0=Effect.CreateEffect(c)
            e0:SetType(EFFECT_TYPE_SINGLE)
            e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e0:SetCode(EFFECT_EQUIP_LIMIT)
            e0:SetValue(function(e,c) return c==tc end)
            e0:SetReset(RESET_EVENT|RESETS_STANDARD)
            c:RegisterEffect(e0)
            --The equipped monster gains 400 ATK/DEF
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_EQUIP)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(400)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            c:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            c:RegisterEffect(e2)
            --The equipped monster cannot be destroyed by monster and Spell effects
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_EQUIP)
            e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e3:SetValue(function(e,re,rc,c) return re:IsMonsterEffect() or re:IsSpellEffect() end)
            e3:SetReset(RESET_EVENT|RESETS_STANDARD)
            c:RegisterEffect(e3)
            --Your opponent cannot target the monster with monster and Spell effects
            local e4=e3:Clone()
            e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
            e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
            e4:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() and (re:IsMonsterEffect() or re:IsSpellEffect()) end)
            c:RegisterEffect(e4)
        end
    end
end