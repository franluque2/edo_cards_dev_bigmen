--Protoss Immortal
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        --If you have more cards in hand than your opponent does, you can Special Summon this card (from your hand). You can only Special Summon "Protoss Immortal" once per turn this way.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    --During the Main Phase, if your opponent would Special Summon a monster while this card is Linked (Quick Effect): You can Negate the Summon, and if you do, your opponent can Special Summon 1 of the monsters used as material from their GY, also they cannot Special Summon monsters with the same name as the monster whose summon was negated for the rest of this turn.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_SPSUMMON)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spnegcon)
    e2:SetTarget(s.spnegtg)
    e2:SetOperation(s.spnegop)
    c:RegisterEffect(e2)

end
s.listed_series={SET_PROTOSS}


function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_HAND)
end

function s.spnegcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.negconfilter,e:GetHandler():GetControler(),LOCATION_ONFIELD,LOCATION_MZONE,1,nil,e:GetHandler(),e:GetHandler():GetLinkedGroup()) and ep~=tp and Duel.GetCurrentChain()==0
end

function s.negconfilter(c,ec,lg)
	return c:IsFaceup() and (lg:IsContains(c) or c:GetLinkedGroup():IsContains(ec))
end

function s.spnegtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return #eg==1 end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
end

function s.spsumfilter(c,e,tp)
    return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spnegop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=eg:GetFirst()
    local mg=tc:GetMaterial()
    Duel.NegateSummon(eg)
    Duel.SendtoGrave(eg, REASON_RULE)
    local g2=mg:Filter(s.spsumfilter,nil,e,tp)
    if #mg>0 and #g2>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
        local sg=g2:Select(1-tp,1,1,nil)
        Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetTarget(function(_,sc) return sc:IsCode(tc:GetCode()) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end