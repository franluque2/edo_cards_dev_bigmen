--Marked by the Monkey
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        aux.GlobalCheck(s, function()
        s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false

        aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false
		end)
    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, s.flipconactive, s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.addfilter(c,tc)
    return c:IsFaceup() and c:IsMonster() and ((not c:IsAttribute(tc:GetAttribute())) or (not c:IsRace(tc:GetRace())))
end

function s.banishfilter(c,tp)
    return c:IsMonster() and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_REMOVED, 0, 1, nil, c)
end

function s.faceupdarkbeastfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_DARK)
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (not s.used_this_skill[e:GetHandlerPlayer()]) and aux.CanActivateSkill(tp)
        and Duel.IsExistingMatchingCard(s.banishfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1, nil,tp)
        and Duel.IsExistingMatchingCard(s.faceupdarkbeastfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.banishfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1, 1, nil, tp)
    if #g > 0 then
        Duel.Remove(g, POS_FACEUP, REASON_COST)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g2 = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_REMOVED, 0, 1, 1, g:GetFirst(), g:GetFirst())
        if #g2 > 0 then
            Duel.SendtoHand(g2, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g2)
        end
    end

end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.cusillufilter(c)
    return c:IsCode(33537328) and c:GetFlagEffect(id)==0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.placecards(e,tp)


    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecusillucon)
    e1:SetOperation(s.rewritecusilluop)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetCondition(s.rewriteworldofspiritscon)
    e2:SetOperation(s.rewriteworldofspiritstop)
    Duel.RegisterEffect(e2,tp)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(2)
	Duel.RegisterEffect(e3,tp)

    --For a Synchro Summon, you can also use Link Monsters as material, treating them as DARK Tuner monsters with a level equal to their Link Rating.
    local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0a:SetCode(EFFECT_SYNCHRO_LEVEL)
	e0a:SetValue(function(_e,sc)
         return _e:GetHandler():GetLink() end)

    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e0b:SetTargetRange(LOCATION_MZONE,0)
    e0b:SetTarget(function(e,c) return c:IsLinkMonster() end)
    e0b:SetLabelObject(e0a)
    Duel.RegisterEffect(e0b,tp)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetCondition(s.rewritesynchroscon)
    e4:SetOperation(s.rewritesynchrosop)
    Duel.RegisterEffect(e4,tp)


    
        --grant effects to zeman
        local e5=Effect.CreateEffect(c)
        e5:SetDescription(aux.Stringid(id,4))
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetRange(LOCATION_MZONE)
        e5:SetTargetRange(0,LOCATION_MZONE)
        e5:SetCode(EFFECT_DISABLE)
        e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e5:SetTarget(s.zemanvictg)

        local e6=Effect.CreateEffect(c)
        e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e6:SetRange(LOCATION_MZONE)
        e6:SetTargetRange(LOCATION_MZONE,0)
        e6:SetTarget(function(e,c) return c:IsCode(22858242) end)
        e6:SetLabelObject(e5)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(c)
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetRange(LOCATION_MZONE)
        e7:SetTargetRange(0,LOCATION_MZONE)
        e7:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
        e7:SetTarget(function (e,c) return c:HasLevel() and s.zemanvictg(e,c) end)
        e7:SetValue(1)

        local e8=e6:Clone()
        e8:SetLabelObject(e7)
        Duel.RegisterEffect(e8,tp)



        local e9=e7:Clone()
        e9:SetCode(EFFECT_CHANGE_LINK_FINAL)
        e9:SetTarget(function (e,c) return c:IsLinkMonster() and s.zemanvictg(e,c) end)

        local e10=e6:Clone()
        e10:SetLabelObject(e9)
        Duel.RegisterEffect(e10,tp)

        local e11=e7:Clone()
        e11:SetCode(EFFECT_CHANGE_RANK_FINAL)
        e11:SetTarget(function (e,c) return c:HasRank() and s.zemanvictg(e,c) end)

        local e12=e6:Clone()
        e12:SetLabelObject(e11)
        Duel.RegisterEffect(e12,tp)

    
end

function s.zemanvictg(e,c)
	return c:IsFaceup() and c:IsMonster() and e:GetHandler():GetColumnGroup():IsContains(c)
end



local SPIRIT_SACRIFICES_NAMES={
    23635815,
    38142739,
    1929294,
    27288416,
    92377303,
    17170970,
    10321588,
    20210570,
    90925163,
    53530069,
    46128076,
    31560081,
    73837870,
    47432275,
    87774234,
    25862691
}

