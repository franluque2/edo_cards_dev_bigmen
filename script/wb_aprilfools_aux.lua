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
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
    return token
end