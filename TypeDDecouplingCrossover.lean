import Mathlib
import TypeDDecoupling

/-!
# Tier 3 black-box statements: the initial-condition crossover (§cross)

Statements of the §cross results of `typeD_decoupling-draft-rev2.tex`:
the two-phase functional CLT (`prop:twophase`), the duality bridge identity
(`lem:crossbridge`), and the regime-A crossover theorem (`thm:cross`).

The cited / assumed (black-box) content is left as `sorry`: the central limit theorems
(`prop:twophase` and its mixture form), and the Schütz/q-Krawtchouk duality identity
(`lem:crossbridge`).  For the latter, the `q`-Laplace observable `qLaplaceObs` is kept as
an **opaque** η-side object — independent of the dual-side hitting probability — so that
`lem:crossbridge` is a genuine (cited) duality identity rather than a definitional
triviality; it is the one cited duality input, left as an honest `sorry`.  The marquee
correlation value `(1−e^{−4c})/(4c)` is `TypeDDecoupling.rhoCorr c`, whose analytic
content (range, monotonicity, limits) is already proved in `TypeDDecoupling.lean`.

## The dual pair is pinned to a concrete model

A previous version of this file left the rescaled dual pair `X : ℝ → Ω → ℝ × ℝ` as a
*completely free, universally-quantified parameter*.  That made `prop_twophase`,
`prop_twophase_mixture` and `lem_crossbridge` over-strong (in fact refutable): for
example the constant family `X T ω = (0,0)` cannot have a limit law with unit variances,
so "for every `X`, there is a standard-normal-marginal limit" is false.

This file fixes that by pinning `X` to the actual object of the paper through two
concrete predicates on the rescaled coupled walks:

* `IsConditionedDualPair μ u X` — the *conditional* model of `prop:twophase`: the two
  species' walks share their `±1` increments for the first `⌊2u·T⌋` steps (the
  "pre-split" phase of fraction `u`) and use independent increments afterwards.
* `IsDualPairRescaling μ c X` — the *full* model: the split happens at a random step
  `τ T`, and the split fraction `τ/T` converges in distribution to the mixing variable
  `U = min(Exp(4c), 1)` (the law `minExpCDF c`).

With these predicates threaded in as hypotheses, the statements below are genuine
(true-but-cited) theorems rather than false universals, and the constant-family
counterexample no longer satisfies the hypothesis.  What remains `sorry` is exactly the
cited CLT/duality content the paper itself cites rather than proves.

Convergence in distribution of `ℝ × ℝ`-valued random variables is rendered by the
portmanteau test-function characterisation (`TendstoInDistribution`).
-/

open scoped BigOperators Real Topology
open MeasureTheory Filter ProbabilityTheory

namespace TypeDDecoupling

