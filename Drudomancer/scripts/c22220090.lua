-- Drudomancer Eulogy
local s,id,o=GetID()
function s.initial_effect(c)
	--Destroy an opponent's Spell/Trap, or a monster if a Drudomancer is revealed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Shuffle 3 Illusion monsters into the Deck and Set this card from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.pubfilter(c)
	return c:IsPublic() and c:IsSetCard(0xdad) and c:IsType(TYPE_MONSTER)
end
function s.desfilter(c,canmon)
	return c:IsDestructable()
		and (c:IsType(TYPE_SPELL+TYPE_TRAP) or (canmon and c:IsType(TYPE_MONSTER)))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local canmon=Duel.IsExistingMatchingCard(s.pubfilter,tp,LOCATION_HAND,0,1,nil)
	if chkc then
		return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD)
			and s.desfilter(chkc,canmon)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil,canmon)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,canmon)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
function s.tdfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
			and s.tdfilter(chkc)
	end
	if chk==0 then
		return e:GetHandler():IsSSetable()
			and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SSet(tp,c)==0 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1,true)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end

--[[
Target 1 Spell/Trap your opponent controls, or, if a "Drudomancer" monster is
revealed in your hand, you can target 1 monster your opponent controls instead;
destroy it. If this card is in your GY: You can target 3 Illusion monsters in
your GY and/or banishment; Set this card (but banish it when it leaves the
field), and if you do, shuffle those targets into the Deck. You can only use
each effect of "Drudomancer Eulogy" once per turn.
]]
