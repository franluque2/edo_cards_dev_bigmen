--Force Viper
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_DECK)
    e0:SetValue(SET_BES)
    c:RegisterEffect(e0)
    --Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --ATK up / Set Powerup / Boss on Parade
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

end
s.listed_names={id,04909946} -- Boss on Parade
s.listed_series={SET_POWERUP}

function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
        and c:GetAttack()==1200 and c:GetDefense()<=1000 and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
    local b1=Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c~=e:GetHandler() end,tp,LOCATION_MZONE,0,1,e:GetHandler())
    local b2=Duel.IsExistingMatchingCard(function(c) return (c:IsSetCard(SET_POWERUP) and c:IsSpellTrap()) or c:IsCode(04909946) and c:IsSSetable() end,tp,LOCATION_DECK,0,1,nil)
    local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=2
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
    e:SetLabel(sel)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local sel=e:GetLabel()
    if sel==1 then
        --ATK up

        local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) end,tp,LOCATION_MZONE,0,e:GetHandler())
        for tc in g:Iter() do
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(1200)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    elseif sel==2 then
        --Set Powerup / Boss on Parade
        local g=Duel.GetMatchingGroup(function(c) return (c:IsSetCard(SET_POWERUP) and c:IsSpellTrap()) or c:IsCode(04909946) and c:IsSSetable() end,tp,LOCATION_DECK,0,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local sg=g:Select(tp,1,1,nil)
            Duel.SSet(tp,sg)
            if sg:GetFirst():IsType(TYPE_TRAP) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sg:GetFirst():RegisterEffect(e1)
            elseif sg:GetFirst():IsType(TYPE_SPELL) and sg:GetFirst():IsType(TYPE_QUICKPLAY) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
                e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sg:GetFirst():RegisterEffect(e1)
            end
        end
    end
end