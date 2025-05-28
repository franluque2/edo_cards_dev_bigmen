--Divine Eradicator RX-ARES - Sky Judgment
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()

	Xyz.AddProcedure(c,nil,12,2)

	local chk1=Effect.CreateEffect(c)
    chk1:SetDescription(aux.Stringid(id, 0))
	chk1:SetType(EFFECT_TYPE_SINGLE)
	chk1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	chk1:SetCode(946)
	chk1:SetCondition(s.cusxyzCondition2(s.xyzfilter,s.xyzop))
    chk1:SetTarget(s.cusXyzTarget2(s.xyzfilter,s.xyzop))
    chk1:SetOperation(s.cusXyzOperation2(s.xyzfilter,s.xyzop))
	c:RegisterEffect(chk1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1173)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.cusxyzCondition2(s.xyzfilter,s.xyzop))
    e1:SetTarget(s.cusXyzTarget2(s.xyzfilter,s.xyzop))
    e1:SetOperation(s.cusXyzOperation2(s.xyzfilter,s.xyzop))
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetLabelObject(chk1)
	c:RegisterEffect(e1)

    --cannot prevent this xyz summon
    local e001=Effect.CreateEffect(c)
	e001:SetType(EFFECT_TYPE_SINGLE)
	e001:SetCode(EFFECT_CAN_ALWAYS_SPECIAL_SUMMON)
	e001:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e001)

    --extra material
    local e01=Effect.CreateEffect(c)
    e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e01:SetRange(LOCATION_EXTRA)
	e01:SetType(EFFECT_TYPE_FIELD)
    e01:SetCode(id)
    e01:SetTarget(s.xyztargfunc)
	e01:SetTargetRange(0,LOCATION_ONFIELD)
	c:RegisterEffect(e01)

	-- no damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e8:SetValue(1)
	c:RegisterEffect(e8)

		local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

end

function s.thfilter(c)
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if Effect.GetCode(eff)==EFFECT_CANNOT_SPECIAL_SUMMON or Effect.GetCode(eff)==EFFECT_FORCE_SPSUMMON_POSITION then
            local _,tar2=Effect.GetTargetRange(eff)
            return tar2~=0
		end
	end
	return false
end

function s.xyzfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsHasEffect(id) and not c:IsControler(tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end


function s.xyztg(e,c)
	return c:IsFaceup() and c:IsHasEffect(id)
end

function s.xyztargfunc(e,c)
	return c:IsFaceup() and s.thfilter(c)
end


function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove(tp,POS_FACEDOWN) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp,POS_FACEDOWN) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp,POS_FACEDOWN)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end


-- rewriting some xyz things to make this work



function s.cusxyzCondition2(alterf,op)
	return  function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_ONFIELD)
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,og,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				if #mustg>1 or (min and min>1) or not mg:Includes(mustg) then return false end
				local mustc=mustg:GetFirst()
				if mustc then
					return s.cusXyzAlterFilter(mustc,alterf,c,e,tp,op)
				else
					return mg:IsExists(s.cusXyzAlterFilter,1,nil,alterf,c,e,tp,op)
				end
			end
end
function s.cusXyzTarget2(alterf,op)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				local cancelable=not og and Duel.IsSummonCancelable()
				Xyz.ProcCancellable=cancelable
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_ONFIELD)
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,og,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				local oc
				if must and #must==min and #must==max then
					oc=mustg:GetFirst()
				elseif #mustg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local ocg=mustg:Select(tp,1,1,cancelable,nil)
					if ocg then
						oc=ocg:GetFirst()
					end
				else
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local ocg=mg:FilterSelect(tp,s.cusXyzAlterFilter,1,1,cancelable,nil,alterf,c,e,tp,op)
					if ocg then
						oc=ocg:GetFirst()
					end
				end
				if not oc or (op and not op(e,tp,1,oc)) then return false end
				e:SetLabelObject(oc)
				return true
			end
end
function s.cusXyzOperation2(alterf,op)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local oc=e:GetLabelObject()
				c:SetMaterial(oc)
				Duel.Overlay(c,oc)
			end
end


function s.cusXyzAlterFilter(c,alterf,xyzc,e,tp,op)
	if not alterf(c,tp,xyzc) or
		(c:IsControler(1-tp) and not c:GetFlagEffect(id)==0)
		or (op and not op(e,tp,0,c)) then return false end
	if xyzc:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,c,xyzc)>0
	else
		return Duel.GetMZoneCount(tp,c,tp)>0
	end
end