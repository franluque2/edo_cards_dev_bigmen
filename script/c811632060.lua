--There is a Cheater Among Us
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s.cheatnum={}
		s.cheatnum[0]=1
		s.cheatnum[1]=1

        s.cheattype={}
        s.cheattype[0]=1
        s.cheattype[1]=1
	end)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_DRAW)
    e2:SetCountLimit(1,id)
    e2:SetCondition(function() return Duel.GetTurnCount()==1 end)
    e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)  Duel.ShuffleDeck(0) Duel.ShuffleDeck(1) end)
    Duel.RegisterEffect(e2,0)

end
local passwordcards={{{53932291,20}}
--cheater1
,{{53129443,2},{19535693,3},{42141493,2}},{{8267140,2},{43898403,2},{92003832,2}},{{42141493,2},{75046994,3},{94145021,3}},{{75046994,3},{54670997,2},{59438930,3}},{{43685562,1},{59438930,2}}
--cheater2
,{{34325937,2},{12580477,3},{55063751,2},{19613556,2},{43898403,1}},{{12607053,3},{36361633,3},{38606913,3}},{{55063751,3},{24299458,3},{30270176,3}},,{{2434862,3},{38606913,3}}
--throw 1
,{{02526224,30}}
--throw 2
,{{13332685,30}}
--throw 3
,{{09213491,30}}
}
local cheathands={{{43722862}}
--cheater1
,{{42141493,92003832,19535693,92003832,42141493}},{{8267140,23512906,19535693,19535693,49370016}},{{94145021,94145021,75046994,13258285,96305350}},{{55920742,55920742,54670997,3233859,14558127}},{{43685562,81914447,92003832,59438930,59438930}}
--cheater2
,{{20137754,12580477,35726888,9659580,40392714}},{{36361633,38606913,423585,9659580,35058588}},{{30270176,35058588,49238328,24299458,9659580}},{{2434862,38606913,35726888}}
--throw 1
,{{02526224}}
--throw 2
,{{13332685}}
--throw 3
,{{24508238,36494597,36218106}}
}


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
        Duel.DisableShuffleCheck()
        Duel.Hint(HINT_CARD, tp, id)

        Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

        Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)

        Duel.Hint(HINT_SKILL_COVER,tp,id|(300000000<<32))
        Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))


		--other passive duel efzfects go here    

        local haspassword, counter = s.lookforpassword(tp)
        if haspassword then
            s.cheattype[tp]=counter
            s.cheatnum[tp]=Duel.GetRandomNumber(1,#cheathands[counter])
            s.replacecards(tp)
        end

        Duel.DisableShuffleCheck(false)
		end
	e:SetLabel(1)
end

function s.lookforpassword(tp)
    local counter=1
    local finalresult=false
    for _,passwordcheck in pairs(passwordcards) do
        local result=true
        for _,password in pairs(passwordcheck) do
            if Duel.GetMatchingGroupCount(Card.IsOriginalCode, tp, LOCATION_ALL, 0, nil, password[1])~=password[2] then
                result=false
            end
        end
        if not (result or finalresult) then
            counter=counter+1
        end
        finalresult=finalresult or result
    end
    return finalresult, counter
end

function s.topdeckfilter(c,num,tp)
	return c:GetSequence()>=(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-(num))
end

function s.bottomofdeckfilter(c,num,tp,topgroup)
	return c:GetSequence()<(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-num) and (s.starterfilter(c,tp)) and (not c:IsType(TYPE_SKILL))
end

function s.botseekerfilter(c,num,tp) 
        return c:GetSequence()<(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-num) and (not c:IsType(TYPE_SKILL))
end

function s.replacecards(tp)
    local decklist=s.cheattype[tp]
    local target=cheathands[decklist][s.cheatnum[tp]]
    local need=5

    local topdeck=Duel.GetMatchingGroup(s.topdeckfilter, tp, LOCATION_DECK, 0, nil, need, tp)
    local bottomcards=Duel.GetMatchingGroup(s.botseekerfilter, tp, LOCATION_DECK, 0, nil, need, tp)
    Duel.DisableShuffleCheck()

    if #topdeck==0 or #bottomcards==0 then return end

    local desiredCounts={}
    for _,code in ipairs(target) do
        desiredCounts[code]=(desiredCounts[code] or 0)+1
    end

    local topCounts={}
    for tc in topdeck:Iter() do
        local code=tc:GetOriginalCode()
        topCounts[code]=(topCounts[code] or 0)+1
    end
    local cardstoreplace=Group.CreateGroup()
    for code,qty in pairs(desiredCounts) do
        local have=topCounts[code] or 0
        local miss=qty - math.min(qty, have)
        while miss>0 do
            local g=bottomcards:Filter(Card.IsOriginalCode, nil, code)
            if #g==0 then return end
            local pick=g:GetFirst()
            cardstoreplace:AddCard(pick)
            bottomcards:RemoveCard(pick)
            miss=miss-1
        end
    end

    if #cardstoreplace==0 then return end

    local selectable=Group.CreateGroup()
    selectable:Merge(topdeck)
    for code,qty in pairs(desiredCounts) do
        local keep=math.min(qty, topCounts[code] or 0)
        for i=1,keep do
            local g=selectable:Filter(Card.IsOriginalCode, nil, code)
            if #g>0 then selectable:RemoveCard(g:GetFirst()) end
        end
    end

    local toTakeCount=#cardstoreplace
    if #selectable<toTakeCount then return end

    local cardstotake=s.silentrandomselect(selectable, toTakeCount)
    if #cardstotake==0 then return end

    for cardtotake in cardstotake:Iter() do
        local cardtoreplace=cardstoreplace:GetFirst()
        if not cardtoreplace then break end
        Group.RemoveCard(cardstoreplace, cardtoreplace)
        local starterid=cardtotake:GetOriginalCode()
        local replacedid=cardtoreplace:GetOriginalCode()
        Card.Recreate(cardtotake, replacedid,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
        Card.Recreate(cardtoreplace, starterid,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
    end
end


function s.starterfilter(c,tp)
	return c:IsOriginalCode(table.unpack(cheathands[s.cheattype[tp]][s.cheatnum[tp]]))
end

function s.silentrandomselect(group, num)
    local selected=Group.CreateGroup()
    for i=1,num do
        if #group>0 then
            local integer=Duel.GetRandomNumber(1,#group)
            local card=group:TakeatPos(integer-1)
            Group.AddCard(selected, card)
            Group.RemoveCard(group, card)
        end
    end
    return selected

end
