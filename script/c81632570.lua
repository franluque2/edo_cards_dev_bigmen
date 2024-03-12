--Service Ace (CT)
local s,id=GetID()
function s.initial_effect(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
    --recover
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(s.thcost)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetTargetCard(g)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
		local op=Duel.SelectOption(1-tp,70,71,72)
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
		if (op~=0 and tc:IsMonster()) or (op~=1 and tc:IsSpell()) or (op~=2 and tc:IsTrap()) then
			Duel.Damage(1-tp,1500,REASON_EFFECT)
		end
        if (op~=4 and tc:IsCode(92595545, 84813516, 21817254, 39552864)) then
            Duel.Damage(1-tp,500,REASON_EFFECT)
        end
        Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end

function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()==nil and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511000644), c:GetControler(), LOCATION_MZONE, 0, 1,nil)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
    Duel.SendtoDeck(e:GetHandler(), tp, SEQ_DECKBOTTOM, REASON_COST)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_DECK) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end