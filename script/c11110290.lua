-- Dragunity Knight - Maltet
local s,id,o=GetID()
function s.initial_effect(c)
	-- Synchro Summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),1,1,aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1,99)
	c:EnableReviveSelection()
	-- Non-Tuner
	local e1=Effect.CreateGenericEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- Equip from GY/Opponent
	local e2=Effect.CreateTriggerEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg1)
	e2:SetOperation(s.eqop1)
	c:RegisterEffect(e2)
	-- Equip self to Dragunity
	local e3=Effect.CreateTriggerEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.eqtg2)
	e3:SetOperation(s.eqop2)
	c:RegisterEffect(e3)
end
s.listed_series={0x29}

function s.ntcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end

function s.eqfilter1(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqfilter2(c)
	return c:IsFaceup() and not c:IsForbidden()
end
function s.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and (Duel.IsExistingTarget(s.eqfilter1,tp,LOCATION_GRAVE,0,1,nil)
		or Duel.IsExistingTarget(s.eqfilter2,tp,0,LOCATION_MZONE,1,nil)) end
	local g1=Duel.GetMatchingGroup(s.eqfilter1,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.eqfilter2,tp,0,LOCATION_MZONE,nil)
	local g=Group.CreateGroup()
	if #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg1=Duel.SelectTarget(tp,s.eqfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
		g:Merge(sg1)
	end
	if #g2>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>(#g) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg2=Duel.SelectTarget(tp,s.eqfilter2,tp,0,LOCATION_MZONE,1,1,nil)
		g:Merge(sg2)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.eqop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetTargetCards(e)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #g>ft then return end
	local tc=g:GetFirst()
	while tc do
		if Duel.Equip(tp,tc,c) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end

function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x29),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsSetCard,0x29),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		if Duel.Equip(tp,c,tc) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(function(e,c) return c==tc end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end

--[[
1 Dragon Tuner + 1+ non-Tuner Winged Beast monsters
If this card you control would be used as Synchro Material, you can treat it as a non-Tuner.
You can only use each of the following effects of "Dragunity Knight - Maltet" once per turn.
If this card is Special Summoned: You can target 1 "Dragunity" monster in your GY and/or 1 face-up monster your opponent controls; equip them to this card.
If this card is sent from the field to the GY: You can equip it to 1 "Dragunity" monster you control.
]]