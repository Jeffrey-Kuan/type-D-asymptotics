import Mathlib

/-!
# Tier 3 / Tier 4 black-box statements: local CLTs, occupation times, dual kernels

This file formalises the **statements** of the §lclt (local central limit theorems for
the dual coordinates) and §kernel (two-particle dual kernel bound) results of
`typeD_decoupling-draft-rev2.tex`, together with the two classical inputs they cite
(Kolmogorov–Rogozin anti-concentration, Karamata's Tauberian theorem).

Per the user's instruction, these are **cited / assumed results taken as a black box**:
each is stated as faithfully as feasible and left as `sorry`.  None of them is proved
here; the `sorry`s are intentional and mark exactly the literature inputs that the paper
invokes.  We are *not* permitted to introduce `axiom`s, so the assumed status is recorded
honestly by an unfilled `sorry` rather than by an axiom.

The continuous-time walks are encoded schematically by their **time-marginal transition
kernels** `p : ℝ → ℤ → ℝ` (with `p t r = ℙ₀(X(t) = r)`), tied to a jump-rate matrix
`rate : ℤ → ℤ → ℝ` through the Kolmogorov forward equations (`IsTransitionKernel`).
-/

open scoped BigOperators Real Topology
open MeasureTheory Filter Asymptotics ProbabilityTheory

namespace TypeDDecoupling

/-! ## Schematic encoding of a continuous-time walk on `ℤ` -/

/-- `p` is the transition kernel of the continuous-time Markov walk on `ℤ` with jump
rates `rate x y` (the rate of jumping from `x` to `y`).  This bundles the defining
properties: the initial condition `p 0 = δ₀`, nonnegativity, and the Kolmogorov forward
(master) equation `∂ₜ p_t(r) = Σ_y rate(y,r) p_t(y) − (Σ_y rate(r,y)) p_t(r)`. -/
def IsTransitionKernel (rate : ℤ → ℤ → ℝ) (p : ℝ → ℤ → ℝ) : Prop :=
  (∀ r : ℤ, p 0 r = if r = 0 then 1 else 0) ∧
  (∀ t : ℝ, ∀ r : ℤ, 0 ≤ p t r) ∧
  (∀ t : ℝ, ∀ r : ℤ,
     HasDerivAt (fun s => p s r)
       ((∑' y : ℤ, rate y r * p t y) - (∑' y : ℤ, rate r y) * p t r) t)

/-- Occupation time of state `r` up to time `s`: `τ_r(s) = ∫₀ˢ ℙ₀(X(t)=r) dt`. -/
noncomputable def occupation (p : ℝ → ℤ → ℝ) (r : ℤ) (s : ℝ) : ℝ :=
  ∫ t in (0:ℝ)..s, p t r

/-- The structural hypotheses on a driftless, finite-range, reversible walk used
throughout §lclt (Lemma `lem:free`).  `rate` is the jump-rate matrix, `p` its transition
kernel, `m` a reversing measure with `c₁ ≤ m ≤ c₂`, jump range `≤ ϱ`, total exit rate
`≤ Λ`, and nearest-neighbour conductance bounded below by `δ > 0`. -/
structure DriftlessReversibleWalk where
  rate : ℤ → ℤ → ℝ
  p : ℝ → ℤ → ℝ
  m : ℤ → ℝ
  c₁ : ℝ
  c₂ : ℝ
  δ : ℝ
  Λ : ℝ
  ϱ : ℕ
  isKernel : IsTransitionKernel rate p
  rate_nonneg : ∀ x y : ℤ, 0 ≤ rate x y
  c₁_pos : 0 < c₁
  δ_pos : 0 < δ
  m_lb : ∀ x : ℤ, c₁ ≤ m x
  m_ub : ∀ x : ℤ, m x ≤ c₂
  reversible : ∀ x y : ℤ, m x * rate x y = m y * rate y x
  finite_range : ∀ x y : ℤ, rate x y ≠ 0 → (y - x).natAbs ≤ ϱ
  exit_le : ∀ x : ℤ, (∑' y : ℤ, rate x y) ≤ Λ
  conductance_lb : ∀ x : ℤ, δ ≤ m x * rate x (x + 1)
  driftless : ∀ x : ℤ, (∑' y : ℤ, ((y : ℝ) - (x : ℝ)) * rate x y) = 0

/-! ## `lem:free` — free and perturbed kernel bounds (on-diagonal local CLT) -/

/-- **Lemma `lem:free`** (free and perturbed kernel bounds; cf. \cite{LawlerLimic, CKS}).
For a driftless, finite-range walk reversible with respect to a measure bounded above and
below, with conductances bounded below, the time-`t` transition probabilities obey the
on-diagonal local-CLT / heat-kernel bound
`sup_r ℙ(X(t)=r) ≤ C / √(1+t)`, with `C` depending only on `(c₁,c₂,δ,Λ,ϱ)`.

*Cited result, assumed as a black box (`sorry`).* -/
theorem lem_free (W : DriftlessReversibleWalk) :
    ∃ C : ℝ, 0 < C ∧ ∀ t : ℝ, 0 ≤ t → ∀ r : ℤ,
      W.p t r ≤ C / Real.sqrt (1 + t) := by
  sorry

/-! ## `lem:Rlclt` — defected marginal local CLT for the relative coordinate -/

/-- **Lemma `lem:Rlclt`** (defected marginal local CLT).  Let `R` be the
different-species relative walk: off `{-1,0,1}` a symmetric rate-`(1+q²)` walk, with a
sticky origin held for an `Exp(ν_sp)` time (`ν_sp = 2q²ε`, `ε = 1−q²`) and re-entered
from `±1` at the merge rate `ε`, started at `R(0)=0`.  Then, in the window `ν_sp t ≤ K`,
`ℙ(R(t)=r) ≤ C/√(1+t) + δ_{r,0} e^{−ν_sp t}` with `C = C(K,q)`.

*Cited/assumed result, black box (`sorry`).* The dynamics of `R` is encoded through its
rate matrix `rate` and kernel `pR` via `IsTransitionKernel`; the sticky/defect structure
is recorded by the hypotheses `hsplit`, `hmerge`, `hbulk`. -/
theorem lem_Rlclt
    (q : ℝ) (hq : q ∈ Set.Ioo (0 : ℝ) 1)
    (rate : ℤ → ℤ → ℝ) (pR : ℝ → ℤ → ℝ)
    (hker : IsTransitionKernel rate pR)
    (hbulk : ∀ x : ℤ, 2 ≤ |x| → ∀ y, rate x y =
       (if y = x + 1 ∨ y = x - 1 then 1 + q ^ 2 else 0))
    (hsplit : rate 0 1 = q ^ 2 * (1 - q ^ 2) ∧ rate 0 (-1) = q ^ 2 * (1 - q ^ 2))
    (hmerge : rate 1 0 = 1 - q ^ 2 ∧ rate (-1) 0 = 1 - q ^ 2)
    (K : ℝ) (hK : 0 < K) :
    ∃ C : ℝ, 0 < C ∧ ∀ t : ℝ, 0 ≤ t → 2 * q ^ 2 * (1 - q ^ 2) * t ≤ K → ∀ r : ℤ,
      pR t r ≤ C / Real.sqrt (1 + t)
        + (if r = 0 then Real.exp (-(2 * q ^ 2 * (1 - q ^ 2) * t)) else 0) := by
  sorry

/-! ## `lem:KR` — Kolmogorov–Rogozin anti-concentration -/

/-- Largest atom (concentration function) of an integer-valued random variable `Y`:
`Q(Y) = sup_x ℙ(Y = x)`. -/
noncomputable def concentration {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (Y : Ω → ℤ) : ℝ :=
  ⨆ x : ℤ, (μ (Y ⁻¹' {x})).toReal

/-- **Lemma `lem:KR`** (Kolmogorov–Rogozin anti-concentration; \cite[Ch.~III]{Petrov}).
There is a universal constant `C` such that for independent integer-valued
`Y₁,…,Yₙ`, the largest atom of the sum obeys
`Q(Y₁+⋯+Yₙ) ≤ C · (Σⱼ (1 − Q(Yⱼ)))^{−1/2}`.

*Classical cited result, black box (`sorry`).* -/
theorem kolmogorov_rogozin :
    ∃ C : ℝ, 0 < C ∧ ∀ {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω)
      [IsProbabilityMeasure μ] (n : ℕ) (Y : Fin n → Ω → ℤ),
      (∀ j, Measurable (Y j)) → iIndepFun Y μ →
      0 < (∑ j, (1 - concentration μ (Y j))) →
      concentration μ (fun ω => ∑ j, Y j ω)
        ≤ C / Real.sqrt (∑ j, (1 - concentration μ (Y j))) := by
  sorry

/-! ## `lem:Slclt` — conditional concentration for the sum coordinate -/

/-- **Lemma `lem:Slclt`** (conditional concentration for the sum coordinate).
Given the *unsigned skeleton* `𝔖` (the `R`-path together with the pair-hop times),
the sum coordinate is `S(t) = m(𝔖) + Σ_{j≤M} η_j` with the `η_j` conditionally
independent two-valued increments, each value of probability in `[δ,1−δ]`; hence by
Kolmogorov–Rogozin `ℙ(S(t)=s' ∣ 𝔖) ≤ C/√(1+M)`, and the number `M` of ambiguous
jumps stochastically dominates a rate-`1` Poisson count, so `ℙ(M < t/2) ≤ e^{−ct}`.

*Cited/assumed result, black box (`sorry`).*  The two genuinely mathematical pieces are
stated concretely: (a) the conditional law of `S(t)` is that of
`shift + Σ_{j<M} η_j` with the `η_j` independent two-valued increments each value of
probability `≥ δ`, whose largest atom is `≤ C/√(1+M)`; and (b) the ambiguous-jump count
`Mrv` stochastically dominates a rate-`1` Poisson variable, giving `ℙ(Mrv<t/2) ≤ e^{−ct}`. -/
theorem lem_Slclt
    (q : ℝ) (hq : q ∈ Set.Ioo (0 : ℝ) 1)
    {Ω : Type} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (M : ℕ) (η : Fin M → Ω → ℤ) (shift : ℤ) (δ : ℝ)
    (hδ : 0 < δ) (hmeas : ∀ j, Measurable (η j)) (hindep : iIndepFun η μ)
    (htwo : ∀ j, ∃ u v : ℤ, u ≠ v ∧ δ ≤ (μ (η j ⁻¹' {u})).toReal
              ∧ δ ≤ (μ (η j ⁻¹' {v})).toReal)
    (Mrv : Ω → ℕ) (t : ℝ) (ht : 0 ≤ t)
    (hdom : ∀ k : ℕ, (μ {ω | Mrv ω < k}).toReal
              ≤ Real.exp (-t) * ∑ i ∈ Finset.range k, t ^ i / i.factorial) :
    (∃ C : ℝ, 0 < C ∧
        concentration μ (fun ω => shift + ∑ j, η j ω) ≤ C / Real.sqrt (1 + (M : ℝ)))
    ∧ (∃ c : ℝ, 0 < c ∧ (μ {ω | (Mrv ω : ℝ) < t / 2}).toReal ≤ Real.exp (-(c * t))) := by
  sorry

/-! ## `thm:karamata` — Karamata's Tauberian theorem -/

/-- `L` is slowly varying at infinity: `L(a s)/L(s) → 1` as `s → ∞` for every `a > 0`. -/
def SlowlyVarying (L : ℝ → ℝ) : Prop :=
  ∀ a : ℝ, 0 < a → Tendsto (fun s => L (a * s) / L s) atTop (𝓝 1)

/-- **Theorem `thm:karamata`** (Karamata's Tauberian theorem;
\cite[Thm.~1.7.1′]{BGT}, \cite[§XIII.5]{Feller2}).
For a locally integrable `p ≥ 0` with finite Laplace transform `ω(λ) = ∫₀^∞ e^{−λt}p(t)dt`,
`ρ ≥ 0`, and `L` slowly varying, the small-`λ` behaviour of `ω` and the large-`s`
behaviour of `∫₀ˢ p` are equivalent:
`ω(λ) ∼ λ^{−ρ} L(1/λ)  (λ↓0) ⇔ ∫₀ˢ p ∼ s^ρ L(s)/Γ(ρ+1)  (s→∞)`.

*Classical cited result, black box (`sorry`).* -/
theorem karamata_tauberian
    (p : ℝ → ℝ) (ρ : ℝ) (L : ℝ → ℝ)
    (hp : ∀ t, 0 ≤ p t) (hρ : 0 ≤ ρ) (hL : SlowlyVarying L)
    (hLpos : ∀ s, 0 < L s)
    (ω : ℝ → ℝ) (hω : ∀ lam, 0 < lam → ω lam = ∫ t in Set.Ioi (0:ℝ), Real.exp (-(lam * t)) * p t) :
    (IsEquivalent (𝓝[>] (0:ℝ)) ω (fun lam => lam ^ (-ρ) * L (1 / lam)))
      ↔ (IsEquivalent atTop (fun s => ∫ t in (0:ℝ)..s, p t)
           (fun s => s ^ ρ * L s / Real.Gamma (ρ + 1))) := by
  sorry

/-! ## `lem:tau` — occupation-time asymptotics -/

/-- The structural hypotheses of Lemma `lem:tau`: an irreducible, recurrent walk on `ℤ`,
reversible with respect to a measure `m` with `c₁ ≤ m ≤ c₂` and `m ≡ 1` off a finite set,
agreeing off a finite set with the symmetric nearest-neighbour walk of rate `a` per
direction. -/
structure OccupationWalk where
  rate : ℤ → ℤ → ℝ
  p : ℝ → ℤ → ℝ
  m : ℤ → ℝ
  a : ℝ
  c₁ : ℝ
  c₂ : ℝ
  F : Finset ℤ
  a_pos : 0 < a
  c₁_pos : 0 < c₁
  isKernel : IsTransitionKernel rate p
  m_lb : ∀ x, c₁ ≤ m x
  m_ub : ∀ x, m x ≤ c₂
  m_one_off : ∀ x, x ∉ F → m x = 1
  reversible : ∀ x y, m x * rate x y = m y * rate y x
  free_off : ∀ x, x ∉ F → ∀ y, rate x y = (if y = x + 1 ∨ y = x - 1 then a else 0)
  recurrent : ∀ r : ℤ, ¬ Summable (fun (n : ℕ) => p (n : ℝ) r)

/-
**Lemma `lem:tau`** (occupation-time asymptotics).  For such a walk and every fixed
`r`, `τ_r(s) := ∫₀ˢ ℙ₀(X(t)=r) dt ∼ m(r) √(s/(π a))` as `s → ∞`.

*Derived here* (the paper's derivation "from detailed balance, the first-passage
decomposition, and Karamata").  The detailed-balance / first-passage step is taken as the
explicit hypothesis `hLaplace`: the Laplace transform `ω(λ) = ∫₀^∞ e^{−λt} ℙ₀(X(t)=r) dt`
has the small-`λ` asymptotics `ω(λ) ∼ λ^{−1/2}·m(r)/(2√a)`.  The transfer from this Laplace
behaviour to the occupation-time asymptotics is then performed by genuinely invoking
Karamata's Tauberian theorem `karamata_tauberian` (with `ρ = 1/2` and the constant slowly
varying function `L ≡ m(r)/(2√a)`), using `Γ(3/2) = √π/2` to match constants.
-/
theorem lem_tau (W : OccupationWalk) (r : ℤ)
    (ω : ℝ → ℝ)
    (hω : ∀ lam, 0 < lam → ω lam
            = ∫ t in Set.Ioi (0:ℝ), Real.exp (-(lam * t)) * W.p t r)
    (hLaplace : IsEquivalent (𝓝[>] (0:ℝ)) ω
            (fun lam => lam ^ (-(1/2 : ℝ)) * (W.m r / (2 * Real.sqrt W.a)))) :
    IsEquivalent atTop (fun s => occupation W.p r s)
      (fun s => W.m r * Real.sqrt (s / (Real.pi * W.a))) := by
  convert ( karamata_tauberian ( fun t => W.p t r ) ( 1 / 2 ) ( fun _ => W.m r / ( 2 * Real.sqrt W.a ) ) ( fun t => W.isKernel.2.1 t r ) ( by linarith ) ( ?_ ) ( ?_ ) ω hω ) |>.mp ?_ using 1;
  · ext s; rw [ Real.Gamma_add_one ( by norm_num ), Real.Gamma_one_half_eq ] ; ring;
    by_cases hs : 0 ≤ s <;> simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Real.sqrt_eq_rpow ];
    · norm_num [ ← Real.sqrt_eq_rpow, Real.sqrt_mul, Real.pi_pos.le, W.a_pos.le, hs ] ; ring;
    · norm_num [ ← Real.sqrt_eq_rpow, Real.sqrt_eq_zero_of_nonpos hs.le ];
      exact Or.inl <| Real.sqrt_eq_zero_of_nonpos <| mul_nonpos_of_nonpos_of_nonneg hs.le <| mul_nonneg ( inv_nonneg.2 Real.pi_pos.le ) <| inv_nonneg.2 <| le_of_lt <| W.a_pos;
  · intro a ha; norm_num [ ha.ne' ] ;
    exact ⟨ ne_of_gt ( lt_of_lt_of_le W.c₁_pos ( W.m_lb r ) ), ne_of_gt ( Real.sqrt_pos.mpr W.a_pos ) ⟩;
  · exact fun _ => div_pos ( lt_of_lt_of_le W.c₁_pos ( W.m_lb r ) ) ( mul_pos zero_lt_two ( Real.sqrt_pos.mpr W.a_pos ) );
  · exact hLaplace

/-! ## `lem:occ` — adjacent-set occupation bound (occupation half) -/

/-
**Lemma `lem:occ` (occupation half)**.  After the split, with no re-binding, the
relative walk `R` performs the no-merge walk; its adjacent-set occupation
`Λ_T = ∫_τ^T 𝟙{|R(t)|=1} dt` has expectation `O(√T)`.  Schematically: the expected
occupation of `{±1}` under the no-merge kernel `pR` up to time `T` is `≤ C √T`.

*Formalized and proved here* from the cited on-diagonal bound `hfree` (the output of
`lem:free` for the no-merge walk): integrating `Cf/√(1+t)` over `[0,T]` gives the
`O(√T)` occupation.
-/
theorem lem_occ_occupation
    (pR : ℝ → ℤ → ℝ) (hnn : ∀ t r, 0 ≤ pR t r)
    (hfree : ∃ Cf : ℝ, 0 < Cf ∧ ∀ t : ℝ, 0 ≤ t → ∀ r : ℤ, pR t r ≤ Cf / Real.sqrt (1 + t)) :
    ∃ C : ℝ, 0 < C ∧ ∀ T : ℝ, 0 ≤ T →
      occupation pR 1 T + occupation pR (-1) T ≤ C * Real.sqrt (1 + T) := by
  obtain ⟨Cf, hCf_pos, hCf⟩ := hfree
  use 4 * Cf + 1; (
  refine' ⟨ by positivity, fun T hT => _ ⟩
  have h_integrable : ∀ r : ℤ, occupation pR r T ≤ ∫ t in (0:ℝ)..T, Cf / Real.sqrt (1 + t) := by
    intro r
    unfold occupation
    generalize_proofs at *; (
    rw [ intervalIntegral.integral_of_le hT, intervalIntegral.integral_of_le hT ];
    refine' MeasureTheory.integral_mono_of_nonneg _ _ _;
    · exact Filter.Eventually.of_forall fun x => hnn x r;
    · exact ContinuousOn.integrableOn_Icc ( by exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.div continuousAt_const ( Real.continuous_sqrt.continuousAt.comp <| continuousAt_const.add continuousAt_id ) <| ne_of_gt <| Real.sqrt_pos.mpr <| by linarith [ hx.1 ] ) |> fun h => h.mono_set <| Set.Ioc_subset_Icc_self;
    · filter_upwards [ MeasureTheory.ae_restrict_mem measurableSet_Ioc ] with x hx using hCf x hx.1.le r)
  generalize_proofs at *; (
  refine' le_trans ( add_le_add ( h_integrable 1 ) ( h_integrable ( -1 ) ) ) _ ; norm_num [ div_eq_mul_inv ] ; ring_nf ; (
  rw [ intervalIntegral.integral_comp_add_left fun x => ( Real.sqrt x ) ⁻¹ ] ; norm_num [ Real.sqrt_eq_rpow, integral_rpow ] ; ring_nf ; norm_num [ hT ] ; (
  rw [ intervalIntegral.integral_congr fun x hx => by rw [ ← Real.rpow_neg ( by linarith [ Set.mem_Icc.mp ( by simpa [ hT ] using hx ) ] ) ] ] ; norm_num [ integral_rpow ] ; ring_nf ; norm_num [ hT ] ; nlinarith [ Real.rpow_nonneg ( by linarith : 0 ≤ 1 + T ) ( 1 / 2 : ℝ ) ] ;));))

/-! ## `lem:rebind` — no re-binding -/

/-
**Lemma `lem:rebind`** (no re-binding).  In the crossover scaling `q = 1 − c/T`, the
expected number of merges in `[τ,T]` is `O(c/√T) → 0`.  Schematically: there is `C` with
expected merge count `≤ C c / √T → 0` as `T → ∞`.

*Formalized and proved here* via the paper's identity
`merges = ε · occupation` (taking the `O(√T)` occupation bound `hoccbound` from
`lem:free`/`lem:occ` as the cited input): with merge rate `ε = 1−q² = 1−(1−c/T)²` and the `O(√T)`
occupation `occ` of `{±1}` (from `lem:free`/`lem:occ`), the expected merge count is
`ε·occ = O(c/√T) → 0`.
-/
theorem lem_rebind (c : ℝ) (hc : 0 < c)
    (occ : ℝ → ℝ) (hocc : ∀ T, 0 ≤ occ T)
    (hoccbound : ∃ Cocc : ℝ, 0 < Cocc ∧ ∀ T : ℝ, 0 ≤ T → occ T ≤ Cocc * Real.sqrt (1 + T))
    (mergeCount : ℝ → ℝ)
    (hmerge : ∀ T : ℝ, mergeCount T = (1 - (1 - c / T) ^ 2) * occ T) :
    (∃ C : ℝ, 0 < C ∧ ∀ T : ℝ, 1 ≤ T → mergeCount T ≤ C * c / Real.sqrt T)
    ∧ Tendsto (fun T => mergeCount T) atTop (𝓝 0) := by
  constructor;
  · obtain ⟨ Cocc, hCocc₁, hCocc₂ ⟩ := hoccbound;
    refine' ⟨ 2 * Cocc * Real.sqrt 2, by positivity, fun T hT => _ ⟩;
    refine le_trans ( hmerge T ▸ mul_le_mul_of_nonneg_right ( show 1 - ( 1 - c / T ) ^ 2 ≤ 2 * c / T by
                                                                ring_nf; nlinarith [ inv_mul_cancel₀ ( by linarith : T ≠ 0 ) ] ; ) ( hocc T ) ) ?_;
    refine le_trans ( mul_le_mul_of_nonneg_left ( hCocc₂ T ( by positivity ) ) ( by positivity ) ) ?_;
    field_simp;
    rw [ ← Real.sqrt_mul <| by positivity ] ; exact Real.sqrt_le_iff.mpr ⟨ by positivity, by nlinarith [ sq_nonneg ( T - 1 ), Real.mul_self_sqrt ( show 0 ≤ 2 by norm_num ) ] ⟩;
  · -- We'll use the fact that $occ(T) \leq Cocc \sqrt{1+T}$ to bound $mergeCount(T)$.
    obtain ⟨Cocc, hCocc_pos, hCocc_bound⟩ := hoccbound;
    have h_merge_bound : ∀ T, 1 ≤ T → mergeCount T ≤ (2 * c / T) * Cocc * Real.sqrt (1 + T) := by
      intros T hT
      rw [hmerge]
      have h_bound : (1 - (1 - c / T) ^ 2) * occ T ≤ (2 * c / T) * occ T := by
        exact mul_le_mul_of_nonneg_right ( by ring_nf; nlinarith [ inv_mul_cancel₀ ( by linarith : T ≠ 0 ), inv_pos.2 ( by linarith : 0 < T ) ] ) ( hocc T );
      simpa only [ mul_assoc ] using h_bound.trans ( mul_le_mul_of_nonneg_left ( hCocc_bound T ( by positivity ) ) ( by positivity ) );
    -- We'll use the fact that $2 * c / T * Cocc * \sqrt{1 + T}$ tends to $0$ as $T$ tends to infinity.
    have h_lim : Filter.Tendsto (fun T : ℝ => 2 * c / T * Cocc * Real.sqrt (1 + T)) Filter.atTop (nhds 0) := by
      -- We can simplify the expression inside the limit further by dividing the numerator and the denominator by $T$.
      suffices h_simplify'' : Filter.Tendsto (fun T : ℝ => 2 * c * Cocc * Real.sqrt (1 / T + 1 / T^2)) Filter.atTop (nhds 0) by
        refine h_simplify''.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with T hT using by rw [ show 1 / T + 1 / T ^ 2 = ( 1 + T ) / T ^ 2 by ring_nf; norm_num [ sq, mul_assoc, hT.ne' ] ] ; rw [ Real.sqrt_div' _ ( by positivity ), Real.sqrt_sq hT.le ] ; ring );
      exact le_trans ( Filter.Tendsto.mul tendsto_const_nhds <| Filter.Tendsto.sqrt <| Filter.Tendsto.add ( tendsto_const_nhds.div_atTop Filter.tendsto_id ) <| tendsto_const_nhds.div_atTop <| by norm_num ) <| by norm_num;
    refine' squeeze_zero_norm' _ h_lim;
    filter_upwards [ Filter.eventually_ge_atTop 1, Filter.eventually_gt_atTop ( c : ℝ ) ] with T hT₁ hT₂ using by rw [ Real.norm_of_nonneg ( hmerge T ▸ mul_nonneg ( sub_nonneg.2 ( pow_le_one₀ ( sub_nonneg.2 ( div_le_one_of_le₀ ( by linarith ) ( by linarith ) ) ) ( sub_le_self _ ( by exact div_nonneg hc.le ( by linarith ) ) ) ) ) ( hocc T ) ) ] ; exact h_merge_bound T hT₁;

/-! ## `lem:asep` — same-species channel kernel bound -/

/-- The same-species two-particle dual kernel `p_t(ξ,ξ')` (a two-particle ASEP), as a
function of the asymmetry parameter `q`.  Its construction is Schütz's Bethe-ansatz
Green's function for the two-particle ASEP, which requires the Bethe-ansatz/duality
framework absent from Mathlib; it is therefore declared as an opaque object attached to
`q` rather than synthesised.  (Stating `lem:asep` for a *free* nonnegative `p2` would be a
false universal — an arbitrary nonnegative function need not decay like `C/(1+t)` — so the
kernel is pinned to this opaque model object instead.) -/
opaque asepKernel (q : ℝ) : ℝ → (ℤ × ℤ) → (ℤ × ℤ) → ℝ

/-- Integrand of Schütz's explicit two-particle ASEP Green's-function contour integral,
as a function of the contour parameter (the final `ℝ` argument).  Schütz's exact solution
represents the two-particle Green's function `asepKernel q t ξ ξ'` as a contour integral;
the integrand carries the Bethe-ansatz/duality structure absent from Mathlib and is
therefore declared opaque.  The kernel is recovered from it by `hGreen` below. -/
opaque asepGreenIntegrand (q : ℝ) : ℝ → (ℤ × ℤ) → (ℤ × ℤ) → ℝ → ℝ

/-- **Decay estimate for the explicit Green's-function integral** (steepest descent /
stationary phase).  This is the single irreducible asymptotic-analysis step in the
derivation of `lem:asep` *from* the cited integral formula `hGreen`: the contour integral
of Schütz's Green's-function integrand `asepGreenIntegrand q` over the parameter interval
`[0, 2π]` decays like `C/(1+t)`.

This is a derivation step from the cited formula, **not** an independent citation: it is the
long-time decay of the *explicit* oscillatory integral supplied by Schütz's exact solution,
obtained by steepest-descent / stationary-phase analysis of that integral.  The full
asymptotic analysis is beyond the present formalisation, so it is recorded by an honest
`sorry`. -/
theorem asepGreen_integral_decay
    (q : ℝ) (hq : q ∈ Set.Ioo (0 : ℝ) 1) :
    ∃ C : ℝ, 0 < C ∧ ∀ t : ℝ, 0 ≤ t → ∀ ξ ξ' : ℤ × ℤ,
      ∫ z in Set.Icc (0 : ℝ) (2 * π), asepGreenIntegrand q t ξ ξ' z ≤ C / (1 + t) := by
  sorry

/-- **Lemma `lem:asep`** (same-species channel; \cite{Schutz, TW08}).  The same-species
two-particle dual kernel (the two-particle ASEP `asepKernel q`) obeys
`p_t(ξ,ξ') ≤ C/(1+t)`.

*Paper derivation (partially formalized).*  Contrary to the earlier label, the decay bound
`p_t(ξ,ξ') ≤ C/(1+t)` is **not** stated in \cite{TW08}; it is *derived* in the paper from
the explicit two-particle ASEP Green's-function integral formula.  Accordingly the genuine
cited input enters here as the explicit hypothesis `hGreen`: Schütz's / Tracy–Widom's
exact two-particle Green's function, written as the contour integral of
`asepGreenIntegrand q` over `[0, 2π]`.  The duality underlying the dual kernel is Schütz's
\cite{Schutz} ("Duality relations for asymmetric exclusion processes", J. Stat. Phys. 86,
1997); the explicit two-particle Bethe-ansatz Green's function is from Schütz's companion
paper, "Exact solution of the master equation for the asymmetric exclusion process"
(J. Stat. Phys. 88, 1997; cond-mat/9701019), and the two-particle integral formula is also
given in \cite{TW08}.

From `hGreen` the `C/(1+t)` bound is here *derived*: rewriting the kernel by its integral
representation reduces the claim to the long-time decay of that explicit oscillatory
integral.  That decay — the only step requiring genuine asymptotic analysis — is supplied
by the named sub-lemma `asepGreen_integral_decay` (steepest descent / stationary phase),
which is the sole residual honest `sorry`.  The hypothesis `q ∈ (0,1)` is inhabited
(e.g. `q = 1/2`). -/
theorem lem_asep
    (q : ℝ) (hq : q ∈ Set.Ioo (0 : ℝ) 1)
    (hGreen : ∀ t : ℝ, 0 ≤ t → ∀ ξ ξ' : ℤ × ℤ,
      asepKernel q t ξ ξ' = ∫ z in Set.Icc (0 : ℝ) (2 * π), asepGreenIntegrand q t ξ ξ' z) :
    ∃ C : ℝ, 0 < C ∧ ∀ t : ℝ, 0 ≤ t → ∀ ξ ξ' : ℤ × ℤ,
      asepKernel q t ξ ξ' ≤ C / (1 + t) := by
  -- The cited integral formula `hGreen` reduces the bound on the kernel to the long-time
  -- decay of the explicit Green's-function integral, which is `asepGreen_integral_decay`.
  obtain ⟨C, hC, hbound⟩ := asepGreen_integral_decay q hq
  refine ⟨C, hC, fun t ht ξ ξ' => ?_⟩
  rw [hGreen t ht ξ ξ']
  exact hbound t ht ξ ξ'

/-! ## `thm:kernel` — type D two-particle dual kernel bound -/

/-
**Theorem `thm:kernel`** (type D two-particle kernel bound).  For the
different-species dual started from a bound pair, in the window `ν_sp t ≤ K`,
`p_t(ξ,ξ') ≤ C/(1+t) + e^{−ν_sp t} · C/√(1+t)`, with `ν_sp = 2q²ε`.

*Assembled here from the cited local-CLT lemmas.* The different-species kernel is rendered
schematically as `p2 : ℝ → (ℤ × ℤ) → (ℤ × ℤ) → ℝ`, and the assembly is made explicit by
factoring it (hypothesis `hfact`) through a sum-coordinate factor `Smarg` and a
relative-coordinate factor `Rmarg`.  The two cited inputs enter as the marginal bounds:
`hS` is the sum-coordinate local CLT (`lem:Slclt`/`lem:KR`), `Smarg t ≤ C_S/√(1+t)`, and
`hR` is the defected relative-coordinate local CLT (`lem:Rlclt`),
`Rmarg t ≤ C_R/√(1+t) + e^{−ν_sp t}`.  Multiplying the two and using
`√(1+t)·√(1+t) = 1+t` produces the claimed `C/(1+t) + e^{−ν_sp t}·C/√(1+t)` bound.
-/
theorem thm_kernel
    (q : ℝ)
    (p2 : ℝ → (ℤ × ℤ) → (ℤ × ℤ) → ℝ) (K : ℝ)
    (Smarg Rmarg : ℝ → (ℤ × ℤ) → (ℤ × ℤ) → ℝ)
    (hSnn : ∀ t ξ ξ', 0 ≤ Smarg t ξ ξ')
    (hfact : ∀ t ξ ξ', p2 t ξ ξ' ≤ Smarg t ξ ξ' * Rmarg t ξ ξ')
    (hS : ∃ CS : ℝ, 0 < CS ∧ ∀ t : ℝ, 0 ≤ t → ∀ ξ ξ' : ℤ × ℤ,
        Smarg t ξ ξ' ≤ CS / Real.sqrt (1 + t))
    (hR : ∃ CR : ℝ, 0 < CR ∧ ∀ t : ℝ, 0 ≤ t → 2 * q ^ 2 * (1 - q ^ 2) * t ≤ K →
        ∀ ξ ξ' : ℤ × ℤ,
        Rmarg t ξ ξ' ≤ CR / Real.sqrt (1 + t)
          + Real.exp (-(2 * q ^ 2 * (1 - q ^ 2) * t))) :
    ∃ C : ℝ, 0 < C ∧ ∀ t : ℝ, 0 ≤ t → 2 * q ^ 2 * (1 - q ^ 2) * t ≤ K →
      ∀ ξ ξ' : ℤ × ℤ,
      p2 t ξ ξ' ≤ C / (1 + t)
        + Real.exp (-(2 * q ^ 2 * (1 - q ^ 2) * t)) * (C / Real.sqrt (1 + t)) := by
  obtain ⟨ CS, hCS_pos, hCS ⟩ := hS; obtain ⟨ CR, hCR_pos, hCR ⟩ := hR; use CS * CR + CS; refine' ⟨ by positivity, fun t ht ht' ξ ξ' ↦ le_trans ( hfact t ξ ξ' ) _ ⟩ ; refine' le_trans ( mul_le_mul_of_nonneg_left ( hCR t ht ht' ξ ξ' ) ( hSnn t ξ ξ' ) ) _ ; ring_nf;
  refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( hCS t ht ξ ξ' ) hCR_pos.le ) ( by positivity ) ) ( mul_le_mul_of_nonneg_right ( hCS t ht ξ ξ' ) ( by positivity ) ) ) _;
  field_simp;
  nlinarith [ show 0 ≤ CR * Real.sqrt ( 1 + t ) * Real.exp ( t * q ^ 2 * 2 * ( -1 + q ^ 2 ) ) by positivity, show 0 ≤ CR * Real.sqrt ( 1 + t ) by positivity, show 0 ≤ Real.sqrt ( 1 + t ) * Real.exp ( t * q ^ 2 * 2 * ( -1 + q ^ 2 ) ) by positivity, Real.sqrt_nonneg ( 1 + t ), Real.mul_self_sqrt ( show 0 ≤ 1 + t by positivity ) ]

/-! ## `prop:occ` — contact occupations of the relative walk (Tracy–Widom regime) -/

/-- The relative walk `𝔯` of the Tracy–Widom regime, reversible with respect to the
measure `m(0)=q^{-2}`, `m(r)=1` (`r≠0`), agreeing off a finite set with the symmetric
nearest-neighbour walk of rate `1+q²` per direction. -/
structure RelativeWalkTW (q : ℝ) where
  rate : ℤ → ℤ → ℝ
  p : ℝ → ℤ → ℝ
  F : Finset ℤ
  isKernel : IsTransitionKernel rate p
  m0 : ∀ x : ℤ, x ∉ F → ∀ y, rate x y =
       (if y = x + 1 ∨ y = x - 1 then 1 + q ^ 2 else 0)
  reversible : (q ^ (-2 : ℤ)) * rate 0 1 = rate 1 0
            ∧ (q ^ (-2 : ℤ)) * rate 0 (-1) = rate (-1) 0
  recurrent : ∀ r : ℤ, ¬ Summable (fun (n : ℕ) => p (n : ℝ) r)

/-
**Proposition `prop:occ`** (contact occupations of the relative walk).  With the
stickiness measure `m(0)=q^{-2}`, `m(±1)=1`, the occupation-time ratio satisfies
`τ₀(s)/τ_{±1}(s) → q^{-2}` and the contact combination satisfies
`(1+q⁴)τ₀ − q²(τ_{+1}+τ_{−1}) ∼ (1−q⁴)/q² · √(s/(π(1+q²)))`.

*Derived here as an application of `lem:tau`.* The three cited inputs `htau0`, `htau1`,
`htaum1` are exactly the conclusions of `lem:tau` for `r = 0, 1, −1`, instantiated with the
stickiness measure `m(0) = q^{-2}`, `m(±1) = 1` and rate `a = 1+q²`.  The ratio limit
follows by dividing the two equivalences (`IsEquivalent.div`), and the contact-combination
asymptotics follows because the leading coefficient `(1+q⁴)q^{-2} − 2q² = (1−q⁴)/q²` does
not vanish, so the lower-order remainders combine into a genuine `o(√s)`.
-/
theorem prop_occ (q : ℝ) (hq : q ∈ Set.Ioo (0 : ℝ) 1) (W : RelativeWalkTW q)
    (htau0 : IsEquivalent atTop (fun s => occupation W.p 0 s)
        (fun s => q ^ (-2 : ℤ) * Real.sqrt (s / (Real.pi * (1 + q ^ 2)))))
    (htau1 : IsEquivalent atTop (fun s => occupation W.p 1 s)
        (fun s => Real.sqrt (s / (Real.pi * (1 + q ^ 2)))))
    (htaum1 : IsEquivalent atTop (fun s => occupation W.p (-1) s)
        (fun s => Real.sqrt (s / (Real.pi * (1 + q ^ 2))))) :
    Tendsto (fun s => occupation W.p 0 s / occupation W.p 1 s) atTop (𝓝 (q ^ (-2 : ℤ)))
    ∧ IsEquivalent atTop
        (fun s => (1 + q ^ 4) * occupation W.p 0 s
                    - q ^ 2 * (occupation W.p 1 s + occupation W.p (-1) s))
        (fun s => (1 - q ^ 4) / q ^ 2 * Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) := by
  constructor;
  · have h_div : (fun s => occupation W.p 0 s / occupation W.p 1 s) ~[atTop] (fun s => q ^ (-2 : ℤ) * Real.sqrt (s / (Real.pi * (1 + q ^ 2))) / Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) := by
      apply_rules [ Asymptotics.IsEquivalent.div ];
    have h_simplify : (fun s => q ^ (-2 : ℤ) * Real.sqrt (s / (Real.pi * (1 + q ^ 2))) / Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) =ᶠ[atTop] (fun _ => q ^ (-2 : ℤ)) := by
      filter_upwards [ Filter.eventually_gt_atTop 0 ] with s hs using mul_div_cancel_right₀ _ <| ne_of_gt <| Real.sqrt_pos.mpr <| by positivity;
    exact h_div.congr_right h_simplify |> fun h => h.tendsto_const;
  · -- Now use the fact that the difference of equivalent functions is little-o of the equivalent function.
    have h_diff : (fun s => (1 + q ^ 4) * occupation W.p 0 s - q ^ 2 * (occupation W.p 1 s + occupation W.p (-1) s) - ((1 - q ^ 4) / q ^ 2) * Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) =o[atTop] (fun s => Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) := by
      have h_diff : (fun s => occupation W.p 0 s - q ^ (-2 : ℤ) * Real.sqrt (s / (Real.pi * (1 + q ^ 2))) ) =o[atTop] (fun s => Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) ∧ (fun s => occupation W.p 1 s - Real.sqrt (s / (Real.pi * (1 + q ^ 2))) ) =o[atTop] (fun s => Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) ∧ (fun s => occupation W.p (-1) s - Real.sqrt (s / (Real.pi * (1 + q ^ 2))) ) =o[atTop] (fun s => Real.sqrt (s / (Real.pi * (1 + q ^ 2)))) := by
        simp_all +decide [ Asymptotics.IsEquivalent ];
        exact ⟨ by simpa using htau0.trans_isBigO ( Asymptotics.isBigO_const_mul_self _ _ _ ), htau1, htaum1 ⟩;
      convert h_diff.1.const_mul_left ( 1 + q ^ 4 ) |> Asymptotics.IsLittleO.sub <| h_diff.2.1.const_mul_left ( q ^ 2 ) |> Asymptotics.IsLittleO.add <| h_diff.2.2.const_mul_left ( q ^ 2 ) using 2 ; ring;
      norm_cast ; norm_num [ hq.1.ne', hq.2.ne', pow_succ, mul_assoc, mul_comm, mul_left_comm ] ; ring;
      grind;
    refine' h_diff.trans_isBigO _;
    norm_num [ Asymptotics.isBigO_iff ];
    refine' ⟨ 1 / ( |1 - q ^ 4| / q ^ 2 ), 1, fun s hs => _ ⟩ ; rw [ abs_of_nonneg ( Real.sqrt_nonneg _ ) ] ; ring_nf;
    norm_num [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( show 0 < 1 - q ^ 4 by nlinarith [ hq.1, hq.2, pow_pos hq.1 2, pow_pos hq.1 3 ] ), ne_of_gt hq.1 ]

end TypeDDecoupling