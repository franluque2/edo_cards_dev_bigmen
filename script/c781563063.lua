--Castle of Dark Shadows
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
end
local CARD_YAMI=59197169

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecon)
    e1:SetOperation(s.rewriteop)
    Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetCondition(function(_e) return Duel.IsTurnPlayer(_e:GetHandlerPlayer()) end)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.valatk)
    Duel.RegisterEffect(e2,tp)
	--Def
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
    e3:SetValue(s.valdef)
    Duel.RegisterEffect(e3,tp)


    	local eset1=Effect.CreateEffect(c)
	eset1:SetType(EFFECT_TYPE_SINGLE)
	eset1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	eset1:SetCode(EFFECT_LIMIT_SET_PROC)
	eset1:SetCondition(s.ttcon)
	eset1:SetTarget(s.tttg)
	eset1:SetOperation(s.ttop)
	eset1:SetTargetRange(POS_FACEDOWN,0)
	local eset2=Effect.CreateEffect(c)
	eset2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	eset2:SetTargetRange(LOCATION_HAND,0)
	eset2:SetTarget(aux.TRUE)
	eset2:SetLabelObject(eset1)
    Duel.RegisterEffect(eset2,tp)

    	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SUMMON_PROC)
    e4:SetDescription(aux.Stringid(id, 2))
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetCondition(s.ntcon)
	e4:SetTarget(aux.FieldSummonProcTg(s.nttg))
	Duel.RegisterEffect(e4,tp)

    local e5=e4:Clone()
    e5:SetCode(EFFECT_SET_PROC)
    Duel.RegisterEffect(e5,tp)


    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetTargetRange(1,0)
    e6:SetCondition(function(_e) return Duel.IsExistingMatchingCard(aux.TRUE, _e:GetHandlerPlayer(), 0, LOCATION_MZONE, 1, nil) end)
    e6:SetValue(2)
    Duel.RegisterEffect(e6,tp)


    	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e7:SetTarget(s.reftg)
	e7:SetValue(1)
    Duel.RegisterEffect(e7,tp)


    --Once per turn, during the End Phase, you can flip any number of face-up monsters you control face-down (in face-down Attack or Defense Position), then shuffle any set cards in your Main Monster Zone.
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e8:SetCode(EVENT_PHASE+PHASE_END)
    e8:SetCountLimit(1)
    e8:SetCondition(s.flipcon)
    e8:SetOperation(s.flipop)
    Duel.RegisterEffect(e8,tp)


    local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_PIERCE)
	e9:SetTargetRange(0,LOCATION_MZONE)
    Duel.RegisterEffect(e9,tp)
end


function s.rewritefilter(c)
    return c:ListsCode(CARD_YAMI) and c:GetFlagEffect(id)==0
end

function s.rewritecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritefilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewriteop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rewritefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)

        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if Effect.IsHasCategory(eff, CATEGORY_SPECIAL_SUMMON) then
                eff:SetCondition(aux.TRUE)
            end
        end
    end
end


function s.valatk(e,c)
	if c:IsRace(RACE_FIEND|RACE_SPELLCASTER) then
        return math.floor(c:GetBaseAttack()*0.3)
	else return 0 end
end

function s.valdef(e,c)
	if c:IsRace(RACE_FIEND|RACE_SPELLCASTER) then
        return math.floor(c:GetBaseDefense()*0.3)
	else return 0 end
end


function s.ttcon(e,c)
	if c==nil then return true end
	min,max=c:GetTributeRequirement()
	return (Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0) or Duel.CheckTribute(c,min,max)
end
function s.tttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	min,max=c:GetTributeRequirement()
    if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and ((not Duel.CheckTribute(c,min,max)) or (max==0 or Duel.SelectYesNo(tp, aux.Stringid(id, 1)))) then
        return true
    end
	local g=Duel.SelectTribute(tp,c,min,max,nil,nil,nil,true)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	g:DeleteGroup()
end



function s.ntcon(e,c,minc)
	if c==nil then return true end
	return c:GetTributeRequirement()>0 and minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsMonster()
end


function s.reftg(e,c)
	return c:GetBattlePosition()==POS_FACEDOWN_ATTACK or c:GetBattlePosition()==POS_FACEDOWN_DEFENSE
end


function s.flipfilter(c)
    return c:IsFaceup() and c:IsCanChangePosition()
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.flipfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end
    local g=Duel.GetMatchingGroup(s.flipfilter, tp, LOCATION_MZONE, 0, nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g2=g:Select(tp,1,#g,nil)
    for tc in g2:Iter() do
        Duel.HintSelection(tc)
        local pos = Duel.SelectPosition(tp, tc, POS_FACEDOWN_ATTACK+POS_FACEDOWN_DEFENSE)
        Duel.ChangePosition(tc, pos)
    end

	Duel.ShuffleSetCard(g2)
end