--Mementotlan Hourglass
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card, then destroy 1 other "Memento" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destroy 1 "Memento" monster in your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Add this card to your hand during the next Standby Phase after it was destroyed and sent to the GY
	local e4reg=Effect.CreateEffect(c)
	e4reg:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4reg:SetCode(EVENT_TO_GRAVE)
	e4reg:SetOperation(s.threg)
	c:RegisterEffect(e4reg)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	e4:SetLabelObject(e4reg)
	c:RegisterEffect(e4)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.desfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsDestructable()
end
function s.spdestfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsDestructable()
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.spdestfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.spdestfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,c)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.deckdesfilter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsDestructable() and not c:IsCode(id)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckdesfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.deckdesfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.threg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (r&REASON_DESTROY)==0 or ((r&REASON_BATTLE)==0 and (r&REASON_EFFECT)==0) then return end
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and c:GetFlagEffect(id)>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	c:ResetFlagEffect(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
