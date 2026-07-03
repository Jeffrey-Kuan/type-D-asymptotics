/* Check (c): forward Monte Carlo of the type D ASEP (n = infinity) at fixed q,
 * step initial condition (bound pairs on x <= 0, empty on x > 0).
 * Measures N_i(T) = #{species-i particles at x > 0} at checkpoint times and
 * accumulates moments for Cov(N1,N2), Var(N_i).
 *
 * Dynamics: uniformized CTMC over bonds, rate table (1.1) of the draft:
 *   (1,0)->(0,1):1   (0,1)->(1,0):q2   (2,0)->(0,2):1   (0,2)->(2,0):q2
 *   (3,0)->(0,3):1   (0,3)->(3,0):q4   (0,3)->(1,2):q2*eps (0,3)->(2,1):q2*eps
 *   (1,2)->(0,3):eps (1,2)->(2,1):q2   (2,1)->(0,3):eps    (2,1)->(1,2):q2
 *   (3,1)->(1,3):1   (1,3)->(3,1):q2   (3,2)->(2,3):1      (2,3)->(3,2):q2
 *
 * Usage: ./typeD_mc <seed> <ntrials>
 * Prints per checkpoint: T n sumN1 sumN2 sumN1sq sumN2sq sumN1N2
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>

#define Q 0.5
#define TMAX 800.0
#define LX 850          /* sites x in [-LX, RX] */
#define RX 850
#define NS (LX + RX + 1)
#define NB (NS - 1)
#define LAMBDA 1.0      /* max total bond rate (attained by (1,0),(1,2),... ) */
#define NCP 4

static const double CP[NCP] = {100.0, 200.0, 400.0, 800.0};

/* rate table: for ordered pair code a*4+b, up to 3 transitions */
typedef struct { int n; int ap[3], bp[3]; double cum[3]; } trans_t;
static trans_t TT[16];

static void build_table(void) {
    double q2 = Q * Q, q4 = q2 * q2, eps = 1.0 - q2;
    for (int i = 0; i < 16; i++) TT[i].n = 0;
    #define ADD(a,b,a2,b2,r) do { trans_t *t = &TT[(a)*4+(b)]; \
        double base = t->n ? t->cum[t->n-1] : 0.0; \
        t->ap[t->n] = (a2); t->bp[t->n] = (b2); t->cum[t->n] = base + (r); t->n++; } while(0)
    ADD(1,0, 0,1, 1.0);  ADD(0,1, 1,0, q2);
    ADD(2,0, 0,2, 1.0);  ADD(0,2, 2,0, q2);
    ADD(3,0, 0,3, 1.0);
    ADD(0,3, 3,0, q4);   ADD(0,3, 1,2, q2*eps); ADD(0,3, 2,1, q2*eps);
    ADD(1,2, 0,3, eps);  ADD(1,2, 2,1, q2);
    ADD(2,1, 0,3, eps);  ADD(2,1, 1,2, q2);
    ADD(3,1, 1,3, 1.0);  ADD(1,3, 3,1, q2);
    ADD(3,2, 2,3, 1.0);  ADD(2,3, 3,2, q2);
    #undef ADD
}

/* splitmix64 */
static uint64_t rng_state;
static inline uint64_t next_u64(void) {
    uint64_t z = (rng_state += 0x9E3779B97F4A7C15ULL);
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
    z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
    return z ^ (z >> 31);
}
static inline double next_dbl(void) { return (next_u64() >> 11) * (1.0/9007199254740992.0); }
/* finalizer-style hash to give each (seed,trial) a well-separated state */
static inline uint64_t hash64(uint64_t z) {
    z = (z ^ (z >> 33)) * 0xFF51AFD7ED558CCDULL;
    z = (z ^ (z >> 33)) * 0xC4CEB9FE1A85EC53ULL;
    return z ^ (z >> 33);
}

int main(int argc, char **argv) {
    uint64_t seed = (argc > 1) ? strtoull(argv[1], NULL, 10) : 1;
    long ntrials  = (argc > 2) ? atol(argv[2]) : 1000;
    build_table();

    static unsigned char w[NS];
    double sN1[NCP] = {0}, sN2[NCP] = {0}, sN1sq[NCP] = {0},
           sN2sq[NCP] = {0}, sN12[NCP] = {0};

    for (long trial = 0; trial < ntrials; trial++) {
        rng_state = hash64(seed ^ hash64((uint64_t)trial + 0x632BE59BD9B4E019ULL));
        next_u64(); next_u64();
        for (int i = 0; i < NS; i++) w[i] = (i <= LX) ? 3 : 0;  /* x<=0 bound pairs */
        double t = 0.0;
        int cpi = 0;
        while (cpi < NCP) {
            double dt = -log(1.0 - next_dbl()) / ((double)NB * LAMBDA);
            double tn = t + dt;
            while (cpi < NCP && CP[cpi] <= tn) {     /* state constant on (t,tn) */
                long n1 = 0, n2 = 0;
                for (int i = LX + 1; i < NS; i++) {  /* x > 0 */
                    unsigned char s = w[i];
                    n1 += (s & 1u);                  /* states 1,3 carry species 1 */
                    n2 += (s >> 1) & 1u;             /* states 2,3 carry species 2 */
                }
                sN1[cpi] += n1;          sN2[cpi] += n2;
                sN1sq[cpi] += (double)n1 * n1;  sN2sq[cpi] += (double)n2 * n2;
                sN12[cpi] += (double)n1 * n2;
                cpi++;
            }
            t = tn;
            if (cpi >= NCP) break;
            int b = (int)(next_dbl() * NB);
            trans_t *tr = &TT[w[b] * 4 + w[b + 1]];
            if (tr->n == 0) continue;
            double u = next_dbl() * LAMBDA;
            for (int k = 0; k < tr->n; k++) {
                if (u < tr->cum[k]) { w[b] = (unsigned char)tr->ap[k];
                                      w[b + 1] = (unsigned char)tr->bp[k]; break; }
            }
        }
    }
    for (int c = 0; c < NCP; c++)
        printf("%.0f %ld %.6f %.6f %.6f %.6f %.6f\n", CP[c], ntrials,
               sN1[c], sN2[c], sN1sq[c], sN2sq[c], sN12[c]);
    return 0;
}
