--Malefic Infinite Gear
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0xff~LOCATION_MZONE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetValue(SET_MALEFIC)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)


    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,{id,1})
    e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.gaintg)
	e4:SetOperation(s.gainop)
	c:RegisterEffect(e4)


end
s.listed_series={SET_MALEFIC}
s.listed_names={75223115} -- Malefic Territory

function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_MALEFIC,scard,sumtype,tp) and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
end

function s.filter(c)
    return c:IsSetCard(SET_MALEFIC)
end
function s.extraval(chk,summon_type,e,...)

	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc==e:GetHandler()) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end



function s.setfilter(c)
	return c:IsCode(75223115) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end


function s.gainfilter(c,firsttar)
	return c:IsSetCard(SET_MALEFIC) and c:IsMonster() and c:IsLevelAbove(7) and c:ListsCode(firsttar:GetCode())
end
function s.putbackfilter(c,tp)
	return c:IsAbleToDeck() and Duel.IsExistingTarget(s.gainfilter, tp, LOCATION_MZONE, 0, 1, nil, c)
end
function s.gaintg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.putbackfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.putbackfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectTarget(tp,s.gainfilter,tp,LOCATION_MZONE,0,1,1,nil,g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	Duel.SetOperationInfo(0,0,g2,1,0,0)
end
function s.gainop(e,tp,eg,ep,ev,re,r,rp)
	local _,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	local _,g2=Duel.GetOperationInfo(0,0)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	if tc1:IsRelateToEffect(e) and Duel.SendtoDeck(tc1, tp, SEQ_DECKSHUFFLE, REASON_EFFECT) and tc2:IsRelateToEffect(e) then
        local effsog={tc2:GetOwnEffects()}
        for _,eff in ipairs(effsog) do
            Effect.Reset(eff)
        end
        if tc1:IsType(TYPE_EFFECT) then
            local effsnew={tc1:GetOwnEffects()}
            for _,eff in ipairs(effsnew) do
                local e1=eff:Clone()
                tc2:RegisterEffect(e1)
            end
            tc2:RegisterFlagEffect(0,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))

        else
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_IMMUNE_EFFECT)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetRange(LOCATION_MZONE)
            e2:SetValue(s.efilter)
            tc2:RegisterEffect(e2)
            tc2:RegisterFlagEffect(0,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
        end
	end
end

function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(SET_MALEFIC)
end