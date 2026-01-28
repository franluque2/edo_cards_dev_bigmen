--Emiya, Fated Hero
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,881564003,881564001)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,s.spcon)

    c:SetSPSummonOnce(id)

    local e001=Effect.CreateEffect(c)
	e001:SetType(EFFECT_TYPE_SINGLE)
	e001:SetCode(EFFECT_CAN_ALWAYS_SPECIAL_SUMMON)
	e001:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e001)

	aux.GlobalCheck(s,function()
		--register
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_STARTUP)
		ge1:SetOperation(s.regop)
		ge1:SetCountLimit(1)
		Duel.RegisterEffect(ge1,0)
		s.cardstoconjure={}
	end)


	--Once per Chain (Quick Effect) you can pay half your LP, then remove from the duel a third of the other cards in your possession, and declare the card name of 1 card that started the duel in either player's Deck; add a copy of the declared card from Outside the Duel to your hand. You can only use this effect of "Emiya, Fated Hero" thrice per turn.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCategory(CATEGORY_CONJURE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e5:SetCost(s.cost)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)

	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsCode(CARD_FATED_CHANT)) end)


end
s.listed_names={CARD_FATED_CHANT}

function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.spcon(tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>=3
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end

function s.regop(e)
	local g=Duel.GetMatchingGroup(aux.TRUE,0,LOCATION_DECK+LOCATION_HAND,LOCATION_DECK+LOCATION_HAND,0)
	local seen = {}
	for card in g:Iter() do
		local code = card:GetOriginalCode()
		if not seen[code] then
			table.insert(s.cardstoconjure, code)
			seen[code] = true
		end
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local toerase=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_DECK|LOCATION_EXTRA|LOCATION_REMOVED,0,e:GetHandler())
	if chk==0 then return #toerase>0 and Duel.GetFlagEffect(tp, id)<3 end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)
	local numtoerase=math.ceil(#toerase/3)
	if numtoerase>0 then
		local g2=toerase:RandomSelect(tp, numtoerase)
		Duel.RemoveCards(g2)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local announceFilter={}
	for _,name in pairs(s.cardstoconjure) do
		if #announceFilter==0 then
			table.insert(announceFilter,name)
			table.insert(announceFilter,OPCODE_ISCODE)
		else
			table.insert(announceFilter,name)
			table.insert(announceFilter,OPCODE_ISCODE)
			table.insert(announceFilter,OPCODE_OR)
		end
	end
	local ac=Duel.AnnounceCard(tp,table.unpack(announceFilter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end



function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	local conjuredCard=Duel.CreateToken(tp, ac)
	Duel.SendtoHand(conjuredCard, tp, REASON_EFFECT)
	Duel.ConfirmCards(1-tp, conjuredCard)
end