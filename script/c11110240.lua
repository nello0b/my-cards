-- Fabled Abyss
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate (negate/destroy), discard 1 only if activating the turn it was Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--You can activate this card the turn it was Set, by discarding 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--If a card(s) is sent from your hand to the GY, while this card is in your GY: Set this card, banish when it leaves
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)

	--Flag if this card was Set this turn
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end

end

s.listed_series={0x35}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsCode(id) then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end

function s.actcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end

function s.fsynfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x35) and c:IsType(TYPE_SYNCHRO)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	return Duel.IsExistingMatchingCard(s.fsynfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local setturn=c:GetFlagEffect(id)>0
	if chk==0 then
		return not setturn or Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
	end
	if setturn then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL then return false end
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsPreviousControler(tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SSET,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end

--[[
You can activate this card the turn it was Set, by discarding 1 card.
When your opponent activates a monster effect, while you control a "Fabled" Synchro Monster: Negate the activation, and if you do, destroy it.
If a card(s) is sent from your hand to the GY, while this card is in your GY (except during the Damage Step): You can Set this card, but banish it when it leaves the field.
You can only use each effect of "Fabled Abyss" once per turn.
]]