big_aux={}

baux=big_aux

SPACE_YGGDRAGO=81632487

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
    98049915, 160012031, 81632103, 76937326, 100000658, 511002902, 81632102, 81632101, 72869010, 19066538
}
Card.IsCTLamp=MakeCheck({0xbc},CustomArchetype.CTLamp)

CustomArchetype.CTFriendship={
  82085619, 02295831, 81332143, 511001802
}
Card.IsCTFriendship=MakeCheck({0x259c},CustomArchetype.CTFriendship) 

CustomArchetype.CTDarkness={
  18967507,79266769,31571902,22586618,
		86229493,93709215,60417395,73018302,
		18897163,6764709,47297616,96561011,
		88264978, 160302004,160015001,160015004,160202036,160016018,
    160003040,160428006,160428007,160011030,160015009,160428008,
    160015010,160015003,160203027,160428020,160015036,160015040,
    160015035,160204023
}
Card.IsCTDarkness=MakeCheck({0x316},CustomArchetype.CTDarkness)



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

bRush.CreateConjureRitualProc = aux.FunctionWithNamedArgs(
function(c,_type,conjurename,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
	if filter and type(filter)=="function" then
		local mt=c.__index
		if not mt.ritual_matching_function then
			mt.ritual_matching_function={}
		end
		mt.ritual_matching_function[c]=filter
	end

  if not conjurename then
    return
  end


  local ge1=Effect.CreateEffect(c)
  ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  ge1:SetCode(EVENT_PREDRAW)
  ge1:SetCountLimit(1)
  ge1:SetLabel(conjurename)
  ge1:SetOperation(bRush.checkop)
  Duel.RegisterEffect(ge1,0)


	local e1=Effect.CreateEffect(c)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1171)
	end
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetLabel(conjurename)
	e1:SetTarget(bRush.ritConjureTarget(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos,extratg))
	e1:SetOperation(bRush.ritConjureOp(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos))
	return e1
end,"handler","lvtype","conjurename","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos","extratg")

bRush.RitualsToSummon={}
bRush.RitualsToSummon[0]={}
bRush.RitualsToSummon[1]={}

bRush.checkop= function(e)
  for tp = 0, 1, 1 do
    if Duel.GetFlagEffect(tp, e:GetHandler():GetOriginalCode())==0 then
      Duel.RegisterFlagEffect(tp, e:GetHandler():GetOriginalCode(), 0, 0, 0)
      local token=Duel.CreateToken(tp, e:GetLabel())
      Duel.SendtoDeck(token, nil, -2, REASON_RULE)
      bRush.RitualsToSummon[tp][e:GetLabel()]=token
  end
  end
end


bRush.getRitualConjureTarget=function (code,tp)
  return bRush.RitualsToSummon[tp][code]
end

local function ExtraReleaseFilter(c,tp)
	return c:IsControler(1-tp) and c:IsHasEffect(EFFECT_EXTRA_RELEASE)
end

local function ForceExtraRelease(mg)
	return function(e,tp,g,c)
		return g:Includes(mg)
	end
end

