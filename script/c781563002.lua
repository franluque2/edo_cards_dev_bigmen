--Court of the Card King
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
        local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownopextra)
    c:RegisterEffect(e3)

	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		nil, nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

	aux.GlobalCheck(s, function()
		s.used_this_skill = {}
		s.used_this_skill[0] = false
		s.used_this_skill[1] = false
		aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false
		end)
	end)


end
s.listed_names={CARD_JACK_KNIGHT,CARD_QUEEN_KNIGHT,CARD_KING_KNIGHT}


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()
	s.rewritecards(e)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetOperation(s.shuffledownop)
    e1:SetCountLimit(1)
    Duel.RegisterEffect(e1, tp)


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.operation)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetLabelObject(e2)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.targetfunc)
    Duel.RegisterEffect(e3, tp)

--CARD_SLIFER
-- The triggered effect of "Slifer the Sky Dragon" can only destroy monster(s) once per turn.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1)
	e4:SetCondition(s.slifercon)
	e4:SetOperation(s.sliferop)
	Duel.RegisterEffect(e4, tp)
end

local oldfunc=Duel.Draw

Duel.Draw=function(tp,num,reason)
    if Duel.GetFlagEffect(tp, id)>0 then
        s.shuffledownop(nil, tp)
    end
    return oldfunc(tp,num,reason)
end

function s.cardfilter(c,tp)
    return c:IsCode(CARD_JACK_KNIGHT, CARD_QUEEN_KNIGHT, CARD_KING_KNIGHT) and c:GetSequence()>=(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-(10))
end

function s.shuffledownopextra(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil,81945678)
    if #g > 0 then
		Duel.MoveToDeckTop(g:GetFirst())
    end
	s.shuffledownop(e, tp)
end


function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil,tp)
    if #g==Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) then return end
    if #g > 0 then
		Duel.MoveToDeckBottom(g)
    end
end

function s.rewritecards(e)
	local g=Duel.GetMatchingGroup(s.repfilter2, e:GetHandlerPlayer(), LOCATION_ALL, 0, nil)
	for tc in g:Iter() do
		local effs = { tc:GetOwnEffects() }
		for _, eff in ipairs(effs) do
			if eff:IsHasType(EFFECT_TYPE_IGNITION|EFFECT_TYPE_QUICK_O|EFFECT_TYPE_TRIGGER_O|EFFECT_TYPE_QUICK_F|EFFECT_TYPE_TRIGGER_F) and (eff:GetCost()~=nil) then
				local neweff=eff:Clone()
				--(4) OPT If you would pay a cost, to activate the effect of a LIGHT Warrior monster, you can send 1 Fusion Monster from your Extra Deck to the GY, instead.

				neweff:SetCost(s.repcostfunc(eff:GetCost()))
				eff:Reset()
				tc:RegisterEffect(neweff)

			end
		end
	end
end

function s.repcostfunc(cost)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return cost(e,tp,eg,ep,ev,re,r,rp,0) or (Duel.IsExistingMatchingCard(s.fusfilter, e:GetHandlerPlayer(), LOCATION_EXTRA, 0, 1, nil) and s.used_this_skill[tp]==false and Duel.GetFlagEffect(tp, id)>0) end
			if not s.used_this_skill[tp] and Duel.IsExistingMatchingCard(s.fusfilter, e:GetHandlerPlayer(), LOCATION_EXTRA, 0, 1, nil) and e:GetHandler():IsOriginalRace(RACE_WARRIOR)
			 and e:GetHandler():IsOriginalAttribute(ATTRIBUTE_LIGHT)  and (not cost or not cost(e,tp,eg,ep,ev,re,r,rp,0)
			 or Duel.SelectYesNo(tp, aux.Stringid(id, 0))) then
			Duel.Hint(HINT_CARD,tp,id)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			Duel.SendtoGrave(g,REASON_COST)
			s.used_this_skill[tp]=true
			if e:GetHandler():IsOriginalCode(93880808) then
				e:SetLabel(g:GetFirst():GetMainCardType())
			elseif e:GetHandler():IsOriginalCode(29284413) then
				e:SetLabel(g:GetFirst():GetCode())
			end

		else
			cost(e,tp,eg,ep,ev,re,r,rp,1)
		end


	end
end

function s.repfilter2(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_EFFECT)
end


function s.targetfunc(e,c)
    return c:IsFaceup() and c:IsLevel(10) and c:HasLevel() and c:GetTextAttack()==-2
end

function s.filter(c)
	return c:IsMonster() and c:IsType(TYPE_FUSION)
end


function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.filter, tp, LOCATION_GRAVE, 0, nil)
	g:Remove(s.codefilterchk,nil,e:GetHandler())
	if c:IsFacedown() or #g<=0 then return end
	repeat
		local tc=g:GetFirst()
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
		c:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)
		local e0=Effect.CreateEffect(c)
		e0:SetCode(id)
		e0:SetLabel(code)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e0,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetLabel(cid)
		e1:SetLabelObject(e0)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(s.resetop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		g:Remove(s.codefilter,nil,code)
	until #g<=0
end
function s.codefilter(c,code)
	return c:IsOriginalCode(code)
end
function s.codefilterchk(c,sc)
	return sc:GetFlagEffect(c:GetOriginalCode())>0
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local mats=e:GetHandler():GetOverlayGroup()
	local g=Group.Filter(mats, s.filter, nil)
	if not g:IsExists(s.codefilter,1,nil,e:GetLabelObject():GetLabel()) or c:IsDisabled() then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		c:ResetFlagEffect(e:GetLabelObject():GetLabel())
	end
end


function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fusfilter, e:GetHandlerPlayer(), LOCATION_EXTRA, 0, 1, nil)
end

function s.fusfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost() and c:IsType(TYPE_FUSION)
end

function s.repval(base,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return c:IsRace(RACE_WARRIOR) and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.repop(base,extracon,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.desfilter(c, re)
	return re and re:IsHasType(EFFECT_TYPE_TRIGGER_F) and re:GetHandler():IsCode(CARD_SLIFER)
end

function s.slifercon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter, 1, nil, re)
end

function s.sliferop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
	e1:SetValue(function(e,re,rp) return re:IsMonsterEffect() and re:GetHandler():IsCode(CARD_SLIFER) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1, tp)
end