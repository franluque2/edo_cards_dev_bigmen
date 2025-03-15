--Backdraft
local s,id=GetID()
function s.initial_effect(c)
		--Activate
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
        e1:SetType(EFFECT_TYPE_ACTIVATE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetCondition(s.condition)
        e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
        e1:SetTarget(s.target)
        e1:SetOperation(s.activate)
        c:RegisterEffect(e1)
end

    function s.condition(e,tp,eg,ep,ev,re,r,rp)
        return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
    end
    
    function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
        Duel.SetTargetPlayer(tp)
        Duel.SetTargetParam(2)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
        Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,3000)
    end

    function s.notfiendorspellfilter(c)
        return not (c:IsType(TYPE_SPELL) or c:IsRace(RACE_FIEND))
    end
    function s.activate(e,tp,eg,ep,ev,re,r,rp)
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        local g=Duel.GetDecktopGroup(p, d)
        if Duel.Draw(p,d,REASON_EFFECT)>0 then
            local fg=g:Filter(s.notfiendorspellfilter,nil)
            if #fg>0 then
                Duel.ConfirmCards(1-p, fg)
                Duel.Remove(fg, POS_FACEDOWN, REASON_EFFECT)
            end
    
            Duel.BreakEffect()
            Duel.Damage(p, 3000, REASON_EFFECT)
        end

    end
    