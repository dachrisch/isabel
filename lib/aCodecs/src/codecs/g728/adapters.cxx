/*************************************************************************/
/*                                                                       */
/*                            LD-CELP  G.728                             */
/*                                                                       */
/*    Low-Delay Code Excitation Linear Prediction speech compression.    */
/*                                                                       */
/*    Code edited by Michael Concannon.                                  */
/*    Based on code written by Alex Zatsman, Analog Devices 1993         */
/*                                                                       */
/*    Reestructuracion: Angel Fdez. Herrero. Octubre-2000                */
/*									 */
/*************************************************************************/

#include "parm.h"
#include "data.h"
#include "state.h"
#include "common.h"
#include "prototyp.h"

static void hybwin(int lpsize, int framesize, int nrsize,
	           real old_input[], real new_input[], real output[],
	           const real window[], real rec[], real decay);
static int  levdur(real[], real[], int);
static int  sf_levdur(LDCELP_STATE *ldst,real[], real[]);
static void bw_expand2(real input[],
		       real z_out[], real p_out[],
		       int order, const real z_vec[], const real p_vec[]);
static void bw_expand1(real input[], real  p_out[],
		       int order, const real p_vec[]);
static void autocorr(real X[], real R[], int K, int M, int N);

/********************************** Adapter for Perceptual Weighting Filter */

/* Las siguientes son constantes inicializadas en init_pwf_adapter() */

static real pwf_z_vec[LPCW+1];  /* Arrays for band widening: zeros and */
static real pwf_p_vec[LPCW+1];  /* poles */

void
pwf_adapter(LDCELP_STATE *ldst,
   	 real input[],
	    real z_out[], /* zero coefficients */
	    real p_out[]) /* pole coefficients */
{
    /* Las siguientes variables no son de estado */

    static real
	acorr[LPCW+1],	/* autocorrelation coefficients */
	lpcoeff[LPCW+1];
    /*static real temp[LPCW+1];*/

    hybwin(LPCW,	/* lpsize */
	   NFRSZ,	/* framesize */
	   NONRW,	/* nrsize -- nonrecursive size */
	   LDST(pwf_old_input),
	   input,
	   acorr,
	   hw_percw,
	   LDST(pwf_rec),
	   0.5);
    if(levdur(acorr, lpcoeff, LPCW))
    {
	/*RCOPY(temp, lpcoeff, LPCW+1);*/
	bw_expand2(lpcoeff, z_out, p_out, LPCW, pwf_z_vec, pwf_p_vec);
    }
}

/*************************************** Backward Synthesis Filter Adapter */

/* Las siguientes son constantes inicializadas en init_bsf_adapter() */

static real facv[LPC+1];

void
bsf_adapter(LDCELP_STATE *ldst, real input[], real p_out[])
{
    /* Las siguientes variables no son de estado */

    static real
	acorr[LPC+1],	/* autocorrelation coefficients */
	lpcoeff[LPC+1];
    /*static real temp[LPC+1];*/

    hybwin(LPC,		/* lpsize */
	   NFRSZ,	/* framesize */
	   NONR,	/* nrsize -- nonrecursive size */
	   LDST(bsf_old_input),
	   input,
	   acorr,
	   hw_synth,
	   LDST(bsf_rec),
	   0.75);
    if(sf_levdur(ldst, acorr, lpcoeff))
    {
	LDST(k10) = -acorr[1]/acorr[0];
	/*RCOPY(temp, lpcoeff, LPC+1);*/
	bw_expand1(lpcoeff, p_out, LPC, facv);
    }
}

/******************************************************* Gain Adapter **/

const real gain_p_vec[LPCLG+1]=  /* Array for band widening */
  { 1.0, 0.90625, 0.8212890625, 0.74432373046875, 0.67449951171875, 
    0.61126708984375, 0.553955078125, 0.50201416015625, 0.4549560546875, 
    0.41229248046875, 0.3736572265625 };

/*** recompute lpc_coeff **/

void gain_adapter(LDCELP_STATE *ldst,real log_gain[], real coeff[])
{
    /* Las siguientes variables no son de estado */

    static real
	acorr[LPCLG+1],	  /* autocorrelation coefficients */
	lpcoeff[LPCLG+1];
    /*static real temp[LPCLG+1];*/

    hybwin(LPCLG,	/* lpsize */
	   NUPDATE,	/* framesize */
	   NONRLG,	/* nrsize -- nonrecursive size */
	   LDST(g_old_input),
	   log_gain,
	   acorr,
	   hw_gain,
	   LDST(g_rec),
	   0.75);
    if(levdur(acorr, lpcoeff, LPCLG))
    {
	/*for(i=1; i<=LPCLG; i++) lpcoeff[i] = temp[i];*/
        bw_expand1(lpcoeff, coeff, LPCLG, gain_p_vec);
    }
}

