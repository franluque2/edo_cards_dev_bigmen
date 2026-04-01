--Protoss Colossus
local s,id=GetID()
function s.initial_effect(c)
        --If you have more cards in hand than your opponent does, you can Special Summon this card (from your hand). You can only Special Summon "Protoss Colossus" once per turn this way.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    --During your opponent's Main Phase, if this card is Linked (Quick Effect): You can choose 1 of your opponent's Main Monster zones, destroy all monsters on it and adjacent Main Monster Zones
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(_e) return Duel.IsMainPhase() and (Duel.GetTurnPlayer()~=e:GetHandler():GetControler()) and Duel.IsExistingMatchingCard(s.desconfilter,_e:GetHandler():GetControler(),LOCATION_ONFIELD,LOCATION_MZONE,1,nil,c,c:GetLinkedGroup()) end)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_PROTOSS}


function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_HAND)
end

function s.desconfilter(c,ec,lg)
    return c:IsFaceup() and (lg:IsContains(c) or c:GetLinkedGroup():IsContains(ec))
end

function s.desfilter(c,zone)
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and (zone&(1<<c:GetSequence())~=0)
end

local function adjzone(loc,seq)
	if loc==LOCATION_MZONE then
		if seq<5 then
			--Own zone and horizontally adjancent
			return ((7<<(seq-1))&ZONES_MMZ)
		else
			--Own zone | vertical adjancent main monster zone
			return (1<<seq)|(2+(6*(seq-5)))
		end
	else --loc == LOCATION_SZONE
		--Own zone and horizontally adjancent | Vertical adjancent zone
		return ((7<<(seq+7))&0x1F00)|(1<<seq)
	end
end

local function groupfrombit(bit,p)
	local loc=(bit&0x7F>0) and LOCATION_MZONE or LOCATION_SZONE
	local seq=(loc==LOCATION_MZONE) and bit or bit>>8
	seq = math.floor(math.log(seq,2))
	local g=Group.CreateGroup()
	local function optadd(loc,seq)
		local c=Duel.GetFieldCard(p,loc,seq)
		if c then g:AddCard(c) end
	end
	optadd(loc,seq)
	if seq<=4 then --No EMZ
		if seq+1<=4 then optadd(loc,seq+1) end
		if seq-1>=0 then optadd(loc,seq-1) end
	end
	if loc==LOCATION_MZONE then
		if seq<5 then
			optadd(LOCATION_SZONE,seq)
			if seq==1 then optadd(LOCATION_MZONE,5) end
			if seq==3 then optadd(LOCATION_MZONE,6) end
		elseif seq==5 then
			optadd(LOCATION_MZONE,1)
		elseif seq==6 then
			optadd(LOCATION_MZONE,3)
		end
	else -- loc == LOCATION_SZONE
		optadd(LOCATION_MZONE,seq)
	end
	return g
end
function s.filter(c)
	return not c:IsLocation(LOCATION_FZONE) and not (Duel.IsDuelType(DUEL_SEPARATE_PZONE) and c:IsLocation(LOCATION_PZONE)) and not c:IsLocation(LOCATION_SZONE)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	local filter=0
	for oc in g:Iter() do
		filter=filter|adjzone(oc:GetLocation(),oc:GetSequence())
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_ONFIELD,~filter<<16)
	Duel.Hint(HINT_ZONE,tp,zone)
	Duel.Hint(HINT_ZONE,1-tp,zone>>16)
	e:SetLabel(zone)
	local sg=groupfrombit(zone>>16,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=groupfrombit(e:GetLabel()>>16,1-tp)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,#Duel.GetOperatedGroup(),false)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end