"""Check (a): occupation-time ratio tau_0/tau_1 for the relative walk of the
different-species two-particle dual (type D ASEP, n = infinity, fixed q).

r-chain rates (read from Sections 5 and 8 of the draft):
  r = 0    -> +1 : q^2*eps      (split (0,3)->(1,2))
  r = 0    -> -1 : q^2*eps      (split (0,3)->(2,1))
  r = +1   ->  0 : eps          (merge (1,2)->(0,3))
  r = +1   -> -1 : q^2          (swap  (1,2)->(2,1))
  r = +1   -> +2 : 1+q^2        (outward: X2 right at 1, X1 left at q^2)
  |r| >= 2 -> r+-1 : 1+q^2 each (independent hops)
  (negative side mirrored; pair hops keep r = 0 and are irrelevant here)

Paper's claim (proof of Thm 8.2): tau_0, tau_{+-1} share a common leading
sqrt(s) coefficient, i.e. tau_0/tau_1 -> 1.
Corrected claim: reversible measure has m(0)/m(1) = 1/q^2, so
tau_0/tau_1 -> q^{-2}  (= 4 at q = 1/2), and
  Cov ~ [(1+q^4)/q^2 - 2 q^2] * sqrt(s/(pi(1+q^2)))   per (8.2)
instead of (1-q^2)^2 * sqrt(s/(pi(1+q^2))).
"""
import numpy as np
import scipy.sparse as sp

q = 0.5
q2, q4 = q**2, q**4
eps = 1 - q2
L = 600                      # r in [-L, L]
n = 2 * L + 1
idx = lambda r: r + L

rows, cols, vals = [], [], []
def add(r_from, r_to, rate):
    rows.append(idx(r_to)); cols.append(idx(r_from)); vals.append(rate)
    rows.append(idx(r_from)); cols.append(idx(r_from)); vals.append(-rate)

add(0, +1, q2 * eps); add(0, -1, q2 * eps)
for s_ in (+1, -1):
    add(s_, 0, eps)                  # merge
    add(s_, -s_, q2)                 # swap
    add(s_, 2 * s_, 1 + q2)          # outward
for r in range(2, L):
    for s_ in (+1, -1):
        add(s_ * r, s_ * (r + 1), 1 + q2)
        add(s_ * r, s_ * (r - 1), 1 + q2)
A = sp.csr_matrix(sp.coo_matrix((vals, (rows, cols)), shape=(n, n)))

p = np.zeros(n); p[idx(0)] = 1.0
dt, T = 0.01, 3000.0
nsteps = int(T / dt)
tau = np.zeros(n)
checkpoints = {int(t / dt) for t in (250, 500, 1000, 2000, 3000)}

c_pred = np.sqrt(1.0 / (np.pi * (1 + q2)))     # bulk occupation constant
print(f"q={q}  eps={eps}  m(0)/m(1) predicted = {1/q2}")
print(f"{'s':>6} {'tau0':>9} {'tau1':>9} {'tau0/tau1':>9} {'p0/p1':>9} "
      f"{'comb/sqrt(s)':>12} {'paper':>8} {'corrected':>10}")
for k in range(1, nsteps + 1):
    # RK4 step + trapezoid accumulation of occupations
    k1 = A @ p
    k2 = A @ (p + 0.5 * dt * k1)
    k3 = A @ (p + 0.5 * dt * k2)
    k4 = A @ (p + dt * k3)
    p_new = p + (dt / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4)
    tau += 0.5 * dt * (p + p_new)
    p = p_new
    if k in checkpoints:
        s_now = k * dt
        t0, t1, tm1 = tau[idx(0)], tau[idx(1)], tau[idx(-1)]
        comb = (1 + q4) * t0 - q2 * (t1 + tm1)          # combination in (8.2)
        print(f"{s_now:6.0f} {t0:9.3f} {t1:9.3f} {t0/t1:9.4f} "
              f"{p[idx(0)]/p[idx(1)]:9.4f} {comb/np.sqrt(s_now):12.4f} "
              f"{(1-q2)**2 * c_pred:8.4f} {(1-q4)/q2 * c_pred:10.4f}")
print(f"\nmass check: sum p = {p.sum():.6f}  (should be ~1)")
print(f"edge mass at |r|>={L-20}: {p[:20].sum()+p[-20:].sum():.2e} (should be ~0)")
