--Doodlebook - Creation!
local s,id=GetID()
function s.initial_effect(c)
    local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_DOODLE_BEAST),nil,nil)
	c:RegisterEffect(e1)


    --Banish, then add something to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tdcon)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	
end
s.listed_series={SET_DOODLE_BEAST}

function s.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_DOODLE_BEAST) and c:IsControler(tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and rp~=tp and not eg:IsContains(e:GetHandler())
end
function s.availablefusionmaterial(c,fus)
    return c:IsMonster() and c:IsCode(table.unpack(fus.material)) and c:IsAbleToHand() and (c:GetReason()&0x40008)==0x40008
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    local fusions=eg:Filter(s.cfilter, nil, tp)
    for fus in fusions:Iter() do
        local g2=Duel.GetMatchingGroup(s.availablefusionmaterial, tp, LOCATION_GRAVE|LOCATION_REMOVED, 0, nil, fus)
        g:Merge(g2)
    end

	if chk==0 then return #g>0 end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)

    local tc=Group.Select(g,tp, 1,1,nil):GetFirst()
    Duel.SetTargetCard(tc)
    Duel.HintSelection(tc)

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    Duel.SendtoHand(tc, tp, REASON_EFFECT)
end
