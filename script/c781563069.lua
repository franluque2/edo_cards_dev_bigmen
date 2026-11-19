--Intelligence of Things
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
        nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)

    aux.GlobalCheck(s, function()
        s.negated_activations = 0

        aux.AddValuesReset(function()
            s.negated_activations = 0
        end)

        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_NEGATED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)


    end)

end


local CARD_ALLIED_CODE=39138610


function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if de then
		s.negated_activations = s.negated_activations + 1
	end
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

local appliancerextracounts={}
appliancerextracounts[0]={}
appliancerextracounts[1]={}


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.registerappliancers(tp)

        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_MOVE)
    e1:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA) end)
    e1:SetOperation(s.completeappliancers)
    Duel.RegisterEffect(e1,tp)


        local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.reinclinkcon)
	e2:SetTarget(s.reinclinktg)
	e2:SetOperation(s.reinclinkop)
	e2:SetValue(SUMMON_TYPE_LINK)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetTarget(function(e,c) return c:IsSetCard(SET_APPLIANCER) and c:IsLinkMonster() and c:IsLink(1) end)
	e3:SetLabelObject(e2)
    Duel.RegisterEffect(e3,tp)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
    e4:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e4:SetValue(s.valfunc)
    Duel.RegisterEffect(e4,tp)

            local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetCondition(s.rewritealliedcodecon)
    e5:SetOperation(s.rewritealliedcodeop)
    Duel.RegisterEffect(e5,tp)
end

function s.valfunc(e,c)

    return 1 + s.negated_activations
end

function s.registerappliancers(tp)

    local g2=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,SET_APPLIANCER)
    for tc in g2:Iter() do
        local code=tc:GetCode()
        if not appliancerextracounts[tp][code] then
            appliancerextracounts[tp][code]=0
        end
        appliancerextracounts[tp][code]=appliancerextracounts[tp][code]+1
    end
end



function s.reincmatfilter(c,lc,tp)
	return c:IsFaceup() and c:IsLinkMonster()
		and c:IsRaceExcept(RACE_MACHINE,lc,SUMMON_TYPE_LINK,tp) and c:IsCanBeLinkMaterial(lc,tp)
        and c:GetLink()>0
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0
end
function s.reinclinkcon(e,c,must,g,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	return ((#mustg==1 and s.reincmatfilter(mustg:GetFirst(),c,tp)) or (#mustg==0 and #g>0))
end
function s.reinclinktg(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	if #mustg>0 then
		if #mustg>1 then
			return false
		end
		mustg:KeepAlive()
		e:SetLabelObject(mustg)
		return true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
	local tc=g:SelectUnselect(Group.CreateGroup(),tp,false,true)
	if tc then
		local sg=Group.FromCards(tc)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.reinclinkop(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
	Duel.Hint(HINT_CARD,0,id)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL|REASON_LINK)
end


function s.completeappliancers(e,tp,eg,ep,ev,re,r,rp)

    for code, count in pairs(appliancerextracounts[tp]) do
        local num=Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, code)
        if count>num then
            for i=1, count-num do
                local token=Duel.CreateToken(tp, code)
                Duel.SendtoDeck(token, nil, SEQ_DECKBOTTOM, REASON_RULE)
            end
        end
    end
end


function s.alliedcodefilter(c)
    return c:IsOriginalCode(CARD_ALLIED_CODE) and c:GetFlagEffect(id)==0
end

function s.rewritealliedcodecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.alliedcodefilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritealliedcodeop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.alliedcodefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))

        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then
                eff:SetTarget(s.sptg)
                eff:SetOperation(s.spop)
            end
        end


    end
end


function s.spfilter1(c,e,tp,zone)
	return c:IsRace(RACE_CYBERSE) and c:IsAttack(2300) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.spfilter2(c,e,tp,zone)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetHandler():GetLinkedZone(tp))
    local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetHandler():GetLinkedZone(tp))
	if chk==0 then return g1
        or ((Duel.GetLP(tp)>2000) and g2)
     end

    
    if g2 then
        if not (#g1>0) or Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            local lptopay=Duel.GetLP(tp)-2000
            Duel.PayLPCost(tp, lptopay)
            e:SetLabel(1)
        end
    end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if c:IsRelateToEffect(e) and c:IsFaceup() and zone>0 and ft>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local selg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_GRAVE,0,nil,e,tp,zone)
		if e:GetLabel()==1 and ft>0 then
			local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_GRAVE,0,nil,e,tp,zone)
			selg1:Merge(g2)
		end
        local g=selg1:Select(tp, 1, ft, nil)
		if #g>0 then
			local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
			if ct>0 then
				c:UpdateAttack(ct*500)
			end
		end
	end
	--You cannot Special Summon for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(CARD_ALLIED_CODE,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end