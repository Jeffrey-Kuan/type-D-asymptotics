# Proposed edit: remove the second-order Boltzmann–Gibbs *assumption* from the EW limit

**Target file:** `typeD_decoupling-draft.tex`.

**Status:** ✅ **APPLIED 2026-06-06.** All seven edits below are in, plus the two
mechanical fixes (numerics reference redirected to `prop:drift`; orphaned
`\cite{ACR,GJS}`/`\ref{ass:bg}` and `eq:W1`/`eq:Wdecomp` checked — none remain). The
document compiles cleanly (every `\ref`/`\cite` resolves; only the five missing figure
PNGs block a real PDF, pre-existing and unrelated).

**Deviation from the proposal — off-symmetric-line constants.** This document (Edit 2)
carried forward the assumption that off the line the overlap is $\propto(\rho_1-\rho_2)
\neq0$. That is **wrong**, for the same reason `eq:W1` was wrong: with the corrected
single-species current, $\langle W_{i,x},B_z\rangle = \mathbb E_\nu[W_{i,x}(\eta_{1,z}-
\rho_1)]\cdot\mathbb E_\nu[\eta_{2,z}-\rho_2] = 0$ for **all** $(\rho_1,\rho_2)$. So the
as-applied `prop:sym` corollary is stated density-free via a new `rem:offline`, and open
problem (i) in the Discussion was reframed: the slow-mode obstruction is *absent* off
the line (only the off-line (N)/(X) noise estimates remain to be written), rather than
"decoupling fails." Confirmed settled by the author.

**Also applied separately (not part of this proposal):** the `prop:decouple` proof
enumeration was made exhaustive over all four species-2 occupancies in each direction
(it previously omitted the `(1,2)`/`(3,0)`/`(2,1)` cases). The conclusion was unchanged.

---

## Rationale

The EW limit theorem (`thm:ewmain`) currently rests on one standing hypothesis,
`ass:bg` — the second-order Boltzmann–Gibbs estimate for the "order-≥2 current
remainder." It is the only non-proved input in regime (A), and its quantitative form
(the `N^{-1}(\sqrt T+1/\sqrt c)` bound asserted in `rem:bgstatus`) comes from a
power-counting in the source notes that does **not** hold up — re-deriving the generic
two-species order-2 estimate gives a divergent `N·t^{3/2}`.

The fix is **not** to repair that estimate but to observe it is unnecessary. By
`prop:decouple`, the species-`i` current is *exactly* a single-species WASEP current in
`η_i` alone. Therefore:

1. The drift is a functional of the **autonomous single-species WASEP** `η_1`; the
   bound pair never enters it.
2. The single-species current is a **gradient plus an `O(γ)` term**,
   `W_{1,x} = -∇η_{1,x} + γ η_{1,x+1}(1-η_{1,x})`, `γ=1-q²`. The gradient gives the
   Laplacian by summation by parts (the easy gradient case, no BG); the `O(γ)` term
   vanishes by an elementary `L²` bound, since `γ² ~ N^{-4}` crushes it.
3. Consequently **no second-order Boltzmann–Gibbs estimate is required**, and
   `prop:sym` (current ⟂ bound-pair mode) becomes a one-line corollary of
   `prop:decouple` (a function of `η_1` is `ν`-orthogonal to the `η_2`-factor in `B_z`).

The two-particle type-D duality is still genuinely used — but only for the **cross
noise** (X), which is already proved in `prop:conc` from the kernel bound `thm:kernel`,
at the normalization (`β=-1`) where the `d=1` two-particle bound is comfortably
convergent (`→0` like `N^{-2}`).

Net effect: `thm:ewmain` becomes complete modulo only the *classical* single-species
WASEP fluctuation result and the classical tightness/uniqueness — no model-specific
assumption.

---

## Edit 1 — §6 "The drift": replace the non-gradient framing

**Location:** the `\subsection{The drift}` block, from `eq:W1` through `eq:Wdecomp`
and the bullet list (gradient / density / order-≥2 remainder).

**Action:** delete the non-gradient decomposition `eq:Wdecomp` and its bullet list, and
the "non-gradient" prose. Replace with the exact single-species expansion.

**New text (insert in place):**

```latex
By Proposition~\ref{prop:decouple} the species--$1$ current $W_{1,x}$ is a function of
$\eta_1$ alone --- the single--species ASEP current --- which expands exactly, with
$\gamma=1-q^2$ and $\nabla f_x=f_{x+1}-f_x$, as
\begin{equation}\label{eq:Wgrad}
  W_{1,x}=-\nabla\eta_{1,x}+\gamma\,\eta_{1,x+1}(1-\eta_{1,x}).
\end{equation}
The first term is a discrete gradient; the second carries the prefactor
$\gamma=O(N^{-2})$. Thus the drift involves only the autonomous single--species WASEP
$\eta_1$, and no two--species (bound--pair) structure enters it.
```

