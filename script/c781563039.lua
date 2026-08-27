--Princess of Frogs
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

            local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownop)
    c:RegisterEffect(e3)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local TADPOLE=10456559
local TOADALLY_AWESOME=90809975
local DESFROG=84451804

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)


    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 09126351)
	if #g1 > 0 then
		Duel.MoveToDeckTop(g1:GetFirst())
	end
end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end
function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)

    --each time a frog card(s) is sent to your GY, place 1 TADPOLE in your GY from Outside the Duel
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.tadpolecon)
    e2:SetOperation(s.tadpoleop)
    Duel.RegisterEffect(e2, tp)

    --TADPOLE in your GY gain the following effect

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetTargetRange(LOCATION_GRAVE,0)
    e4:SetTarget(function(_,c) return c:IsCode(TADPOLE) end)
    e4:SetLabelObject(e3)
    Duel.RegisterEffect(e4,tp)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.cfilter(c)
	return c:IsCode(TADPOLE) and c:IsAbleToRemoveAsCost()
end
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(SET_FROG) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end

function s.sfilter(c,e,tp,lv)
	return c:IsSetCard(SET_FROG) and c:GetLevel()==lv and c:IsAbleToHand()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk, chkc)
	local c=e:GetHandler()
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
		return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,#cg)
	end

	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,#cg)
	local lvt={}
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		local tlv=0
		tlv=tlv+tc:GetLevel()
		lvt[tlv]=tlv
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	local rg1=Group.CreateGroup()
	if lv>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg2=cg:Select(tp,lv-1,lv-1,c)
		rg1:Merge(rg2)
	end
	rg1:AddCard(c)
	Duel.Remove(rg1,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,#rg1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	if tc and Duel.SendtoHand(tc, tp, REASON_EFFECT) then
        if tc:IsLevel(5) and Card.IsSummonable(tc, true, e) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Summon(tp,tc,true,nil)
		end 
	end
end

function s.toadfilter(c)
    return c:IsCode(TOADALLY_AWESOME) and c:GetFlagEffect(id)==0
end

function s.dtsfrogfilter(c)
    return c:IsCode(09910360) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetMatchingGroupCount(s.toadfilter,tp,LOCATION_EXTRA,0,nil)>0) or (Duel.GetMatchingGroupCount(s.dtsfrogfilter,tp,LOCATION_EXTRA,0,nil)>0)
end

local oldfunc=Card.IsRank

function Card.IsRank(c, r)
    if c:IsOriginalCode(TOADALLY_AWESOME) and r==5 and c:GetFlagEffect(id) then return true end
    if c:IsOriginalCode(TOADALLY_AWESOME) and r~=5 and c:GetFlagEffect(id) then return false end
    return oldfunc(c, r)
end
function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.toadfilter,tp,LOCATION_EXTRA,0,nil)
    for tc in g1:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RANK)
        e1:SetRange(LOCATION_ALL)
        e1:SetValue(5)
        tc:RegisterEffect(e1)

        local effs={tc:GetOwnEffects()}

        for _,eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_SPSUMMON_PROC then
                eff:Reset()
            end
        end

	    Xyz.AddProcedure(tc,s.xyzfilter,nil,2,nil,nil,nil,nil,false)

        tc:RegisterFlagEffect(id,0,0,1)
    end

    local g2=Duel.GetMatchingGroup(s.dtsfrogfilter,tp,LOCATION_EXTRA,0,nil)
    for tc in g2:Iter() do
	    Fusion.AddContactProc(tc,s.contactfil,s.contactop,nil,nil,nil,nil,false)

        tc:RegisterFlagEffect(id,0,0,1)
    end
end

function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
end

function s.xyzfilter(c,xyz,sumtype,tp)
	return c:HasLevel() and c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_WATER,xyz,sumtype,tp)
end

function s.tadpolecon(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsSetCard,nil,SET_FROG)
    return #g>0 and g:IsExists(Card.IsControler, 1, nil, tp)
end

function s.tadpoleop(e,tp,eg,ep,ev,re,r,rp)
    local token=Duel.CreateToken(tp, TADPOLE)
    Duel.SendtoGrave(token, REASON_RULE)
end