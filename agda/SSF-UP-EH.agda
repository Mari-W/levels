
module SSF-UP-EH where
  
module Types where
  open import Level using (Level; zero; suc; _⊔_; Lift; lift)
  open import Data.Unit using (⊤; tt)
  open import Data.Nat using (ℕ) renaming (suc to sucₙ)
  open import Data.List using (List; []; _∷_)
  open import Data.List.Membership.Propositional using (_∈_)
  open import Data.List.Relation.Unary.Any using (here; there)
  open import Data.List.Relation.Unary.All using (All; [] ; _∷_)
  open import Relation.Binary.PropositionalEquality using (_≡_; refl; trans; cong; cong₂)
  open import Function using (_∘_; id; flip; _$_)

  open import ExtendedHierarchy using (𝟎; 𝟏; ω; ω+ₙ_; ⌊_⌋; cast; β-suc-zero; β-suc-ω; β-suc-⌊⌋; ω^_+_;  <₁; <₂; <₃; ℕ→MutualOrd)
  open import BoundQuantification using (BoundLevel; BoundLift; bound-lift; bound-unlift; _,_; #; #<Λ; _<_; <₁; <₂; <₃)

  private variable
    ℓ ℓ′ ℓ₁ ℓ₂ ℓ₃ : BoundLevel ⌊ ω ⌋

  module Syntax where
    LvlEnv = List ⊤

    variable
      δ δ′ δ₁ δ₂ δ₃ : LvlEnv

    data LivesIn : Set where
      <ω : LivesIn
      ≥ω : LivesIn

    variable
      μ μ′ μ₁ μ₂ μ₃ : LivesIn
    
    _⊔̌_ : LivesIn → LivesIn → LivesIn
    ≥ω ⊔̌ _ = ≥ω
    _ ⊔̌ ≥ω = ≥ω
    <ω ⊔̌ <ω = <ω
    
    data Lvl (δ : LvlEnv) : LivesIn → Set where 
      `zero : Lvl δ <ω
      `suc  : Lvl δ <ω → Lvl δ <ω
      `_    : ∀ {l} → l ∈ δ → Lvl δ <ω
      _`⊔_  : Lvl δ μ₁ → Lvl δ μ₂ → Lvl δ (μ₁ ⊔̌ μ₂)
      `ω+_  : ℕ → Lvl δ ≥ω
      
    variable
      l l′ l₁ l₂ l₃ : Lvl δ <ω
      lμ lμ′ lμ₁ lμ₂ lμ₃ : Lvl δ μ
    
    wkₗ  : Lvl δ μ → Lvl (tt ∷ δ) μ
    wkₗ `zero      = `zero
    wkₗ (`suc l)   = `suc (wkₗ l)
    wkₗ (` x)      = ` (there x)
    wkₗ (l₁ `⊔ l₂) = wkₗ l₁ `⊔ wkₗ l₂
    wkₗ (`ω+ n)    = `ω+ n

    Env : LvlEnv → Set
    Env δ = List (Lvl δ <ω)
  
    wkₗₑ : Env δ → Env (tt ∷ δ)
    wkₗₑ []      = []
    wkₗₑ (l ∷ Δ) = wkₗ l ∷ wkₗₑ Δ
      
    variable
      Δ Δ′ Δ₁ Δ₂ Δ₃ : Env δ
    
    data Type (δ : LvlEnv) (Δ : Env δ) : Lvl δ μ → Set where
      `_    : l ∈ Δ → Type δ Δ l
      _⇒_   : Type δ Δ l₁ → Type δ Δ l₂ → Type δ Δ (l₁ `⊔ l₂) 
      ∀α    : (l : Lvl δ <ω) → Type δ (l ∷ Δ) l′ → Type δ Δ (`suc l `⊔ l′) 
      ∀ℓ    : Type (tt ∷ δ) (wkₗₑ Δ) (wkₗ l) → Type δ Δ ((`ω+ 0) `⊔ l)
      
    pattern ∀α:_⇒_ l {l′ = l′} T = ∀α {l = l} {l′ = l′} T
  
  module Substitution where
    open Syntax   
      
    REN : (Δ₁ Δ₂ : Env δ) → Set
    REN Δ₁ Δ₂ = ∀ {ℓ} → ℓ ∈ Δ₁ → ℓ ∈ Δ₂

    module _ (ρ : REN (l ∷ Δ₁) Δ₂) where
      popᵣ : REN Δ₁ Δ₂
      popᵣ = ρ ∘ there

      topᵣ : l ∈ Δ₂
      topᵣ = ρ (here refl)

    tabulateᵣ : REN Δ₁ Δ₂ → All (_∈ Δ₂) Δ₁
    tabulateᵣ {Δ₁ = []}    _ = []
    tabulateᵣ {Δ₁ = _ ∷ _} ρ = topᵣ ρ ∷ tabulateᵣ (popᵣ ρ)

    lookupᵣ : All (_∈ Δ₂) Δ₁ → REN Δ₁ Δ₂
    lookupᵣ (α ∷ ρ) = λ where (here refl) → α ; (there x) → lookupᵣ ρ x

    record Ren (Δ₁ Δ₂ : Env δ) : Set where
      constructor mkRen
      field
        ren : REN Δ₁ Δ₂

      wkᵣ : REN Δ₁ (l ∷ Δ₂)
      wkᵣ = there ∘ ren

      liftᵣ : REN (l ∷ Δ₁) (l ∷ Δ₂)
      liftᵣ (here refl) = (here refl)
      liftᵣ (there α)   = there $ ren α

      postulate
        liftᵣ′ : REN (wkₗₑ Δ₁) (wkₗₑ Δ₂)

    open Ren public using (ren)

    module _ (ρ : Ren Δ₁ Δ₂) where
      wkᵣ : Ren Δ₁ (l ∷ Δ₂)
      ren wkᵣ = Ren.wkᵣ ρ

      liftᵣ : Ren (l ∷ Δ₁) (l ∷ Δ₂)
      ren liftᵣ = Ren.liftᵣ ρ

      liftᵣ′ : Ren (wkₗₑ Δ₁) (wkₗₑ Δ₂)
      ren liftᵣ′ = Ren.liftᵣ′ ρ

    private variable
      ρ ρ′ ρ₁ ρ₂ ρ₃ : Ren Δ₁ Δ₂

    idᵣ : Ren Δ Δ
    ren idᵣ = id

    skipᵣ : Ren Δ (l ∷ Δ)
    ren skipᵣ = there

    dropᵣ : Ren (l ∷ Δ₁) Δ₂ → Ren Δ₁ Δ₂
    ren (dropᵣ ρ*) = popᵣ $ ren ρ*

    renᵣ : Ren Δ₁ Δ₂ → Type δ Δ₁ lμ → Type δ Δ₂ lμ
    renᵣ ρ (` α)     = ` ren ρ α
    renᵣ ρ (T₁ ⇒ T₂) = renᵣ ρ T₁ ⇒ renᵣ ρ T₂
    renᵣ ρ (∀α ℓ T)  = ∀α ℓ (renᵣ (liftᵣ ρ) T)
    renᵣ ρ (∀ℓ T)    = ∀ℓ (renᵣ (liftᵣ′ ρ) T)

    ⟦_⟧ᵣ_ : Type δ Δ₁ lμ → Ren Δ₁ Δ₂ → Type δ Δ₂ lμ
    ⟦_⟧ᵣ_ = flip renᵣ

    wk : Type δ Δ l′ → Type δ (l ∷ Δ) l′
    wk = renᵣ skipᵣ

    SUB : (Δ₁ Δ₂ : Env δ) → Set
    SUB {δ = δ} Δ₁ Δ₂ = ∀ {l} → l ∈ Δ₁ → Type δ Δ₂ l

    module _ (σ : SUB {δ = δ} (l ∷ Δ₁) Δ₂) where
      popₛ : SUB Δ₁ Δ₂
      popₛ = σ ∘ there

      topₛ : Type δ Δ₂ l
      topₛ = σ (here refl)

    tabulateₛ : SUB Δ₁ Δ₂ → All (Type δ Δ₂) Δ₁
    tabulateₛ {Δ₁ = []}    _ = []
    tabulateₛ {Δ₁ = _ ∷ _} σ = topₛ σ ∷ tabulateₛ (popₛ σ)

    lookupₛ : All (Type δ Δ₂) Δ₁ → SUB Δ₁ Δ₂
    lookupₛ (α ∷ σ) = λ where (here refl) → α ; (there x) → lookupₛ σ x

    record Sub (Δ₁ Δ₂ : Env δ) : Set where
      constructor mkSub
      field
        sub : SUB Δ₁ Δ₂

      wkₛ : SUB Δ₁ (l ∷ Δ₂)
      wkₛ = wk ∘ sub

      liftₛ : SUB (l ∷ Δ₁) (l ∷ Δ₂)
      liftₛ (here refl)      = ` (here refl)
      liftₛ (there α) = wk $ sub α

      postulate
        liftₛ′ : SUB (wkₗₑ Δ₁) (wkₗₑ Δ₂)

      extₛ : Type δ Δ₂ lμ → SUB (lμ ∷ Δ₁) Δ₂
      extₛ T (here refl) = T
      extₛ T (there α)   = sub α


    open Sub public using (sub)

    module _ (σ : Sub {δ = δ} Δ₁ Δ₂) where
      wkₛ : Sub Δ₁ (l ∷ Δ₂)
      sub wkₛ = Sub.wkₛ σ

      liftₛ : Sub (l ∷ Δ₁) (l ∷ Δ₂)
      sub liftₛ = Sub.liftₛ σ

      liftₛ′ : Sub (wkₗₑ Δ₁) (wkₗₑ Δ₂)
      sub liftₛ′ = Sub.liftₛ′ σ

      extₛ : Type δ Δ₂ l → Sub (l ∷ Δ₁) Δ₂
      sub (extₛ T) = Sub.extₛ σ T


    private variable
      σ σ′ σ₁ σ₂ σ₃ : Sub Δ₁ Δ₂

    idₛ : Sub Δ Δ

    sub idₛ = `_

    subₛ : Sub Δ₁ Δ₂ → Type δ Δ₁ lμ → Type δ Δ₂ lμ
    subₛ σ (` α)     = sub σ α
    subₛ σ (T₁ ⇒ T₂) = subₛ σ T₁ ⇒ subₛ σ T₂
    subₛ σ (∀α ℓ T)  = ∀α ℓ (subₛ (liftₛ σ) T)
    subₛ σ (∀ℓ T)    = ∀ℓ (subₛ (liftₛ′ σ) T)

    ⟦_⟧ₛ_ : Type δ Δ₁ lμ → Sub Δ₁ Δ₂ → Type δ Δ₂ lμ
    ⟦_⟧ₛ_ = flip subₛ

    _∷ₛ_ : Type δ Δ₂ lμ → Sub Δ₁ Δ₂ → Sub (lμ ∷ Δ₁) Δ₂
    T ∷ₛ σ = extₛ σ T

    [_] : Type δ Δ lμ → Sub (lμ ∷ Δ) Δ
    [ T ] = T ∷ₛ idₛ

    _[_]ₛ : Type δ (lμ ∷ Δ) lμ′ → Type δ Δ lμ → Type δ Δ lμ′
    _[_]ₛ T T' = ⟦ T ⟧ₛ [ T' ]

    ρ⇒σ : Ren Δ₁ Δ₂ → Sub Δ₁ Δ₂
    sub (ρ⇒σ ρ) = `_ ∘ ren ρ

    _≫ᵣᵣ_ : Ren Δ₁ Δ₂ → Ren Δ₂ Δ₃ → Ren Δ₁ Δ₃
    ren (ρ₁ ≫ᵣᵣ ρ₂) = ren ρ₂ ∘ ren ρ₁

    _≫ᵣₛ_ : Ren Δ₁ Δ₂ → Sub Δ₂ Δ₃ → Sub Δ₁ Δ₃
    sub (ρ ≫ᵣₛ σ) = sub σ ∘ ren ρ

    _≫ₛᵣ_ : Sub Δ₁ Δ₂ → Ren Δ₂ Δ₃ → Sub Δ₁ Δ₃
    sub (σ ≫ₛᵣ ρ) = ⟦_⟧ᵣ ρ ∘ sub σ

    _≫ₛₛ_ : Sub Δ₁ Δ₂ → Sub Δ₂ Δ₃ → Sub Δ₁ Δ₃
    sub (σ₁ ≫ₛₛ σ₂) = ⟦_⟧ₛ σ₂ ∘ sub σ₁

  module Denotational where
    open Syntax 
    ⟦_⟧ηₗ : (δ : LvlEnv) → Set
    ⟦_⟧ηₗ δ = tt ∈ δ → Level
    
    []ηₗ : ⟦ [] ⟧ηₗ
    []ηₗ ()

    _∷ηₗ_ : ∀ {δ : LvlEnv} → (BoundLevel ⌊ ω ⌋) → ⟦ δ ⟧ηₗ → ⟦ tt ∷ δ ⟧ηₗ
    (l ∷ηₗ ηₗ) (here refl) = # l
    (l ∷ηₗ ηₗ) (there x) = ηₗ x

    lookupηₗ : ∀ {δ : LvlEnv} → ⟦ δ ⟧ηₗ → tt ∈ δ → Level 
    lookupηₗ ηₗ x = ηₗ x

    ⟦_⟧ₗ : ∀ {δ : LvlEnv} → (l : Lvl δ μ) → ⟦ δ ⟧ηₗ → Level
    ⟦ `zero    ⟧ₗ ηₗ = zero
    ⟦ `suc l   ⟧ₗ ηₗ = suc (⟦ l ⟧ₗ  ηₗ)
    ⟦ ` x      ⟧ₗ ηₗ = lookupηₗ ηₗ x
    ⟦ l₁ `⊔ l₂ ⟧ₗ ηₗ = ⟦ l₁ ⟧ₗ ηₗ ⊔ ⟦ l₂ ⟧ₗ ηₗ
    ⟦ `ω+ n ⟧ₗ ηₗ    = ⌊ ω+ₙ n ⌋
    
    suc⨆ :  {δ : LvlEnv} → ⟦ δ ⟧ηₗ → Env δ → Level
    suc⨆ ηₗ [] = zero
    suc⨆ ηₗ (l ∷ Δ) = suc (⟦ l ⟧ₗ ηₗ) ⊔ suc⨆ ηₗ Δ  

    l∈Δ⇒l<⨆Δ : {δ : LvlEnv} {Δ : Env δ} {l : Lvl δ <ω} (ηₗ : ⟦ δ ⟧ηₗ) → l ∈ Δ → ⟦ l ⟧ₗ ηₗ < (suc⨆ ηₗ Δ)
    l∈Δ⇒l<⨆Δ {Δ = Δ} ηₗ (here refl) = <₃ {ℓ₂ = suc⨆ ηₗ Δ} <₁
    l∈Δ⇒l<⨆Δ {Δ = Δ} ηₗ (there x) = <₃ {ℓ₂ = suc⨆ ηₗ Δ} (l∈Δ⇒l<⨆Δ ηₗ x)
  
    ⟦⟧ₗ-wk : {δ : LvlEnv} (ηₗ : ⟦ δ ⟧ηₗ) (l : Lvl δ μ) (ℓ : BoundLevel ⌊ ω ⌋) → ⟦ wkₗ l ⟧ₗ (ℓ ∷ηₗ ηₗ) ≡ ⟦ l ⟧ₗ ηₗ
    ⟦⟧ₗ-wk ηₗ `zero      ℓ = refl
    ⟦⟧ₗ-wk ηₗ (`suc l)   ℓ = cong suc (⟦⟧ₗ-wk ηₗ l ℓ)
    ⟦⟧ₗ-wk ηₗ (` x)      ℓ = lookup-wk ηₗ x ℓ
      where lookup-wk : ∀  {δ : LvlEnv} (ηₗ : ⟦ δ ⟧ηₗ) x ℓ → lookupηₗ (ℓ ∷ηₗ ηₗ) (there x) ≡ lookupηₗ ηₗ x
            lookup-wk {tt ∷ []}     ηₗ t ℓ = refl
            lookup-wk {tt ∷ tt ∷ δ} ηₗ t ℓ = refl
    ⟦⟧ₗ-wk ηₗ (l₁ `⊔ l₂) ℓ = cong₂ _⊔_ (⟦⟧ₗ-wk ηₗ l₁ ℓ) (⟦⟧ₗ-wk ηₗ l₂ ℓ)
    ⟦⟧ₗ-wk ηₗ (`ω+ x)    ℓ = refl

    ⟦_⟧η_ : (Δ : Env δ) → (ηₗ : ⟦ δ ⟧ηₗ) → Set (suc⨆ ηₗ Δ)
    ⟦_⟧η_ {δ = δ} Δ ηₗ = ∀ (l : Lvl δ <ω) → (x : l ∈ Δ) → BoundLift (l∈Δ⇒l<⨆Δ ηₗ x) (Set (⟦ l ⟧ₗ ηₗ)) 

    []η : (ηₗ : ⟦ δ ⟧ηₗ) → ⟦ [] ⟧η ηₗ 
    []η _ _ ()
    
    _∷η_   : {Δ : Env δ} → {ηₗ : ⟦ δ ⟧ηₗ} → Set (⟦ l ⟧ₗ ηₗ) → ⟦ Δ ⟧η ηₗ → ⟦ l ∷ Δ ⟧η ηₗ
    (_∷η_) {l = l} {ηₗ = ηₗ} A η (.l) x@(here refl) = bound-lift (l∈Δ⇒l<⨆Δ {l = l} ηₗ x) A
    (_∷η_) {l = l} {ηₗ = ηₗ} A η l′ x@(there x′)    = bound-lift (l∈Δ⇒l<⨆Δ {l = l′} ηₗ x) (bound-unlift (l∈Δ⇒l<⨆Δ _ _) (η _ x′))

    _∷η⋆_ : {Δ : Env δ} → {ηₗ : ⟦ δ ⟧ηₗ} → (ℓ : BoundLevel ⌊ ω ⌋) → ⟦ Δ ⟧η ηₗ → ⟦ wkₗₑ Δ ⟧η (ℓ ∷ηₗ ηₗ)
    _∷η⋆_ {δ} {Δ = l₁ ∷ Δ} ℓ η l (here refl) = {! η _ (here refl)  !}
    _∷η⋆_ {δ} {Δ = l₁ ∷ l₂ ∷ Δ} ℓ η l (there x) = {!    !}

    lookup : {Δ : Env δ} {ηₗ : ⟦ δ ⟧ηₗ} → ⟦ Δ ⟧η ηₗ → l ∈ Δ → Set (⟦ l ⟧ₗ ηₗ)
    lookup η x = bound-unlift (l∈Δ⇒l<⨆Δ _ _) (η _ x) 

    ⟦_⟧ : ∀ {δ : LvlEnv} {l : Lvl δ μ} {Δ : Env δ} → (T : Type δ Δ l) (ηₗ : ⟦ δ ⟧ηₗ) → ⟦ Δ ⟧η ηₗ → Set (⟦ l ⟧ₗ ηₗ)
    -- ⟦ Nat     ⟧ ηₗ η = ℕ
    ⟦ ` α     ⟧ ηₗ η = lookup η α
    ⟦ T₁ ⇒ T₂ ⟧ ηₗ η = ⟦ T₁ ⟧ ηₗ η → ⟦ T₂ ⟧ ηₗ η 
    ⟦ ∀α l T  ⟧ ηₗ η = ∀ A → ⟦ T ⟧ ηₗ (A ∷η η) 
    ⟦_⟧ {l = l} (∀ℓ T) ηₗ η = ∀ (ℓ : BoundLevel ⌊ ω ⌋) → 
      cast ((⟦⟧ₗ-wk ηₗ l ℓ)) (Lift ⌊ ω ⌋ (⟦ T ⟧ (ℓ ∷ηₗ ηₗ) (ℓ ∷η⋆ η)))
    -- ⟦ Ty l    ⟧ ηₗ η = Set (⟦ l ⟧ₗ ηₗ) 
    -- ⟦ Tyω+ n  ⟧ ηₗ η = cast β-suc-* (Set ⌊ ω+ₙ n ⌋)
    --   -- compiler law
    --   where β-suc-* = trans (β-suc-ω {ℓ₁ = ⌊ 𝟏 ⌋} {ℓ₂ = ⌊ ℕ→MutualOrd n ⌋})
    --                   (cong (ω^ ⌊ 𝟏 ⌋ +_) (β-suc-⌊⌋ {ℕ→MutualOrd n}))
    
    

    
            