---

## Edit 2 — §6: replace `prop:sym` with a corollary

**Location:** `\begin{proposition}[current orthogonal to the bound--pair mode]\label{prop:sym}` … `\end{proposition}` (and its proof).

**Action:** keep the label `prop:sym` (it is referenced in `rem:icmeaning` and the
Discussion under the off-symmetric-line problem) but demote it to a corollary with the
trivial proof. Keep the explicit single-bond identities as a remark if desired (they
are still the off-symmetric-line content).

**New text:**

```latex
\begin{corollary}[current orthogonal to the bound--pair mode]\label{prop:sym}
On the species--symmetric line $\rho_1=\rho_2$, $\ip{W_{i,x}}{B_z}=0$ for all $z$, where
$B_z=(\eta_{1,z}-\rho)(\eta_{2,z}-\rho)$.
\end{corollary}
\begin{proof}
By Proposition~\ref{prop:decouple}, $W_{1,x}$ is a function of $\eta_1$ alone. Since
$\nu$ is a product measure with the two species independent and $\E_\nu[\eta_{2,z}-\rho]=0$,
\[
  \ip{W_{1,x}}{B_z}=\E_\nu\big[W_{1,x}\,(\eta_{1,z}-\rho)\big]\,\E_\nu[\eta_{2,z}-\rho]=0,
\]
and symmetrically for $W_{2,x}$. (Off the symmetric line the overlap is
$\propto(\rho_1-\rho_2)\ne0$; see the Discussion.)
\end{proof}
```

**Note:** keep `eq:Bdef` (defines `B_z`) — still referenced here and in the off-line
discussion.

---

## Edit 3 — §6: delete `rem:slow`, `ass:bg`, `rem:bgstatus`; add `prop:drift`

**Location:** the `\begin{remark}\label{rem:slow}` (slow-mode danger), the
`\begin{assumption}…\label{ass:bg}`, and the `\begin{remark}\label{rem:bgstatus}`.

**Action:** delete all three. The slow-mode "danger" is moot once the current is
single-species. Insert the following proved Proposition in their place.

**New text:**

```latex
\begin{proposition}[drift]\label{prop:drift}
On the species--symmetric line, $\Gamma_i^N(\varphi,\cdot)\to D\,Y_i(\Delta\varphi,\cdot)$
in $L^2$, with $D$ the diffusivity of the symmetric part of the single--species
dynamics; no second--order Boltzmann--Gibbs estimate is required. This establishes
\textup{(D)}.
\end{proposition}
\begin{proof}
By \eqref{eq:Wgrad}, $\Gamma_1^N=\Gamma_1^{N,\mathrm{grad}}+\gamma\,\Gamma_1^{N,\mathrm{cor}}$
with
\[
  \Gamma_1^{N,\mathrm{grad}}=N^{1/2}\sum_x\varphi'(\tfrac xN)(-\nabla\eta_{1,x}),\qquad
  \Gamma_1^{N,\mathrm{cor}}=N^{1/2}\sum_x\varphi'(\tfrac xN)\,g_x,\quad g_x:=\eta_{1,x+1}(1-\eta_{1,x}).
\]
\emph{Gradient term.} A summation by parts gives
$\Gamma_1^{N,\mathrm{grad}}=N^{1/2}\sum_x(\nabla\varphi')(\tfrac xN)\,\eta_{1,x}
 =N^{-1/2}\sum_x\varphi''(\tfrac xN)(\eta_{1,x}-\rho)+o(1)=D\,Y_1^N(\Delta\varphi)+o(1)$
in $L^2$, $D$ the symmetric--part diffusivity; this is the standard gradient
computation \cite[Ch.~11]{KL}.
\emph{Correction term.} Write $g_x=\bar g+(g_x-\bar g)$, $\bar g=\rho(1-\rho)$. The mean
part $\gamma N^{1/2}\bar g\sum_x\varphi'(\tfrac xN)$ is the Euler flux
$\partial_x[\gamma\rho(1-\rho)]$, of order $O(\gamma)\to0$ in the EW window. For the
fluctuating part, by stationarity its time--integral has second moment
\[
  \E\Big[\Big(\gamma\!\int_0^t\!N^{1/2}\!\sum_x\varphi'(g_x{-}\bar g)(\eta(sN^2))\dd s\Big)^2\Big]
  =\gamma^2 N\!\int_0^t\!\!\int_0^t\!\sum_{x,y}\varphi'\varphi'\,
   \E_\nu[(g_x{-}\bar g)(\eta_0)(g_y{-}\bar g)(\eta_{|s-s'|N^2})]\dd s\dd s'.
\]
The static cross--correlation of $g$ is summable, $\sum_y|\E_\nu[(g_x-\bar g)(g_y-\bar g)(\tau)]|\le C$
uniformly in $\tau$ (its conserved/density component sums to the compressibility, the
rest decays), so the double sum is $\le C N$ for every lag, and the bound is
$\le\gamma^2 N\cdot CN\,t^2=Cc^2N^{-2}t^2\to0$. Hence $\Gamma_1^N\to D\,Y_1(\Delta\varphi)$
in $L^2$, with no Boltzmann--Gibbs input; the species--$2$ drift is identical.
\end{proof}
```