/******************************************** Initializations **/

void
init_pwf_adapter(real z_co[], real p_co[])
{
    int i;
    real zv = 1.0, pv = 1.0;

    for(i=0; i<=LPCW; i++)
    {
	pwf_z_vec[i] = zv;
	pwf_p_vec[i] = pv;
	zv *= WZCF;
	pv *= WPCF;
	z_co[i] = 0.0;
	p_co[i] = 0.0;
    }
    p_co[0] = 1.0;
    z_co[0] = 1.0;

    /*ZARR(LDST(pwf_old_input));
    ZARR(LDST(pwf_rec));*/
}

void
init_bsf_adapter(real co[])
{
    int i;
    real v = 1.0;

    for(i=0; i<=LPC; i++)
    {
	facv[i] = v;
	v *= FAC;
	co[i] = 0;
    }
    co[0] = 1.0;

    /*ZARR(LDST(bsf_old_input));
    ZARR(LDST(bsf_rec));*/
}

void init_gain_adapter(real co[])
{
    co[0] = 1.0;
    co[1] = -1.0;

    /*for(i=0; i<LPCLG+NUPDATE+NONRLG; i++)
	LDST(g_old_input)[i] = -GOFF;*/

    /*ZARR(LDST(g_rec));
    ZARR(LDST(g_old_input));*/
}

/******************************************** Hybrid Window Module **/

/*
  Hybrid Window 

  LPSIZE	- size of OUTPUT (autocorrelation vector)
  FRAMESIZE	- size of NEW_INPUT
  NRSIZE	- size of non-recursive part.
  OLD_INPUT	- buffer for holding old input (size LPSIZE+FRAMESIZE+NRSIZE)
  NEW_INPUT	- new input, or frame (size FRAMESIZE)
  OUTPUT	- autocorrelation vector (size LPSIZE)
  WINDOW	- window coefficients (size LPSIZE+FRAMESIZE+NRSIZE)
  REC	- 	- recursive part (size LPSIZE)
  DECAY	- 	- scaling for the old recursive part.
 */

static void
hybwin(int lpsize, int framesize, int nrsize, real old_input[], 
       real new_input[], real output[], const real window[],
		    real rec[],		/* Recursive Part */
		    real decay)
{
    int N1 = lpsize + framesize; /* M+L */
    int N2 = lpsize + nrsize;	/* M+N */
    int N3 = lpsize + framesize + nrsize;
    int i;

    real* ws   = new real[N3];
    real* tmp1 = new real[lpsize+1];
    real* tmp2 = new real[lpsize+1];


    /* shift in INPUT into OLD_INPUT and window it */
    
    for(i=0; i<N2; i++)
	old_input[i] = old_input[i+framesize];
    for(i=0; i<framesize; i++)
	old_input[N2+i] = new_input[i];

    VPROD(old_input, window, ws, N3);
    
    autocorr(ws, tmp1, lpsize, lpsize, N1);
    
    for(i=0; i<=lpsize; i++)
	rec[i] = decay * rec[i] + tmp1[i];
    
    autocorr(ws, tmp2, lpsize,  N1, N3);
    
    for(i=0; i<=lpsize; i++)
	output[i] = rec[i] + tmp2[i];

    output[0] *= WNCF;

    delete ws;
    delete tmp1;
    delete tmp2;
}

/********************************************* Levinson-Durbin Routines */

/* Levinson-Durbin algorithm */
/* return 1 if ok, otherwise 0 */

static int levdur(real acorr[], real coeff[], int order)
{
  /* Local variables */
  int minc, minc2;
  real s;
  int ib, mh;
  real at;
  int ip;
  real rc[20];
  real alpha;
  real tmp;

  /* Parameter adjustments */
  --acorr;
  --coeff;

/* .......CHECK FOR ZERO SIGNAL OR ILLEGAL ZERO-LAG AUTOCORRELATION */
  if ((acorr[1] <= (real)0.)||(acorr[order+1] == 0))
    return 0;

/* .......START DURBIN's RECURSION */
  rc[1] = -acorr[2] / acorr[1];
  coeff[1] = (real)1.;
  coeff[2] = rc[1];
  alpha = acorr[1] + acorr[2] * rc[1];
  if (alpha <= (real)0.)
    return 0;
  for (minc = 2; minc <= order; ++minc) {
    minc2 = minc + 2;
    s = acorr[minc + 1];
    for (ip = 2; ip <= minc; ++ip) {
      s += acorr[minc2 - ip] * coeff[ip];
    }
    rc[minc] = -s / alpha;
    mh = minc / 2 + 1;
    for (ip = 2; ip <= mh; ++ip) {
      ib = minc2 - ip;
      at = rc[minc] * coeff[ib];
      at += coeff[ip];
      tmp = rc[minc] * coeff[ip];
      coeff[ib] += tmp;
      coeff[ip] = at;
    }
    coeff[minc + 1] = rc[minc];
    alpha += rc[minc] * s;

/* ...........IF RESIDUAL ENERGY LESS THAN ZERO (DUE TO ILL-CONDITIONING), */
/* ...........RETURN WITHOUT UPDATING FILTER COEFFICIENTS (USE OLD ONES). */
    if (alpha <= (real)0.)
      return 0;
  }
  return 1;
}

