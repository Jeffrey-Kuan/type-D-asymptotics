import Mathlib

/-!
# Tier 4 black-box statements: the Tracy–Widom regime (§tw)

Statements of the §tw asymptotic results of `typeD_decoupling-draft-rev2.tex`:
`thm:marg` (Tracy–Widom GUE marginals of each species' current) and `conj:cov` (the open
linear-covariance conjecture).

Both are **cited / assumed (black-box) statements**, left as `sorry`.  The GUE
Tracy–Widom law `F₂` is not in Mathlib; it is taken as an abstract cumulative
distribution function `F2` (a monotone right-continuous function with limits `0` and `1`),
and convergence in distribution is rendered by pointwise convergence of cumulative
distribution functions.  `conj:cov` is an **open conjecture** in the paper, recorded here
as a formal statement left unproven.
-/

open scoped BigOperators Real Topology
open Filter

namespace TypeDDecoupling

/-- `F` is a cumulative distribution function: monotone, with limits `0` at `−∞` and `1`
at `+∞`. -/
def IsCDF (F : ℝ → ℝ) : Prop :=
  Monotone F ∧ Tendsto F atBot (𝓝 0) ∧ Tendsto F atTop (𝓝 1)

/-! ## `thm:marg` — Tracy–Widom marginals -/

/-
**Theorem `thm:marg`** (Tracy–Widom marginals).  For every `n ∈ ℕ ∪ {∞}` and each
species, the standardised current `O^i_s = (N_i − E N_i)/σ_i` (with `σ_i ≍ s^{1/3}`)
converges in distribution to `F₂`, the GUE Tracy–Widom law, as `s → ∞`.

*Status.*  `thm_marg` is `sorry`-free, but it carries no standalone content: its proof is
the one-line reduction `simpa only [hreduce] using hBCS` (the trivial implication
`A = B, B → C ⊢ A → C`).  Both of its inputs are *assumed*, not proved here — `hreduce`
(the `prop:decouple`(a) species→single-species reduction) and `hBCS` (the cited
Tracy–Widom result \cite{TW2009} (Tracy–Widom, Comm. Math. Phys. 290, 2009), reproved
via duality in \cite{BCS}).  The genuine mathematics lives entirely in those
two hypotheses, not in this theorem.
`F2` is the GUE Tracy–Widom cumulative distribution function (taken abstractly), and
`Ocdf s x = ℙ(O^i_s ≤ x)` is the cumulative distribution function of the standardised
current at scale `s`.  Convergence in distribution is stated as pointwise convergence of
`Ocdf s` to `F2` (legitimate at every point since `F₂` is continuous).  Phrased as the
paper's reduction and the cited input: by `prop:decouple`(a) each species' current is an
autonomous single-species step-ASEP current (`hreduce`: `Ocdf = aspCdf`), and step-ASEP
currents converge to `F₂` by \cite{TW2009} (reproved via duality in \cite{BCS}) (`hBCS`, the cited black box); hence the
type D species current converges to `F₂`.
-/
theorem thm_marg
    (F2 : ℝ → ℝ)
    (Ocdf aspCdf : ℝ → ℝ → ℝ)
    (hreduce : ∀ s x, Ocdf s x = aspCdf s x)
    (hBCS : ∀ x : ℝ, Tendsto (fun s => aspCdf s x) atTop (𝓝 (F2 x))) :
    ∀ x : ℝ, Tendsto (fun s => Ocdf s x) atTop (𝓝 (F2 x)) := by
  simpa only [ hreduce ] using hBCS

/-! ## `conj:cov` — linear covariance (open conjecture) -/

/-- **Conjecture `conj:cov`** (linear covariance).  At every `n`, from the step initial
condition, `Cov(N₁,N₂)(s) ∼ c(q) √s` as `s → ∞` with `c(q) ∈ (0,∞)`; consequently
`Corr(N₁,N₂) ≍ s^{−1/6} → 0` and the two Tracy–Widom currents are asymptotically
uncorrelated.

*This is an open conjecture in the paper*, recorded here as a formal statement left as
`sorry` (it is **not** a proof target).  `cov s = Cov(N₁,N₂)(s)` and
`corr s = Corr(N₁,N₂)(s)` are the (model-defined) covariance and correlation. -/
theorem conj_cov (q : ℝ) (hq : q ∈ Set.Ioo (0 : ℝ) 1)
    (cov corr : ℝ → ℝ) (hcorr_nonneg : ∀ s, 0 ≤ corr s) :
    (∃ cq : ℝ, 0 < cq ∧
        Asymptotics.IsEquivalent atTop cov (fun s => cq * Real.sqrt s))
    ∧ (∃ c₁ c₂ : ℝ, 0 < c₁ ∧ 0 < c₂ ∧
        ∀ᶠ s in atTop, c₁ * s ^ (-(1:ℝ)/6) ≤ corr s ∧ corr s ≤ c₂ * s ^ (-(1:ℝ)/6)) := by
  sorry

end TypeDDecoupling