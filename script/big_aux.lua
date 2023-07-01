big_aux={}

baux=big_aux

if not CustomArchetype then
	CustomArchetype = {}

	local MakeCheck=function(setcodes,archtable,extrafuncs)
		return function(c,sc,sumtype,playerid)
			sumtype=sumtype or 0
			playerid=playerid or PLAYER_NONE
			if extrafuncs then
				for _,func in pairs(extrafuncs) do
					if Card[func](c,sc,sumtype,playerid) then return true end
				end
			end
			if setcodes then
				for _,setcode in pairs(setcodes) do
					if c:IsSetCard(setcode,sc,sumtype,playerid) then return true end
				end
			end
			if archtable then
				if c:IsSummonCode(sc,sumtype,playerid,table.unpack(archtable)) then return true end
			end
			return false
		end
	end

	CustomArchetype.kdr_ct_number={15862758,
62541668, 95134948, 23187256, 89477759, 26556950, 21858819, 51543904, 32559361, 49032236, 47017574, 90162951, 68396121, 6165656, 69170557, 1992816, 33776843, 97403510, 73445448, 31801517, 48348921, 89516305, 48995978, 2978414, 28400508, 63767246, 88177324, 75433814, 8165596, 23085002, 23085002, 66547759, 66547759, 88120966, 6387204, 95474755, 16037007, 92015800, 80117527, 53701457, 82308875, 10389142, 21521304, 96864105, 64554883, 9161357, 75253697, 93713837, 57707471, 69757518, 11522979,
 49456901, 67173574, 87911394, 20785975, 85121942, 12744567, 55888045, 66970002, 56832966, 21313376, 29669359, 19333131, 39139935, 36076683, 62070231, 35772782, 55067058, 23998625, 20563387, 90126061, 42421606, 49221191, 65676461, 2061963, 37279508, 2407234, 86532744, 49678559, 56840427, 84013237, 59627393, 76067258, 11411223, 84417082, 47387961, 46871387, 80796456, 94380860, 54719828, 71921856, 82697249, 23649496, 8387138, 90590303, 51735257, 48739166, 50260683, 55470553, 63746411, 31437713,
  67557908, 80764541, 63504681, 66011101, 93108839, 53244294, 7194917, 62517849, 93777634, 93568288, 81330115, 56292140, 31320433, 69610924, 47805931, 1426714, 49195710, 4997565, 71166481, 77205367, 39622156, 16259549, 32003338, 59479050, 32446630, 29208536, 79747096, 54191698, 3790062, 39972129, 55727845, 32453837, 56051086, 26973555, 4019153, 15232745, 42230449, 78625448, 55935416, 48928529, 69058960, 95442074, 84124261, 54366836, 89642993, 29085954, 43490025, 57314798, 65305468, 52653092}

CustomArchetype.kdr_ct_australian={78613627,95789089,42129512,01371589,69579761,87685879,27134689,07243511,
	98416533,87322377,80141480,17021204,25654671,80637190,40634253,04941482,511000794,17243896,82041999,45688586,
	54248491,79636594,30537973,81759748,37279508,98978921,81635012}
Card.IsAustralian=MakeCheck(nil,CustomArchetype.kdr_ct_australian)

	CustomArchetype.Kdr_legendary={
    74677422,06368038,43793530,49563947,78060096,CARD_SKULL_SERVANT,
		31447217,60862676,87322377, 47986555,78780140,
		58538870, 12143771, 85936485, --the trio of the peasant
		03797883
  }

	Card.IsLegendary=MakeCheck(nil,CustomArchetype.Kdr_legendary)

	CustomArchetype.kdr_treasure={
6008269, 03493058, 05133471, 07165085, 17449108, 41139112, 11830996, 13210191, 15305240, 22346472, 08842266, 378812118, 18591904, 43422537, 43434803, 49140998, 18756904, 56256517, 75500286, 11961740, 01248895, 63102017, 25880422, 22047978, 33245030, 89882100, 71044499, 59344077, 70046172, 34016756, 70095154, 68535320, 95929069, 33508719, 11110587, 16435215, 18144506, 19613556, 25311006, 26412047, 33782437, 42534368, 42598242, 45141013, 55144522, 56830749, 58577036, 60399954, 66788016, 67169062,
 69162969, 70231910, 70368879, 72302403, 72767833, 72892473, 74117290, 74191942, 74848038, 79571449, 79759861, 81000306, 81439174, 82828051, 83764719, 84211599, 85602018, 87910978, 90928333, 95308449, 96765646, 97169186, 14087893, 19230408, 25789292, 27243130, 55713623, 73178098, 98045062, 70828912, 67616300, 981540, 1224927, 3280747, 4178474, 12607053, 19254117, 20735371, 21597117, 24673894, 26533075, 35316708, 36361633, 37507488, 41440817, 44509898, 51099515, 53582587, 56120475, 80604092,
  77414722, 78156759
}

