--Mystical Spirit of Mirrors
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2)


    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.cpcon)
	e1:SetOperation(s.cpop)
    e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

    aux.GlobalCheck(s,function()
		s.eff_list={}
		s.eff_list[0]={}
		s.eff_list[1]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE+PHASE_END)
		ge1:SetCountLimit(1)
		ge1:SetCondition(s.resetop)
		Duel.RegisterEffect(ge1,0)

        local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_SOLVING)
		ge2:SetOperation(s.checkop)
		Duel.RegisterEffect(ge2,0)
	end)
end

Duel.RegisterEffect=(function()
	local oldfunc=Duel.RegisterEffect
	return function(e, player)
		local res=oldfunc(e, player)
        local rc=e:GetHandler()
        if rc and rc:GetFlagEffect(id)>0 then
            table.insert(s.eff_list[player], e)
        end
		return res
	end
end)()


function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return #s.eff_list[1-tp]>0
end

function s.cpop(e,tp,eg,ep,ev,re,r,rp)

    local totaleffs={}
    for _,eff in ipairs(s.eff_list[1-tp]) do
        if not eff:IsDeleted() then
            local reset=eff:GetReset()
            if not reset or reset&RESET_CHAIN==0 then
                local neweff=eff:Clone()
                table.insert(totaleffs,neweff)
            end
        end
    end

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(s.cpcon1)
	e1:SetOperation(s.cpop1)
    e1:SetLabelObject(totaleffs)
	if Duel.IsTurnPlayer(tp) then
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end

function s.cpcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()
end

function s.cpop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)

    local totaleffs=e:GetLabelObject()
    if #totaleffs>0 then
        for _,eff in ipairs(totaleffs) do
            if not eff:IsDeleted() then
                Duel.RegisterEffect(eff, tp)
            end
        end
    end
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
    local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsMonsterEffect() and trig_loc==LOCATION_HAND then
		rc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	end
end

function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.eff_list[0]={}
	s.eff_list[1]={}
	return false
end