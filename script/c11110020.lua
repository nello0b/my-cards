--Aquamirror Crash
local s,id=GetID()
function s.initial_effect(c)
	--return to negate and shuffle
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--copy ritual spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.negfilter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand() and c:IsFaceup()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		return aux.ndcon(tp,re) and Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_HAND) then return end
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		rc:CancelToGrave()
		Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.cpfilter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_SPELL+TYPE_RITUAL) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(true,true,true)~=nil
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(true,true,true)
	if not te then return end
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
