--Heartland Security Lockdown
Duel.LoadScript("big_aux.lua")


local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
end


local zonemarkers={81632513,81632514,81632515,81632516,81632517,81632518,81632519,81632520,81632521,81632522}
local rankxyzs={}
rankxyzs[1]={1174075,33909817,60181553,46895036,12533811,23848752,58058134,7020743,8491961,19369609,27240101,48608796,72971064}
rankxyzs[2]={61307542,90809975,53054164,52645235,36776089,9486959,54498517,98049934,97170107,12219047,2766877,32224143,62592805,76833149,1249315,30439101,10002346,84224627,50789693,24434049,37649320}
rankxyzs[3]={19891310,94151981,61641818,37057743,40424929,93730230,74416224,34001672,80993256,47506081,62709239,87327776,101206205,65892585,71068247,47579719,5014629,51497409,85252081,91895091,14306092,75367227,95992081,68836428,3989465,12615446,100305063,15914410,56337500,52558805,64245689,44241999,59170782,84401683,4423206,78156759,81122844,26563200,88942504,57043117,90098780,83531441,90664857,52323874,70597485,76589815}
rankxyzs[4]={6247535,9053187,38273745,68618157,440556,2191144,71594310,64414267,91279700,75620895,74593218,39987164,56638325,1855932,16195942,17016362,21065189,42160203,67865534,97453744,42741437,58858807,1269512,1828513,1688285,21501505,55285840,74294676,75840616,3758046,47349116,75797046,77631175,2091298,26329679,39943352,36757171,65884091,3594985,11398059,32530043,46804536,42752141,28912357,61399402,28290705,9608555,78135071,11646785,49121795,91135480,37164373,23232295,34481518,58712976,96381979,66506689,90726340,82944432,73659078,59071624,75215744,21293424,42589641,6983839,90590303,28150174,41524885,48009503,76372778,76078185,69069911,25853045,72167543,31123642,53334641,85909450,86848580,40390147,3828844,21223277,60645181,68300121,86331741,54358015,82633039,95169481,31563350,58720904,61344030,30100551,28781003,85692042,85747929,88021907,59208943,62967433,22653490,91499077,51960178,68597372,94942656,5916510,37926346,46772449,88722973,16643334,20343502,8660395,25341652,73289035,58504745,34086406,581014,21044178,29423048,78876707,12014404,65301952,5530780,48285768,74689476,20248754,96592102,359563,18326736,75574498,6511113,73347079,73887236,8809344,47195442,7593748,38180759,11510448,14970113,41375811,48905153,74393852,85115440}
rankxyzs[5]={29515122,1621413,64276752,2896663,60992364,94798725,100305024,9272381,49689480,57031794,77334267,31386180,94119480,100305023,44311445,13183454,39317553,20145685,23672629,73964868,24701066,38250531,69840739,50449881,2609443,10613952,58600555,58069384,8617563,15092394,770365,34876719,29510428,26211048}
rankxyzs[6]={30128445,79559912,14152862,38495396,92661479,75083197,64689404,71100270,27069566,18511599,32302078,27552504,23776077,35103106,61248471,15561463,6284176,27337596,10000030,99666430,45935145,19684740,99469936,10443957,79985120,81927732,44505297,96637156,45742626}
rankxyzs[7]={48626373,30095833,45627618,86238081,95685352,98452268,92918648,16691074,95239444,44405066,47132793,74371660,67630394,78144171,57450198,22110647,85004150,91949988,38694052,96471335,96157835,51822687,85551711,60195675,83827392,73542331}
rankxyzs[8]={39272762,39030163,18897163,26988374,38026562,73082255,18963306,77799846,3292267,64332231,698785,23603403,64182380,98986900,33779875,59242457,30741334,1639384,11132674,93854893,44698398,10406322,62941499,76290637,10678778}
rankxyzs[9]={12632096,2530830,97584719,95113856,9940036,95243515,9349094,74615388,28981598,2665273}
rankxyzs[10]={66523544,28346136,86221741,3814632,46593546,56910167,70636044,87676171}


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		--bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local c=e:GetHandler()
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCountLimit(1)
        e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e2:SetCondition(s.adcon)
        e2:SetOperation(s.adop)
        Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_IMMUNE_EFFECT)
        e3:SetTargetRange(LOCATION_MZONE, 0)
        e3:SetTarget(function (_,tc ) return tc:IsCode(table.unpack(zonemarkers))end)
        e3:SetValue(s.efilter)
        Duel.RegisterEffect(e3, tp)

        local e4=e3:Clone()
        e4:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
        e4:SetValue(1)
        Duel.RegisterEffect(e4, tp)

        local e5=e3:Clone()
        e5:SetCode(EFFECT_UNRELEASABLE_SUM)
        e5:SetValue(1)
        Duel.RegisterEffect(e5, tp)

        local e6=e5:Clone()
        e6:SetCode(EFFECT_UNRELEASABLE_SUM)
        Duel.RegisterEffect(e6, tp)

        local e7=Effect.CreateEffect(c)
        e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e7:SetCode(EVENT_SUMMON_SUCCESS)
        e7:SetCondition(s.spcon)
        e7:SetOperation(s.spop)
        Duel.RegisterEffect(e7,tp)

        local e8=e7:Clone()
        e8:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e8,tp)

        local e9=e7:Clone()
        e9:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
        Duel.RegisterEffect(e9,tp)


        local e10=Effect.CreateEffect(c)
        e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e10:SetCountLimit(1)
        e10:SetCode(EVENT_PHASE+PHASE_END)
        e10:SetCondition(s.spendcon)
        e10:SetOperation(s.spendop)
        Duel.RegisterEffect(e10,tp)


	end
	e:SetLabel(1)
