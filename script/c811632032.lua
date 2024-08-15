--Summons of Future Past
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
end
local graveyardpend={}

local fusions_that_crash={73360025,47705572,72291412,3659803,6077601,12071500,36484016,45906428,54283059,71490127,80033124,32104431}


Duel.GetFusionMaterial=(function()
	local oldfunc=Duel.GetFusionMaterial
	return function(tp)
		local res=oldfunc(tp)
		local g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_REMOVED,0,nil,EFFECT_EXTRA_FUSION_MATERIAL)
		if #g>0 then
			res:Merge(g)
		end
		return res
	end
end)()


 function s.AuxHandling(e,tc,tp,sg)
		local rg=sg:Filter(Card.IsFacedown,nil)
		if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
		local sg1=sg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		Duel.SendtoDeck(sg1,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)

		Group.Sub(sg, sg1)
		sg1:Clear()

		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Clear()

end

Fusion.BanishMaterial=s.AuxHandling
Fusion.ShuffleMaterial=s.AuxHandling

local gPend=graveyardpend
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
        local c=e:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

        --Graveyard Pendulum
        gPend.AddGravePendProcedure()(e,tp,eg,ep,ev,re,r,rp)

        --Graveyard Xyz
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.rmop)
	Duel.RegisterEffect(e2,tp)

	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(511002793)
	e5:SetTargetRange(LOCATION_GRAVE,0)
	e5:SetTarget(s.eftg)
	Duel.RegisterEffect(e5,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	Duel.RegisterEffect(e4,tp)


	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetHintTiming(0,TIMING_MAIN_END)
	e6:SetCountLimit(1)
	e6:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase() end)
	e6:SetTarget(s.sctg)
	e6:SetOperation(s.scop)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(s.eftg2)
	e7:SetLabelObject(e6)
	Duel.RegisterEffect(e7,tp)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetTarget(s.mttg)
	e3:SetValue(1)
	e3:SetLabelObject({s.forced_replacement})
	Duel.RegisterEffect(e3,tp)

    local e21=Effect.CreateEffect(e:GetHandler())
    e21:SetType(EFFECT_TYPE_FIELD)
    e21:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
    e21:SetTargetRange(LOCATION_GRAVE+LOCATION_REMOVED,0)
	e21:SetTarget(aux.TargetBoolFunction(s.extrafil_repl_filter))
	e21:SetOperation(s.AuxHandling)
	e21:SetLabelObject({s.extrafil_replacement,s.extramat})
    e21:SetValue(1)
    Duel.RegisterEffect(e21,tp)
    end
end

function s.extrafil_repl_filter(c)
    return c:IsMonster() and ((c:IsAbleToDeck() and c:IsLocation(LOCATION_REMOVED)) or (c:IsAbleToRemove() and c:IsLocation(LOCATION_GRAVE)))
end
function s.extrafil_replacement(e,tp,mg)
    return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.extrafil_repl_filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
function s.extramat(c,e,tp)
    return c:IsControler(tp) and not e:GetHandler():IsOriginalCode(table.unpack(fusions_that_crash))
end


function s.mttg(e,c)
	local g=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_EXTRA,0,nil)
	return g:IsContains(c)
end
function s.forced_replacement(e,tp,sg,rc)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	return ct<=1,ct>1
end

function s.eftg2(e,c)
	return c:IsMonster() and c:IsType(TYPE_TUNER)
end

function s.eftg(e,c)
	return c:IsMonster()
end

function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,c):GetFirst()
	if sc then
		Duel.SynchroSummon(tp,sc,c)
	end
end

function s.gravexyzfilter(c)
    return c:IsPreviousLocation(LOCATION_GRAVE)
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and eg:IsExists(s.gravexyzfilter, 1, nil)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    for c in eg:Filter(s.gravexyzfilter, nil):Iter() do
       c:RegisterFlagEffect(id+1,RESET_EVENT+0x1fa0000,0,0)
    end
end


function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    for c in eg:Iter() do
        
        if c:GetFlagEffect(id+1)>0 then
            Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
            c:ResetFlagEffect(id+1)
        end
        end

end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end



function gPend.AddGravePendProcedure()
  return function(e,tp,eg,ep,ev,re,r,rp)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1074)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(gPend.Condition)
	e1:SetOperation(gPend.Operation)
	e1:SetValue(SUMMON_TYPE_PENDULUM)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(s.checkop)
	Duel.RegisterEffect(e2,tp)


    Duel.RegisterFlagEffect(e:GetHandlerPlayer(), 10000000, 0, 0, 0)

    end
end

