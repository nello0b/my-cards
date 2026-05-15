local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,66947414)
	c:EnableCounterPermit(0x1f)
	-- If a "B.E.S." monster(s) is Normal or Special Summoned to your field (except during the Damage Step):
	-- You can Special Summon this card from your hand or GY.
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	

	-- If this card is Normal or Special Summoned: Set 1 "Boss Rush" (66947414) or 1 Spell/Trap that mentions it, from the Deck.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end


function s.setfilter(c)
	return (c:IsCode(66947414) or (aux.IsCodeListed(c,66947414) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then Duel.SSet(tp,tc) end
end

-- helpers for summon trigger
function s.spfilter(c,tp,se)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x15) and (se==nil or c:GetReasonEffect()~=se)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	local ph=Duel.GetCurrentPhase()
	if ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL then return false end
	return eg:IsExists(s.spfilter,1,nil,tp,se)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
