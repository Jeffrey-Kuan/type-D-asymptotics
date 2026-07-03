# Fable5 — Session Notes

_Working dir: `~/Documents/Fable5` • Recorded: 2026-06-22_

This document is a faithful record of the work done in this session. It has two
parts: (1) the LaTeX→DOCX conversion workflow for the paper, and (2) the
iterative correctness review of the Aristotle Lean formalization of
`typeD_decoupling-draft-rev2.tex`.

---

## Part 1 — LaTeX → DOCX with Pandoc

Goal: convert `Fable5.tex` to DOCX with accessible structure and clickable
internal citations.

### Pipeline established

Files produced (originals left intact; `Fable5.tex` still compiles):

- `refs.bib` — the 15 bibliography entries as a BibTeX database (keys match the
  `\cite` keys in the body).
- `Fable5.citeproc.tex` — auto-generated copy of the paper with the manual
  `\begin{thebibliography}…\end{thebibliography}` stripped and a
  `\subsection{Bibliography}` heading injected at the strip point.
- `ieee.csl` — numeric citation style (from the official CSL repo).
- `refs-as-list.lua` — Pandoc Lua filter turning the citeproc `#refs` div into a
  real ordered list (so it tags as `<L>`/`<LI>` in a tagged PDF, not loose `<P>`s).

### Reproducible command

```bash
awk '/\\begin\{thebibliography\}/{print "\\subsection{Bibliography}"; print "\\end{document}"; exit} {print}' \
  Fable5.tex > Fable5.citeproc.tex

pandoc Fable5.citeproc.tex --citeproc --bibliography=refs.bib --csl=ieee.csl \
  -M link-citations=true --lua-filter=refs-as-list.lua -o Fable5.docx
```

### Key findings / decisions

- **Internal citation links** only work via `--citeproc` + `link-citations=true`.
  A manual `\thebibliography` makes pandoc drop `\cite` entirely (no links). With
  citeproc, each citation becomes a real Word hyperlink (`w:anchor="ref-*"`) to a
  bookmark on the matching reference (`w:name="ref-*"`). Verified 15 anchors ↔ 15
  bookmarks on every rebuild.
- **External URL links** (separate issue): pandoc's `autolink_bare_uris` is *not*
  supported for the LaTeX reader; bare URLs need `\url{}`/`\href{}` + `hyperref`.
- **Headings**: sections were changed to `\subsection` so they map to Heading 2.
  On Word "Save as tagged PDF", the `\title` → "Title" style is promoted to `<H1>`,
  giving a clean H1(title) → H2(sections) outline.
- **Bibliography as a list** improves accessibility tags; note the IEEE numeric
  labels render as `1.` (list `<Lbl>`) rather than `[1]`, still 1:1 with the
  in-text `[n]`.
- Typo fixes applied to `Fable5.tex` during the session (e.g. abstract
  "without" → "within"); DOCX regenerated each time.

---

## Part 2 — Aristotle Lean formalization review

Subject: the Lean 4 / Mathlib formalization of the type-D ASEP decoupling paper,
produced by Harmonic's **Aristotle** CLI (project `c4a248ca-…`, "Fable5").

### Method

For each iteration: download the project, **read the actual Lean source**, run a
local `lake build` (Mathlib v4.28.0, cached), and check `#print axioms` on the
key theorems. Toolchain installed under `~/.elan`; Mathlib cache under `/tmp`.

Ground truth = the Lean kernel. A green build alone is **not** sufficient: a file
full of `sorry` still "builds." The real checks are whether statements are
faithful and whether `#print axioms` shows only the standard axioms
(`propext, Classical.choice, Quot.sound`) vs. `sorryAx`.

### The three-point check (rubric applied to every `sorry`)

1. **True as written** — not a false universal over an unconstrained variable.
2. **Hypothesis inhabited** — some concrete object satisfies it (not vacuously true).
3. **Genuine citation vs. skipped derivation** — a result the paper *cites*, or a
   step the paper *derives* (which should be proved from cited inputs, not asserted).

### Issues found and fixed (each caught by reading code / axioms, not by build failures)

