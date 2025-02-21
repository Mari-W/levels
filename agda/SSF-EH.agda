module SSF-EH where

open import Axiom.Extensionality.Propositional using (∀-extensionality; Extensionality)
open import Level using (Level; Lift; lift; zero; suc; _⊔_)
open import Data.Unit using (⊤; tt)
open import Data.Product using (_×_; _,_; proj₁; proj₂)
open import Data.Nat using (ℕ) renaming (zero to zeroℕ; suc to sucℕ) 
open import Data.List using (List; []; _∷_)
open import Data.List.Membership.Propositional using (_∈_) 
open import Data.List.Relation.Unary.Any using (here; there)
open import Data.Product using (_,_; _×_; ∃-syntax)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; trans; cong; cong₂; icong; subst)
open import Function using (_∘_; id; flip; _$_)
open import ExtendedHierarchy using (𝟎; 𝟏; ω; ω²; ⌊_⌋; cast; cast-intro; cast-elim; β-suc-zero; β-suc-ω; β-suc-⌊⌋; ω^_+_;  <₁; <₂; <₃)
open import BoundQuantification using (BoundLevel; BoundLift; bound-lift; bound-unlift; _,_; #; #<Λ; _<_; _≤_; ≤-id; ≤-suc; ≤-add; ≤-exp; ≤-lublub; <-suc-lim; lim)

LEnv = List ⊤

variable
  δ δ′ δ₁ δ₂ δ₃ : LEnv

data Mode : Set where
  fin : Mode
  any : Mode

variable
  μ μ′ μ₁ μ₂ μ₃ : Mode
    
data Lvl (δ : LEnv) : Mode → Set where 
  `zero : Lvl δ fin
  `suc  : Lvl δ μ → Lvl δ μ
  `_    : tt ∈ δ → Lvl δ fin
  _`⊔_  : Lvl δ μ → Lvl δ μ → Lvl δ μ
  ⟨_⟩   : Lvl δ fin → Lvl δ any
  `ω    : Lvl δ any
      
variable
  l l′ l₁ l₂ l₃ : Lvl δ any

postulate 
  LLwk  : Lvl δ μ → Lvl (tt ∷ δ) μ
  _[_]LL : Lvl (tt ∷ δ) μ → Lvl δ fin → Lvl δ μ

variable
  ℓ ℓ′ ℓ₁ ℓ₂ ℓ₃ : BoundLevel ⌊ ω ⌋

⟦_⟧δ : (δ : LEnv) → Set
⟦ []    ⟧δ = ⊤
⟦ _ ∷ δ ⟧δ = BoundLevel ⌊ ω ⌋ × ⟦ δ ⟧δ
    
variable
  κ κ′ κ₁ κ₂ κ₃ : ⟦ δ ⟧δ

_∷κ_ : BoundLevel ⌊ ω ⌋ → ⟦ δ ⟧δ → ⟦ tt ∷ δ ⟧δ
_∷κ_ = _,_

lookup-κ : ⟦ δ ⟧δ → tt ∈ δ → BoundLevel ⌊ ω ⌋
lookup-κ {_ ∷ δ} (ℓ , κ) (here refl) = ℓ
lookup-κ {_ ∷ δ} (ℓ , κ) (there x)   = lookup-κ κ x

drop-κ : ⟦ tt ∷ δ ⟧δ → ⟦ δ ⟧δ
drop-κ (_ , κ) = κ

⟦_⟧L : (l : Lvl δ μ) → ⟦ δ ⟧δ → Level
⟦ `zero     ⟧L κ = zero
⟦ `suc l    ⟧L κ = suc (⟦ l ⟧L κ)
⟦ ` x       ⟧L κ = # (lookup-κ κ x)
⟦ l₁ `⊔ l₂  ⟧L κ = (⟦ l₁ ⟧L κ) ⊔ (⟦ l₂ ⟧L κ)
⟦ ⟨ l ⟩     ⟧L κ = ⟦ l ⟧L κ
⟦ `ω        ⟧L κ = ⌊ ω ⌋

⟦_⟧L′ : Lvl δ fin → ⟦ δ ⟧δ → BoundLevel ⌊ ω ⌋
⟦ `zero    ⟧L′ κ = zero , let 0<ω = subst (suc zero ≤_) β-suc-zero (≤-id (suc zero)) in  -- subst would be gone if EH be part of agda
  ≤-exp zero 0<ω
⟦ `suc l   ⟧L′ κ = (suc (# (⟦ l ⟧L′ κ))) , let 0<ω = subst (suc zero ≤_) β-suc-zero (≤-id (suc zero)) in
  <-suc-lim _ _ (#<Λ (⟦ l ⟧L′ κ)) (lim 0<ω)
⟦ ` x      ⟧L′ κ = lookup-κ κ x 
⟦ l₁ `⊔ l₂ ⟧L′ κ = # (⟦ l₁ ⟧L′ κ) ⊔ # (⟦ l₂ ⟧L′ κ) , 
  ≤-lublub (#<Λ (⟦ l₁ ⟧L′ κ)) (#<Λ (⟦ l₂ ⟧L′ κ))

postulate
  ⟦LLwk⟧L  : ∀ (l : Lvl δ μ) (κ : ⟦ δ ⟧δ) ℓ → 
    ⟦ LLwk l ⟧L (ℓ ∷κ κ) ≡ ⟦ l ⟧L κ
  ⟦[]LL⟧L : ∀ (l : Lvl (tt ∷ δ) μ) (κ : ⟦ δ ⟧δ) l′ → 
    ⟦ l [ l′ ]LL ⟧L κ ≡ ⟦ l ⟧L (⟦ l′ ⟧L′ κ , κ)

data TEnv : LEnv → Set where
  []   : TEnv δ
  _∷_  : Lvl δ any → TEnv δ → TEnv δ 
  ∷l_  : TEnv δ → TEnv (tt ∷ δ) 

variable
  Δ Δ′ Δ₁ Δ₂ Δ₃ : TEnv δ

suc⨆Δ :  ⟦ δ ⟧δ → TEnv δ → Level
suc⨆Δ κ []      = zero
suc⨆Δ κ (l ∷ Δ) = suc (⟦ l ⟧L κ) ⊔ suc⨆Δ κ Δ  
suc⨆Δ κ (∷l Δ)  = suc⨆Δ (drop-κ κ) Δ 

data _∍_ : TEnv δ → Lvl δ any → Set where
  here  : (l ∷ Δ) ∍ l
  there : Δ ∍ l → (l′ ∷ Δ) ∍ l
  lskip : Δ ∍ l → (∷l Δ) ∍ LLwk l

data Type (Δ : TEnv δ) : Lvl δ any → Set where
  Nat   : Type Δ ⟨ `zero ⟩
  `_    : Δ ∍ l → Type Δ l
  _⇒_   : Type Δ l₁ → Type Δ l₂ → Type Δ (l₁ `⊔ l₂) 
  ∀α    : Type (l ∷ Δ) l′ → Type Δ (`suc l `⊔ l′) 
  ∀ℓ    : Type (∷l Δ) (LLwk l) → Type Δ (`ω `⊔ l)
      
variable
  T T′ T₁ T₂ T₃ : Type Δ l

postulate
  TTwk : Type Δ l′ → Type (l ∷ Δ) l′
  TLLwk : Type Δ l → Type (∷l Δ) (LLwk l)
  _[_]TT : Type (l ∷ Δ) l′ → Type Δ l → Type Δ l′
  _[_]TL : Type (∷l Δ) l → (l′ : Lvl δ fin) → Type Δ (l [ l′ ]LL)
       
⟦_⟧Δ_ : (Δ : TEnv δ) → (κ : ⟦ δ ⟧δ) → Set (suc⨆Δ κ Δ)
⟦  []   ⟧Δ κ = ⊤
⟦ l ∷ Δ ⟧Δ κ = Set (⟦ l ⟧L κ) × ⟦ Δ ⟧Δ κ
⟦ ∷l Δ  ⟧Δ κ = ⟦ Δ ⟧Δ drop-κ κ

_∷η_ : {κ : ⟦ δ ⟧δ} → Set (⟦ l ⟧L κ) → ⟦ Δ ⟧Δ κ → ⟦ l ∷ Δ ⟧Δ κ
_∷η_ = _,_

lookup-η : {κ : ⟦ δ ⟧δ} → ⟦ Δ ⟧Δ κ → Δ ∍ l → Set (⟦ l ⟧L κ) 
lookup-η (A , _) here                    = A
lookup-η (_ , η) (there x)               = lookup-η η x
lookup-η {κ = ℓ , κ} η (lskip {l = l} x) = cast (sym (⟦LLwk⟧L l κ ℓ)) (lookup-η η x)

drop-η : {κ : ⟦ δ ⟧δ} → ⟦ l ∷ Δ ⟧Δ κ → ⟦ Δ ⟧Δ κ 
drop-η (_ , η) = η

⟦_⟧T : {Δ : TEnv δ} → (T : Type Δ l) → (κ : ⟦ δ ⟧δ) → ⟦ Δ ⟧Δ κ → Set (⟦ l ⟧L κ)
⟦ Nat     ⟧T κ η = ℕ
⟦ ` α     ⟧T κ η = lookup-η η α
⟦ T₁ ⇒ T₂ ⟧T κ η = ⟦ T₁ ⟧T κ η → ⟦ T₂ ⟧T κ η   
⟦_⟧T {Δ = Δ} (∀α {l = l} T) κ η = 
  ∀ (A : Set (⟦ l ⟧L κ)) → ⟦ T ⟧T κ (_∷η_ {l = l} {Δ = Δ} {κ = κ} A η)
⟦_⟧T {l = l} {Δ = Δ} (∀ℓ {l = l₁} T) κ η = 
  ∀ (ℓ : BoundLevel ⌊ ω ⌋) → cast (cong (⌊ ω ⌋ ⊔_) (⟦LLwk⟧L l₁ κ ℓ)) (Lift ⌊ ω ⌋ (⟦ T ⟧T (ℓ ∷κ κ) η))

postulate
  ⟦TLLwk⟧T : {Δ : TEnv δ} {T : Type Δ l} {κ : ⟦ δ ⟧δ} {η : ⟦ Δ ⟧Δ κ} →
    ⟦ T ⟧T κ η ≡ cast (⟦LLwk⟧L l κ ℓ) (⟦ TLLwk T ⟧T (ℓ , κ) η) 
  ⟦TTwk⟧T : {Δ : TEnv δ} {T : Type Δ l} {κ : ⟦ δ ⟧δ} {A : Set (⟦ l′ ⟧L κ)} {η : ⟦ Δ ⟧Δ κ} → 
    ⟦ T ⟧T κ η ≡ ⟦ TTwk {l = l′} T ⟧T κ (A , η)

  ⟦[]LT⟧T : {T : Type (∷l Δ) (LLwk l)} {l′ : Lvl δ fin} {κ : ⟦ δ ⟧δ} {η : ⟦ Δ ⟧Δ κ} →  
    ⟦ T ⟧T (⟦ l′ ⟧L′ κ , κ) η ≡ cast (⟦[]LL⟧L (LLwk l) κ l′) (⟦ T [ l′ ]TL ⟧T κ η)
  ⟦[]TT⟧T : {l′ : Lvl δ any} {T : Type (l′ ∷ Δ) l} {T′ : Type Δ l′} {κ : ⟦ δ ⟧δ} {η : ⟦ Δ ⟧Δ κ} → 
    ⟦ T ⟧T κ (_∷η_ {l = l′} {Δ = Δ} {κ = κ} (⟦ T′ ⟧T κ η) η) ≡ ⟦ T [ T′ ]TT ⟧T κ η
    
data EEnv : (Δ : TEnv δ) → Set where
  []   : EEnv Δ
  _∷_  : Type Δ l → EEnv Δ → EEnv Δ
  _∷l_ : (l : Lvl δ any) → EEnv Δ → EEnv (l ∷ Δ)
  ∷l_ : EEnv Δ → EEnv (∷l Δ)

variable
  Γ Γ′ Γ₁ Γ₂ Γ₃ : EEnv Δ

data _∋_ : EEnv Δ → Type Δ l → Set where
  here  : (T ∷ Γ) ∋ T
  there : Γ ∋ T → (T′ ∷ Γ) ∋ T
  tskip : Γ ∋ T → (l ∷l Γ) ∋ TTwk T
  lskip : Γ ∋ T → (∷l Γ) ∋ TLLwk T

⨆Γ : ∀ {Δ : TEnv δ} → EEnv Δ → ⟦ δ ⟧δ → Level
⨆Γ []                κ = zero 
⨆Γ (_∷_ {l = l} T Γ) κ = ⟦ l ⟧L κ  ⊔ ⨆Γ Γ κ 
⨆Γ (ℓ ∷l Γ)          κ = ⨆Γ Γ κ
⨆Γ (∷l Γ)            κ = ⨆Γ Γ (drop-κ κ)

data Expr {Δ : TEnv δ} (Γ : EEnv Δ) : Type Δ l → Set where
  `_    : Γ ∋ T → Expr Γ T
  #_    : ℕ → Expr Γ Nat
  ‵suc  : Expr Γ Nat → Expr Γ Nat
  λx_   : Expr (T ∷ Γ) T′ → Expr Γ (T ⇒ T′)
  Λ_⇒_  : (l : Lvl δ any) {T : Type (l ∷ Δ) l′} → Expr (l ∷l Γ) T → Expr Γ (∀α T)
  Λℓ_   : {T : Type (∷l Δ) (LLwk l)} → Expr (∷l Γ) T → Expr Γ (∀ℓ T)
  _·_   : Expr Γ (T ⇒ T′) → Expr Γ T → Expr Γ T′
  _∙_   : Expr Γ (∀α T) → (T′ : Type Δ l) → Expr Γ (T [ T′ ]TT) 
  _∙ℓ_  : {T : Type (∷l Δ) (LLwk l)} → Expr Γ (∀ℓ T) → (l′ : Lvl δ fin) → Expr Γ (T [ l′ ]TL) 

⟦_⟧Γ   : {Δ : TEnv δ} → (Γ : EEnv Δ) → (κ : ⟦ δ ⟧δ) → ⟦ Δ ⟧Δ κ → Set (⨆Γ Γ κ)
⟦ []     ⟧Γ κ η = ⊤
⟦ T ∷ Γ  ⟧Γ κ η = ⟦ T ⟧T κ η × ⟦ Γ ⟧Γ κ η
⟦_⟧Γ {Δ = l ∷ Δ} (l ∷l Γ) κ η = ⟦ Γ ⟧Γ κ (drop-η {l = l} {Δ = Δ} {κ = κ} η) 
⟦ ∷l Γ   ⟧Γ κ η = ⟦ Γ ⟧Γ (drop-κ κ) η 
   
_∷γ_ : {Δ : TEnv δ} {T : Type Δ l} {Γ : EEnv Δ} {κ : ⟦ δ ⟧δ} {η : ⟦ Δ ⟧Δ κ} → 
    ⟦ T ⟧T κ η → ⟦ Γ ⟧Γ κ η → ⟦ T ∷ Γ ⟧Γ κ η
_∷γ_ = _,_

lookup-γ : {Δ : TEnv δ} {Γ : EEnv Δ} {T : Type Δ l} {κ : ⟦ δ ⟧δ} {η : ⟦ Δ ⟧Δ κ} → 
    ⟦ Γ ⟧Γ κ η → Γ ∋ T → ⟦ T ⟧T κ η 
lookup-γ (A , γ) here       = A
lookup-γ (_ , γ) (there x)  = lookup-γ γ x
lookup-γ {Γ = _ ∷l Γ} {κ = κ} {η = A , η} γ (tskip {T = T} x) = 
  subst id ⟦TTwk⟧T (lookup-γ γ x)
lookup-γ {δ = tt ∷ δ} {Γ = ∷l Γ} {κ = A , κ} {η = η} γ (lskip x) = 
  cast-elim _ (subst id ⟦TLLwk⟧T (lookup-γ {δ = δ} {κ = κ} γ x))

⟦_⟧E : {Δ : TEnv δ} {T : Type Δ l} {Γ : EEnv Δ} → 
  Expr Γ T → (κ : ⟦ δ ⟧δ) (η : ⟦ Δ ⟧Δ κ) → ⟦ Γ ⟧Γ κ η → ⟦ T ⟧T κ η
⟦ ` x     ⟧E κ η γ = lookup-γ γ x
⟦ # n     ⟧E κ η γ = n
⟦ ‵suc e  ⟧E κ η γ = sucℕ (⟦ e ⟧E κ η γ)
⟦_⟧E {T = (T₁ ⇒ T₂)} {Γ} (λx e) κ η γ = 
  λ (x : ⟦ T₁ ⟧T κ η) → ⟦ e ⟧E κ η (_∷γ_ {T = T₁} {Γ = Γ} x γ)
⟦_⟧E {Δ = Δ} {T = T} {Γ = Γ} (Λ l ⇒ e) κ η γ = 
  λ (A : Set (⟦ l ⟧L κ)) → ⟦ e ⟧E κ (_∷η_ {l = l} {Δ = Δ} {κ = κ} A η) γ
⟦ Λℓ e ⟧E κ η γ = 
  λ (ℓ : BoundLevel ⌊ ω ⌋) → cast-intro _ (lift {ℓ = ⌊ ω ⌋} (⟦ e ⟧E (ℓ ∷κ κ) η γ))
⟦ e₁ · e₂ ⟧E κ η γ = ⟦ e₁ ⟧E κ η γ (⟦ e₂ ⟧E κ η γ)
⟦ e ∙ T′ ⟧E κ η γ = subst id ⟦[]TT⟧T (⟦ e ⟧E κ η γ (⟦ T′ ⟧T κ η)) 
⟦ _∙ℓ_ {l = l} e l′ ⟧E κ η γ = 
  cast-elim _ (subst id ⟦[]LT⟧T (Lift.lower (cast-elim _ (⟦ e ⟧E κ η γ (⟦ l′ ⟧L′ κ)))))
      
                                