end

function s.spendcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)) and (Duel.GetFlagEffect(tp, id+1)==0) and Duel.IsPlayerCanSpecialSummonMonster(1-tp, 73915052, 0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH)
end


function s.spendop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD, tp, id)
    local sheeptoken=Duel.CreateToken(1-tp, 73915052)
    Duel.SpecialSummonStep(sheeptoken, SUMMON_TYPE_SPECIAL, 1-tp, 1-tp, false, false, POS_FACEUP_DEFENSE)
    Duel.SpecialSummonComplete()
end

function s.spfilter(c, tp)
    return c:IsOnField() and c:GetColumnGroup():IsExists(s.markerfilter,1,nil,LOCATION_MZONE,tp)
end

function s.markerfilter(c, loc, tp)
    return c:IsFaceup() and c:IsCode(table.unpack(zonemarkers)) and c:IsLocation(loc) and c:IsControler(tp)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    if (rp==tp and not eg:IsExists(Card.IsCode, 1, nil, 73915052)) then return false end
    Duel.RegisterFlagEffect(tp, id+1, RESET_PHASE+PHASE_END, 0,0)
    return eg:IsExists(s.spfilter, 1, nil, tp) and #(eg:Filter(s.spfilter, nil, tp))==1
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)

    local tc1=eg:Filter(s.spfilter, nil, tp):GetFirst()
    if not tc1 then return end
    local g2=tc1:GetColumnGroup()
    local tc2=g2:Filter(s.markerfilter, nil, LOCATION_MZONE, tp)
    if tc2 and #tc2>0 then
        Duel.Hint(HINT_CARD, tp, id)
        local tcfinal=tc2:GetFirst()
        local lv=tcfinal:GetOriginalLevel()
        local zone=1<<tcfinal:GetSequence()
        Duel.Remove(tcfinal, POS_FACEUP, REASON_RULE)
        Duel.BreakEffect()

        local token_to_summ=Duel.CreateToken(tp, s.getrandomxyz(lv))
        Duel.SpecialSummon(token_to_summ, SUMMON_TYPE_SPECIAL, tp, tp, true, false, POS_FACEUP, zone)

        for i = 1, token_to_summ.minxyzct, 1 do
            local toxyzmat=Duel.CreateToken(tp, zonemarkers[lv])
            Duel.Remove(toxyzmat, POS_FACEUP, REASON_RULE)
            Duel.Overlay(token_to_summ, toxyzmat)
        end
    end
    return
end

function s.efilter(e,re)
	return e:GetOwner()~=re:GetOwner()
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetLocationCount(tp, LOCATION_MZONE)
end

function s.getcard()
    return zonemarkers[ Duel.GetRandomNumber(1, #zonemarkers ) ]
end


function s.getrandomxyz(lv)
    return rankxyzs[lv][ Duel.GetRandomNumber(1, #rankxyzs[lv] ) ]
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
    local num=Duel.GetLocationCount(tp, LOCATION_MZONE)
    local g=Group.CreateGroup()

    local fid=e:GetHandler():GetFieldID()
    for i = 1, num, 1 do
        local tc=Duel.CreateToken(tp,s.getcard())
        Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP_ATTACK)
        tc:RegisterFlagEffect(id,0,0,1,fid)

		g:AddCard(tc)

    end
    g:KeepAlive()

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	e1:SetCountLimit(1)
    e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
    Duel.RegisterEffect(e1,tp)

end

function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
    if Duel.GetTurnPlayer()~=tp then return false end
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD, tp, id)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	Duel.RemoveCards(tg)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
