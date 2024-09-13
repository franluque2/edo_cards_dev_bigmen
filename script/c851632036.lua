--Evocator Voleuse
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Gemini.AddProcedure(c)

    --become an effect by discarding a card
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
    e1:SetCondition(aux.NOT, Gemini.EffectStatusCondition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

    --aux to tell when this is an effect monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_ADJUST)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(Gemini.EffectStatusCondition)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    --equip a card
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_CUSTOM+id)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.eqcon)
    e3:SetTarget(s.eqtarfunc)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
    e4:SetCondition(s.adcon)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetCondition(s.gaincon)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_GEMINI))
	e5:SetCode(EFFECT_GEMINI_STATUS)
	c:RegisterEffect(e5)


    aux.GlobalCheck(s,function()
		s.eqcount=0

        --count cards equipped this duel
        local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		ge1:SetCode(EVENT_EQUIP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)

        local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_STARTUP)
		ge2:SetOperation(s.checkop2)
		Duel.RegisterEffect(ge2,0)
        
	end)
end

s.GenCards={[0]=Group.CreateGroup(),[1]=Group.CreateGroup()}
s.listed_card_types={TYPE_GEMINI,TYPE_EQUIP}
s.listed_names={95750695}

local equips_to_create={12735388,19578592,21900719,22046459,68427465,90246973,242146,1118137,24845628,44092304,53363708,64867422,69954399,75524092,75560629,87481592,90861137,95515060,95638658}

function s.gaincon(e,tp,eg,ep,ev,re,r,rp,chk)
    return Gemini.EffectStatusCondition(e) and s.eqcount>5
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp,chk)
    return Gemini.EffectStatusCondition(e) and s.eqcount>1
end

function s.thfilter2(c)
	return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        Card.Recreate(tc, 95750695, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)

		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
    for i = 0, 1, 1 do
        for index, value in ipairs(equips_to_create) do
            local token=Duel.CreateToken(i, value)
            Group.AddCard(s.GenCards[i], token)
        end
    end
    e:Reset()

end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    s.eqcount=s.eqcount+#eg
end

function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
    Card.RegisterFlagEffect(e:GetHandler(), id, RESET_EVENT+RESETS_STANDARD, 0, 0)
    Duel.RaiseEvent(e:GetHandler(), EVENT_CUSTOM+id, re, r, rp, ep, ev)
end

function s.eqcon(e,tp,eg,ep,ev,re,r,rp,chk)
    if not Gemini.EffectStatusCondition(e) then return false end
    Card.ResetFlagEffect(e:GetHandler(), id)
    return true
end

function s.eqtarfunc(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,0)
end
function s.eqfilter2(c,tc)
	return c:IsFaceup() and tc:CheckEquipTarget(c)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local num1=Duel.GetRandomNumber(1, #s.GenCards[tp] )
    local num2=Duel.GetRandomNumber(1, #s.GenCards[tp] )
    while num2==num1 do
        num2=Duel.GetRandomNumber(1, #s.GenCards[tp] )
    end
    local num3=Duel.GetRandomNumber(1, #s.GenCards[tp] )
    while num3==num2 or num3==num1 do
        num3=Duel.GetRandomNumber(1, #s.GenCards[tp] )
    end

    num1,num2,num3=num1-1,num2-1,num3-1

    local tc1=Group.TakeatPos(s.GenCards[tp], num1)
    local tc2=Group.TakeatPos(s.GenCards[tp], num2)
    local tc3=Group.TakeatPos(s.GenCards[tp], num3)

    local sel=Group.FromCards(tc1,tc2,tc3)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
    local tc=sel:Select(tp, 1,1,nil):GetFirst()
    if tc then
        local token=Duel.CreateToken(tp, tc:GetOriginalCode())
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local tg=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,token)
        if #tg==0 then return end
        Duel.HintSelection(tg,true)
        local ectg=tg:GetFirst()
        Duel.BreakEffect()
        Duel.Equip(tp,token,ectg)
    end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():EnableGeminiStatus()
end