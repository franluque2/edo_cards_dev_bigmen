--Welcoming Rites
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

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

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local c=e:GetHandler()

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_ADJUST)
        e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsExistingMatchingCard(s.optfilter, tp, LOCATION_MZONE, 0, 1, nil) end)
        e2:SetOperation(s.tptop)
		Duel.RegisterEffect(e2,tp)


        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
        e3:SetCondition(s.repcon)
		e3:SetOperation(s.doubop)
		Duel.RegisterEffect(e3,tp)
        local e4=e3:Clone()
        e4:SetCode(EVENT_SUMMON_SUCCESS)
        Duel.RegisterEffect(e4,tp)

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_CHANGE_DAMAGE)
        e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e5:SetTargetRange(0,1)
        e5:SetValue(s.damval)
        Duel.RegisterEffect(e5,tp)
        local e6=e5:Clone()
        e6:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        Duel.RegisterEffect(e6,tp)
    

    

	end
	e:SetLabel(1)
end

function s.damval(e,re,val,r,rp,rc)
	if rp==e:GetHandlerPlayer() and (r&REASON_EFFECT)~=0 then return 0
	else return val end
end

function s.sumfilter(c,tp)
    return c:GetFlagEffect(id+1)==0 and c:IsControler(tp)
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sumfilter, 1, nil, tp)
end


function s.doubop(e,tp,eg,ep,ev,re,r,rp)
    if not eg then return end
    if not eg:IsExists(s.sumfilter, 1, nil, tp) then return end
    local g=eg:Filter(s.sumfilter, nil, tp)
    for card in g:Iter() do

		card:RegisterFlagEffect(id+1,RESET_EVENT|RESET_PHASE|PHASE_END,0,1)
        s.resummonmonster(e,tp,eg,ep,ev,re,r,rp, card)
    end

end

Card.IsSummonType = (function()
	local oldfunc=Card.IsSummonType
    return function(c, summontype,...)
		if not (c and c:GetFlagEffect(id)>0) then return oldfunc(c, summontype,...) end
		if summontype|SUMMON_TYPE_TRIBUTE==SUMMON_TYPE_TRIBUTE then
			return true
		end
		return oldfunc(c, summontype,...)
	end
end)()



function s.resummonmonster(e,tp,eg,ep,ev,re,r,rp, eqc)
    if Card.GetSummonType(eqc)==SUMMON_TYPE_NORMAL then
        Duel.RaiseEvent(eqc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,eqc:GetControler(),ev)
	elseif Card.GetSummonType(eqc)==SUMMON_TYPE_TRIBUTE then
		eqc:RegisterFlagEffect(id, 0, 0, 0)
        Duel.RaiseEvent(eqc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,eqc:GetControler(),ev)
    elseif Card.GetSummonType(eqc)==SUMMON_TYPE_LINK then
        Duel.RaiseEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_LINK,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_LINK,tp,eqc:GetControler(),ev)
	elseif Card.GetSummonType(eqc)==SUMMON_TYPE_SYNCHRO then
        Duel.RaiseEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_SYNCHRO,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_SYNCHRO,tp,eqc:GetControler(),ev)
	elseif Card.GetSummonType(eqc)==SUMMON_TYPE_RITUAL then
        Duel.RaiseEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_RITUAL,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_RITUAL,tp,eqc:GetControler(),ev)
	elseif Card.GetSummonType(eqc)==SUMMON_TYPE_XYZ then
        Duel.RaiseEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_XYZ,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_XYZ,tp,eqc:GetControler(),ev)
	elseif Card.GetSummonType(eqc)==SUMMON_TYPE_FUSION then
        Duel.RaiseEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_FUSION,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_FUSION,tp,eqc:GetControler(),ev)
	else
        Duel.RaiseEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,eqc:GetControler(),ev)
        Duel.RaiseSingleEvent(eqc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,eqc:GetControler(),ev)
    end

end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local effs={rc:GetCardEffect()}

    if not (re:GetCode()==EVENT_SUMMON_SUCCESS or re:GetCode()==EVENT_SPSUMMON_SUCCESS) then return end
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
function s.tptop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.optfilter, tp, LOCATION_MZONE, 0, nil)
    for eqc in g:Iter() do
        
	for _,te in ipairs(OPTEffs[eqc]) do
		local chk=true
		for _,te2 in ipairs(AffectedEffs[eqc]) do
			if te2==te then chk=false end
		end
		if chk then
			local _,ctmax,ctcode,ctflag,hopt=te:GetCountLimit()
			if ctflag&EFFECT_COUNT_CODE_SINGLE>0 then
				te:SetCountLimit(ctmax+1,{ctcode,hopt},ctflag)
			else
				te:SetCountLimit(ctmax+1,{ctcode,hopt},ctflag)
			end
			table.insert(AffectedEffs[eqc],te)
		end
	end
end
end


function s.optfilter(c)
    return c:IsMonster() and c:GetFlagEffect(id)==1
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
