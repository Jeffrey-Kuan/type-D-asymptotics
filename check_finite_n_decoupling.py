"""Symbolic verification (sympy), from the exact general-n type D ASEP generator of
REU arXiv:2209.11114 Section 2.1 (delta=0), of:
  (1) current decoupling at every n: species-i transfer rates across a bond are
      q^{-1}beta_n (right), q beta_n (left), beta_n = q^{1-2n}+q^{2n-1},
      independent of the other species' occupancy;
  (2) the draft's n=infinity rate table eq:rates = entrywise limit of q^{2n} x rates;
  (3) both binding rates proportional to 2 - q^{2n-2}(1-q^2), vanishing exactly at
      n_crit = log(2q^2/(1-q^2)) / (2 log q)   [whence n_crit < 0 iff q > 1/sqrt(3)].
Run: python3 check_finite_n_decoupling.py   (prints True for all three)
"""
import sympy as sp

q, u = sp.symbols('q u', positive=True)   # u = q^{2n}
beta = q/u + u/q
swap = u/q**2 - 2 + q**2/u                # (q^{n-1}-q^{1-n})^2
R = {
 ((0,1),(1,0)): q*beta, ((0,2),(2,0)): q*beta,
 ((0,3),(1,2)): 2*q**2 + q**2/u - q**4/u,
 ((0,3),(2,1)): 2*q**2 + q**2/u - q**4/u,
 ((0,3),(3,0)): q**2*swap,
 ((1,0),(0,1)): beta/q, ((2,0),(0,2)): beta/q,
 ((1,2),(0,3)): 1/u - q**2/u + 2, ((2,1),(0,3)): 1/u - q**2/u + 2,
 ((1,2),(2,1)): swap, ((2,1),(1,2)): swap,
 ((1,2),(3,0)): u - u/q**2 + 2, ((2,1),(3,0)): u - u/q**2 + 2,
 ((3,0),(0,3)): swap/q**2,
 ((3,0),(1,2)): u/q**2 - u/q**4 + 2/q**2, ((3,0),(2,1)): u/q**2 - u/q**4 + 2/q**2,
 ((1,3),(3,1)): q*beta, ((3,1),(1,3)): beta/q,
 ((2,3),(3,2)): q*beta, ((3,2),(2,3)): beta/q,
}
occ = lambda s, i: (s >> i) & 1

ok = True
for i in (0, 1):
    for a in range(4):
        for c in range(4):
            right = sum(r for ((x,y),(x2,y2)), r in R.items()
                        if (x,y)==(a,c) and occ(y2,i)-occ(y,i) == +1)
            left  = sum(r for ((x,y),(x2,y2)), r in R.items()
                        if (x,y)==(a,c) and occ(y2,i)-occ(y,i) == -1)
            exp_r = beta/q if (occ(a,i)==1 and occ(c,i)==0) else 0
            exp_l = q*beta if (occ(a,i)==0 and occ(c,i)==1) else 0
            ok &= (sp.simplify(right-exp_r) == 0 and sp.simplify(left-exp_l) == 0)
print("(1) finite-n current decoupling:", ok)

draft = {((1,0),(0,1)):1, ((0,1),(1,0)):q**2, ((2,0),(0,2)):1, ((0,2),(2,0)):q**2,
 ((3,0),(0,3)):1, ((0,3),(3,0)):q**4, ((0,3),(1,2)):q**2*(1-q**2),
 ((0,3),(2,1)):q**2*(1-q**2), ((1,2),(0,3)):1-q**2, ((2,1),(0,3)):1-q**2,
 ((1,2),(2,1)):q**2, ((2,1),(1,2)):q**2, ((3,1),(1,3)):1, ((1,3),(3,1)):q**2,
 ((3,2),(2,3)):1, ((2,3),(3,2)):q**2,
 ((1,2),(3,0)):0, ((2,1),(3,0)):0, ((3,0),(1,2)):0, ((3,0),(2,1)):0}
print("(2) rescaled n->infinity limit = eq:rates:",
      all(sp.simplify(sp.limit(u*r, u, 0, '+') - draft[k]) == 0 for k, r in R.items()))

c1 = sp.simplify(R[((1,2),(3,0))] - (2 - (u/q**2)*(1-q**2)))
c2 = sp.simplify(R[((3,0),(1,2))] - (2 - (u/q**2)*(1-q**2))/q**2)
n = sp.symbols('n')
ncrit = sp.log(2*q**2/(1-q**2))/(2*sp.log(q))
expr = q**(2*n-2)*(1-q**2) - 2
print("(3) binding rates and n_crit:", c1 == 0, c2 == 0,
      sp.simplify(expr.subs(n, ncrit).rewrite(sp.exp)) == 0)
