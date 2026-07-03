"""Verified statements (machine precision; see session transcript for full code):

(1) EXACT ORTHOGONALITY (CFG arXiv:2003.07837 Thm 'teoasep' at theta=1, two species),
    for the n=infinity type D rates, L=2,3 sites, three parameter sets:
      sum_eta  varpi_{a1}(eta_1) varpi_{a2}(eta_2) Dbar(xi,eta) Dbar(xi',eta)
         = delta_{xi,xi'} * prod_i g_{a_i}(xi_i)/varpi_{a_i}(xi_i)     (x global const)
    with varpi_a = mu_a * q^{N(N-1)} * (a q^{2N-2L}; q^2)_inf,
         g_a     = q^{2N(N-1)} (a q^{2N-2L})_inf (a q^{-2N})_inf,  window a < q^{2L},
    and Dbar = REU function with PROCESS in the N^- slot, DUAL in the N^+ slot.
    Orientation matters: the transpose pairing fails (rel. off-diag 0.05-0.3).

(2) EXPANSION SUPPORT of V_x in (varpi, Dbar), L=4, bond (2,3):
    <V, Dbar(xi,.)>_varpi = 0 for: |xi|<=1; any xi with <=1 particle on the bond;
    same-species bond pairs; and ANY xi with a particle strictly RIGHT of the bond
    (one-sided dressing). Nonzero: the four different-species bond pairs (O(1)) and
    left-dressed configurations.

(3) DRESSED MASS -> 0 as q -> 1 (window-scaled alphas), supporting lem:eps:
    dressed/pair mass ratio: 7.1e-2 (q=0.7), 1.8e-2 (0.9), 6.4e-3 (0.95),
    2.8e-4 (0.99), 5.4e-5 (0.999) on L=4.
