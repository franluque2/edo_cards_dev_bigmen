--Guile of the Trickster God
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local runickbanishingquickplays={20618850,30430448,31562086,66712905,67835547,68957034,93229151,94445733}
local runickqpbanishmap = {}
runickqpbanishmap[20618850] = 4
runickqpbanishmap[30430448] = 3
runickqpbanishmap[31562086] = 1
runickqpbanishmap[66712905] = 2
runickqpbanishmap[67835547] = 3
runickqpbanishmap[68957034] = 2
runickqpbanishmap[93229151] = function (tp) return Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_ONFIELD,nil) end
runickqpbanishmap[94445733] = 4

local CARD_LOKI=67098114
function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


    --Level 3 and lower "Runick" monsters in your possession are always treated as "Nordic Alfar" tuner monsters.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetTargetRange(LOCATION_ALL,0)
    e1:SetTarget(s.lowlevelrunickfilter)
    e1:SetValue(TYPE_TUNER)
    Duel.RegisterEffect(e1, tp)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_ADD_SETCODE)
    e2:SetValue(SET_NORDIC_ALFAR)
    Duel.RegisterEffect(e2, tp)


    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetCondition(s.rewriteksipcon)
    e3:SetOperation(s.rewriteskipop)
    Duel.RegisterEffect(e3, tp)



    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
    Duel.RegisterEffect(e4, tp)
	--check
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetOperation(s.checkop)
	e5:SetLabelObject(e4)
    Duel.RegisterEffect(e5, tp)


    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetTarget(s.lokifilter)
    e6:SetCondition(function(e) return Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), id) and Duel.IsBattlePhase() and Duel.IsTurnPlayer(e:GetHandlerPlayer()) end)
	e6:SetValue(s.value)
	Duel.RegisterEffect(e6,tp)

       local e10=Effect.CreateEffect(e:GetHandler())
    e10:SetType(EFFECT_TYPE_FIELD)
    e10:SetCode(EFFECT_CANNOT_TRIGGER)
    e10:SetTargetRange(LOCATION_FZONE,0)
    e10:SetCondition(s.discon)
    e10:SetTarget(s.actfilter)
    Duel.RegisterEffect(e10, tp)


end

function s.lowlevelrunickfilter(e,c)
    return c:IsOriginalSetCard(SET_RUNICK) and c:IsMonster() and c:IsLevelBelow(3)
end

function s.discon(e)
	return (Duel.GetTurnPlayer() ~=e:GetHandlerPlayer())
end

function s.actfilter(e,c)
	return c:IsCode(92107604)
end


function s.lokifilter(e,c)
    return c:IsCode(CARD_LOKI) and c:IsFaceup()
end

function s.value(e,damp)
   if e:GetOwnerPlayer()~=damp then
		local val=Duel.GetBattleDamage(damp)
		if val>1 then
			if Duel.GetFlagEffect(damp, id-500)==0 then
			Duel.RegisterFlagEffect(damp, id-500, RESET_PHASE+PHASE_DAMAGE, 0, 0)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_ADJUST)
			e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
			e1:SetLabel(e:GetOwnerPlayer())
			e1:SetOperation(s.millop)
			Duel.RegisterEffect(e1,damp)
		end

		end

		return 0
	else
		return -1
	end
end


function s.millop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()
	if p then
		e:SetLabel(0)
        local tomillgroup = Duel.GetMatchingGroup(Card.IsCode, p, LOCATION_GRAVE, 0, nil,table.unpack(runickbanishingquickplays))
        local tomillnames=tomillgroup:GetClass(Card.GetCode)

        local millval=0
        for _,code in ipairs(tomillnames) do
            local val = runickqpbanishmap[code]
            if type(val)=="function" then
                millval=millval+val(1-p)
            else
                millval=millval+val
            end
        end
        if millval>0 then
            Duel.Hint(HINT_CARD, p, id)
            Duel.DiscardDeck(1-p, millval, REASON_EFFECT)
        end
		e:Reset()

	end
end




Duel.Remove = (function()
    local oldfunc = Duel.Remove
    return function(g, pos, reason,...)
        local res
        if g and type(g)=="Group" then
        if (g:GetFirst():GetLocation()&LOCATION_DECK~=0) and (Duel.GetFlagEffect(1 - g:GetFirst():GetControler(), id) > 0) then
            local rescard = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_EFFECT)
            if rescard:GetHandler():IsSetCard(0x180) then
                local g2=Group.CreateGroup()
                res = oldfunc(g2, pos, reason,...)
            else
                res = oldfunc(g, pos, reason,...)
            end
        else
            res = oldfunc(g, pos, reason,...)
        end
    else
        if (g:GetLocation()&LOCATION_DECK~=0) and (Duel.GetFlagEffect(1 - g:GetControler(), id) > 0) then
            local rescard = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_EFFECT)
            if rescard:GetHandler():IsSetCard(0x180) then
                local g2=Group.CreateGroup()
                res = oldfunc(g2, pos, reason,...)
            else
                res = oldfunc(g, pos, reason,...)
            end
        else
            res = oldfunc(g, pos, reason,...)
        end
    end
        return res
    end
end)()


function s.rewriteksipcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc:IsSetCard(SET_RUNICK) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_QUICKPLAY)
end

function s.rewriteskipop(e,tp,eg,ep,ev,re,r,rp)
    local effs={Duel.GetPlayerEffect(tp,EFFECT_SKIP_BP)}
    for _,eff in ipairs(effs) do
        if eff:GetHandler():IsSetCard(SET_RUNICK) and eff:GetHandler():IsType(TYPE_QUICKPLAY) then
            eff:Reset()


            --until the end of your next battle phase, only 1 "Loki, lord of the aesir" you control can attack (and no other of your monsters) and it deals half damage
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetTargetRange(LOCATION_MZONE,0)
            e1:SetTarget(s.notlokifilter)
            if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
                e1:SetLabel(Duel.GetTurnCount())
                e1:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
                e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
            else
                e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
            end
            Duel.RegisterEffect(e1,tp)

            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetCode(id)
            e2:SetDescription(aux.Stringid(id, 0))
            e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e2:SetTargetRange(1,0)
            if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
                e2:SetLabel(Duel.GetTurnCount())
                e2:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
                e2:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
            else
                e2:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
            end
            Duel.RegisterEffect(e2,tp)

        end
    end
end

function s.notlokifilter(e,c)
    return not (c:IsCode(CARD_LOKI) and c:IsFaceup())
end


function s.atkcon(e)
	return (Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), id)) and Duel.GetFlagEffect(e:GetHandlerPlayer(), id+1)~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	Duel.RegisterFlagEffect(tp, id+1, RESETS_STANDARD_PHASE_END, 0, 1)
	e:GetLabelObject():SetLabel(fid)
end