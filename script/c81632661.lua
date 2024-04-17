--Double Check (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    --Draw 1 card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
    e4:SetCost(aux.bfgcost)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return (tc and tc:IsControler(tp) and tc:IsCode(14152862, 41147577) and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil) and Duel.GetTurnPlayer()~=tp
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttacker()
    if tc:IsControler(tp) then tc=Duel.GetAttackTarget() end
    if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return ep==tp and (code1==16227556 or code2==16227556)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local dg=sg:RandomSelect(tp,1)
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end