function s.placecards(e,tp)

    local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 5414777)
    local finishedgroup=Group.CreateGroup()
    Duel.Hint(HINT_CARD,tp, 22858242)
    for tc in g:Iter() do
        if not tc:IsLocation(LOCATION_HAND) then
            Duel.SendtoGrave(tc, REASON_RULE)
            Card.Recreate(tc, 681563001, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
            finishedgroup:AddCard(tc)
        else
            Card.Recreate(tc, 681563001, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
        end

    end
    if #finishedgroup>0 then
        Duel.Remove(finishedgroup, POS_FACEUP, REASON_RULE)
        Duel.SendtoDeck(finishedgroup, tp, SEQ_DECKSHUFFLE, REASON_RULE)
    end
    if #finishedgroup~=#g then
        Duel.ShuffleHand(tp)
    end

    for _,code in ipairs(SPIRIT_SACRIFICES_NAMES) do
        local token=Duel.CreateToken(tp,code)
        Duel.Remove(token, POS_FACEUP, REASON_RULE)
    end

    local token1=Duel.CreateToken(tp, 681563001)
    Duel.SendtoHand(token1, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, token1)

    local token2=Duel.CreateToken(tp, 33537328)
    Duel.SendtoHand(token2, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, token2)
end

function s.rewritecusillucon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cusillufilter,tp,LOCATION_ALL,0,1,nil)
end

function s.rewritecusilluop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.cusillufilter,tp,LOCATION_ALL,0,nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id,0,0,0)
        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_DESTROY_REPLACE then
                eff:SetTarget(s.newdesreptg)
            end
        end

        local e1=Effect.CreateEffect(tc)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetCode(EFFECT_SUMMON_PROC)
        e1:SetCondition(s.sumcon)
        e1:SetTarget(s.sumtg)
        e1:SetOperation(s.sumop)
        e1:SetValue(SUMMON_TYPE_TRIBUTE)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_PROC)
        tc:RegisterEffect(e2)

        local e3=Effect.CreateEffect(tc)
        e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_DESTROY_REPLACE)
        e3:SetRange(LOCATION_MZONE)
        e3:SetTarget(s.reptg)
        e3:SetValue(s.repval)
        tc:RegisterEffect(e3)

        
    end
end

function s.rewriteworldofspiritscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ALL,0,1,nil,5414777)
end

function s.rewriteworldofspiritstop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,0,nil,5414777)
    for tc in g:Iter() do
        Card.Recreate(tc, 681563001, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
    end
end

function s.returnfilter(c)
    return c:IsMonster() and c:IsFaceup() and c:IsAbleToGraveAsCost()
end

function s.newdesreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:GetBattlePosition()~=POS_FACEUP_DEFENSE
		and (Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,1,c) or Duel.IsExistingMatchingCard(s.returnfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)) end
	if Duel.SelectEffectYesNo(tp,c,96) then
        local canrelease=Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,1,c)
        local canreturn=Duel.IsExistingMatchingCard(s.returnfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)
        local option=-1
        if canrelease and canreturn then
            option=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
        elseif canrelease then
            option=0
        else
            option=1
        end

        if option==0 then
            local g=Duel.SelectReleaseGroup(tp,Card.IsReleasableByEffect,1,1,c)
            Duel.Release(g,REASON_EFFECT)
        elseif option==1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.returnfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
            Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN+REASON_REPLACE)
        end
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2)
		return true
	else
		return false
	end
end


function s.cfilter(c,tp)
    return c:IsMonster() and c:IsFaceup() and c:IsAbleToGraveAsCost()
end

function s.rescon(zone)
	return	function(sg,e,tp,mg)
				return Duel.GetMZoneCount(tp,sg,tp,LOCATION_REASON_TOFIELD,zone)>0
			end
end

function s.sumcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	if c:IsLevelBelow(6) then return false end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,tp)
	return aux.SelectUnselectGroup(mg,e,tp,c:GetTributeRequirement(),c:GetTributeRequirement(),s.rescon(zone),0)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,tp)
	local g=aux.SelectUnselectGroup(mg,e,tp,c:GetTributeRequirement(),c:GetTributeRequirement(),s.rescon(zone),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_SUMMON+REASON_MATERIAL+REASON_RETURN)
	g:DeleteGroup()
end


function s.repfilter(c,tp,ec)
	return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:IsFaceup() 
		and ((c:IsControler(tp) and c:IsLocation(LOCATION_FZONE)) 
		or (c==ec and c:IsLocation(LOCATION_MZONE)))
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then 
        return eg:IsExists(s.repfilter,1,nil,tp,c)
        and (tp~=rp)
		and (Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,1,c) or Duel.IsExistingMatchingCard(s.returnfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		 local canrelease=Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,1,c)
        local canreturn=Duel.IsExistingMatchingCard(s.returnfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)
        local option=-1
        if canrelease and canreturn then
            option=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
        elseif canrelease then
            option=0
        else
            option=1
        end

        if option==0 then
            local g=Duel.SelectReleaseGroup(tp,Card.IsReleasableByEffect,1,1,c)
            Duel.Release(g,REASON_EFFECT)
        elseif option==1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.returnfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
            Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN+REASON_REPLACE)
        end
		return true
	end
	return false
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),e:GetHandler())
end

function s.synchrofilter(c)
    return c:IsType(TYPE_SYNCHRO) and c:GetFlagEffect(id)==0
end

function s.rewritesynchroscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.synchrofilter,tp,LOCATION_EXTRA,0,1,nil)
end

function s.rewritesynchrosop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.synchrofilter,tp,LOCATION_EXTRA,0,nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id,0,0,0)
        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:GetCode()&EFFECT_SPSUMMON_PROC==EFFECT_SPSUMMON_PROC then
                eff:Reset()
            end
        end
	Synchro.AddProcedure(tc,nil,1,1,Synchro.NonTuner(aux.NOT(Card.IsLinkMonster)),1,99,s.matfilter)

    end
end

function s.matfilter(c,scard,sumtype,tp)
	return c:IsLinkMonster()
end