| # | Issue | Where | Resolution | Verified |
|---|-------|-------|------------|----------|
| 1 | `thm:cross` was a bare `sorry`; assembly not carried out | Crossover | Real assembly using proved closed-form lemmas | builds; rests on cited CLT |
| 2 | **False universal** — limit claimed for *any* `X` | Crossover (`prop_twophase`) | `X` pinned to concrete dual-pair model predicates | counterexample excluded |
| 3 | **Factor-of-2** — `⌊T⌋` steps ÷ `√(2T)` ⇒ variance ½, not 1 | Crossover (`dualWalkFst`) | `⌊2T⌋` steps ⇒ unit variance, cross-cov → u | matches paper's variance-rate-2 walk |
| 4 | **Uninhabited hypothesis** risk (vacuity) | Crossover | Satisfiability witness `exists_isDualPairRescaling` (i.i.d. ±1 coins × Exp(4c)) | `sorryAx`-free, genuine |
| 5 | **Circular fix** — `qLaplaceObs := q^{2a}·dualHitProb`, lemma true by `rfl` | Crossover (`lem_crossbridge`) | Reverted to `opaque qLaplaceObs` + honest `sorry` | `lem_crossbridge` back on `sorryAx` |
| 6 | LCLT audit: 3 paper-derivations asserted as `sorry` | LCLT | `lem:tau`, `thm:kernel`, `prop:occ` derived from cited inputs as named hypotheses | `thm_kernel`/`prop_occ` `sorryAx`-free; `lem_tau` via `karamata_tauberian` |
| 7 | **False universal** bonus catch | LCLT (`lem:asep`) | Pinned to `opaque asepKernel` + honest `sorry` | faithful citation |
| 8 | `thm:ewmain` was a disconnected propositional **skeleton** (`sorryAx`-free but tied to nothing) | EW | Rewired to apply real toolkit lemmas over the file's `opaque` objects | now `sorryAx` via toolkit, like `lem_tau` |
| 9 | Overstated docstring ("proved here") on a trivial reduction | TracyWidom (`thm:marg`) | Docstring corrected to "sorry-free but content is in its hypotheses" | docstring-only diff |

Three distinct "looks-verified-but-isn't" failure modes were seen and corrected:
**false universal** (over-claim), **uninhabited hypothesis** (vacuous), and
**circular definition** (`rfl`). None showed up as a build error.

### Final state

- Build: green, 8026+ jobs, Mathlib v4.28.0.
- `sorry` count: **21**, all confined to genuine black boxes.
- Every derivation the paper actually carries out is a genuine, axiom-clean Lean
  proof. Proved-and-clean (`[propext, Classical.choice, Quot.sound]`) includes:
  tiers 1–2 (closed forms, Price/Sheppard, Bessel–Struve, detailed balance,
  current decoupling), the duality reductions (`thm:dual`, `prop:orth`,
  `lem:acr`), `thm_kernel`, `prop_occ`, and the satisfiability witness.
- The 21 remaining `sorry`s are faithful, non-vacuous statements of results the
  paper **cites**: the CLTs, Tracy–Widom/GUE (`F₂`), Schütz duality, the local
  CLTs / Karamata / Kolmogorov–Rogozin, Mitoma/Aldous/martingale-problem, and the
  Schwartz-distribution/SPDE objects absent from Mathlib — plus the one open
  conjecture (`conj:cov`).

### Honest one-line summary

> Every derivation the paper carries out is now a genuine, axiom-clean Lean proof;
> the remaining `sorry`s are all faithful, non-vacuous statements of results the
> paper legitimately cites (CLTs, Tracy–Widom, Schütz duality, Mitoma/Aldous, the
> SPDE machinery), plus one open conjecture.

What this does **not** claim: the paper's headline asymptotics (Tracy–Widom and
Edwards–Wilkinson limits) are *not* proved in Lean — they are honest cited black
boxes. "The closed-form/algebraic results and all the paper's own derivations are
formally verified, modulo the cited literature inputs" is accurate; "the paper's
results are formally verified" would not be.

### Aristotle CLI notes

- Binary at `~/.local/bin/aristotle`; reads `ARISTOTLE_API_KEY`.
- Key was placed in `~/.zshrc` (interactive shells only), so non-interactive tool
  shells need a wrapper: `zsh -ic 'aristotle …'`. For all shells to inherit it,
  move the export to `~/.zshenv`.
- Useful subcommands: `list`, `show <id>`, `tasks <id>`, `continue <id> "<prompt>"
  --mode instruct`, `download <id> --destination <path>`.

---

## Part 3 — Citation faithfulness (web verification pass)

A web search pass (4 parallel research agents) checked whether the cited "black
box" results are faithful to their references. Two layers: **(A)** does the
reference exist / is it correctly attributed, and **(B)** does the precise stated
theorem match the Lean black box.

**Bottom line:** every reference is real and correctly attributed (nothing
fabricated), and each genuinely contains a result of the claimed form. All issues
found are pinpoint-citation matters (theorem numbers, which of two same-year
papers), not existence.

### Fully confirmed (full-text or authoritative source)

