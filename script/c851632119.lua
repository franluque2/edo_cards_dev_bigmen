--Mokey Mokey Emperor
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    c:EnableReviveLimit()
	--Link Summon Procedure

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1174)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Link.Condition(aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),2,3,s.matcheck))
	e1:SetTarget(Link.Target(aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),2,3,s.matcheck))
	e1:SetOperation(s.linkoperation(aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),2,3,s.matcheck))
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)



    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(1,0)
    e2:SetCondition(s.spcon)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)


    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)



    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.tgtg)
	e3:SetValue(3000)
	c:RegisterEffect(e3)


    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.dtrcon)
	e5:SetOperation(s.dtrop)
	c:RegisterEffect(e5)


    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetOperation(s.winop)
	c:RegisterEffect(e6)



    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)


end
s.counter_place_list={0x1655}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp then return end
    local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
        if tc:GetPreviousLocation()==LOCATION_EXTRA then
            Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE|PHASE_END|RESET_OPPO_TURN,0,1)
            return
        end
	end
end

function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end


function s.linkoperation(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
				local g,filt,emt=table.unpack(e:GetLabelObject())
				for _,ex in ipairs(filt) do
					if ex[3]:GetValue() then
						ex[3]:GetValue()(1,SUMMON_TYPE_LINK,ex[3],ex[1]&g,c,tp)
						if ex[3]:CheckCountLimit(tp) then
							ex[3]:UseCountLimit(tp,1)
						end
					end
				end
				c:SetMaterial(g)
                local torem=Group.Filter(g, Card.IsLocation, nil, LOCATION_GRAVE)

				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)

                Duel.Remove(torem, POS_FACEUP, REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
				aux.DeleteExtraMaterialGroups(emt)
			end
end


function s.spcon(e)
	return Duel.GetFlagEffect(1-e:GetHandlerPlayer(),id)>=3
end


function s.extraval(chk,summon_type,e,...)

	if chk==0 then

		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc==e:GetHandler()) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(Card.IsAbletoRemoveAsCost,tp,LOCATION_GRAVE,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end


function s.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsType(TYPE_NORMAL)
end


function s.dtrcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsType(TYPE_NORMAL) or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsType(TYPE_NORMAL))
end
function s.dtrop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,0)
    e:GetHandler():AddCounter(0x1655,1)
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(0x1655)>=5 then
		Duel.Win(tp,0x2681)
	end
end



function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CHAOS) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local king=Duel.CreateToken(tp, 13803864)
    Duel.SpecialSummon(king, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
    Card.CompleteProcedure(king)
end