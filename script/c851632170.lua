--Selaphielsauce auf Friesla
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SET_PROC)
	e0:SetCondition(s.sumcon)
	e0:SetTarget(s.sumtg)
	e0:SetOperation(s.sumop)
	e0:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)

	local e2=WbAux.CreateFrieslaFlipEffect(c,s.adtar,s.adop,CATEGORY_TODECK+CATEGORY_LEAVE_GRAVE+CATEGORY_DRAW)
    c:RegisterEffect(e2)
end
s.listed_names={30243636}

function s.sumcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	local tp=c:GetControler()
	if minc>1 or c:IsLevelBelow(4) or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return false end
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	local must_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	return #g>0 and (#must_g==0 or #(g&must_g)>0)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	local must_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	if #must_g>0 then g=g&must_g end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mc=g:Select(tp,1,1,nil):GetFirst()
	if not mc then return false end
	e:SetLabelObject(mc)
	return true
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local mc=e:GetLabelObject()
	c:SetMaterial(mc)
	Duel.Release(mc,REASON_SUMMON|REASON_MATERIAL)
end

function s.valiadttachfilter(c)
    return c:IsCode(30243636) and c:IsFaceup()
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==tp and eg:IsExists(s.valiadttachfilter, 1, nil)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=eg:Filter(s.valiadttachfilter, nil)
    if not tc then return end

    local g1=Duel.GetMatchingGroup(aux.NOT,tp,0,LOCATION_SZONE,nil,Card.IsType,TYPE_TOKEN)
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_GRAVE,nil)
	local g3=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
	local sg=Group.CreateGroup()
	if #g1>0 and ((#g2==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,4))) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id, 2))
		local sg1=g1:Select(tp,1,1,nil)
		Duel.HintSelection(sg1)
		sg:Merge(sg1)
	end
	if #g2>0 and ((#sg==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id, 2))
		local sg2=g2:Select(tp,1,1,nil)
		Duel.HintSelection(sg2)
		sg:Merge(sg2)
	end
	if #g3>0 and (#sg==0 or Duel.SelectYesNo(tp,aux.Stringid(id,5))) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id, 2))
		local sg3=g3:RandomSelect(tp,1)
		sg:Merge(sg3)
	end

    if #sg>0 then
        Duel.Hint(HINT_CARD, tp, id)
        Duel.Overlay(tc:GetFirst(), sg)
    end
    e:Reset()
end


function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.repcon)
    e2:SetOperation(s.repop)
    e2:SetCountLimit(1)
    Duel.RegisterEffect(e2, tp)
end



function s.addfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsMonster() and c:IsAbleToDeck()
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsRace,1,nil,RACE_PLANT)
end
function s.adfilter2(c)
    return c:IsMonster() and c:IsAbleToDeck()
end
function s.adtar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_HAND|LOCATION_GRAVE,LOCATION_GRAVE,1,nil) and Duel.IsPlayerCanDraw(tp) end
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.adfilter2,tp,LOCATION_HAND|LOCATION_GRAVE,LOCATION_GRAVE,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local tc2 = aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
        if Duel.SendtoDeck(tc2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and #tc2==3 then
            Duel.Draw(tp, 2, REASON_EFFECT)
        end
    end
end