- `lem:acr` ← Ayala–Carinci–Redig **Lem 2.1** — exact identity verified in PMC full text.
- `thm:dual` ← REU (Blyschak–…–Kuan) **Thm 3.1** — verified in arXiv full text.
- `thm:karamata` ← Bingham–Goldie–Teugels **1.7.1′** — incl. Γ-constant / ρ=½ case.
- `lem:free` ← Lawler–Limic (Thm 2.1.1, n^(−1/2) bound), Carlen–Kusuoka–Stroock — verified.
- `lem:KR` ← Petrov — result confirmed (chapter label varies by edition).
- `thm:mitoma`, `prop:aldous` ← Mitoma 1983, Aldous 1978 — criteria confirmed.
- `cor:tri` ← KLLPZ, Groenevelt — confirmed. KPZ, Feller II §XIII.5 — standard, confirmed.

### Confirmed in substance, pinpoint-citation fixes worth making

1. **BCS "Thm 1.4" — mis-citation.** The step-ASEP GUE Tracy–Widom result is in
   Borodin–Corwin–Sasamoto, but as **eq. (1) / Appendix D**, resting on **Thms
   1.2–1.3**. There is no Theorem 1.4 (full PDF read). Fix the label.
2. **Schütz — split across two 1997 papers.** The duality is in the cited
   "Duality relations…" paper; the explicit two-particle Bethe-ansatz Green's
   function (`lem:asep`) is in the companion "Exact Solution of the Master
   Equation…" (cond-mat/9701019). Citation may point at the wrong one.
3. **TW08 kernel bound `p_t ≤ C/(1+t)` — UNCONFIRMED.** ASEP Tracy–Widom
   asymptotics are solidly real (TW 2009, CMP 290), but the specific
   transition-kernel decay used in `lem:asep`/`thm:kernel` was not located at
   statement level. The one genuinely open item — needs the exact source.
4. **Ethier–Kurtz "Thm 7.1.4"** and **CFG20 "Thm 3.2"**: results definitely
   present, exact internal numbers unconfirmed (paywall / non-extractable PDF).
5. **Mitoma** proves the sufficiency direction; "iff" is slightly stronger
   (converse is elementary/standard — harmless).

### What this establishes
- Layer A (attribution): strong — nothing fabricated, all correct.
- Layer B (exact-statement fidelity): partial — full-text confirmed for
  ACR/REU/Lawler–Limic/Karamata; abstract-level for paywalled items; one real gap
  (the TW08 `C/(1+t)` kernel bound).

### Follow-up fixes applied (after the web pass)

- **Docstring citation corrections** (docstring-only, verified `#print axioms`
  unchanged): `thm:marg` BCS pinpoint `Thm 1.4` → `eq.(1)/App.D (via Thms 1.2–1.3)`;
  `lem:asep` Schütz attribution split (duality → original paper; two-particle
  Bethe-ansatz Green's function → companion master-equation paper, cond-mat/9701019).
- **`lem:asep` reclassified from citation → partial derivation.** The bound
  `p_t ≤ C/(1+t)` is **not** stated in TW08; TW08/Schütz give the explicit
  two-particle Green's-function *integral formula*, from which the bound must be
  *derived*. New structure: `opaque asepGreenIntegrand`; `lem_asep` takes the
  integral formula as a named hypothesis `hGreen` and genuinely uses it
  (`rw [hGreen …]`), reducing to a named sub-lemma `asepGreen_integral_decay`
  (the steepest-descent / stationary-phase decay) which carries the sole honest
  `sorry`, correctly labeled as a derivation step (not a TW08 citation).
  Verified: builds; `lem_asep` body `sorry`-free; `#print axioms lem_asep =
  [propext, sorryAx, Classical.choice, Quot.sound]` (sorryAx only via the decay
  sub-lemma). This was the subtlest issue — it looked like a valid citation and
  was caught only by domain knowledge that the bound isn't in the reference.
- **BCS "Thm 1.4" → TW2009 primary (the one genuine paper-level citation bug).**
  `thm:marg` cited `\cite[Thm.~1.4]{BCS}`, but BCS has no Theorem 1.4. Fixed in
  `typeD_decoupling-draft-rev2.tex` to cite the primary source — Tracy–Widom,
  "Asymptotics in ASEP with step initial condition," CMP 290 (2009),
  arXiv:0807.1713 (new `TW2009` bibitem) — with BCS noted as the duality-based
  reproof. The matching Lean `thm_marg` docstring was synced (docstring-only).
- **`lem:asep` / Schütz — already correct in the TeX (no change needed).** The
  draft already has `\bibitem{Schutz}` = the master-equation paper (JSP 88, 1997,
  the Green's-function source) and `\bibitem{SchutzDual}` = the duality paper, and
  `lem:asep`'s proof already derives the C/(1+t) bound from the explicit Green's
  function (eq:schutz2). The earlier "Schütz split" concern was a Lean-docstring
  artifact, not a paper bug.
- **Feller II §XIII.5 — clean citation, no change.** §XIII.5 is the Tauberian-
  theorems section of Feller Vol. II; correctly paired with BGT Thm 1.7.1′ on
  `thm:karamata`. Verified.
