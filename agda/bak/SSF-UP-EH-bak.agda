module SSF-up2-EH where

open import Axiom.Extensionality.Propositional using (∀-extensionality; Extensionality)
open import Level using (Level; Lift; lift; zero; suc; _⊔_)
open import Data.Unit using (⊤; tt)
open import Data.Product using (_×_; _,_; proj₁; proj₂)
open import Data.Nat using (ℕ) renaming (zero to zeroℕ; suc to sucℕ) 
open import Data.List using (List; []; _∷_)
open import Data.List.Membership.Propositional using (_∈_) 
open import Data.List.Relation.Unary.Any using (here; there)
open import Data.Product using (_,_; _×_; ∃-syntax)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; trans; cong; cong₂; subst)
open import Function using (_∘_; id; flip; _$_)
open import ExtendedHierarchy using (𝟎; 𝟏; ω; ω+ₙ_; ⌊_⌋; cast; β-suc-zero; β-suc-ω; β-suc-⌊⌋; ω^_+_;  <₁; <₂; <₃; ℕ→MutualOrd)
open import BoundQuantification using (BoundLevel; BoundLift; bound-lift; bound-unlift; _,_; #; #<Λ; _<_; <₁; <₂; <₃)


postulate
  fun-ext : ∀ {ℓ₁ ℓ₂} → Extensionality ℓ₁ ℓ₂

dep-ext : ∀ {ℓ₁ ℓ₂} {A : Set ℓ₁} {F G : (a : A) → Set ℓ₂} → 
  ((a : A) → F a ≡ G a) → ((a : A) → F a) ≡ ((a : A) → G a) 
dep-ext = ∀-extensionality fun-ext _ _

LEnv = List ⊤

variable
  δ δ′ δ₁ δ₂ δ₃ : LEnv

data LivesIn : Set where
  <ω : LivesIn
  <ω> : LivesIn

variable
  μ μ′ μ₁ μ₂ μ₃ : LivesIn
    
_⊔̌_ : LivesIn → LivesIn → LivesIn
<ω> ⊔̌ _ = <ω>
_ ⊔̌ <ω> = <ω>
<ω ⊔̌ <ω = <ω
    
data Lvl (δ : LEnv) : LivesIn → Set where 
  `zero : Lvl δ <ω
  `suc  : Lvl δ μ → Lvl δ μ
  `_    : ∀ {l} → l ∈ δ → Lvl δ <ω
  _`⊔_  : Lvl δ μ₁ → Lvl δ μ₂ → Lvl δ (μ₁ ⊔̌ μ₂)
  ⟨_⟩   : Lvl δ <ω → Lvl δ <ω>
  `ω    : Lvl δ <ω>
      
variable
  l l′ l₁ l₂ l₃ : Lvl δ μ
    
Lwk  : Lvl δ μ → Lvl (tt ∷ δ) μ
Lwk `zero      = `zero
Lwk (`suc l)   = `suc (Lwk l)
Lwk (` x)      = ` (there x)
Lwk (l₁ `⊔ l₂) = Lwk l₁ `⊔ Lwk l₂
Lwk ⟨ l ⟩      = ⟨ Lwk l ⟩ 
Lwk `ω         = `ω

_[_]LL : Lvl (tt ∷ δ) μ → Lvl δ <ω → Lvl δ μ
`zero         [ l′ ]LL = `zero
`suc l        [ l′ ]LL = `suc (l [ l′ ]LL)
(` here refl) [ l′ ]LL = l′
(` there x)   [ l′ ]LL = ` x
(l₁ `⊔ l₂)    [ l′ ]LL = (l₁ [ l′ ]LL) `⊔ (l₂ [ l′ ]LL)
⟨ l ⟩         [ l′ ]LL = ⟨ l [ l′ ]LL ⟩
`ω            [ l′ ]LL = `ω

⟦_⟧δ : (δ : LEnv) → Set
⟦ []    ⟧δ = ⊤
⟦ x ∷ δ ⟧δ = BoundLevel ⌊ ω ⌋ × ⟦ δ ⟧δ

variable
  κ κ′ κ₁ κ₂ κ₃ : ⟦ δ ⟧δ
    
[]κ : ⟦ [] ⟧δ
[]κ = tt

_∷κ_ : (BoundLevel ⌊ ω ⌋) → ⟦ δ ⟧δ → ⟦ tt ∷ δ ⟧δ
_∷κ_ = _,_

lookup-κ : ⟦ δ ⟧δ → tt ∈ δ → BoundLevel ⌊ ω ⌋
lookup-κ {_ ∷ δ} (ℓ , κ) (here refl) = ℓ
lookup-κ {_ ∷ δ} (ℓ , κ) (there x)   = lookup-κ κ x

drop-κ : ⟦ tt ∷ δ ⟧δ → ⟦ δ ⟧δ
drop-κ (_ , κ) = κ

⟦_⟧L : ∀ {δ : LEnv} → (l : Lvl δ μ) → ⟦ δ ⟧δ → BoundLevel ⌊ ω ⌋
⟦ `zero    ⟧L κ = zero , {!   !}
⟦ `suc l   ⟧L κ = suc (# (⟦ l ⟧L κ)) , {!   !}
⟦ ` x      ⟧L κ = lookup-κ κ x
⟦ l₁ `⊔ l₂ ⟧L κ = (# (⟦ l₁ ⟧L κ)) ⊔ (# (⟦ l₂ ⟧L κ)) , {!   !}
⟦ ⟨ l ⟩    ⟧L κ = # (⟦ l ⟧L κ) , {!   !} 
⟦ `ω       ⟧L κ = ⌊ ω ⌋ , {!   !} 

postulate
  ⟦⟧L-Lwk : ∀ (l : Lvl δ μ) κ → ⟦ Lwk l ⟧L κ ≡ ⟦ l ⟧L (drop-κ κ)
-- ⟦⟧L-Lwk `zero      κ = refl
-- ⟦⟧L-Lwk (`suc l)   κ = cong suc (⟦⟧L-Lwk l κ)
-- ⟦⟧L-Lwk (` x)      κ = refl
-- ⟦⟧L-Lwk (l₁ `⊔ l₂) κ = cong₂ _⊔_ (⟦⟧L-Lwk l₁ κ) (⟦⟧L-Lwk l₂ κ)
-- ⟦⟧L-Lwk ⟨ l ⟩      κ = ⟦⟧L-Lwk l κ
-- ⟦⟧L-Lwk `ω         κ = refl

data TEnv : LEnv → Set where
  []   : TEnv δ
  _∷_  : (l : Lvl δ μ) → TEnv δ → TEnv δ 
  ∷l_  : TEnv δ → TEnv (tt ∷ δ) 

variable
  Δ Δ′ Δ₁ Δ₂ Δ₃ : TEnv δ

suc⨆Δ :  {δ : LEnv} → ⟦ δ ⟧δ → TEnv δ → BoundLevel ⌊ ω ⌋
suc⨆Δ κ [] = zero , {!   !}
suc⨆Δ κ (l ∷ Δ) = suc (# (⟦ l ⟧L κ)) ⊔ # (suc⨆Δ κ Δ) , {!   !}  
suc⨆Δ κ (∷l Δ)  = suc⨆Δ (drop-κ κ) Δ 

data _∍_ : TEnv δ → Lvl δ μ → Set where
  here  : (l ∷ Δ) ∍ l
  there : Δ ∍ l → (l′ ∷ Δ) ∍ l
  lskip : Δ ∍ l → (∷l Δ) ∍ Lwk l

data Type {δ : LEnv} (Δ : TEnv δ) : Lvl δ μ → Set where
  Nat   : Type Δ `zero
  `_    : Δ ∍ l → Type Δ l
  _⇒_   : Type Δ l₁ → Type Δ l₂ → Type Δ (l₁ `⊔ l₂) 
  ∀α    : {l : Lvl δ <ω>} → Type (l ∷ Δ) l′ → Type Δ (`suc l `⊔ l′) 
  ∀ℓ    : Type (∷l Δ) (Lwk l) → Type Δ (`ω `⊔ l)
      
pattern ∀α:_⇒_ l {l′ = l′} T = ∀α {l = l} {l′ = l′} T

variable
  T T′ T₁ T₂ T₃ : Type Δ l

TRen : TEnv δ → TEnv δ → Set
TRen {δ} Δ₁ Δ₂ = ∀ μ (l : Lvl δ μ) → Δ₁ ∍ l → Δ₂ ∍ l

variable 
  ρ ρ′ ρ₁ ρ₂ ρ₃ : TRen Δ₁ Δ₂

Tidᵣ : TRen Δ Δ
Tidᵣ _ _ = id

Tdropᵣ : TRen (l ∷ Δ₁) Δ₂ → TRen Δ₁ Δ₂
Tdropᵣ ρ _ _ x = ρ _ _ (there x)

Twkᵣ : TRen Δ₁ Δ₂ → TRen Δ₁ (l ∷ Δ₂)
Twkᵣ ρ _ _ x = there (ρ _ _ x)

TTliftᵣ : TRen Δ₁ Δ₂ → ∀ (l : Lvl δ μ) → TRen (l ∷ Δ₁) (l ∷ Δ₂)
TTliftᵣ ρ _ _ _ (here)      = here
TTliftᵣ ρ _ _ _ (there x)   = there (ρ _ _ x)

TLliftᵣ : TRen Δ₁ Δ₂ → TRen (∷l Δ₁) (∷l Δ₂)
TLliftᵣ ρ _ _ (lskip x) = lskip (ρ _ _ x)

Tren : TRen Δ₁ Δ₂ → Type Δ₁ l → Type Δ₂ l
Tren ρ Nat       = Nat
Tren ρ (` x)     = ` ρ _ _ x
Tren ρ (T₁ ⇒ T₂) = Tren ρ T₁ ⇒ Tren ρ T₂
Tren ρ (∀α T)    = ∀α (Tren (TTliftᵣ ρ _) T)
Tren ρ (∀ℓ T)    = ∀ℓ (Tren (TLliftᵣ ρ) T)

TTwk : Type Δ l′ → Type (l ∷ Δ) l′
TTwk = Tren (Twkᵣ Tidᵣ)

TLwk : Type Δ l′ → Type (∷l Δ) (Lwk l′)
TLwk Nat       = Nat
TLwk (` x)     = ` lskip x
TLwk (T₁ ⇒ T₂) = TLwk T₁ ⇒ TLwk T₂
-- TODO: yeah nah
TLwk (∀α T)    = ∀α (Tren ((λ { _ _ (lskip here) → here ; _ _ (lskip (there x)) → there (lskip x) })) (TLwk T))
TLwk (∀ℓ T)    = ∀ℓ (TLwk T)

TSub : TEnv δ → TEnv δ → Set
TSub {δ} Δ₁ Δ₂ = ∀ μ (l : Lvl δ μ) → Δ₁ ∍ l → Type Δ₂ l

Tidₛ : TSub Δ Δ
Tidₛ _ _ = `_

Tdropₛ : TSub (l ∷ Δ₁) Δ₂ → TSub Δ₁ Δ₂
Tdropₛ σ _ _ x = σ _ _ (there x)

Twkₛ : TSub Δ₁ Δ₂ → TSub Δ₁ (l ∷ Δ₂)
Twkₛ σ _ _ x = TTwk (σ _ _ x)

TTliftₛ : TSub Δ₁ Δ₂ → ∀ (l : Lvl δ μ) → TSub (l ∷ Δ₁) (l ∷ Δ₂)  
TTliftₛ σ _ _ _ here = ` here
TTliftₛ σ _ _ _ (there x) = TTwk (σ _ _ x)

TLliftₛ : TSub Δ₁ Δ₂ → TSub (∷l Δ₁) (∷l Δ₂)  
TLliftₛ σ _ _ (lskip x) = TLwk (σ _ _ x)

Tsub : TSub Δ₁ Δ₂ → Type Δ₁ l → Type Δ₂ l
Tsub σ Nat       = Nat
Tsub σ (` x)     = σ _ _ x
Tsub σ (T₁ ⇒ T₂) = Tsub σ T₁ ⇒ Tsub σ T₂
Tsub σ (∀α T)    = ∀α (Tsub (TTliftₛ σ _) T)
Tsub σ (∀ℓ T)    = ∀ℓ (Tsub (TLliftₛ σ) T)

Textₛ : TSub Δ₁ Δ₂ → Type Δ₂ l → TSub (l ∷ Δ₁) Δ₂
Textₛ σ T′ _ _ here = T′
Textₛ σ T′ _ _ (there x)   = σ _ _ x

_[_]TT : Type (l ∷ Δ) l′ → Type Δ l → Type Δ l′
T [ T′ ]TT = Tsub (Textₛ Tidₛ T′) T

_[_]TL : ∀ {Δ : TEnv δ} {l : Lvl δ μ} →
  Type (∷l Δ) (Lwk l) → Lvl δ <ω → Type Δ l
_[_]TL {l = l} T l′ = {!   !}

_T≫ᵣᵣ_ : TRen Δ₁ Δ₂ → TRen Δ₂ Δ₃ → TRen Δ₁ Δ₃
(ρ₁ T≫ᵣᵣ ρ₂) _ _ x = ρ₂ _ _ (ρ₁ _ _ x)

_T≫ᵣₛ_ : TRen Δ₁ Δ₂ → TSub Δ₂ Δ₃ → TSub Δ₁ Δ₃
(ρ T≫ᵣₛ σ) _ _ x = σ _ _ (ρ _ _ x)

_T≫ₛᵣ_ : TSub Δ₁ Δ₂ → TRen Δ₂ Δ₃ → TSub Δ₁ Δ₃
(σ T≫ₛᵣ ρ) _ _ x = Tren ρ (σ _ _ x)

_T≫ₛₛ_ : TSub Δ₁ Δ₂ → TSub Δ₂ Δ₃ → TSub Δ₁ Δ₃
(σ₁ T≫ₛₛ σ₂) _ _ x = Tsub σ₂ (σ₁ _ _ x)
       
⟦_⟧Δ_ : (Δ : TEnv δ) → (κ : ⟦ δ ⟧δ) → Set (# (suc⨆Δ κ Δ))
⟦  []   ⟧Δ κ = ⊤
⟦ l ∷ Δ ⟧Δ κ = Set (# (⟦ l ⟧L κ)) × ⟦ Δ ⟧Δ κ
⟦ ∷l Δ  ⟧Δ κ = ⟦ Δ ⟧Δ drop-κ κ
  
[]η : ∀ {δ} {κ : ⟦ δ ⟧δ} → ⟦ [] ⟧Δ κ
[]η = tt
  
_∷η_ : ∀ {l : Lvl δ μ} {Δ : TEnv δ} → Set (# (⟦ l ⟧L κ)) → ⟦ Δ ⟧Δ κ → ⟦ l ∷ Δ ⟧Δ κ
_∷η_ = _,_

_∷ηℓ_ : {Δ : TEnv δ} → {κ : ⟦ δ ⟧δ} → 
  (ℓ : BoundLevel ⌊ ω ⌋) → ⟦ Δ ⟧Δ κ → ⟦ ∷l Δ ⟧Δ (ℓ ∷κ κ)
_∷ηℓ_ {δ} {Δ} {κ} ℓ η = η

lookup-η : ∀ {l : Lvl δ μ} {Δ : TEnv δ} → ⟦ Δ ⟧Δ κ → Δ ∍ l → Set (# (⟦ l ⟧L κ)) 
lookup-η (A , _) here = A
lookup-η (_ , η) (there x) = lookup-η η x
lookup-η {κ = κ} η (lskip {l = l} x) = {! (lookup-η η x) !}

drop-η : ∀ {l : Lvl δ μ} {Δ : TEnv δ} → ⟦ l ∷ Δ ⟧Δ κ → ⟦ Δ ⟧Δ κ 
drop-η (_ , η) = η

⟦_⟧T : ∀ {l : Lvl δ μ} {Δ : TEnv δ} → 
  (T : Type Δ l) → (κ : ⟦ δ ⟧δ) → ⟦ Δ ⟧Δ κ → Set (# (⟦ l ⟧L κ))
⟦ Nat     ⟧T κ η = ℕ
⟦ ` α     ⟧T κ η = lookup-η η α
⟦ T₁ ⇒ T₂ ⟧T κ η = ⟦ T₁ ⟧T κ η → ⟦ T₂ ⟧T κ η   
⟦_⟧T {δ = δ} {Δ = Δ} (∀α {l = l} T) κ η = 
    ∀ (A : Set (# (⟦ l ⟧L κ))) → ⟦ T ⟧T κ (_∷η_ {κ = κ} {l = l} {Δ = Δ} A η)
⟦ ∀ℓ {l = l} T ⟧T κ η = {! ∀ (ℓ : BoundLevel ⌊ ω ⌋) → 
       (Lift ⌊ ω ⌋ (⟦ T ⟧T (ℓ ∷κ κ) (ℓ ∷ηℓ η)))  !}
-- ⟦_⟧ρ_ : TRen Δ₁ Δ₂ → ⟦ Δ₂ ⟧Δ → ⟦ Δ₁ ⟧Δ
-- ⟦_⟧ρ_ {Δ₁ = []}    ρ η = []η
-- ⟦_⟧ρ_ {Δ₁ = _ ∷ _} ρ η = (⟦ ` ρ _ (here refl) ⟧T η) ∷η (⟦ Tdropᵣ ρ ⟧ρ η)
-- 
-- ⟦⟧ρ-wkᵣ : (ρ : TRen Δ₁ Δ₂) (η : ⟦ Δ₂ ⟧Δ) (A : Set ℓ) → 
--   (⟦ ρ T≫ᵣᵣ Twkᵣ Tidᵣ ⟧ρ (A ∷η η)) ≡ ⟦ ρ ⟧ρ η
-- ⟦⟧ρ-wkᵣ {[]} ρ η A    = refl
-- ⟦⟧ρ-wkᵣ {ℓ ∷ Δ} ρ η A = cong ((lookup-η η (ρ _ (here refl))) ,_) (⟦⟧ρ-wkᵣ (Tdropᵣ ρ) η A)
-- 
-- ⟦⟧ρ-idᵣ : (η : ⟦ Δ ⟧Δ) → (⟦ Tidᵣ ⟧ρ η) ≡ η
-- ⟦⟧ρ-idᵣ {[]}     η = refl
-- ⟦⟧ρ-idᵣ {x ∷ Δ₂} (A , γ) = cong (A ∷η_) (trans (⟦⟧ρ-wkᵣ Tidᵣ γ A) (⟦⟧ρ-idᵣ γ))
-- 
-- ⟦⟧ρ-liftᵣ : ∀ {ℓ} (ρ : TRen Δ₁ Δ₂) (η : ⟦ Δ₂ ⟧Δ) (A : Set ℓ) →
--    (⟦ Tliftᵣ ρ ℓ ⟧ρ (A ∷η η)) ≡ (A ∷η (⟦ ρ ⟧ρ η))
-- ⟦⟧ρ-liftᵣ ρ η A = cong (_ ∷η_) (⟦⟧ρ-wkᵣ ρ η A)
--   
-- ⟦⟧T-ren : (η : ⟦ Δ₂ ⟧Δ) (ρ : TRen Δ₁ Δ₂) (T : Type Δ₁ ℓ) → 
--   ⟦ Tren ρ T ⟧T η ≡ ⟦ T ⟧T (⟦ ρ ⟧ρ η)
-- ⟦⟧T-ren η ρ Nat       = refl
-- ⟦⟧T-ren η ρ (` x)     = ⟦⟧Δ-lookup η ρ x
--   where ⟦⟧Δ-lookup : ∀ {ℓ} (η : ⟦ Δ₂ ⟧Δ) (ρ : TRen Δ₁ Δ₂) (x : ℓ ∈ Δ₁) → 
--                         (⟦ ` ρ ℓ x ⟧T η) ≡ (⟦ ` x ⟧T (⟦ ρ ⟧ρ η))
--         ⟦⟧Δ-lookup η ρ (here refl) = refl
--         ⟦⟧Δ-lookup η ρ (there x) rewrite ⟦⟧Δ-lookup η (Tdropᵣ ρ) x = refl
-- ⟦⟧T-ren η ρ (T₁ ⇒ T₂) rewrite ⟦⟧T-ren η ρ T₁ | ⟦⟧T-ren η ρ T₂ = refl
-- ⟦⟧T-ren η ρ (∀α {ℓ} T) = dep-ext λ A → 
--   trans (⟦⟧T-ren (A ∷η η) (Tliftᵣ ρ ℓ) T) (cong (λ η → ⟦ T ⟧T (A , η)) (⟦⟧ρ-wkᵣ ρ η A))
-- 
-- ⟦_⟧σ_ : TSub Δ₁ Δ₂ → ⟦ Δ₂ ⟧Δ → ⟦ Δ₁ ⟧Δ
-- ⟦_⟧σ_ {Δ₁ = []}    σ η = []η
-- ⟦_⟧σ_ {Δ₁ = _ ∷ _} σ η = (⟦ σ _ (here refl) ⟧T η) ∷η (⟦ Tdropₛ σ ⟧σ η)
-- 
-- ⟦⟧σ-wkᵣ : (σ : TSub Δ₁ Δ₂) (η : ⟦ Δ₂ ⟧Δ) (A : Set ℓ) → 
--   (⟦ σ T≫ₛᵣ Twkᵣ Tidᵣ ⟧σ (A ∷η η)) ≡ ⟦ σ ⟧σ η
-- ⟦⟧σ-wkᵣ {[]} σ η A    = refl
-- ⟦⟧σ-wkᵣ {ℓ ∷ Δ} σ η A = 
--   cong₂ _∷η_ (trans (⟦⟧T-ren (A ∷η η) (Twkᵣ Tidᵣ) (σ ℓ (here refl))) 
--       (cong (λ η → ⟦ σ ℓ (here refl) ⟧T η) (trans (⟦⟧ρ-wkᵣ Tidᵣ η A) (⟦⟧ρ-idᵣ η)))) 
--   (⟦⟧σ-wkᵣ (Tdropₛ σ) η A)
-- 
-- ⟦⟧σ-idₛ : (η : ⟦ Δ ⟧Δ) → (⟦ Tidₛ ⟧σ η) ≡ η
-- ⟦⟧σ-idₛ {[]}     η = refl
-- ⟦⟧σ-idₛ {x ∷ Δ₂} (A , γ) = cong (A ∷η_) (trans (⟦⟧σ-wkᵣ Tidₛ γ A) (⟦⟧σ-idₛ γ))
-- 
-- ⟦⟧T-sub : (η : ⟦ Δ₂ ⟧Δ) (σ : TSub Δ₁ Δ₂) (T : Type Δ₁ ℓ) → 
--   ⟦ Tsub σ T ⟧T η ≡ ⟦ T ⟧T (⟦ σ ⟧σ η)
-- ⟦⟧T-sub η σ Nat       = refl
-- ⟦⟧T-sub η σ (` x)     = ⟦⟧Δ-lookup η σ x
--   where ⟦⟧Δ-lookup : ∀ {ℓ} (η : ⟦ Δ₂ ⟧Δ) (σ : TSub Δ₁ Δ₂) (x : ℓ ∈ Δ₁) → 
--                           (⟦ σ ℓ x ⟧T η) ≡ (⟦ ` x ⟧T (⟦ σ ⟧σ η))
--         ⟦⟧Δ-lookup η σ (here refl) = refl
--         ⟦⟧Δ-lookup η σ (there x) rewrite ⟦⟧Δ-lookup η (Tdropₛ σ) x = refl
-- ⟦⟧T-sub η σ (T₁ ⇒ T₂) rewrite ⟦⟧T-sub η σ T₁ | ⟦⟧T-sub η σ T₂ = refl
-- ⟦⟧T-sub η σ (∀α T)    = dep-ext λ A → 
--   trans (⟦⟧T-sub (A ∷η η) (Tliftₛ σ _) T) (cong (λ η → ⟦ T ⟧T (A , η)) (⟦⟧σ-wkᵣ σ η A))
--   
-- data EEnv : (Δ : TEnv) → Set where
--   []   : EEnv Δ
--   _∷_  : Type Δ ℓ → EEnv Δ → EEnv Δ
--   _∷ℓ_ : (ℓ : Level) → EEnv Δ → EEnv (ℓ ∷ Δ)
-- 
-- variable
--   Γ Γ′ Γ₁ Γ₂ Γ₃ : EEnv Δ
-- 
-- data _∋_ : EEnv Δ → Type Δ ℓ → Set where
--   here  : (T ∷ Γ) ∋ T
--   there : Γ ∋ T → (T′ ∷ Γ) ∋ T
--   tskip : Γ ∋ T → (ℓ ∷ℓ Γ) ∋ Twk T
-- 
-- ⨆Γ : EEnv Δ → Level
-- ⨆Γ []                        = zero 
-- ⨆Γ (_∷_ {Δ = Δ} {ℓ = ℓ} T Γ) = ℓ ⊔ ⨆Γ  Γ 
-- ⨆Γ (_∷ℓ_ {Δ = Δ} ℓ Γ)        = ⨆Γ Γ 
-- 
-- data Expr {Δ} (Γ : EEnv Δ) : Type Δ ℓ → Set where
--   `_   : Γ ∋ T → Expr Γ T
--   #_   : ℕ → Expr Γ Nat
--   ‵suc : Expr Γ Nat → Expr Γ Nat
--   λx_  : Expr (T ∷ Γ) T′ → Expr Γ (T ⇒ T′)
--   Λ_⇒_ : ∀ ℓ {T : Type (ℓ ∷ Δ) ℓ′} → Expr (ℓ ∷ℓ Γ) T → Expr Γ (∀α T)
--   _·_  : Expr Γ (T ⇒ T′) → Expr Γ T → Expr Γ T′
--   _∙_  : Expr Γ (∀α T) → (T′ : Type Δ ℓ) → Expr Γ (T [ T′ ]TT) 
-- 
-- module FunctionExprSemEnv where
--   open import BoundQuantification 
--   
--   Γ∋T⇒Tℓ≤⨆Γ : ∀ {ℓ} {Δ : TEnv} {T : Type Δ ℓ} {Γ : EEnv Δ} → Γ ∋ T → ℓ ≤ (⨆Γ Γ)
--   Γ∋T⇒Tℓ≤⨆Γ {Γ = _ ∷ Γ} here       = <₃ {ℓ₂ = ⨆Γ Γ} <₁
--   Γ∋T⇒Tℓ≤⨆Γ {Γ = _∷_ {ℓ = ℓ} _ Γ} (there x) = <₃ {ℓ₂ = ℓ} (Γ∋T⇒Tℓ≤⨆Γ x)
--   Γ∋T⇒Tℓ≤⨆Γ {Γ = _ ∷ℓ Γ} (tskip x) = Γ∋T⇒Tℓ≤⨆Γ x
--   
--   ⟦_⟧Γ : ∀ {Δ} → (Γ : EEnv Δ) → ⟦ Δ ⟧Δ → Set (⨆Γ Γ)
--   ⟦_⟧Γ {Δ} Γ η = ∀ (ℓ : BoundLevel (suc (⨆Γ Γ))) (T : Type Δ (BoundQuantification.# ℓ)) → (x : Γ ∋ T) → 
--     BoundLift (Γ∋T⇒Tℓ≤⨆Γ x) ((⟦ T ⟧T η))
-- 
-- ⟦_⟧Γ_   : ∀ {Δ} → (Γ : EEnv Δ) → ⟦ Δ ⟧Δ → Set (⨆Γ Γ)
-- ⟦ []     ⟧Γ η = ⊤
-- ⟦ T ∷ Γ  ⟧Γ η = ⟦ T ⟧T η × ⟦ Γ ⟧Γ η
-- ⟦ ℓ ∷ℓ Γ ⟧Γ η = ⟦ Γ ⟧Γ (drop-η η) 
-- 
-- []γ    : ∀ {Δ} {η : ⟦ Δ ⟧Δ} → ⟦ [] ⟧Γ η
-- []γ = tt
--    
-- _∷Η_   : ∀ {ℓ} {Δ} {T : Type Δ ℓ} {Γ : EEnv Δ} {η : ⟦ Δ ⟧Δ} → 
--     ⟦ T ⟧T η → ⟦ Γ ⟧Γ η → ⟦ T ∷ Γ ⟧Γ η
-- _∷Η_ = _,_
--     
-- _∷Ηℓ_   : ∀ {ℓ} {Δ} {Γ : EEnv Δ} {η : ⟦ Δ ⟧Δ} → 
--     (A : Set ℓ) → ⟦ Γ ⟧Γ η → ⟦ ℓ ∷ℓ Γ ⟧Γ (A ∷η η)
-- _∷Ηℓ_ {Γ = Γ} A γ = γ
-- 
-- lemma : {Δ : TEnv} (η : Set ℓ × ⟦ Δ ⟧Δ) → (⟦ Twkᵣ Tidᵣ ⟧ρ η) ≡ drop-η η
-- lemma γ = trans (⟦⟧ρ-wkᵣ Tidᵣ (proj₂ γ) (proj₁ γ)) (⟦⟧ρ-idᵣ (proj₂ γ))
--   
-- lookup-γ : ∀ {ℓ} {Δ : TEnv} {Γ : EEnv Δ} {T : Type Δ ℓ} {η : ⟦ Δ ⟧Δ} → 
--     ⟦ Γ ⟧Γ η → Γ ∋ T → ⟦ T ⟧T η 
-- lookup-γ (A , γ) here       = A
-- lookup-γ (_ , γ) (there x)  = lookup-γ γ x
-- lookup-γ {Γ = _ ∷ℓ Γ} {η = η} γ (tskip {T = T} x) = subst id (sym (⟦⟧T-ren η (Twkᵣ Tidᵣ) T)) 
--   (lookup-γ (subst (λ η → ⟦ Γ ⟧Γ η) (sym (trans (⟦⟧ρ-wkᵣ Tidᵣ (proj₂ η) (proj₁ η)) (⟦⟧ρ-idᵣ (proj₂ η)))) γ) x)
-- 
-- ⟦_⟧E : {Δ : TEnv} {T : Type Δ ℓ} {Γ : EEnv Δ} → 
--   Expr Γ T → (η : ⟦ Δ ⟧Δ) → ⟦ Γ ⟧Γ η → ⟦ T ⟧T η
-- ⟦ ` x     ⟧E η γ = lookup-γ γ x
-- ⟦ # n     ⟧E η γ = n
-- ⟦ ‵suc e  ⟧E η γ = sucℕ (⟦ e ⟧E η γ)
-- ⟦_⟧E {_} {Δ} {T = (T₁ ⇒ T₂)} {Γ} (λx e) η γ    = λ x → ⟦ e ⟧E η (_∷Η_ {T = T₁} {Γ = Γ} x γ)
-- ⟦_⟧E {_} {Δ} {T} {Γ}             (Λ ℓ ⇒ e) η γ = λ A → ⟦ e ⟧E (A ∷η η) (_∷Ηℓ_ {Γ = Γ} A γ)
-- ⟦ e₁ · e₂ ⟧E η γ = ⟦ e₁ ⟧E η γ (⟦ e₂ ⟧E η γ)
-- ⟦ _∙_ {T = T} e T′ ⟧E η γ = subst id (trans 
--                     (cong (λ η′ → ⟦ T ⟧T ((⟦ T′ ⟧T η) , η′)) (sym (⟦⟧σ-idₛ η))) 
--                     (sym (⟦⟧T-sub η (Textₛ Tidₛ T′) T))) (⟦ e ⟧E η γ (⟦ T′ ⟧T η)) 
--    
                 