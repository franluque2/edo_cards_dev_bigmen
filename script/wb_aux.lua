--Generate from outside the duel
CATEGORY_CONJURE=0x20000000

--Make a card dissapear from the Duel
CATEGORY_ERASE=0x30000000

--Abyssal Dredges
CARD_ABYSSAL_DREDGE=851632001

NORMAL_IGKNIGHTS={96802306,93662626,67273917,50407691,97024987,24019092,61639289,24131534}
NORMAL_IGKNIGHTS_TWOS={96802306,67273917,24019092,61639289}
NORMAL_IGKNIGHTS_SEVENS={93662626,50407691,97024987,24131534}


--Spiderite

CARD_SPIDERITELING=851632018

SET_SPIDERITE=0xc00

CARD_SPIDERITELING_ARTS={851632018,851632019,851632020,851632021,851632022}

-- Friesla

SET_FRIESLA=0xc01

CARD_FRIESLA_BIERGARTEN=851632054

-- Diktat / Techminator

SET_DIKTAT=0xc02
SET_TECHMINATOR=0xc03
CARD_TECHMINATOR_TOKEN=851632091
TECHMINATOR_LINKS={851632086, 851632087, 851632088, 851632089, 851632090}
REGISTER_FLAG_TECHMINATOR_IGNITION=2048

if not WbAux then
    WbAux={}
end
function WbAux.GetDredgeCount(tp)
    return Duel.GetFlagEffect(tp, CARD_ABYSSAL_DREDGE)
end

function WbAux.CanPlayerSummonDredge(tp)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_ABYSSAL_DREDGE,nil,TYPE_MONSTER+TYPE_EFFECT,0,0,4,RACE_REPTILE,ATTRIBUTE_DARK,POS_FACEUP,tp,0)
end

function WbAux.SpecialSummonDredge(tp, pos)
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_ABYSSAL_DREDGE,nil,TYPE_MONSTER+TYPE_EFFECT,0,0,4,RACE_REPTILE,ATTRIBUTE_DARK,POS_FACEUP,tp,0) then return false end
    local dredge=Duel.CreateToken(tp, CARD_ABYSSAL_DREDGE)
    if not pos then pos=POS_FACEUP end
    return Duel.SpecialSummon(dredge, SUMMON_TYPE_SPECIAL, tp, tp, false,false, pos)
end

