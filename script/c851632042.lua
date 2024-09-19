--Charmethyst Archvist
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    --add
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
    aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_STARTUP)
		ge:SetOperation(s.setup)
		Duel.RegisterEffect(ge,0)
	end)
end

function s.setup(e,tp,eg,ep,ev,re,r,rp)
	for i = 0, 1, 1 do
        local totalmons=Duel.GetMatchingGroupCount(Card.IsType, i, LOCATION_DECK, 0, nil, TYPE_MONSTER)
        local totalspells=Duel.GetMatchingGroupCount(Card.IsType, i, LOCATION_DECK, 0, nil, TYPE_SPELL)
        local totaltraps=Duel.GetMatchingGroupCount(Card.IsType, i, LOCATION_DECK, 0, nil, TYPE_TRAP)

        if totalmons==totalspells and totalmons==totaltraps then
            Duel.RegisterFlagEffect(i, id, 0, 0, 0)
        end
    end
	e:Reset()
end


function s.monfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end
function s.spelfilter(c)
	return c:IsSpell() and c:IsAbleToHand()
end
function s.trapfilter(c)
	return c:IsTrap() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp, id)>0 and Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil) 
        and Duel.IsExistingMatchingCard(s.spelfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_DECK,0,1,nil)
     end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.ShuffleDeck(tp)
    local monster=Duel.GetFirstMatchingCard(s.monfilter, tp, LOCATION_DECK, 0, nil)
    local spell=Duel.GetFirstMatchingCard(s.spelfilter, tp, LOCATION_DECK, 0, nil)
    local trap=Duel.GetFirstMatchingCard(s.trapfilter, tp, LOCATION_DECK, 0, nil)

	local g=Group.FromCards(monster,spell,trap)

	if #g==3 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
