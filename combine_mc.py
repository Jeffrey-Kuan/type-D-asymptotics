"""Combine parallel MC outputs and compare Cov(N1,N2)/sqrt(T) against:
  - paper (Thm 8.2):      (1-q^2)^2 * sqrt(1/(pi(1+q^2)))            = 0.2839
  - corrected occupations: q^{-2}(1-q^4) * sqrt(1/(pi(1+q^2)))       = 1.8923
(q = 1/2). Errors: jackknife over files.
"""
import sys, glob
import numpy as np

q2 = 0.25
c_occ = np.sqrt(1.0 / (np.pi * (1 + q2)))
paper = (1 - q2) ** 2 * c_occ
corr = (1 - q2**2) / q2 * c_occ

def load(pattern):
    data = {}
    for fn in sorted(glob.glob(pattern)):
        for line in open(fn):
            parts = line.split()
            if len(parts) != 7:
                continue
            T = float(parts[0])
            vals = np.array([float(x) for x in parts[1:]])
            data.setdefault(T, []).append(vals)
    return data

def stats(rows):
    tot = np.sum(rows, axis=0)
    n, s1, s2, s1q, s2q, s12 = tot
    m1, m2 = s1 / n, s2 / n
    v1 = s1q / n - m1 * m1
    v2 = s2q / n - m2 * m2
    cov = s12 / n - m1 * m2
    # jackknife over blocks (files)
    covs = []
    if len(rows) > 1:
        for i in range(len(rows)):
            t = tot - rows[i]
            nn = t[0]
            covs.append(t[5] / nn - (t[1] / nn) * (t[2] / nn))
        jk = np.array(covs)
        err = np.sqrt((len(rows) - 1) * np.mean((jk - jk.mean()) ** 2))
    else:
        err = float('nan')
    return int(n), m1, v1, v2, cov, err

print(f"predicted Cov/sqrt(T):  paper = {paper:.4f}   corrected-dual = {corr:.4f}")
print(f"{'T':>5} {'trials':>7} {'E[N1]':>8} {'Var(N1)':>8} {'Var_BCS':>8} "
      f"{'Cov':>8} {'+-':>6} {'Cov/sqrt(T)':>11} {'Corr':>7}")
allT = {}
for pat in sys.argv[1:]:
    for T, rows in load(pat).items():
        allT.setdefault(T, []).extend(rows)
for T in sorted(allT):
    n, m1, v1, v2, cov, err = stats(allT[T])
    vbcs = 2 ** (-8 / 3) * (0.75 * T) ** (2 / 3) * 0.8132  # BCS/TW prediction
    print(f"{T:5.0f} {n:7d} {m1:8.2f} {v1:8.3f} {vbcs:8.3f} "
          f"{cov:8.3f} {err:6.3f} {cov/np.sqrt(T):11.4f} {cov/np.sqrt(v1*v2):7.4f}")