Card.IsTreasure=MakeCheck(nil,CustomArchetype.kdr_treasure)


  CustomArchetype.Jester={
    62962630,25280974,80275707,511000000,511000026,08487449,72992744,100000195,511000810,88722973,
  }



Card.IsJester=MakeCheck({0x152c},CustomArchetype.Jester)


CustomArchetype.Beast_borg_medal={
  511001546, 511001547, 511001559, 511002705, 513000077
  }

Card.IsBeastBorgMedal=MakeCheck(nil,CustomArchetype.Beast_borg_medal)

CustomArchetype.ruler_backrow={
  40703393, 54693926, 160006042, 160009046, 6850209, 41925941, 91781589, 160006060, 160305030, 160428084, 511000896, 511001132, 511002734, 513000131
}

Card.IsRulerBackrow=MakeCheck(nil,CustomArchetype.ruler_backrow)

CustomArchetype.armor_canine={
  81632413, 81632412, 81632414
}

Card.IsArmorCanine=MakeCheck(nil,CustomArchetype.armor_canine)



CustomArchetype.Toy={
  56675280,37364101,1826676,57902462,70245411,58132856,
  11471117,92607427,

  511000006,01826676,511000005,511001399

}

Card.IsCTToy=MakeCheck({0x558,0xad,0x559},CustomArchetype.Toy)

CustomArchetype.CTMantis={
  58818411, 85505315, 51254980, 82738277, 100297002, 100297003, 94573223, 100297102, 53754104, 31600513, 31600514, 101111083,
}
Card.IsCTMantis=MakeCheck({0x535},CustomArchetype.CTMantis)


CustomArchetype.CTLamp={
  97590747,99510761, 160011012, 42596828, 160316017, 54912977, 18236002, 511009005, 81632206, 160316018, 160205061,
    98049915, 160012031, 81632103, 76937326, 100000658, 511002902, 81632102, 81632101
}
Card.IsCTLamp=MakeCheck({0xbc},CustomArchetype.CTLamp)


end


if not baux.RushProcedure then
	baux.RushProcedure = {}
	bRush = baux.RushProcedure
end
if not bRush then
	bRush = baux.RushProcedure
end

function bRush.addrules()
  return function(e,tp,eg,ep,ev,re,r,rp)
    --Disable left and right-most zones
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE_FIELD)
    e2:SetOperation(bRush.disabledzones)
    Duel.RegisterEffect(e2,tp)

    --Draw till you have 5 cards in hand
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DRAW_COUNT)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetValue(bRush.getcarddraw)
    Duel.RegisterEffect(e3,tp)

    --Give almost infinite normal summons
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1,0)
    e4:SetValue(999999999)
    Duel.RegisterEffect(e4,tp)

    --skip MP2

    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetCode(EFFECT_SKIP_M2)
    e5:SetTargetRange(1,0)
    Duel.RegisterEffect(e5,tp)

    --skip SP

    --local e7=Effect.CreateEffect(e:GetHandler())
    --e7:SetType(EFFECT_TYPE_FIELD)
    --e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    --e7:SetCode(EFFECT_SKIP_SP)
    --e7:SetTargetRange(1,0)
    --Duel.RegisterEffect(e7,tp)

    --disable EMZs
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_FORCE_MZONE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e6:SetTargetRange(1,0)
    e6:SetValue(bRush.znval)
    Duel.RegisterEffect(e6,tp)

    --give infinite hand size
    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_HAND_LIMIT)
    e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e7:SetTargetRange(1,0)
    e7:SetValue(100)
    Duel.RegisterEffect(e7,tp)
  end
end

function bRush.getcarddraw(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0) < 5 then
		return 5-Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
	else
		return 1
end
end

function bRush.znval(e)
	return ~(0x60)
end


function bRush.disabledzones(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandlerPlayer()==tp then
			return 0x00001111
	else
			return 0x11110000
	end
end


if not kdr then

	kdr_aux={}

	kdr=kdr_aux


	function kdr.IsQuestDone(tp)
		return Duel.GetFlagEffect(tp, 81632500)>0
	end

	function kdr.CompleteQuest(tp,card,e)
		Duel.RegisterFlagEffect(tp, 81632500, 0, 0, 0)

		Duel.RaiseEvent(card, EVENT_CUSTOM+81632500, e, REASON_RULE, tp, tp, 1)
	end

	function kdr.GetDex(tp)
		return Duel.GetFlagEffect(tp, 81632650)
	end

	function kdr.GetCon(tp)
		return Duel.GetFlagEffect(tp, 81632651)
	end

	function kdr.GetStr(tp)
		return Duel.GetFlagEffect(tp, 81632652)
	end





end
