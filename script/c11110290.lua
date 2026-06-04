-- Dragunity Knight - Maltet
local s,id,o=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	--treat as non-Tuner for a Synchro Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(s.ntval)
	c:RegisterEffect(e1)
	--equip Dragunity monster from your GY and/or opponent's face-up monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	--equip this card to a Dragunity monster you control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.eqstg)
	e3:SetOperation(s.eqsop)
	c:RegisterEffect(e3)
end
function s.ntval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
function s.eqfilter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.oppfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtgfilter(c,tp)
	return (c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and s.eqfilter(c))
		or (c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and s.oppfilter(c))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return s.eqtgfilter(chkc,tp)
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingTarget(s.oppfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return ft>0 and (b1 or b2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqtgfilter,tp,LOCATION_GRAVE,LOCATION_MZONE,1,1,nil,tp)
	if ft>1 then
		local tc=g:GetFirst()
		if tc and tc:IsLocation(LOCATION_GRAVE) and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local sg=Duel.SelectTarget(tp,s.oppfilter,tp,0,LOCATION_MZONE,1,1,nil)
			g:Merge(sg)
		elseif tc and tc:IsLocation(LOCATION_MZONE) and b1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local sg=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			g:Merge(sg)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
	local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gy>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gy,#gy,0,0)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<#sg then return end
	local tc=sg:GetFirst()
	while tc do
		if tc:IsType(TYPE_MONSTER) and not tc:IsForbidden() and Duel.Equip(tp,tc,c,false) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1)
		end
		tc=sg:GetNext()
	end
	Duel.EquipComplete()
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.eqstgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER)
end
function s.eqstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqstgfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsType(TYPE_MONSTER) and not e:GetHandler():IsForbidden()
		and Duel.IsExistingTarget(s.eqstgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqstgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqsop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and not c:IsForbidden() then
		if not Duel.Equip(tp,c,tc) then return end
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		c:RegisterEffect(e1)
	end
end

--[[
1 Dragon Tuner + 1+ non-Tuner Winged Beast monsters
If this card you control would be used as Synchro Material, you can treat it as a non-Tuner.
You can only use each of the following effects of "Dragunity Knight - Maltet" once per turn.
If this card is Special Summoned: You can target 1 "Dragunity" monster in your GY and/or 1 face-up monster your opponent controls; equip them to this card.
If this card is sent to the GY: You can equip this card to 1 "Dragunity" monster you control.
]]