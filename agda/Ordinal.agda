module Ordinal where

open import Data.Sum using (_⊎_; inj₁; inj₂) 
import Relation.Binary.PropositionalEquality as Eq
open Eq using (_≡_; refl; cong; cong₂; subst; subst₂) renaming (sym to _⁻¹; trans to _∙_)
open import Relation.Nullary using (Dec; yes; no; ¬_)
open import Data.Empty using (⊥; ⊥-elim)
open import Level using(Level)

private variable
  ℓ : Level

infix 30 _<_ _≤_ _>_ _≥_

data MutualOrd : Set
data _<_ : MutualOrd → MutualOrd → Set
fst : MutualOrd → MutualOrd

_>_ _≥_ _≤_ : MutualOrd → MutualOrd → Set
a > b = b < a
a ≥ b = a > b ⊎ a ≡ b
a ≤ b = b ≥ a

data MutualOrd where
 𝟎 : MutualOrd
 ω^_+_[_] : (a b : MutualOrd) → a ≥ fst b → MutualOrd

private
 variable
  a b c d : MutualOrd
  r : a ≥ fst b
  s : c ≥ fst d

data _<_ where
 <₁ : 𝟎 < ω^ a + b [ r ]
 <₂ : a < c → ω^ a + b [ r ] < ω^ c + d [ s ]
 <₃ : a ≡ c → b < d → ω^ a + b [ r ] < ω^ c + d [ s ]

fst  𝟎               = 𝟎
fst (ω^ a + _ [ _ ]) = a

rest : MutualOrd → MutualOrd
rest  𝟎               = 𝟎
rest (ω^ _ + b [ _ ]) = b

caseMutualOrd : {A : Set ℓ} (x y : A) → MutualOrd → A
caseMutualOrd x y  𝟎               = x
caseMutualOrd x y (ω^ _ + _ [ _ ]) = y

𝟎≢ω : {r : a ≥ fst b} → ¬ (𝟎 ≡ ω^ a + b [ r ])
𝟎≢ω e = subst (caseMutualOrd MutualOrd ⊥) e 𝟎

ω≢𝟎 : {r : a ≥ fst b} → ¬ (ω^ a + b [ r ] ≡ 𝟎)
ω≢𝟎 e = subst (caseMutualOrd ⊥ MutualOrd) e 𝟎

<-irrefl : ¬ a < a
<-irrefl (<₂ r)     = <-irrefl r
<-irrefl (<₃ a=a r) = <-irrefl r

<-irreflexive : a ≡ b → ¬ a < b
<-irreflexive {a} e = subst (λ x → ¬ a < x) e <-irrefl

<IsPropValued : (p q : a < b) → p ≡ q
<IsPropValued <₁ <₁                   = refl
<IsPropValued (<₂ p) (<₂ q)           = cong <₂ (<IsPropValued p q)
<IsPropValued (<₂ p) (<₃ r q)         = ⊥-elim (<-irreflexive r p)
<IsPropValued (<₃ r p) (<₂ q)         = ⊥-elim (<-irreflexive r q)
<IsPropValued (<₃ refl p) (<₃ refl q) = cong (<₃ _) (<IsPropValued p q)

≤IsPropValued : (p q : a ≤ b) → p ≡ q
≤IsPropValued (inj₁ p) (inj₁ q)       = cong inj₁ (<IsPropValued p q)
≤IsPropValued (inj₁ p) (inj₂ e)       = ⊥-elim (<-irreflexive (e ⁻¹) p)
≤IsPropValued (inj₂ e) (inj₁ q)       = ⊥-elim (<-irreflexive (e ⁻¹) q)
≤IsPropValued (inj₂ refl) (inj₂ refl) = refl

MutualOrd⁼ : {r : a ≥ fst b} {s : c ≥ fst d} → a ≡ c → b ≡ d
           → ω^ a + b [ r ] ≡ ω^ c + d [ s ]
MutualOrd⁼ {r = r} {s = s} refl refl = cong ω^ _ + _ [_] (≤IsPropValued r s)

