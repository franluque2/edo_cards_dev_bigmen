--Generate from outside the duel
CATEGORY_CONJURE=0x20000000

--Abyssal Dredges
CARD_ABYSSAL_DREDGE=851632001

NORMAL_IGKNIGHTS={96802306,93662626,67273917,50407691,97024987,24019092,61639289,24131534,851632017}


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