function s.checkop(e,tp)
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz~=nil and lpz:GetFlagEffect(id)<=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(1074)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_PZONE)
		e1:SetCondition(gPend.Condition)
		e1:SetOperation(gPend.Operation)
		e1:SetValue(SUMMON_TYPE_PENDULUM)
		lpz:RegisterEffect(e1)
		lpz:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
	local olpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
	local orpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if olpz~=nil and orpz~=nil and olpz:GetFlagEffect(id)<=0
		and olpz:GetFlagEffectLabel(31531170)==orpz:GetFieldID()
		and orpz:GetFlagEffectLabel(31531170)==olpz:GetFieldID() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetDescription(1074)
			e1:SetCode(EFFECT_SPSUMMON_PROC_G)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_PZONE)
			e1:SetCondition(gPend.Condition)
			e1:SetOperation(gPend.Operation)
			e1:SetValue(SUMMON_TYPE_PENDULUM)
			olpz:RegisterEffect(e2)
		olpz:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end


function gPend.Filter(c,e,tp,lscale,rscale,lvchk)
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
    else
		lv=c:GetLevel()
	end
	return (c:IsLocation(LOCATION_HAND) or ((c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA))
        or (c:IsLocation(LOCATION_GRAVE) )))
		and ((lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false))
		and not c:IsForbidden()
end
function gPend.Condition(e,c,ischain,re,rp)
				if c==nil then return true end
				local tp=c:GetControler()
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				if rpz==nil or c==rpz or (not inchain and Duel.GetFlagEffect(tp,81632992-500)>0) then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local loc=0
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND+LOCATION_GRAVE end
				if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
				if loc==0 then return false end
				local g=nil
				if og then
					g=og:Filter(Card.IsLocation,nil,loc)
				else
					g=Duel.GetFieldGroup(tp,loc,0)
				end
				return g:IsExists(gPend.Filter,1,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
			end
function gPend.Operation(e,tp,eg,ep,ev,re,r,rp,c,sg,inchain)
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
				local ft=Duel.GetUsableMZoneCount(tp)
				if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
					if ft1>0 then ft1=1 end
					if ft2>0 then ft2=1 end
					ft=1
				end
				local loc=0
				if ft1>0 then loc=loc+LOCATION_HAND+LOCATION_GRAVE end
				if ft2>0 then loc=loc+LOCATION_EXTRA end
				local tg=nil
				if og then
					tg=og:Filter(Card.IsLocation,nil,loc):Match(gPend.Filter,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				else
					tg=Duel.GetMatchingGroup(gPend.Filter,tp,loc,0,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				end
				ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE))
				ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
				ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
				while true do
					local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE)
					local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
					local ct=ft
					if ct1>ft1 then ct=math.min(ct,ft1) end
					if ct2>ft2 then ct=math.min(ct,ft2) end
					local loc=0
					if ft1>0 then loc=loc+LOCATION_HAND+LOCATION_GRAVE end
					if ft2>0 then loc=loc+LOCATION_EXTRA end
					local g=tg:Filter(Card.IsLocation,sg,loc)
					if #g==0 or ft==0 then break end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tc=Group.SelectUnselect(g,sg,tp,#sg>0,Duel.IsSummonCancelable())
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
						if tc:IsLocation(LOCATION_HAND+LOCATION_GRAVE) then
							ft1=ft1+1
						else
							ft2=ft2+1
						end
						ft=ft+1
					else
						sg:AddCard(tc)
						if c:IsHasEffect(511007000)~=nil or rpz:IsHasEffect(511007000)~=nil then
							if not gPend.Filter(tc,e,tp,lscale,rscale) then
								local pg=sg:Filter(aux.TRUE,tc)
								local ct0,ct3,ct4=#pg,pg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE),pg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
								sg:Sub(pg)
								ft1=ft1+ct3
								ft2=ft2+ct4
								ft=ft+ct0
							else
								local pg=sg:Filter(aux.NOT(gPend.Filter),nil,e,tp,lscale,rscale)
								sg:Sub(pg)
								if #pg>0 then
									if pg:GetFirst():IsLocation(LOCATION_HAND+LOCATION_GRAVE) then
										ft1=ft1+1
                                    else
                                        ft2=ft2+1
                                    end
									ft=ft+1
								end
							end
						end
						if tc:IsLocation(LOCATION_HAND+LOCATION_GRAVE) then
							ft1=ft1-1
						else
							ft2=ft2+1
						end
						ft=ft-1
					end
				end
				if #sg>0 then
					if not inchain then
						Duel.RegisterFlagEffect(tp,81632992-500,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
					end

					Duel.HintSelection(Group.FromCards(c),true)
					Duel.HintSelection(Group.FromCards(rpz),true)

					local tc=sg:GetFirst()
					Duel.SpecialSummonComplete()
				end
			end