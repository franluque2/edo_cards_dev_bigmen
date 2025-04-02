if not WbAux then
    WbAux={}
end

--IPC

SET_IPC=0xd00

TOKEN_FOLLOWUP=881563202

CARD_TOPAZ=881563201
CARD_DOCTOR_RATIO=881563208
CARD_AVENTURINE=881563206
CARD_JADE=881563207

COUNTER_DEBTOR=0x1700
COUNTER_BLIND_BET=0x1701

function WbAux.CanPlayerSpecialSummonFollowupToken(tp)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_FOLLOWUP,nil,TYPE_MONSTER+TYPE_TOKEN,500,0,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,tp,0)
end

FOLLOWUP_TOKEN_IDS={881563202,881563203,881563204}

function WbAux.GetFollowupToken(tp, c)
    if not WbAux.CanPlayerSpecialSummonFollowupToken(tp) then return end
    local tokenid=FOLLOWUP_TOKEN_IDS[Duel.GetRandomNumber(1,3)]
    if c then
        local id=c:GetOriginalCode()
        if id==CARD_TOPAZ then
            tokenid=881563202
        elseif id==CARD_AVENTURINE then
            tokenid=881563204
        elseif id==CARD_DOCTOR_RATIO then
            tokenid=881563203
        end
    end
    local token=Duel.CreateToken(tp,tokenid)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    return token
end

--Minecraft

SET_MINECRAFT=0xd04

MINECRAFT_NORMIE_IDS={881563802,881563803,881563804,881563805,881563806,881563807}

function WbAux.GetMinecraftNormie(tp,att)
    local normieid=881563808
    if att==ATTRIBUTE_DARK then
        normieid=MINECRAFT_NORMIE_IDS[2]
    elseif att==ATTRIBUTE_EARTH then
        normieid=MINECRAFT_NORMIE_IDS[1]
    elseif att==ATTRIBUTE_FIRE then
        normieid=MINECRAFT_NORMIE_IDS[5]
    elseif att==ATTRIBUTE_LIGHT then
        normieid=MINECRAFT_NORMIE_IDS[6]
    elseif att==ATTRIBUTE_WATER then
        normieid=MINECRAFT_NORMIE_IDS[5]
    elseif att==ATTRIBUTE_WIND then
        normieid=MINECRAFT_NORMIE_IDS[3]
    end
    local normie=Duel.CreateToken(tp,normieid)
    return normie
end


--DBZ

SET_DRAGON_BALL=0xd01
SET_GOKU=0xd02
SET_SAIYAN=0xd03
SET_VEGETA=0xd05

DRAGON_BALL_COUNTER=0x1702

CARD_DRAGON_BALLS=881563450


WbAux.CreateDBZEvolutionEffect=(function()

    local id=881563403
   

    return function(c, cardcode, followup)

    local function battleop(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        c:ResetFlagEffect(id)

        Duel.HintSelection(c)
        Card.Recreate(c, cardcode, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
        if followup then
            Duel.BreakEffect()
            followup(e,tp,eg,ep,ev,re,r,rp)
        end
    end

    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetOperation(battleop)

	return e4
	end
end
)()

WbAux.CreateDBZInstantAttackEffect=(function()

    local id=881563403

    local function destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
        if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    end

    return function(c,cardid,followupop)

    local function desop(e,tp,eg,ep,ev,re,r,rp)
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            Duel.CalculateDamage(e:GetHandler(), tc)
        end
        if followupop then
            Duel.BreakEffect()
            followupop(e,tp,eg,ep,ev,re,r,rp)
         end
         e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    end

        
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{cardid,0})
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e5:SetCondition(function() return Duel.IsMainPhase() end)
	e5:SetTarget(destg)
	e5:SetOperation(desop)
	return e5
    end
end
)()


WbAux.CreateDBZPlaceDragonBallsEffect=(function()

    local id=881563403


    local function tffilter(c)
        return c:IsFaceup() and c:IsCode(CARD_DRAGON_BALLS)
    end

    local function tftg(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and not Duel.IsExistingMatchingCard(tffilter,tp,LOCATION_ONFIELD,0,1,nil) end
    end

    local function tfop(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
        local tc=Duel.CreateToken(tp, CARD_DRAGON_BALLS)
        if tc then
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    end
    return function(c)
        
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(tftg)
	e1:SetOperation(tfop)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)

    local e3=e2:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)

	return e1, e2, e3
    end
end
)()