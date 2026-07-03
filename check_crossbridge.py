# Finite check of the Section-7 bridging identity (block IC), n=infinity type D.
#   LHS  = E_block[ D^tri(xi_bp, eta_s) ]   (forward 4^L process from the block)
#        = joint q-Laplace observable of the two species
#   dual = E_{xi_bp}[ D^tri(eta=block, xi_s) ]   (two-particle dual from a bound pair)
#   claim: dual = q^{4m} * P_{xi_bp}( both dual particles land in the block )
# If LHS = dual = q^{4m} P(both in block), the bridge identity (i) holds.
import numpy as np
from scipy.linalg import expm

def build_rates(q):
    q2,q4=q*q,q**4; eps=1-q2
    return {(1,0):[(0,1,1.0)],(0,1):[(1,0,q2)],(2,0):[(0,2,1.0)],(0,2):[(2,0,q2)],
            (3,0):[(0,3,1.0)],(0,3):[(3,0,q4),(1,2,q2*eps),(2,1,q2*eps)],
            (1,2):[(0,3,eps),(2,1,q2)],(2,1):[(0,3,eps),(1,2,q2)],
            (3,1):[(1,3,1.0)],(1,3):[(3,1,q2)],(3,2):[(2,3,1.0)],(2,3):[(3,2,q2)]}

def generator(L,q):
    R=build_rates(q); n=4**L; M=np.zeros((n,n))
    for c in range(n):
        st=[(c>>(2*x))&3 for x in range(L)]
        for x in range(L-1):
            for (a2,b2,r) in R.get((st[x],st[x+1]),[]):
                st2=st.copy(); st2[x],st2[x+1]=a2,b2
                c2=sum(s<<(2*xx) for xx,s in enumerate(st2))
                M[c,c2]+=r; M[c,c]-=r
    return M

occ=lambda c,x,i:((c>>(2*x))>>i)&1

def Dtri(L,q):
    n=4**L; D=np.zeros((n,n))
    for eta in range(n):
        for xi in range(n):
            ok=True; v=1.0
            for x in range(L):
                for i in range(2):
                    if occ(xi,x,i):
                        if not occ(eta,x,i): ok=False; break
                        Nm=sum(occ(xi,y,i) for y in range(x))
                        Np=sum(occ(eta,y,i) for y in range(x+1,L))
                        v*=q**(2*((x+1)-Nm+Np))
                if not ok: break
            D[eta,xi]=v if ok else 0.0
    return D

def subset_block(xi,m):           # xi subseteq block(sites 0..m-1, both species)
    for x in range(m, (xi.bit_length()+1)//2+1):
        if (xi>>(2*x))&3: return False
    return all(((xi>>(2*x))&3)==0 for x in range(m, 8))  # crude; refined below

for (q,s) in [(0.6,1.0),(0.45,0.7),(0.8,1.3)]:
    L=6
    M=generator(L,q); D=Dtri(L,q); Ps=expm(s*M)
    interlace=np.abs(M@D-D@M.T).max()
    for m in (2,3):                       # block = bound pairs on sites 0..m-1
        block=sum(3<<(2*x) for x in range(m))
        for a in (m-1, m):                # bound pair start site
            xibp=3<<(2*a)
            LHS = Ps[block,:] @ D[:,xibp]
            dual= Ps[xibp,:] @ D[block,:]
            # P(both dual particles in block): final configs with all particles in 0..m-1
            inblock=[c for c in range(4**L) if all(((c>>(2*x))&3)==0 for x in range(m,L))]
            Pboth=Ps[xibp, inblock].sum()
            claim=q**(4*m)*Pboth
            print(f"q={q} s={s} m={m} a={a}: interlace={interlace:.1e}  "
                  f"LHS={LHS:.6e}  dual={dual:.6e}  q^4m*P={claim:.6e}  "
                  f"|LHS-dual|={abs(LHS-dual):.1e}  |LHS-q^4m P|={abs(LHS-claim):.1e}")
