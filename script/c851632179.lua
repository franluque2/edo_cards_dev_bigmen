--Doomed Spirit Message - N
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- If your opponent Special Summons a monster in the same Column as a face-up "Spirit Message" Spell/Trap Card or "Destiny Board" you control, you can activate one of the following effects (but you can only use each effect once per turn):
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp~=tp and eg:IsExists(s.colfilter,1,nil,tp) end)
    e3:SetTarget(s.choosetg)
    c:RegisterEffect(e3)
    
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.ctfilter)

end
s.listed_series={SET_SPIRIT_MESSAGE}
s.listed_names={CARD_DESTINY_BOARD, 16625614, 31829185} --Dark Sanctuary, Dark Necrofear

function s.ctfilter(c)
    return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>0 then return false end
        return true
    end
    -- Cannot Special Summon from the Extra Deck this turn, except Fusion Monsters
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION) end)
    Duel.RegisterEffect(e1,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spfilter(c,e,tp)
    return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
end

function s.colfilter(c,tp)
    local col=c:GetColumnGroup():Filter(Card.IsControler,nil,tp)
    return col and Group.IsExists(col, function(tc) return (tc:IsSetCard(SET_SPIRIT_MESSAGE) or tc:IsCode(CARD_DESTINY_BOARD)) and tc:IsFaceup() end, 1, nil)
end

function s.fusfilter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

function s.fextra(e,tp,mg)
    return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
end

function s.extraop(e,tc,tp,sg)
    local g1=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    if #g1>0 then
        Duel.Remove(g1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    end
    sg:Sub(g1)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end

function s.choosetg(e,tp,eg,ep,ev,re,r,rp,chk)
    local opts={}
    local opval={}
    
    -- Option 1: Fusion Summon
    if Duel.GetFlagEffect(tp, id+2)==0 then
        local fuscheck=Fusion.SummonEffTG(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),Fusion.OnFieldMat,s.fextra,s.extraop,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
        if fuscheck(e,tp,eg,ep,ev,re,r,rp,0) then
            table.insert(opts,aux.Stringid(id,2))
            table.insert(opval,1)
        end
    end
    
    -- Option 2: Equip Dark Necrofear
    if Duel.GetFlagEffect(tp, id+1)==0 and Duel.IsExistingMatchingCard(s.necrofilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
        table.insert(opts,aux.Stringid(id,3))
        table.insert(opval,2)
    end
    
    -- Option 3: Place Dark Sanctuary
    if Duel.GetFlagEffect(tp, id)==0 then
        table.insert(opts,aux.Stringid(id,4))
        table.insert(opval,3)
    end
    
    if chk==0 then return #opts>0 end
    
    if #opts==0 then return end
    
    local op=Duel.SelectOption(tp,table.unpack(opts))+1
    local sel=opval[op]
    e:SetLabel(sel)
    
    if sel==1 then
        Duel.RegisterFlagEffect(tp, id+2, RESET_PHASE+PHASE_END, 0, 1)
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
        e:SetOperation(s.fusop)
        local fustg=Fusion.SummonEffTG(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),Fusion.OnFieldMat,s.fextra,s.extraop,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
        fustg(e,tp,eg,ep,ev,re,r,rp,1)
    elseif sel==2 then
        Duel.RegisterFlagEffect(tp, id+1, RESET_PHASE+PHASE_END, 0, 1)
        e:SetCategory(CATEGORY_EQUIP)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e:SetOperation(s.eqop)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g1=Duel.SelectTarget(tp,s.necrofilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,0,0)
    elseif sel==3 then
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)

        if Duel.IsExistingMatchingCard(s.lv8filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
            e:SetCategory(CATEGORY_CONJURE+CATEGORY_SPECIAL_SUMMON)
            e:SetLabel(1)
        end
        e:SetOperation(s.sanctop)
    end
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local fusop=Fusion.SummonEffOP(aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),Fusion.OnFieldMat,s.fextra,s.extraop)
    fusop(e,tp,eg,ep,ev,re,r,rp)
end

-- Dark Necrofear equip filters and operation
function s.necrofilter(c)
    return c:IsOriginalCode(31829185) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    local necro=g:Filter(s.necrofilter,nil):GetFirst()
    local target=g:Filter(function(c) return c:IsFaceup() and c:IsControler(1-tp) end,nil):GetFirst()
    
    if not necro or not target or not target:IsFaceup() or not target:IsRelateToEffect(e) then return end
    if necro:IsLocation(LOCATION_GRAVE) or necro:IsLocation(LOCATION_MZONE) then
        if not Duel.Equip(tp,necro,target,true,true) then return end
    end
    
    -- Grant control effect
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_CONTROL)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(tp)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    target:RegisterEffect(e1)
    
    -- Limit to 1 equip
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(function(e,c) return c==target end)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    necro:RegisterEffect(e2)
end

-- Dark Sanctuary filters and operation
function s.lv8filter(c)
    return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsLevel(8) and c:IsRace(RACE_FIEND)
end

function s.sanctop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==1 then
        local token=Duel.CreateToken(tp,CARD_DARK_SANCTUARY)
        Duel.MoveToField(token,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end

    -- Treat coin toss as Heads
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_TOSS_COIN_REPLACE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e) local cardid=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE) return cardid and cardid==CARD_DARK_SANCTUARY end)
    e1:SetValue(function(e,c,tp) return COIN_HEADS end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,6))
end