function WbAux.GetSpideriteling(tp)
    return Duel.CreateToken(tp, CARD_SPIDERITELING_ARTS[Duel.GetRandomNumber(1,#CARD_SPIDERITELING_ARTS)])
end

--Aux Function to Create Friesla on-demand flip effects
WbAux.CreateFrieslaFlipEffect=(function()

    local function thcon(e,tp,eg,ep,ev,re,r,rp)
        local ph=Duel.GetCurrentPhase()
        return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():IsPosition(POS_FACEDOWN)
    end
    local function cfilter(c)
        return c:IsDiscardable()
    end
    local function thcost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(cfilter,tp,LOCATION_HAND,0,1,nil) end
        Duel.DiscardHand(tp,cfilter,1,1,REASON_COST+REASON_DISCARD)
        Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
    end

    return function(c, tarfunc, opfunc, category)
    local e1=Effect.CreateEffect(c)
    if category then
        e1:SetCategory(category)
    end
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_MAIN_END,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(thcon)
	e1:SetCost(aux.CostWithReplace(thcost, CARD_FRIESLA_BIERGARTEN))
	e1:SetTarget(tarfunc)
	e1:SetOperation(opfunc)
	return e1
	end
end
)()


WbAux.CreateFrieslaAttachEffect=(function()

    
    local function valiadttachfilter(c)
        return c:IsCode(30243636) and c:IsFaceup()
    end

    local function repcon(e,tp,eg,ep,ev,re,r,rp)
        return rp==tp and eg:IsExists(valiadttachfilter, 1, nil)
    end

    local function repop(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        local tc=eg:Filter(valiadttachfilter, nil)
        if not tc then return end

        local tc1=tc:GetFirst()

        if tc1 then
                   
            Duel.Hint(HINT_CARD, tp, e:GetLabel())
            local token=Duel.CreateToken(tp, e:GetLabel())
            Duel.Remove(token, POS_FACEUP, REASON_RULE)
            Duel.Overlay(tc1 , token)
        end
        e:Reset()
    end
    return function(c)
        local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(repcon)
		e2:SetOperation(repop)
        e2:SetLabel(c:GetOriginalCode())
        e2:SetCountLimit(1)
	return e2
	end
end
)()

function WbAux.GetNormalIgknight(tp,c)
    local scale=0
    if c then
        scale=c:GetLeftScale()
    end

    local id=0
    if scale==0 or ((scale~=2) and (scale~=7)) then
        id=NORMAL_IGKNIGHTS[Duel.GetRandomNumber(1,#NORMAL_IGKNIGHTS)]
    elseif scale==2 then
        id=NORMAL_IGKNIGHTS_SEVENS[Duel.GetRandomNumber(1,#NORMAL_IGKNIGHTS_SEVENS)]
    elseif scale==7 then
        id=NORMAL_IGKNIGHTS_TWOS[Duel.GetRandomNumber(1,#NORMAL_IGKNIGHTS_TWOS)]

    end

    return Duel.CreateToken(tp, id)
end

function WbAux.CanPlayerSummonTechminator(tp)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,TECHMINATOR_LINKS[1],nil,TYPE_MONSTER+TYPE_EFFECT+TYPE_LINK,0,0,2,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_ATTACK,tp,0)
end

function WbAux.MMzoneTechminatorFilter(c)
    return c:IsInMainMZone(c:GetControler()) and c:IsSetCard(SET_TECHMINATOR)
end

function WbAux.FuCodeFilter(c,code)
    return c:IsFaceup() and c:IsCode(code)
end

function WbAux.SpecialTechminatorLink(tp, pos)
    local id=TECHMINATOR_LINKS[Duel.GetRandomNumber(1,#TECHMINATOR_LINKS)]
    if Duel.GetMatchingGroupCount(Card.IsInMainMZone, tp, LOCATION_MZONE, 0, nil)>4 then return false end
    if Duel.GetMatchingGroupCount(WbAux.MMzoneTechminatorFilter, tp, LOCATION_MZONE, 0, nil)>=#TECHMINATOR_LINKS then return false end

    while Duel.IsExistingMatchingCard(WbAux.FuCodeFilter, tp, LOCATION_MZONE, 0, 1, nil, id) do
        id=TECHMINATOR_LINKS[Duel.GetRandomNumber(1,#TECHMINATOR_LINKS)]
    end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,nil,TYPE_MONSTER+TYPE_EFFECT+TYPE_LINK,0,0,2,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP,tp,0) then return false end
    local token=Duel.CreateToken(tp, id)
    if not pos then pos=POS_FACEUP end

    local res= Duel.SpecialSummon(token, SUMMON_TYPE_LINK, tp, tp, false,false, pos)

    if res>0 then
        Card.CompleteProcedure(token)
    end
    return res
end


WbAux.CreateDiktatSummonEffect=(function()

    

    return function(e,tp,eg,ep,ev,re,r,rp)
    
        if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and WbAux.CanPlayerSummonTechminator(tp) and Duel.SelectYesNo(tp, aux.Stringid(851632093,0)) then
            if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)>0 then
                WbAux.SpecialTechminatorLink(tp,POS_FACEUP_ATTACK)
            end
        end
	end
end
)()



local regeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	if c:IsStatus(STATUS_INITIALIZING) and not e then
		error("Parameter 2 expected to be Effect, got nil instead.",2)
	end
	--2048 == 851632099 - access to ignition effects of "Techminator" Monsters
	local reg_e = regeff(c,e,forced,...)
	if not reg_e then
		return nil
	end
	local reg={...}
	local resetflag,resetcount=e:GetReset()
	for _,val in ipairs(reg) do
		local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
		if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
		if val==2048 then
			e2:SetCode(851632099)
		end
		e2:SetLabelObject(e)
		e2:SetLabel(c:GetOriginalCode())
		if resetflag and resetcount then
			e2:SetReset(resetflag,resetcount)
		elseif resetflag then
			e2:SetReset(resetflag)
		end
		c:RegisterEffect(e2)
	end
	return reg_e
end



--For LP Gain Manipulation

EFFECT_NO_LP_GAIN=851632104

Duel.Recover=(function()

	local oldfunc=Duel.Recover

			return function(player,value,reason,...)
                local res=false
                if Duel.IsPlayerAffectedByEffect(player,EFFECT_NO_LP_GAIN) then
                    res=oldfunc(player, 0, reason,...)
                else
                    res=oldfunc(player, value, reason,...)
                end
			return res
	end


end)()