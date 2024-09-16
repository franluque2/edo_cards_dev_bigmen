--Razieltomate auf Friesla
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    --flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)

	local e2=WbAux.CreateFrieslaFlipEffect(c,s.adtar,s.adop,CATEGORY_TOHAND+CATEGORY_SEARCH)
    c:RegisterEffect(e2)


	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(function(e) return e:GetHandler():IsCode(30243636) and aux.bdocon end)
	e4:SetTarget(s.atchtg)
	e4:SetOperation(s.atchop)
	c:RegisterEffect(e4)

end
s.listed_names={30243636}

function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc:IsMonster() and bc:IsFaceup()
		and bc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) end
	Duel.SetTargetCard(bc)
	if bc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,tp,0)
	end
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and bc:IsRelateToEffect(e)
		and bc:IsMonster() and bc:IsFaceup() then
		Duel.Overlay(c,bc,true)
	end
end



function s.addfilter(c)
	return c:IsCode(30243636,CARD_FRIESLA_BIERGARTEN) and c:IsAbleToHand()
end
function s.adtar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        Duel.SendtoHand(g, tp,  REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
    local e1=WbAux.CreateFrieslaAttachEffect(c)
    Duel.RegisterEffect(e1, tp)
end