--Viviane, Guardian of Avalon
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(s.mfilter),2,2,s.lcheck)
	c:EnableReviveLimit()


    	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
    e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(aux.TargetBoolFunction(s.nonwarrfilter))
	c:RegisterEffect(e2)

	
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_TOHAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_EQUIP)
    e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.regcon)
    e3:SetTarget(s.regtg)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)

    aux.GlobalCheck(s,function()
        OPTEffs={}
        AffectedEffs={}
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAINING)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=Effect.CreateEffect(c)
        ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge2:SetCode(EVENT_ADJUST)
        ge2:SetCountLimit(1)
        ge2:SetOperation(s.clear)
        Duel.RegisterEffect(ge2,0)
    end)


end
s.listed_series={0x107a,0x207a}

function s.clear(e,tp,eg,ep,ev,re,r,rp)
	OPTEffs={}
	for _,c in pairs(AffectedEffs) do
		for _,te in ipairs(c) do
			local _,_,ctcode,ctflag,hopt=te:GetCountLimit()
			if ctflag&EFFECT_COUNT_CODE_SINGLE>0 then
				te:SetCountLimit(1,{ctcode,hopt},ctflag)
			end
		end
	end
	AffectedEffs={}
end


function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local effs={rc:GetCardEffect()}

	local _,ctmax,_,ctflag=re:GetCountLimit()
	if ctflag&~EFFECT_COUNT_CODE_SINGLE>0 or ctmax~=1 then return end
	if rc:GetFlagEffect(id)==0 then
		OPTEffs[rc]={}
		AffectedEffs[rc]={}
		rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	end
	for _,te in ipairs(OPTEffs[rc]) do
		if te==re then return end
	end
	table.insert(OPTEffs[rc],re)
	if ctflag&EFFECT_COUNT_CODE_SINGLE>0 then
		for _,eff in ipairs(effs) do
			local te=eff:GetLabelObject()
			if te:GetCode()&511001822==511001822 or te:GetLabel()==511001822 then te=te:GetLabelObject() end
			local _,_,_,ctlflag=te:GetCountLimit()
			if ctlflag&EFFECT_COUNT_CODE_SINGLE>0 then
				local chk=true
				for _,te2 in ipairs(OPTEffs[rc]) do
					if te==te2 then chk=false end
				end
				if chk then
					table.insert(OPTEffs[rc],te)
				end
			end
		end
	end
end


function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.HintSelection(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,g:GetFirst():GetLocation())
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and  tc:IsRelateToEffect(e) and Duel.SendtoHand(tc, tp, REASON_EFFECT) then


        Duel.ConfirmCards(1-tp, tc)

        for _,te in ipairs(OPTEffs[tc]) do
            local chk=true
            for _,te2 in ipairs(AffectedEffs[tc]) do
                if te2==te then chk=false end
            end
            if chk then
                local _,ctmax,ctcode,ctflag,hopt=te:GetCountLimit()
                if ctflag&EFFECT_COUNT_CODE_SINGLE>0 then
                    te:SetCountLimit(ctmax+1,{ctcode,hopt},ctflag)
                else
                    te:SetCountLimit(ctmax+1,{ctcode,hopt},ctflag)
                end
                table.insert(AffectedEffs[tc],te)
            end
        end
    
    
    end
end



function s.cfilter(c,tc)
    local g=c:GetEquipTarget()
	local lg=g:GetLinkedGroup()

	return lg:IsContains(tc) or tc:GetLinkedGroup():IsContains(g)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e:GetHandler())
end

function s.nonwarrfilter(c)
    return not c:IsRace(RACE_WARRIOR)
end
function s.mfilter(c,lc,sumtype,tp)
    return c:IsRace(RACE_AQUA+RACE_SPELLCASTER+RACE_WARRIOR,lc,sumtype,tp)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0x107a,lc,sumtype,tp)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
	return (c:ListsArchetype(0x107a,0x207a)) and c:IsMonster() and c:IsAbleToHand() and not c:IsRace(RACE_WARRIOR)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end