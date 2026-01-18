--Time Dart Striker
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)	

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RELEASE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_RELEASE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)


end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsDart() and chkc:IsReleasable() and chkc:IsFaceup() end

    if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsDart() and c:IsReleasable() and c:IsFaceup() end,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsPlayerCanDraw(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectTarget(tp,function(c) return c:IsDart() and c:IsReleasable() and c:IsFaceup() end,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.HintSelection(g)
    Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)

    Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
        Duel.Draw(p,d,REASON_EFFECT)
    end
end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
    if chk==0 then return e:GetHandler():IsReleasable()
        and Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,e:GetHandler(),1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Release(e:GetHandler(),REASON_EFFECT)~=0 then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end