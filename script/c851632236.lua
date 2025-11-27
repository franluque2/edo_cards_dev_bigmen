--Digital Bug RAMefly
local s,id=GetID()
function s.initial_effect(c)
    --If this card is in your hand: You can reveal 1 LIGHT Insect Xyz monster in your Extra Deck; Special Summon both this card and 1 LIGHT Insect monster with the same level as the revealed monster's Rank from your Extra Deck, and if you do, change this card's level to the revealed monster's rank, then, immediately after this effect resolves, Xyz summon the revealed monster using these two monsters only.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --If this card is in your GY, except the turn it was sent there: You can banish this card from your GY, then target 2 Insect monsters in your GY with the same level; Special Summon them, then immediately after this effect resolves, Xyz summon 1 Insect Xyz monster using those 2 monsters only.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)

    --An Insect Xyz Monster that has this card as material gains this effect:
    --• The DEF of monsters your opponent controls becomes 0.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.defcon)
    e3:SetTarget(function(e,c) return c:IsFaceup() end)
    e3:SetValue(s.defval)
    c:RegisterEffect(e3)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

function s.counterfilter(c)
    return c:IsRace(RACE_INSECT)
end

--Effect 1: Special Summon from hand
function s.spcostfilter(c,e,tp)
    return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_INSECT) and not c:IsPublic()
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRank())
end
function s.spfilter(c,e,tp,rank)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_INSECT) and c:IsLevel(rank) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
         end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local rc=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
    e:SetLabelObject(rc)
    Duel.ConfirmCards(1-tp,rc)
    Duel.ShuffleExtra(tp)
    --Cannot Special Summon monsters, except Insect monsters
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not c:IsRace(RACE_INSECT) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsPlayerCanSpecialSummonCount(tp, 3)
         end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_HAND+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return end
    local rc=e:GetLabelObject()
    if not rc then return end
    local rank=rc:GetRank()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,rank)
    if #g>0 then
        g:AddCard(c)
        if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==2 then
            --Change this card's level
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(rank)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
            --Xyz Summon the revealed monster
            Duel.BreakEffect()
            if rc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) 
                and Duel.GetLocationCountFromEx(tp,tp,g,rc)>0 then
                Duel.XyzSummon(tp,rc,nil,g,2,2)
            end
        end
    end
end

--Effect 2: Special Summon from GY
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and aux.exccon(e)
end
function s.gyfilter(c,e,tp)
    return c:IsRace(RACE_INSECT) and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
        and c:IsCanBeEffectTarget(e)
end
function s.xyzfilter2(c,mg,tp)
    return c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ) and c:IsXyzSummonable(nil,mg,2,2) 
        and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.gylvfilter(c,lv,mg,exg,tp)
    return c:IsLevel(lv) and mg:IsExists(s.gylvfilter2,1,c,c,lv,exg,tp)
end
function s.gylvfilter2(c,mc,lv,exg,tp)
    return c:IsLevel(lv) and exg:IsExists(Card.IsXyzSummonable,1,nil,nil,Group.FromCards(c,mc),2,2)
end
function s.rescon(lv,exg)
    return function(sg)
        return #sg==2 and exg:IsExists(Card.IsXyzSummonable,1,nil,nil,sg,2,2)
    end
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local mg=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e,tp)
    if chk==0 then 
        return Duel.IsPlayerCanSpecialSummonCount(tp,2)
            and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
            and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
            and mg:FilterCount(Card.HasLevel,nil)>=2
            and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,mg,tp)
    end
    local exg=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_EXTRA,0,nil,mg,tp)
    local levels={}
    for tc in mg:Iter() do
        local lv=tc:GetLevel()
        if not levels[lv] and mg:IsExists(s.gylvfilter,1,nil,lv,mg,exg,tp) then
            levels[lv]=true
        end
    end
    local slv=0
    if #levels>1 then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
        for lv in pairs(levels) do
            local sel=Duel.AnnounceLevel(tp,lv,lv)
            slv=sel
            break
        end
    else
        for lv in pairs(levels) do
            slv=lv
            break
        end
    end
    local sg=aux.SelectUnselectGroup(mg:Filter(Card.IsLevel,nil,slv),e,tp,2,2,s.rescon(slv,exg),1,tp,HINTMSG_SPSUMMON)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
    --Cannot Special Summon monsters, except Insect monsters
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not c:IsRace(RACE_INSECT) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.gyspfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    local g=Duel.GetTargetCards(e):Match(s.gyspfilter,nil,e,tp)
    if #g~=2 then return end
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=2 then return end
    Duel.BreakEffect()
    local xyzg=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_EXTRA,0,nil,g,tp)
    if #xyzg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
        Duel.XyzSummon(tp,xyz,nil,g,2,2)
    end
end

--Effect 3: Xmaterial effect
function s.defcon(e)
    local c=e:GetHandler()
    return c:IsType(TYPE_XYZ) and c:IsRace(RACE_INSECT)
end


function s.defval(e,c)
	return c:GetAttack()/2
end