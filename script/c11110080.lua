--Boss Rush #2
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,68468459)
	--This card is always treated as "Boss Rush"
	aux.EnableChangeCode(c,68468459,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	c:EnableCounterPermit(0x1f)
	--If your face-up "B.E.S." monster is destroyed: Special Summon 1 different-name "B.E.S." monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Negate opponent monster effect (once per turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end

function s.desfilter(c,tp)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.samecode(c,code,tp)
	return s.desfilter(c,tp) and c:GetPreviousCodeOnField()==code
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil,tp)
end
function s.spfilter(c,e,tp,eg)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not eg:IsExists(s.samecode,1,nil,c:GetCode(),tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,eg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,eg)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.ctfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and c:IsCanRemoveCounter(tp,0x1f,1,REASON_EFFECT)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and e:GetHandler():GetFlagEffect(id)==0
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVECNT)
	local tc=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if tc and tc:RemoveCounter(tp,0x1f,1,REASON_EFFECT) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
end