---

## Edit 4 — `thm:ewmain` statement: drop the assumption

**Location:** `\begin{theorem}[decoupled Edwards--Wilkinson limit]\label{thm:ewmain}`.

**Action:** change the hypothesis line.

- **Old:** `Under $q=q_N=1-c/N^2$ and Assumption~\ref{ass:bg}, the pair …`
- **New:** `Under $q=q_N=1-c/N^2$, the pair …`

---

## Edit 5 — abstract: remove the "hypothesis" framing

**Location:** the EW paragraph of the abstract.

- **Old:** "… (Theorem~\ref{thm:ewmain}). This is subject to one second--order
  Boltzmann--Gibbs estimate stated as a hypothesis; every model--specific input to that
  hypothesis --- a two--particle dual kernel bound (Theorem~\ref{thm:kernel}) and the
  orthogonality of the slow mode to the species current (Proposition~\ref{prop:sym}) ---
  is proved here in full, including the two underlying one--dimensional local central
  limit theorems (\S\ref{sec:lclt})."
- **New:** "… (Theorem~\ref{thm:ewmain}). The proof is self--contained modulo the
  classical single--species fluctuation result: the drift reduces, via the exact
  current decoupling (Proposition~\ref{prop:decouple}), to a single--species WASEP and
  needs no Boltzmann--Gibbs input, while the cross--noise cancellation is controlled by
  a two--particle dual kernel bound (Theorem~\ref{thm:kernel}) proved here in full,
  including the two underlying one--dimensional local central limit theorems
  (\S\ref{sec:lclt})."

---

## Edit 6 — Discussion / Status paragraph

**Location:** the `\paragraph{Status.}` line about regime (A).

- **Old:** "Theorem~\ref{thm:ewmain} is complete modulo Assumption~\ref{ass:bg} (the
  published second--order Boltzmann--Gibbs theorem applied with the inputs proved here)
  and the classical tightness/uniqueness \cite{KL}."
- **New:** "Theorem~\ref{thm:ewmain} is complete modulo the classical single--species
  WASEP fluctuation result (used for the drift via Proposition~\ref{prop:decouple} and
  the diagonal noise) and the classical tightness/uniqueness \cite{KL}; it carries no
  model--specific assumption."

Also update the Status list of regime-(A) proved items: add `prop:drift`, and replace
`prop:sym` (now a corollary, still cite it).

---

## Edit 7 — citations / cross-references to check after applying

- `\cite{ACR,GJS}` were invoked mainly for the second-order BG. After the edit they are
  no longer load-bearing in §6; keep `GJ`/`GJS`/`ACR` in the Introduction's literature
  paragraph (still the right context), but verify no orphaned `\cite` remains in §6.
  `ACR`/`ACR2` are still cited (duality covariance `lem:acr`, single-species EW in
  `lem:gauss`), so the bibitems stay.
- Confirm `ass:bg` is no longer `\ref`-ed anywhere (it was referenced in `thm:ewmain`,
  the abstract, `rem:bgstatus`, and the Status paragraph — all handled above).
- `rem:slow` is referenced in the §10 numerics ("excluding the `T^{1/2}` … of
  Remark~\ref{rem:slow}"). If `rem:slow` is deleted, redirect that reference to
  `prop:drift` or to the off-symmetric-line corollary remark.

---

## Caveats (honest scope)

- The new `prop:drift` cites the **classical single-species WASEP** drift→Laplacian
  (`\cite[Ch.~11]{KL}`); this is standard for a gradient (SSEP) system plus an `O(γ)`
  perturbation and is *not* the disputed type-D estimate.
- The `O(γ)` correction bound is deliberately crude (uses only `γ²~N^{-4}` smallness and
  the summability of `g`'s static correlations); it does not need any kernel decay.
- The diffusivity constant `D` is the standard symmetric-part value; the proof does not
  pin it (the paper already writes `D=D(ρ)`).
- This removes the assumption from regime (A) only. Regime (B) is unchanged (it already
  carries no Boltzmann–Gibbs assumption; its results are the marginals and the
  uncorrelatedness).
