--Generate from outside the duel
CATEGORY_CONJURE=0x20000000

--Make a card dissapear from the Duel
CATEGORY_ERASE=0x30000000

--Abyssal Dredges
CARD_ABYSSAL_DREDGE=851632001

NORMAL_IGKNIGHTS={96802306,93662626,67273917,50407691,97024987,24019092,61639289,24131534,851632017}

--Spiderite

CARD_SPIDERITELING=851632018

SET_SPIDERITE=0xc00

CARD_SPIDERITELING_ARTS={851632018,851632019,851632020,851632021,851632022}

-- Friesla

SET_FRIESLA=0xc01

CARD_FRIESLA_BIERGARTEN=851632054

if not WbAux then
    WbAux={}
end
function WbAux.GetDredgeCount(tp)
    return Duel.GetFlagEffect(tp, CARD_ABYSSAL_DREDGE)
end

function WbAux.CanPlayerSummonDredge(tp)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_ABYSSAL_DREDGE,0,TYPE_EFFECT,0,0,4,RACE_AQUA,ATTRIBUTE_DARK)
end

function WbAux.SpecialSummonDredge(tp, pos)
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_ABYSSAL_DREDGE,0,TYPE_EFFECT,0,0,4,RACE_AQUA,ATTRIBUTE_DARK) then return false end
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