<-tri : (a b : MutualOrd) → a < b ⊎ a ≥ b
<-tri  𝟎                𝟎               = inj₂ (inj₂ refl)
<-tri  𝟎               (ω^ b + d [ _ ]) = inj₁ <₁
<-tri (ω^ a + c [ _ ])  𝟎               = inj₂ (inj₁ <₁)
<-tri (ω^ a + c [ _ ]) (ω^ b + d [ _ ]) with <-tri a b
<-tri (ω^ a + c [ _ ]) (ω^ b + d [ _ ]) | inj₁       a<b  = inj₁ (<₂ a<b)
<-tri (ω^ a + c [ _ ]) (ω^ b + d [ _ ]) | inj₂ (inj₁ a>b) = inj₂ (inj₁ (<₂ a>b))
<-tri (ω^ a + c [ _ ]) (ω^ b + d [ _ ]) | inj₂ (inj₂ a=b) with <-tri c d
<-tri (ω^ a + c [ _ ]) (ω^ b + d [ _ ]) | inj₂ (inj₂ a=b) | inj₁       c<d  = inj₁ (<₃ a=b c<d)
<-tri (ω^ a + c [ _ ]) (ω^ b + d [ _ ]) | inj₂ (inj₂ a=b) | inj₂ (inj₁ c>d) = inj₂ (inj₁ (<₃ (a=b ⁻¹) c>d))
<-tri (ω^ a + c [ _ ]) (ω^ b + d [ _ ]) | inj₂ (inj₂ a=b) | inj₂ (inj₂ c=d) = inj₂ (inj₂ (MutualOrd⁼ a=b c=d))

<-trans : a < b → b < c → a < c
<-trans  <₁      (<₂ _)   = <₁
<-trans  <₁      (<₃ _ _) = <₁
<-trans (<₂ r)   (<₂ s)   = <₂ (<-trans r s)
<-trans (<₂ r)   (<₃ p _) = <₂ (subst (λ x → _ < x) p r)
<-trans (<₃ p _) (<₂ s)   = <₂ (subst (λ x → x < _) (p ⁻¹) s)
<-trans (<₃ p r) (<₃ q s) = <₃ (p ∙ q) (<-trans r s)

≤-trans : a ≤ b → b ≤ c → a ≤ c
≤-trans (inj₁ a<b) (inj₁ b<c) = inj₁ (<-trans a<b b<c)
≤-trans (inj₁ a<b) (inj₂ c=b) = inj₁ (subst (λ x → _ < x) (c=b ⁻¹) a<b)
≤-trans (inj₂ b=a) (inj₁ b<c) = inj₁ (subst (λ x → x < _) b=a b<c)
≤-trans (inj₂ b=a) (inj₂ c=b) = inj₂ (c=b ∙ b=a)

<≤-trans : a < b → b ≤ c → a < c
<≤-trans a<b (inj₁ b<c) = <-trans a<b b<c
<≤-trans a<b (inj₂ c≡b) = subst (_ <_) (c≡b ⁻¹) a<b

Lm[≥→¬<] : a ≥ b → ¬ a < b
Lm[≥→¬<] (inj₁ b<a) a<b = <-irrefl (<-trans a<b b<a)
Lm[≥→¬<] (inj₂ a=b)     = <-irreflexive a=b


Lm[<→¬≥] : a < b → ¬ a ≥ b
Lm[<→¬≥] a<b (inj₁ a>b) = <-irrefl (<-trans a<b a>b)
Lm[<→¬≥] a<b (inj₂ a=b) = <-irreflexive a=b a<b

Lm[¬<→≥] : ¬ a < b → a ≥ b
Lm[¬<→≥] f with <-tri _ _
Lm[¬<→≥] f | inj₁       a<b  = ⊥-elim (f a<b)
Lm[¬<→≥] f | inj₂ (inj₁ a>b) = inj₁ a>b
Lm[¬<→≥] f | inj₂ (inj₂ a=b) = inj₂ a=b

<-dec : (a b : MutualOrd) → a < b ⊎ ¬ a < b
<-dec a b with <-tri a b
<-dec a b | inj₁ a<b = inj₁ a<b
<-dec a b | inj₂ a≥b = inj₂ (Lm[≥→¬<] a≥b)

<-≡ : {a b c : MutualOrd} → a < b → b ≡ c → a < c
<-≡ {a} e r = subst (a <_) r e

