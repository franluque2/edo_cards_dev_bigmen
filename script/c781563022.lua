--Roots of the Mother Tree
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)


    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end



function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

local sunvineextracounts={}
sunvineextracounts[0]={}
sunvineextracounts[1]={}


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.registersunvines(tp)

    s.rewritetree(e,tp)
    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_MOVE)
    e2:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA) end)
    e2:SetOperation(s.completesunvines)
    Duel.RegisterEffect(e2,tp)

    s.completesunvines(nil, tp, nil, nil, nil, nil, nil, nil)

    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
    e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetTarget(s.efilter)
    e6:SetValue(1)
    Duel.RegisterEffect(e6, tp)
end

function s.treefilter(c)
    return c:IsCode(92770064) and (c:GetFlagEffect(id)==0)
end


function s.rewritetree(e,tp)
    local g=Duel.GetMatchingGroup(s.treefilter, tp, LOCATION_EXTRA, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)
        local effs={tc:GetOwnEffects()}

        for _, eff in ipairs(effs) do
            if eff:GetCategory()&CATEGORY_DESTROY~=0 then

                local neweff=eff:Clone()
                neweff:SetCost(s.newcost)
                neweff:SetTarget(s.newtg)

                eff:Reset()
                tc:RegisterEffect(neweff)
            end
        end
    end
end

function s.newcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.costfilter(c,dg,lg)
	return c:IsFaceup() and c:IsLinkMonster() and lg:IsContains(c) and (c:IsSetCard(SET_SUNVINE) or c:GetControler()~=c:GetOwner())
end
function s.newtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return #dg>0 and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,aux.ReleaseCheckTarget,nil,dg,lg)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,aux.ReleaseCheckTarget,nil,dg,lg)
	Duel.Release(sg,REASON_COST)
	local lk=sg:GetFirst():GetLink()
	e:SetLabel(lk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,lk,0,0)
end

function s.efilter(e,c)
	return c:IsCode(91557476)
end


function s.registersunvines(tp)

    local g2=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,SET_SUNVINE)
    for tc in g2:Iter() do
        local code=tc:GetCode()
        if not sunvineextracounts[tp][code] then
            sunvineextracounts[tp][code]=0
        end
        sunvineextracounts[tp][code]=sunvineextracounts[tp][code]+1
    end
end

function s.completesunvines(e,tp,eg,ep,ev,re,r,rp)

    for code, count in pairs(sunvineextracounts[tp]) do
        local num=Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, code)
        if count>num then
            for i=1, count-num do
                local token=Duel.CreateToken(tp, code)
                Duel.SendtoDeck(token, nil, SEQ_DECKBOTTOM, REASON_RULE)
            end
        end
    end
end