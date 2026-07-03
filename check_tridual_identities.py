# Exact small-lattice (L=8) verification of the step-sector triangular duality
# identities of Section 8 / Lemma lem:tridual of the draft (machine precision):
#   E_step[ eta_{i,a}(s) q^{2(a+N+_{a+1}(eta_i))} ]     = q^{2k} P_a(X_s <= k)
#   E_step[ eta_{1,a}eta_{2,b}(s) q^{2(...)+2(...)} ]   = q^{4k} P_{(a,b)}(both <= k)
# Forward side: 4^8 chain via expm_multiply; dual side: 1- and 2-particle sectors.
# Verified 2026-06-12 at q=0.6, s=1.5, diffs ~1e-17..1e-20 for a in {2,4,5,6},
# (a,b) in {(3,5),(5,5),(2,6),(5,3)}.