≤≥→≡ : a ≤ b → a ≥ b → a ≡ b
≤≥→≡ a≤b (inj₁ a>b) = ⊥-elim (Lm[<→¬≥] a>b a≤b)
≤≥→≡ a≤b (inj₂ a=b) = a=b

≮𝟎 : ¬ a < 𝟎
≮𝟎 ()

≥𝟎 : a ≥ 𝟎
≥𝟎 {𝟎}              = inj₂ refl
≥𝟎 {ω^ a + b [ _ ]} = inj₁ <₁

fst< : (a b : MutualOrd) (r : a ≥ fst b)
     → a < ω^ a + b [ r ]
fst<  𝟎               b r = <₁
fst< (ω^ a + c [ s ]) b r = <₂ (fst< a c s)

rest< : (a b : MutualOrd) (r : a ≥ fst b)
      → b < ω^ a + b [ r ]
rest< a  𝟎                _       = <₁
rest< a (ω^ b + c [ s ]) (inj₁ r) = <₂ r
rest< a (ω^ b + c [ s ]) (inj₂ e) = <₃ (e ⁻¹) (rest< b c s)

ω^⟨_⟩ : MutualOrd → MutualOrd
ω^⟨ a ⟩ = ω^ a + 𝟎 [ ≥𝟎 ]

𝟏 ω ω+1 ω+2 : MutualOrd
𝟏 = ω^⟨ 𝟎 ⟩
𝟐 = ω^ 𝟎 + 𝟏 [ inj₂ refl ]
ω = ω^⟨ 𝟏 ⟩

ω+1 = ω^ 𝟏 + 𝟏 [ inj₁ <₁ ]
ω+2 = ω^ 𝟏 + 𝟐 [ inj₁ <₁ ]

sucₒ : MutualOrd → MutualOrd
fst-ignores-suc : ∀ a → (fst a) ≡ fst (sucₒ a)

sucₒ 𝟎 = 𝟏
sucₒ ω^ a + b [ r ] = ω^ a + sucₒ b [ subst (a ≥_) (fst-ignores-suc b) r ]

fst-ignores-suc 𝟎              = refl
fst-ignores-suc ω^ a + b [ r ] = refl
  
_⊔ₒ_ : MutualOrd → MutualOrd → MutualOrd
𝟎 ⊔ₒ              a              = a
a              ⊔ₒ 𝟎              = a
ω^ a + b [ r ] ⊔ₒ ω^ c + d [ s ] with <-tri a c 
... | inj₁ _        = ω^ c + d [ s ]
... | inj₂ (inj₁ _) = ω^ a + b [ r ]
... | inj₂ (inj₂ _) with <-tri b d 
... | inj₁ _        = ω^ c + d [ s ]
... | inj₂ (inj₁ _) = ω^ a + b [ r ]
... | inj₂ (inj₂ _) = ω^ a + b [ r ]

open import Data.Nat using (ℕ)
ℕ→MutualOrd : ℕ → MutualOrd
ℕ→MutualOrd ℕ.zero    = 𝟎
ℕ→MutualOrd (ℕ.suc n) = sucₒ (ℕ→MutualOrd n)

fst[ℕ→MutualOrd]≡0 : ∀ n → fst (ℕ→MutualOrd n) ≡ 𝟎
fst[ℕ→MutualOrd]≡0 ℕ.zero    = refl
fst[ℕ→MutualOrd]≡0 (ℕ.suc n) = (fst-ignores-suc (ℕ→MutualOrd n) ⁻¹) ∙ (fst[ℕ→MutualOrd]≡0 n)

ω+ₙ_ : ℕ → MutualOrd
ω+ₙ n = ω^ 𝟏 + ℕ→MutualOrd n [ subst (𝟏 ≥_) (fst[ℕ→MutualOrd]≡0 n ⁻¹) (inj₁ <₁) ]