/-- Convergence in distribution, along `atTop` in the scaling parameter `T : ℝ`, of a
family `X T : Ω → ℝ × ℝ` of random variables towards a probability law `ν` on `ℝ × ℝ`:
`E[f(X_T)] → ∫ f dν` for every bounded continuous `f`. -/
def TendstoInDistribution {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (X : ℝ → Ω → ℝ × ℝ) (ν : Measure (ℝ × ℝ)) : Prop :=
  ∀ f : (ℝ × ℝ) → ℝ, Continuous f → (∃ M : ℝ, ∀ z, |f z| ≤ M) →
    Tendsto (fun T => ∫ ω, f (X T ω) ∂μ) atTop (𝓝 (∫ z, f z ∂ν))

/-- Mean, variance and covariance read off a law `ν` on `ℝ × ℝ` via its coordinate
projections; used to state "standard normal marginals, cross-correlation `r`". -/
def HasStdNormalMarginalsCorr (ν : Measure (ℝ × ℝ)) (r : ℝ) : Prop :=
  (∫ z, z.1 ∂ν = 0) ∧ (∫ z, z.2 ∂ν = 0) ∧
  (∫ z, z.1 ^ 2 ∂ν = 1) ∧ (∫ z, z.2 ^ 2 ∂ν = 1) ∧
  (∫ z, z.1 * z.2 ∂ν = r)

/-! ## The concrete dual-pair model -/

/-- A real random variable that is a **symmetric `±1` increment**: it is measurable,
takes only the values `±1`, and has mean zero (`E[e] = 0`).  These are the elementary
nearest-neighbour steps of the dual walks. -/
def SymmetricPMOneIncrement {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (e : Ω → ℝ) : Prop :=
  Measurable e ∧ (∀ ω, e ω = 1 ∨ e ω = -1) ∧ ∫ ω, e ω ∂μ = 0

/-- CDF of the mixing variable `U = min(E, 1)` with `E ∼ Exp(4c)`:
`0` for `x < 0`, `1 − e^{−4cx}` for `0 ≤ x < 1`, and `1` for `x ≥ 1` (the atom of mass
`e^{−4c}` at `1`). -/
noncomputable def minExpCDF (c x : ℝ) : ℝ :=
  if x < 0 then 0 else if x < 1 then 1 - Real.exp (-(4 * c * x)) else 1

/-- The first species' rescaled walk built from the shared increments `eps (.inl ·)`.

The walk runs for real time `T` at jump rate `2` (the symmetric nearest-neighbour
rate of the dual SSEP walk), hence sums `⌊2T⌋` independent `±1` increments; dividing by
`√(2T)` gives the diffusive scaling with limiting variance `2T/(2T) = 1`, i.e. an
`N(0,1)` marginal, matching `(X₁,X₂)/√(2T)` of the paper. -/
noncomputable def dualWalkFst {Ω : Type*} (eps : ℕ ⊕ ℕ → Ω → ℝ)
    (T : ℝ) (ω : Ω) : ℝ :=
  (∑ i ∈ Finset.range ⌊2 * T⌋₊, eps (Sum.inl i) ω) / Real.sqrt (2 * T)

/-- The second species' rescaled walk: it uses the *same* increments `eps (.inl ·)` for
the first `splitStep` steps (the coupled, pre-split phase) and the *independent*
increments `eps (.inr ·)` afterwards. -/
noncomputable def dualWalkSnd {Ω : Type*} (eps : ℕ ⊕ ℕ → Ω → ℝ)
    (splitStep : ℕ) (T : ℝ) (ω : Ω) : ℝ :=
  (∑ i ∈ Finset.range ⌊2 * T⌋₊,
      (if i < splitStep then eps (Sum.inl i) ω else eps (Sum.inr i) ω)) / Real.sqrt (2 * T)

/-- **Conditional dual-pair model** (`prop:twophase`, conditional form).  `X` is the
rescaled pair `(X₁,X₂)/√(2T)` of two coupled nearest-neighbour walks whose `±1`
increments are independent and symmetric, sharing their increments for the first
`⌊2u·T⌋` steps (the pre-split phase of fraction `u` of the `⌊2T⌋` total steps) and
running on independent increments afterwards.  The shared count is `⌊u·(2T)⌋` so that
the limiting cross-covariance `⌊2uT⌋/(2T) → u` equals the correlation `u`. -/
def IsConditionedDualPair {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (u : ℝ) (X : ℝ → Ω → ℝ × ℝ) : Prop :=
  ∃ eps : ℕ ⊕ ℕ → Ω → ℝ,
    (∀ k, SymmetricPMOneIncrement μ (eps k)) ∧ iIndepFun eps μ ∧
    (∀ T ω, X T ω = (dualWalkFst eps T ω, dualWalkSnd eps ⌊u * (2 * T)⌋₊ T ω))

/-- **Full dual-pair model** (`prop:twophase`, unconditional form, and `thm:cross`).
`X` is the rescaled pair `(X₁,X₂)/√(2T)` of two coupled nearest-neighbour walks whose
`±1` increments are independent and symmetric.  The split happens at a *random* step
`τ T : Ω → ℕ`; the two species share their increments before `τ T` and use independent
increments afterwards.  Driven by the regime-(A) split rate `q = 1 − c/T`, the split
fraction `τ/T` converges in distribution to the mixing variable `U = min(Exp(4c), 1)`
(its CDF is `minExpCDF c`). -/
def IsDualPairRescaling {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (c : ℝ) (X : ℝ → Ω → ℝ × ℝ) : Prop :=
  ∃ (eps : ℕ ⊕ ℕ → Ω → ℝ) (τ : ℝ → Ω → ℕ),
    (∀ k, SymmetricPMOneIncrement μ (eps k)) ∧ iIndepFun eps μ ∧
    -- the split fraction τ/(2T) (real-time fraction) converges in distribution to
    -- U = min(Exp(4c), 1): here `τ T ω` is the split *jump count* out of the `⌊2T⌋`
    -- total jumps, so the real-time split fraction is `τ/(2T)`.
    (∀ x : ℝ, Tendsto (fun T => (μ {ω | (τ T ω : ℝ) ≤ x * (2 * T)}).toReal) atTop
        (𝓝 (minExpCDF c x))) ∧
    -- X is the rescaled coupled dual pair
    (∀ T ω, X T ω = (dualWalkFst eps T ω, dualWalkSnd eps (τ T ω) T ω))

/-- The dual pair's joint hitting probability `ℙ(X₁(s) ≤ 0, X₂(s) ≤ 0)`, the right-hand
object of `lem:crossbridge`. -/
noncomputable def dualHitProb {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (X : ℝ → Ω → ℝ × ℝ) (s : ℝ) : ℝ :=
  (μ {ω | (X s ω).1 ≤ 0 ∧ (X s ω).2 ≤ 0}).toReal

/-- The **species cross-correlation `q`-Laplace observable** of the two-species process.

This is the η-side object of `lem:crossbridge`: the joint `q`-Laplace current observable
of the two species under the block initial condition,
`E_{η⁰}[∏_i η_{i,a}(s) · q^{2(a + N⁺_{a+1}(η_i(s)))}]`.  Its construction lives in the
q-Krawtchouk / Schütz self-duality framework of the two-species ASEP, which is not
available in Mathlib.  We therefore keep it **opaque**: a schematic real-valued
observable attached to the model data `(μ, X, q, a, s)`, with **no** definitional tie to
the dual-side hitting probability `dualHitProb`.

Keeping it opaque (rather than *defining* it to equal its dual-side value) is essential:
the entire mathematical content of `lem:crossbridge` is the Schütz/q-Krawtchouk *duality
identity* that rewrites this η-side expectation as the dual-side quantity
`q^{2k} · ℙ_{(a,a)}(X₁(s) ≤ 0, X₂(s) ≤ 0)`.  Defining the left-hand side to be the
right-hand side would make that identity hold by `rfl` and delete exactly the duality
content the lemma is about.  With the observable independent, `lem:crossbridge` is a
genuine (cited) identity, proved below from the duality input. -/
opaque qLaplaceObs {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (X : ℝ → Ω → ℝ × ℝ) (q : ℝ) (a : ℤ) (s : ℝ) : ℝ

/-! ## `prop:twophase` — two-phase functional CLT -/

/-- **Proposition `prop:twophase`** (two-phase functional CLT, conditional form).
Conditionally on `τ/T → u ∈ [0,1]` and on the no-rebinding event `A_T`, the rescaled
dual pair `(X₁(T),X₂(T))/√(2T)` converges in distribution to a standard bivariate normal
of correlation `u` — the law of `(√u ξ₀ + √(1−u) ξ₁, √u ξ₀ + √(1−u) ξ₂)` with
`ξ₀,ξ₁,ξ₂` i.i.d. `N(0,1)`.

The conditioning on `τ/T → u` is encoded by `hX : IsConditionedDualPair μ u X`: the two
walks share their `±1` increments for the first `⌊2u·T⌋` steps and use independent
increments afterwards.  This pins `X` to the actual coupled walks, so the statement is a
genuine (cited) bivariate CLT rather than a free universal.

*Cited/assumed result, black box (`sorry`).* -/
theorem prop_twophase
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (u : ℝ) (hu : u ∈ Set.Icc (0 : ℝ) 1)
    (X : ℝ → Ω → ℝ × ℝ) (hX : IsConditionedDualPair μ u X) :
    ∃ ν : Measure (ℝ × ℝ), IsProbabilityMeasure ν ∧
      HasStdNormalMarginalsCorr ν u ∧ TendstoInDistribution μ X ν := by
  sorry

/-! ## `lem:crossbridge` — the dual pair computes the species cross-correlation -/

/-- **Lemma `lem:crossbridge`** (the dual pair computes the species cross-correlation).
For the block initial condition, the joint `q`-Laplace observable of the two species
equals, up to the explicit boundary constant `q^{2k}`, a two-particle hitting
probability of the different-species dual pair:
`E_{η⁰}[∏_i η_{i,a}(s) q^{2(a + N⁺_{a+1}(η_i(s)))}] = q^{2k} ℙ_{(a,a)}(X₁(s)≤0, X₂(s)≤0)`.

The right-hand side is the dual-pair hitting probability `dualHitProb μ X s`, and the
left-hand side is the η-side observable `qLaplaceObs μ X q a` — an object *independent* of
`dualHitProb` (kept opaque, since its q-Krawtchouk/Schütz construction needs the duality
framework absent from Mathlib).  The equality of the two is exactly the
Schütz/q-Krawtchouk **duality identity** the paper cites; it is the entire content of the
lemma and is *not* a definitional triviality.

The hypotheses `_hc : 0 < c`, `_hX : IsDualPairRescaling μ c X` and `_hq : q ∈ (0,1)`
scope the statement to the actual regime-A dual-pair model.

*Cited duality result, black box (`sorry`).*  This single `sorry` stands for the one
cited input — the q-Krawtchouk/Schütz self-duality of the two-species ASEP — which is not
yet formalized in Mathlib.  It is deliberately left as an honest `sorry` rather than
discharged by *defining* `qLaplaceObs` to equal its dual-side value, which would make the
identity hold by `rfl` and delete its mathematical content. -/
theorem lem_crossbridge
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (c : ℝ) (_hc : 0 < c) (X : ℝ → Ω → ℝ × ℝ) (_hX : IsDualPairRescaling μ c X)
    (q : ℝ) (_hq : q ∈ Set.Ioo (0 : ℝ) 1) (a : ℤ) :
    ∃ k : ℤ, ∀ s : ℝ, 0 ≤ s → qLaplaceObs μ X q a s = q ^ (2 * k) * dualHitProb μ X s := by
  sorry

/-! ## Mixture form of `prop:twophase` (the genuine CLT black box) -/

/-- **Mixture form of `prop:twophase`.**  The limit law of `(X₁,X₂)/√(2T)` is the
mixture, over the split fraction `U ∼ min(Exp(4c),1)`, of the bivariate normals of
correlation `U` produced by `prop:twophase`.  This mixture is a probability law with
standard normal marginals, and its cross-correlation is the mean of the mixing
variable, `r = E[U] = ∫₀^∞ min(t,1)·(4c)·e^{−4ct} dt`.

This is the *unconditional* statement of `prop:twophase` (its second paragraph in the
paper): convergence in distribution of the rescaled dual pair to the `U`-mixture.  The
pair is pinned to the concrete model via `hX : IsDualPairRescaling μ c X`, so this is a
genuine (cited) CLT statement.  It is the **only** CLT black box (`sorry`) that the
crossover theorem `thm_cross` below rests on; everything else in `thm_cross` is then
assembled from already-proved results.  The correlation is returned in its raw
integral form `∫ … min t 1 …` precisely so that `thm_cross` can identify it with
`rhoCorr c` using the proved closed-form lemma `expMin_mean_eq_rhoCorr`. -/
theorem prop_twophase_mixture
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (c : ℝ) (hc : 0 < c) (X : ℝ → Ω → ℝ × ℝ) (hX : IsDualPairRescaling μ c X) :
    ∃ (ν : Measure (ℝ × ℝ)) (r : ℝ), IsProbabilityMeasure ν ∧
      r = ∫ t in Set.Ioi (0 : ℝ), min t 1 * (4 * c) * Real.exp (-(4 * c * t)) ∧
      HasStdNormalMarginalsCorr ν r ∧ TendstoInDistribution μ X ν := by
  sorry

/-! ## `thm:cross` — regime-A crossover from the block initial condition -/

/-- **Theorem `thm:cross`** (regime-A crossover from the block initial condition).
Fix `c > 0` and set `q = 1 − c/T`.  As `T → ∞` the rescaled dual pair
`(X₁,X₂)/√(2T)` converges in distribution to a law `(G₁,G₂)` with standard normal
marginals and cross-correlation `Corr(G₁,G₂) = (1−e^{−4c})/(4c) = rhoCorr c ∈ (0,1)`.
The joint law is the non-Gaussian mixture of `prop:twophase` with mixing variable
`U ∼ min(Exp(4c),1)` (an atom of mass `e^{−4c}` at `1`, where `G₁=G₂`).  By
`lem:crossbridge`, `(G₁,G₂)` is the limiting joint law of the two species' `q`-Laplace
current observables from the block initial condition.

The dual pair `X` is the concrete model `hX : IsDualPairRescaling μ c X`.  This is the
paper's one-line assembly carried out in Lean: the proof **combines** three inputs and
contains no `sorry` of its own.
* `prop_twophase_mixture` (the mixture form of `prop:twophase`) supplies the limit law
  `ν`, its standard normal marginals, its cross-correlation `r = E[U]`, and the
  convergence in distribution;
* `thm:closed` supplies the closed form of the correlation —
  `expMin_mean_eq_rhoCorr` rewrites `E[U]` to `rhoCorr c`, and `rhoCorr_mem_Ioo`
  places it in `(0,1)` (both already proved in `TypeDDecoupling.lean`);
* `lem_crossbridge` supplies the identification of `(G₁,G₂)` with the two species'
  `q`-Laplace observables (the final existential clause). -/
theorem thm_cross
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (c : ℝ) (hc : 0 < c) (X : ℝ → Ω → ℝ × ℝ) (hX : IsDualPairRescaling μ c X)
    (q : ℝ) (hq : q ∈ Set.Ioo (0 : ℝ) 1) (a : ℤ) :
    ∃ ν : Measure (ℝ × ℝ), IsProbabilityMeasure ν ∧
      HasStdNormalMarginalsCorr ν (rhoCorr c) ∧
      rhoCorr c ∈ Set.Ioo (0 : ℝ) 1 ∧
      TendstoInDistribution μ X ν ∧
      ∃ k : ℤ, ∀ s : ℝ, 0 ≤ s → qLaplaceObs μ X q a s = q ^ (2 * k) * dualHitProb μ X s := by
  -- `prop:twophase` (mixture form): the limit law, its marginals, correlation `E[U]`,
  -- and convergence in distribution.
  obtain ⟨ν, r, hprob, hr, hmarg, htend⟩ := prop_twophase_mixture μ c hc X hX
  -- `thm:closed`: the closed form `E[U] = rhoCorr c`.
  rw [expMin_mean_eq_rhoCorr hc] at hr
  subst hr
  -- Assemble, using `rhoCorr_mem_Ioo` (`thm:closed`) and `lem_crossbridge`.
  exact ⟨ν, hprob, hmarg, rhoCorr_mem_Ioo hc, htend,
    lem_crossbridge μ c hc X hX q hq a⟩

end TypeDDecoupling