bRush.ritConjureTarget = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos,extratg)
	location = location or LOCATION_EXTRA
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
					--add that forcedselection to the one of the Ritual Spell, if any
					local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					local func=forcedselection
					--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
					--used as material
					local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
					if #extra_mat_g>0 then
						func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
					end
					if #extra_eff_g>0 then
						local prev_repl_function=nil
						for tmp_c in extra_eff_g:Iter() do
							local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
							for _,eff in ipairs(effs) do
								local repl_function=eff:GetLabelObject()
								if repl_function and prev_repl_function~=repl_function[1] then
									prev_repl_function=repl_function[1]
									func=MergeForcedSelection(func,repl_function[1])
								end
							end
						end
					end
					Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
          return Ritual.Filter(bRush.getRitualConjureTarget(e:GetLabel(),tp),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
				end
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","specificmatfilter","requirementfunc","sumpos","extratg")

local function MergeForcedSelection(f1,f2)
	if f1==nil or f2==nil then
		return f1 or f2
	end
	return function(...)
		local ret1,ret2=f1(...)
		local repl1,repl2=f2(...)
		return ret1 and repl1,ret2 or repl2
	end
end

bRush.ritConjureOp = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos)
	location = location or LOCATION_EXTRA
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
				--add that forcedselection to the one of the Ritual Spell, if any
				local func=forcedselection
				local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
				if #extra_eff_g>0 then
					local prev_repl_function=nil
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							local repl_function=eff:GetLabelObject()
							if repl_function and prev_repl_function~=repl_function[1] then
								prev_repl_function=repl_function[1]
								func=MergeForcedSelection(func,repl_function[1])
							end
						end
					end
				end
				--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
				--used as material
				local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
				if #extra_mat_g>0 then
					func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
				end
				Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Group.FromCards(bRush.getRitualConjureTarget(e:GetLabel(),tp))
				if #tg>0 then
					local tc=tg:GetFirst()
					local lv=(lv and (type(lv)=="function" and lv(tc)) or lv) or tc:GetLevel()
					lv=math.max(1,lv)
					Ritual.SummoningLevel=lv
					local mat=nil
					mg:Match(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					if specificmatfilter then
						mg:Match(specificmatfilter,nil,tc,mg,tp)
					end
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,func,_type)
						mat=tc:GetMaterial()
					else
						func=MergeForcedSelection(tc.ritual_custom_check,func)
						if tc.mat_filter then
							mg:Match(tc.mat_filter,tc,tp)
						end
						if ft>0 and not func then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							if _type==RITPROC_EQUAL then
								mat=mg:SelectWithSumEqual(tp,requirementfunc or Card.GetRitualLevel,lv,1,#mg,tc)
							else
								mat=mg:SelectWithSumGreater(tp,requirementfunc or Card.GetRitualLevel,lv,tc)
							end
						else
							mat=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(tc,lv,WrapTableReturn(func),_type,requirementfunc),1,tp,HINTMSG_RELEASE,Ritual.Finishcon(tc,lv,WrapTableReturn(func),requirementfunc,_type))
						end
					end
					--check if a card from an "once per turn" EFFECT_EXTRA_RITUAL_MATERIAL effect was selected
					local extra_eff_g=mat:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							--if eff is OPT and tmp_c is not returned
							--by the Ritual Spell's exrafil
							--then use the count limit and register
							--the flag to turn the extra eff OFF
							--requires the EFFECT_EXTRA_RITUAL_MATERIAL effect
							--to check the flag in its condition
							local _,max_count_limit=eff:GetCountLimit()
							if max_count_limit>0 and not mg2:IsContains(tmp_c) then
								eff:UseCountLimit(tp,1)
								Duel.RegisterFlagEffect(tp,eff:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1)
							end
						end
					end
					if not customoperation then
            local tc2=Duel.CreateToken(tp, tc:GetOriginalCode())
						tc2:SetMaterial(mat)
						if extraop then
							extraop(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc2)
						else
							Duel.ReleaseRitualMaterial(mat)
						end
						Duel.BreakEffect()
						Duel.SpecialSummon(tc2,SUMMON_TYPE_RITUAL,tp,tp,false,true,sumpos)
						tc2:CompleteProcedure()
						if tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc2) end
						if stage2 then
							stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc2)
						end
					else
						customoperation(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc2)
					end
					Ritual.SummoningLevel=nil
				end
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos")


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
		return Duel.GetFlagEffect(tp, 881632500)>0
	end

	function kdr.CompleteQuest(tp,card,e)
		Duel.RegisterFlagEffect(tp, 881632500, 0, 0, 0)

		Duel.RaiseEvent(card, EVENT_CUSTOM+881632500, e, REASON_RULE, tp, tp, 1)
	end

	function kdr.GetDex(tp)
		return Duel.GetFlagEffect(tp, 881632650)
	end

	function kdr.GetCon(tp)
		return Duel.GetFlagEffect(tp, 881632651)
	end

	function kdr.GetStr(tp)
		return Duel.GetFlagEffect(tp, 881632652)
	end





end

if not Skills then
  Skills={}
  Skills[0]=nil
  Skills[1]=nil

  local notcopyskills={81632944,81632943,81632987,881632757}

  function Skills.getSkill()
    return Skills[0]
  end

  function Skills.checkValidSkill(val)
    for index, value in ipairs(notcopyskills) do
      if val==value then return false end
    end
    return true
  end

  function Skills.setSkill(val)
    if Skills.checkValidSkill(val) then
      Skills[0]=val
    end
  end

  aux.AddSkillProcedure = (function()
    local oldfunc = aux.AddSkillProcedure
    return function(c,coverNum,drawless,skillcon,skillop,countlimit)
		if Skills.getSkill()==nil then
			Skills.setSkill(c:GetOriginalCode())
		end
        local res=oldfunc(c,coverNum,drawless,skillcon,skillop,countlimit)
        return res
    end
end)()
end