/*
  Levinson-Durbin algorithm  for Synthesis Filter. Its main 
  difference from the above is the fact that it saves 10-th
  order coefficients for Postfilter, plus some speedup since this 
  is one of the longest routines in the algorithm.
  */ 

static int sf_levdur(LDCELP_STATE *ldst,real acorr[], real coeff[])
{
    real E;
    /*register*/ real K REG(r9), c1 REG(r0), tmp REG(r12);
    int m, j, halfm;

    if (acorr[LPC] == 0)
        return 0;
    E = acorr[0];
    if (E<=0) 
	return 0;
    coeff[0] = 1.0;
    for(m=1; m<=LPC; m++) {
	K =  -acorr[m];
	if (m>1)
	{
	    real a1 REG(r4)=acorr[m-1];
	    c1=coeff[1];
	    tmp = c1*a1;
	    if (m>2) {
		c1 = coeff[2]; a1 = acorr[m-2];
		for(j=3; j<=m-1; j++) {
		    K -= tmp;
		    tmp = c1 * a1;
		    c1 = coeff[j];
		    a1 = acorr[m-j];
		}
		K -= tmp;
		tmp = c1*a1;
	    }
	    K -= tmp;
	}
	K = K/E;
	coeff[m] = K;
	halfm = m>>1;

	/** this is pipelened version of parallel assignment:  **/
	/*  coeff[j]   =     coeff[j] + K * coeff[m-j] */
	/*  coeff[m-j] = K * coeff[j] +     coeff[m-j] */

	if (halfm>=1) {
	      /*register*/ real
		  x REG(r1), y REG(r5), t1 REG(r10),
		  t2 REG(r14), t3 REG(r2), t4 REG(r6);
	      /*register*/ real *p  REG(i10);
	      /*register*/ real *pp REG(i11);
	      /*register*/ real *q  REG(i12);
	      /*register*/ real *qq REG(i13);

	      p = coeff+1;   pp = p;
	      q = coeff+m-1; qq = q;
	      x=*p++;
	      y=*q--;
	      t1 = K * x;
	      t2 = K * y;
	      for(j=2; j<=halfm; j++) {
		  t4 = t2 + x;	 x=*p++;
		  t3 = t1 + y;   y=*q--;      
		  t1 = K * x;	*pp++ = t4;
		  t2 = K * y;	*qq-- = t3;
	      }
	      t3 = t1 + y;
	      t4 = t2 + x;
	      *pp = t4;
	      *qq = t3;
	}

	if (m==10) {
	    int jj;
	    for(jj=0; jj<=10; jj++)
		LDST(a10)[jj] = coeff[jj];
	}
	E = (1 - K * K) * E;
	if (E<0)
	    return 0;
    }
    return 1;
}

/******************************************** Band Width Expanders **/

/* Don't have to worry about i=0 -- z_vec[0] and p_vec[0] should stay 1.0. */

static void
bw_expand2(real input[], real z_out[], real p_out[],
	   int order, const real z_vec[], const real p_vec[])
{
	int i;
	for(i=1; i<=order; i++)
	    z_out[i] = z_vec[i]*input[i];
	for(i=1; i<=order; i++)
	    p_out[i] = p_vec[i]*input[i];
}

/* Poles only */

static void
bw_expand1(real input[], real p_out[], int order, const real p_vec[])
{
	int i;
	for(i=1; i<=order; i++)
	    p_out[i] = p_vec[i]*input[i];
}

static void
autocorr(real X[], real R[], int K, int M, int N)
{
  int  ii,jj;
  real tmp;

  for(ii=0; ii<=K; ii++) {
    R[ii] = 0;
    for(jj=M; jj<N; jj++) {
      tmp = X[jj] * X[jj-ii];
      R[ii] += tmp;
    }
  }
}
