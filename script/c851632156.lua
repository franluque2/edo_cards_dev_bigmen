--Spiderite Tutor
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return (c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)


end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}


function s.cfilter(c,tp)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_HAND,LOCATION_MZONE,c)
	return #g>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end

function s.tdfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1) and sg:FilterCount(s.tdfilter, nil,tp)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_HAND,LOCATION_MZONE,c)
	local g=aux.SelectUnselectGroup(sg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE,s.rescon)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end



function s.filter(c)
	return c:IsSetCard(SET_SPIDERITE) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil)
            and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0
         end

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not (c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,2,2,nil)
	for tc in g:Iter() do
        Duel.SSet(tp,tc)
        if Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) then
            if tc1:IsType(TYPE_TRAP) then
                local e2=Effect.CreateEffect(e:GetHandler())
                e2:SetDescription(aux.Stringid(id,3))
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e2:SetReset(RESET_EVENT|RESETS_STANDARD)
                tc1:RegisterEffect(e2)
            end
            
            if tc1:IsQuickPlaySpell() then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetDescription(aux.Stringid(id,3))
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
                e1:SetReset(RESET_EVENT|RESETS_STANDARD)
                tc1:RegisterEffect(e1)
                end
        end
    end
end