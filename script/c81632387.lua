--Super Fusion God (CT)
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,12)

    --must be summoned with super poly
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.fuslimit)
	c:RegisterEffect(e1)

    --add spoly to hand
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.acon)
	e3:SetTarget(s.atg)
	e3:SetOperation(s.aop)
	c:RegisterEffect(e3)

    --cannot be target, cannot be tributed
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.immcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)

    local e4=e2:Clone()
    e4:SetCode(EFFECT_UNRELEASABLE_SUM)
    c:RegisterEffect(e4)

    --destroy replace
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.desreptg)
	c:RegisterEffect(e5)

    --copy
	local e6 = Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetDescription(aux.Stringid(id, 1))
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_ADJUST)
	e6:SetCondition(s.cpcon)
	e6:SetTarget(s.cptg)
	e6:SetOperation(s.cpop)
	c:RegisterEffect(e6)
end

s.name_list_sfg={}
s.name_list_sfg[0]={}
s.name_list_sfg[1]={}

function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.name_list_sfg[0]={}
	s.name_list_sfg[1]={}
	return false
end

if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end

function s.inffilter(c,tp)
	return c:IsMonster() and not table.includes(s.name_list_sfg[tp],c:GetOriginalCode()) and c:IsAbleToRemove()
end

function s.cpcon(e, tp, eg, ep, ev, re, r, rp, chk)
	return Duel.IsExistingMatchingCard(s.inffilter, tp, LOCATION_GRAVE, 0, 2, nil, tp)
end
function s.cptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return true
	end
	local bc = Duel.SelectMatchingCard(tp, s.inffilter, tp, LOCATION_GRAVE, 0, 2, 2, nil,tp)
	Duel.SetTargetCard(bc)
end

function s.cpop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id, 2))
    local tg1=tc:Select(tp,1,1,false,nil):GetFirst()
    local tg2=tc:GetFirst()
    if tg2==tg1 then
        tg2=tc:GetNext()
    end

	if tg1 and tg2 and e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():CopyEffect(tg2:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD, 1)
		table.insert(s.name_list_sfg[tp],tg2:GetOriginalCode())
        table.insert(s.name_list_sfg[tp],tg1:GetOriginalCode())

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tg1:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e:GetHandler():RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        e2:SetValue(tg2:GetDefense())
        e:GetHandler():RegisterEffect(e2)



        Duel.BreakEffect()
        Duel.Remove(tg1, POS_FACEUP, REASON_EFFECT)
        Duel.Remove(tg2, POS_FACEUP, REASON_EFFECT)

	end
end

function s.repfilter(c)
	return c:IsCode(48130397) and c:IsAbleToRemove()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
	return not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,c) end
	
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
    local g=Duel.GetFirstMatchingCard(s.repfilter, tp, LOCATION_GRAVE, 0, nil,c)
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    return true
end


function s.immcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,48130397)
end

function s.acon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.aop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_REMOVED, 0, 1, nil, 48130397) then
		local spoly=Duel.GetFirstMatchingCard(Card.IsCode, tp, LOCATION_REMOVED, 0, nil, 48130397)
		Duel.SendtoHand(spoly, tp, REASON_EFFECT)
	end
end

function s.fuslimit(e,se,sp,st)
	if (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION then
		return se:GetHandler():IsCode(48130397)
	end
	return true
end

function s.ffilter(c,fc,sumtype,sump,sub,matg,sg)
	return c:IsLevelBelow(12) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or (not sg:IsExists(s.fusfilter,1,c,c:GetLevel())))
end

function s.fusfilter(c,lv)
	return c:IsLevel(lv)
end