"""Check the self-duality interlacing  L D = D L^T  for the n = infinity type D
ASEP rates of the draft, on L = 2 and L = 3 sites (closed boundaries), against:

  (A) the draft's duality function eq:Dfac: local product of normalized
      kappa_1's (orthonormal basis, a(xi) = 1);
  (B) the actual REU duality function (arXiv:2209.11114, Thm 3.1, eqs 14-15):
      D = prod_{i species} prod_{x in common sites of (eta_i, xi_i)}
            ( 1 - q^{2(x - N^-_{x-1}(xi_i) + N^+_{x+1}(eta_i))} / alpha_i ),
      with N^-_{x-1}(xi) = # dual particles strictly left of x,
           N^+_{x+1}(eta) = # process particles strictly right of x.
      REU prove this for (q,n,delta) = (q,2,0), (q,3,0) and conjecture general n
      (their Remark 4); here we test it at n = infinity.

Also checks orthogonality of (B) w.r.t. the blocking measure and inspects a(xi).
"""
import numpy as np
import itertools

def bits(s):           # site state -> (eta1, eta2)
    return (s & 1, (s >> 1) & 1)

RATES = None
def build_rates(q):
    q2, q4 = q*q, q**4
    eps = 1 - q2
    return {
        (1,0):[(0,1,1.0)], (0,1):[(1,0,q2)],
        (2,0):[(0,2,1.0)], (0,2):[(2,0,q2)],
        (3,0):[(0,3,1.0)],
        (0,3):[(3,0,q4),(1,2,q2*eps),(2,1,q2*eps)],
        (1,2):[(0,3,eps),(2,1,q2)], (2,1):[(0,3,eps),(1,2,q2)],
        (3,1):[(1,3,1.0)], (1,3):[(3,1,q2)],
        (3,2):[(2,3,1.0)], (2,3):[(3,2,q2)],
    }

def generator(L, q):
    """4^L x 4^L generator, closed boundaries, M[c][c'] = rate, diag = -sum."""
    rates = build_rates(q)
    n = 4**L
    M = np.zeros((n, n))
    for c in range(n):
        st = [(c >> (2*x)) & 3 for x in range(L)]      # site 0..L-1
        for x in range(L - 1):
            key = (st[x], st[x+1])
            for (a2, b2, r) in rates.get(key, []):
                st2 = st.copy(); st2[x], st2[x+1] = a2, b2
                c2 = sum(s << (2*xx) for xx, s in enumerate(st2))
                M[c][c2] += r
                M[c][c]  -= r
    return M

def D_draft(L, q, alphas):
    """Local product of normalized kappa_1's; site x = 1..L, t_{i,x}=alpha_i q^{-2x}."""
    n = 4**L
    D = np.ones((n, n))
    for eta in range(n):
        for xi in range(n):
            v = 1.0
            for x in range(L):
                se = (eta >> (2*x)) & 3; sx = (xi >> (2*x)) & 3
                for i in range(2):
                    if (sx >> i) & 1:
                        t = alphas[i] * q**(-2*(x+1))
                        e = (se >> i) & 1
                        v *= ((1+t)*e - t) / np.sqrt(t)
            D[eta][xi] = v
    return D

def D_reu(L, q, alphas):
    """REU eqs (14)-(15) at the two-point specialization."""
    n = 4**L
    D = np.ones((n, n))
    for eta in range(n):
        es = [[(eta >> (2*x)) >> i & 1 for x in range(L)] for i in range(2)]
        for xi in range(n):
            xs = [[(xi >> (2*x)) >> i & 1 for x in range(L)] for i in range(2)]
            v = 1.0
            for i in range(2):
                for x in range(L):           # x is 0-based; site label = x+1
                    if es[i][x] == 1 and xs[i][x] == 1:
                        Nminus = sum(xs[i][:x])          # dual particles left of x
                        Nplus  = sum(es[i][x+1:])        # eta particles right of x
                        v *= 1 - q**(2*((x+1) - Nminus + Nplus)) / alphas[i]
            D[eta][xi] = v
    return D

def blocking(L, q, alphas):
    n = 4**L
    w = np.ones(n)
    for c in range(n):
        for x in range(L):
            s = (c >> (2*x)) & 3
            for i in range(2):
                if (s >> i) & 1:
                    w[c] *= alphas[i] * q**(-2*(x+1))
    return w

for (q, a1, a2) in [(0.37, 0.83, 2.31), (0.61, 1.57, 0.49)]:
    for L in (2, 3):
        M = generator(L, q)
        DA = D_draft(L, q, (a1, a2))
        DB = D_reu(L, q, (a1, a2))
        rA = np.abs(M @ DA - DA @ M.T).max()
        rB = np.abs(M @ DB - DB @ M.T).max()
        # orthogonality of DB w.r.t. blocking measure
        w = blocking(L, q, (a1, a2))
        G = DB.T @ np.diag(w) @ DB
        off = np.abs(G - np.diag(np.diag(G))).max()
        print(f"q={q} alphas=({a1},{a2}) L={L}:  "
              f"interlacing draft-D: {rA:.3e}   REU-D: {rB:.3e}   "
              f"REU-D orthogonality off-diag: {off:.3e}")

# inspect a(xi) for REU-D vs blocking weight (L=2, first param set)
q, a1, a2, L = 0.37, 0.83, 2.31, 2
DB = D_reu(L, q, (a1, a2)); w = blocking(L, q, (a1, a2))
a_xi = (DB**2 * w[:, None]).sum(axis=0)
print("\nxi (site1,site2) : a(xi)/sum(w)  vs  blocking w(xi)/sum(w)   ratio")
Z = w.sum()
for xi in range(16):
    s1, s2 = xi & 3, (xi >> 2) & 3
    if a_xi[xi] > 0:
        print(f"({s1},{s2}) : {a_xi[xi]/Z:10.6f}   {w[xi]/Z:10.6f}   "
              f"{a_xi[xi]/w[xi]:8.4f}")
