--Kozmo Insidious Warlock
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    c:SetUniqueOnField(1,0,id)


    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1174)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Link.Condition(s.matfilter,3,3,specialchk))
	e1:SetTarget(Link.Target(s.matfilter,3,3,specialchk))
	e1:SetOperation(s.linkoperation(s.matfilter,3,3,specialchk))
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



    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e4:SetValue(1)
    c:RegisterEffect(e4)


    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_CONTROL)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e5:SetTarget(s.cttg)
    e5:SetCost(s.discost)
	e5:SetOperation(s.ctop)
	c:RegisterEffect(e5)

end

function s.spfilter(c)
	return c:IsSetCard(0xd2) and c:IsAbleToRemoveAsCost()
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        Duel.GetControl(tc,tp) 
        if tc:IsControler(1-tp) then return end
        --Target becomes a Psychic monster
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_RACE)
        e2:SetValue(RACE_PSYCHIC)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e2)

        local e3=e2:Clone()
        e3:SetDescription(aux.Stringid(id, 1))
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetValue(0xd2)
        tc:RegisterEffect(e3)

    end
end

function s.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC) and c:IsSetCard(0xd2)
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(s.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end


function s.machinefilter(c)
    return c:IsRace(RACE_MACHINE) and c:IsSetCard(0xd2)
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




function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.machinefilter, e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 3,nil)
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



function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0xd2,scard,sumtype,tp)
end