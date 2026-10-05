-- Argostars - Counter Attack
local s,id,o=GetID()
local SET_ARGOSTARS=0x1c1

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.mzfilter(c)
	return c:IsFaceup() and c:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP) and c:IsSetCard(SET_ARGOSTARS)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.mzfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.banfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ARGOSTARS) and c:IsType(TYPE_MONSTER)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_REMOVED,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_REMOVED,0,1,nil) then
		local tc=re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then Duel.Destroy(tc,REASON_EFFECT) end
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetActivateLocation()==LOCATION_MZONE
		and rc:IsFaceup() and rc:IsSetCard(SET_ARGOSTARS)
		and rc:IsAllTypes(TYPE_CONTINUOUS+TYPE_TRAP)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsRelateToEffect(e) then
		Duel.SSet(tp,e:GetHandler())
	end
end
