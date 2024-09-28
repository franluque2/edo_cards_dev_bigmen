--Cassieldill auf Friesla
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    --flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)

	local e2=WbAux.CreateFrieslaFlipEffect(c,s.drawtar,s.drawop,CATEGORY_DRAW)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(function(e) return e:GetHandler():IsCode(30243636) end)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	c:RegisterEffect(e3)

	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)


end
s.listed_names={30243636}

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp~=tp and e:GetHandler():CanAttack() and eg:IsExists(Card.IsCanBeBattleTarget, 1, e:GetHandler(),e:GetHandler()) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetHandler():CanAttack() and eg:IsExists(Card.IsCanBeBattleTarget, 1, e:GetHandler(),e:GetHandler())) then return end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACKTARGET)
	local g=eg:Filter(Card.IsCanBeBattleTarget, e:GetHandler(), e:GetHandler())
	local tc=g:Select(tp, 1,1,nil)
	if tc then
		Duel.CalculateDamage(e:GetHandler(), tc:GetFirst())
	end
end


function s.tgfilter(c)
	return c:IsSetCard({SET_FRIESLA, SET_RECIPE}) and c:IsDiscardable()
end
function s.drawtar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,s.tgfilter,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end


function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
    local e1=WbAux.CreateFrieslaAttachEffect(c)
    Duel.RegisterEffect(e1, tp)
end