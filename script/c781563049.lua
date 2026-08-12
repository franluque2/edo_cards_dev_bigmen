--Past in Flames
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCondition(function (_e) return Duel.GetTurnCount()<=2 and Duel.IsTurnPlayer(_e:GetHandlerPlayer()) end)
    e1:SetCountLimit(1)
    e1:SetOperation(s.placebackrow)
    Duel.RegisterEffect(e1,tp)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.reinclinkcon)
	e2:SetTarget(s.reinclinktg)
	e2:SetOperation(s.reinclinkop)
	e2:SetValue(SUMMON_TYPE_LINK)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetTarget(function(e,c) return c:IsRace(RACE_WARRIOR) and c:IsLinkMonster() end)
	e3:SetLabelObject(e2)
    Duel.RegisterEffect(e3,tp)


    --While you control an Equip Spell, Gemini monsters you control become Effect monsters and gain their effects.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_GEMINI))
	e4:SetCode(EFFECT_GEMINI_STATUS)
    e4:SetCondition(s.geminicon)
    Duel.RegisterEffect(e4,tp)

end

function s.geminicon(e)
    return Duel.IsExistingMatchingCard(Card.IsType, e:GetHandlerPlayer(), LOCATION_SZONE, 0, 1, nil, TYPE_EQUIP)
end

function s.placebackrow(e,tp,eg,ep,ev,re,r,rp)
    --At the start of your first turn, place 1 "Gearbreed" and 1 "Gemini Ablation" face-up in your Spell & Trap Zone from Outside the Duel.
    local gearbreed=Duel.CreateToken(tp, 27979109)
    local geminiablation=Duel.CreateToken(tp, 80758812)

    Duel.MoveToField(gearbreed, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
    Duel.MoveToField(geminiablation, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
end


function s.reincmatfilter(c,lc,tp)
	return c:IsFaceup() and c:IsLinkMonster()
		and c:IsRace(RACE_WARRIOR,lc,SUMMON_TYPE_LINK,tp) and c:IsCanBeLinkMaterial(lc,tp)
        and c:IsLink(lc:GetLink()) and c:GetLink()>0
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0
end
function s.reinclinkcon(e,c,must,g,min,max)
	if c==nil then return true end
    if Duel.GetMatchingGroupCount(aux.TRUE, c:GetControler(), 0, LOCATION_MZONE, nil) == 0 then return false end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	return ((#mustg==1 and s.reincmatfilter(mustg:GetFirst(),c,tp)) or (#mustg==0 and #g>0))
		and not Duel.HasFlagEffect(tp,id+500)
end
function s.reinclinktg(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
	local g=Duel.GetMatchingGroup(s.reincmatfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	if #mustg>0 then
		if #mustg>1 then
			return false
		end
		mustg:KeepAlive()
		e:SetLabelObject(mustg)
		return true
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
	local tc=g:SelectUnselect(Group.CreateGroup(),tp,false,true)
	if tc then
		local sg=Group.FromCards(tc)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.reinclinkop(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
	Duel.Hint(HINT_CARD,0,id)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL|REASON_LINK)
	Duel.RegisterFlagEffect(tp,id+500,RESET_PHASE|PHASE_END,0,1)
end