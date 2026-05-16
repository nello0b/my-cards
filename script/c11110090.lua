--Vic Viper Beginning
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,66947414)
	c:EnableCounterPermit(0x1f)
	--Special Summon
	local e1_chk=aux.AddThisCardInGraveAlreadyCheck(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetLabelObject(e1_chk)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.spfilter(c,tp,se)
	return c:IsControler(tp) and c:IsSetCard(0x15) and c:IsFaceup()
		and (se==nil or c:GetReasonEffect()~=se)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter,1,nil,tp,se)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.setfilter(c)
	return (c:IsCode(66947414) or (aux.IsCodeOrListed(c,66947414) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local hp=e:GetHandler():GetOwner()
	if Duel.GetLocationCount(hp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,hp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(hp,s.setfilter,hp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(hp,g)
	end
end

--[[
(This card is always treated as an "B.E.S." card.)
If a "B.E.S." monster(s) is Normal or Special Summoned to your field (except during the Damage Step): You can Special Summon this card from your GY (if it was there when the Summon resolved) or hand (even if not). 
If this card is Normal or Special Summoned: The owner of this card Sets 1 "Boss Rush" or 1 Spell/Trap that mentions it, from thier Deck. 
You can only use each effect of "Vic Viper Beginning" once per turn.
]]