module Properties where 
  distributivity : ∀ (a b c : MutualOrd) (r : a ≥ fst (b ⊔ₒ c)) (s : a ≥ fst b) (t : a ≥ fst c) → 
    ω^ a + (b ⊔ₒ c) [ r ] ≡ ω^ a + b [ s ] ⊔ₒ ω^ a + c [ t ]
  distributivity a b c r s t with <-tri a a
  ... | inj₁ a<a = ⊥-elim (<-irrefl a<a)
  ... | inj₂ (inj₁ a<a) = ⊥-elim (<-irrefl a<a)
  distributivity a 𝟎 𝟎 r s t | inj₂ (inj₂ refl) = MutualOrd⁼ refl refl
  distributivity a 𝟎 ω^ c + c₁ [ x ] r s t | inj₂ (inj₂ refl) = MutualOrd⁼ refl refl
  distributivity a ω^ b + b₁ [ x ] 𝟎 r s t | inj₂ (inj₂ refl) = MutualOrd⁼ refl refl
  distributivity a ω^ ba + bb [ br ] ω^ ca + cb [ ct ] r s t | inj₂ (inj₂ refl) with <-tri ba ca 
  ... | inj₁ _ = MutualOrd⁼ refl refl
  ... | inj₂ (inj₁ _) = MutualOrd⁼ refl refl
  ... | inj₂ (inj₂ refl) with <-tri bb cb 
  ... | inj₁ _ = MutualOrd⁼ refl refl
  ... | inj₂ (inj₁ _) = MutualOrd⁼ refl refl
  ... | inj₂ (inj₂ _) = MutualOrd⁼ refl refl

  ¬ω^a+b<b : ∀ {a b : MutualOrd} {r : a ≥ fst b} → ¬ (ω^ a + b [ r ] < b)
  ¬ω^a+b<b {r = r} (<₂ a<c) = ⊥-elim (Lm[≥→¬<] r a<c)
  ¬ω^a+b<b (<₃ refl x)      = ⊥-elim (¬ω^a+b<b x)
  
  subsumption₁₀ : ∀ (b a  : MutualOrd) (s : a ≥ fst b) → b ⊔ₒ ω^ a + b [ s ] ≡ ω^ a + b [ s ]
  subsumption₁₀ 𝟎              a s = refl 
  subsumption₁₀ ω^ b + d [ r ] a s with <-tri b a 
  ... | inj₁ _          = refl
  ... | inj₂ (inj₁ a<b) = ⊥-elim (Lm[≥→¬<] s a<b)
  ... | inj₂ (inj₂ refl) with <-tri d ω^ b + d [ r ]
  ... | inj₁ _ = refl
  ... | inj₂ (inj₁ ω^b+d<d) = (⊥-elim (¬ω^a+b<b ω^b+d<d)) 

  ¬ω^a+suc[b]<b : ∀ {a b : MutualOrd} {r : a ≥ fst (sucₒ b)} → ¬ (ω^ a + sucₒ b [ r ] < b)
  ¬ω^a+suc[b]<b {r = r} (<₂ a<c) = ⊥-elim (Lm[≥→¬<] r a<c)
  ¬ω^a+suc[b]<b (<₃ refl x)      = ⊥-elim (¬ω^a+suc[b]<b x)

  ¬ω^a+suc[b]≡b : ∀ {a b : MutualOrd} {r : a ≥ fst (sucₒ b)} → ¬ (ω^ a + sucₒ b [ r ] ≡ b)
  ¬ω^a+suc[b]≡b {a} {b} {r = r} x = {!  !}
  
  subsumption₁₁ : ∀ (b a  : MutualOrd) (s : a ≥ fst (sucₒ b)) → b ⊔ₒ ω^ a + sucₒ b [ s ] ≡ ω^ a + sucₒ b [ s ]
  subsumption₁₁ 𝟎              a s = refl 
  subsumption₁₁ ω^ b + d [ r ] a s with <-tri b a 
  ... | inj₁ _          = refl
  ... | inj₂ (inj₁ a<b) = ⊥-elim (Lm[≥→¬<] s a<b)
  ... | inj₂ (inj₂ refl) with <-tri d (ω^ b + sucₒ d [ subst (λ b₁ → b₁ < b ⊎ b ≡ b₁) (fst-ignores-suc d) r ]) 
  ... | inj₁ x = refl
  ... | inj₂ (inj₁ x) = ⊥-elim (¬ω^a+suc[b]<b x)
  ... | inj₂ (inj₂ y) = ⊥-elim (¬ω^a+suc[b]≡b (y ⁻¹)) 

                     
  module TypeTheoreticOrdinal where           