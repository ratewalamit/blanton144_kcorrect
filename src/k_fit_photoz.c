#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <kcorrect.h>

/*
 * k_fit_nonneg.c
 *
 * Given the rmatrix, does a nonnegative fit of templates to data. 
 *
 * Mike Blanton
 * 5/2003 */

#define ZRES 0.10
#define TOL 0.005
#define MAXITER 3000
#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

static float *pz_coeffs=NULL;
static float *pz_rmatrix=NULL;
static float *pz_zvals=NULL;
static float *pz_maggies=NULL;
static float *pz_maggies_ivar=NULL;
static IDL_LONG pz_nk=0,pz_nv=0,pz_nz=0;

float pz_fit_coeffs(float z) 
{
	IDL_LONG niter;
	float chi2;
	
	k_fit_nonneg(pz_coeffs,pz_rmatrix,pz_nk,pz_nv,pz_zvals,pz_nz, 
							 pz_maggies,pz_maggies_ivar,&z,1,TOL,MAXITER,&niter,
							 &chi2,0);
	
	return(chi2);
} /* end pz_fit_coeffs */

/* Create the rmatrix, a lookup table which speeds analysis */
IDL_LONG k_fit_photoz(float *photoz,
											float *coeffs,
											float *rmatrix,
											IDL_LONG nk,
											IDL_LONG nv,
											float *zvals,
											IDL_LONG nz,
											float *maggies,
											float *maggies_ivar,
											IDL_LONG ngalaxy,
											float tolerance,
											IDL_LONG maxiter,
											IDL_LONG *niter,
											float *chi2,
											IDL_LONG verbose)
{
	float *zgrid,*chi2grid,chi2min,az,bz,cz;
	IDL_LONG i,j,k,nzsteps,jmin;

	pz_nk=nk;
	pz_nv=nv;
	pz_nz=nz;
	nzsteps=(IDL_LONG) floor((zvals[nz-1]-zvals[0])/ZRES);
	chi2grid=(float *) malloc(nzsteps*sizeof(float));
	pz_maggies=(float *) malloc(nk*sizeof(float));
	pz_maggies_ivar=(float *) malloc(nk*sizeof(float));
	pz_coeffs=(float *) malloc(nv*sizeof(float));
	pz_rmatrix=(float *) malloc(pz_nv*pz_nk*pz_nz*sizeof(float));
	for(i=0;i<pz_nv*pz_nk*pz_nz;i++)
		pz_rmatrix[i]=rmatrix[i];
	pz_zvals=(float *) malloc(pz_nz*sizeof(float));
	for(i=0;i<pz_nz;i++)
		pz_zvals[i]=zvals[i];
	zgrid=(float *) malloc(nzsteps*sizeof(float));
	for(j=0;j<nzsteps;j++) 
		zgrid[j]=zvals[0]+(zvals[nz-1]-zvals[0])*(float)j/(float)(nzsteps-1);
	for(i=0;i<ngalaxy;i++) {
		
		for(k=0;k<nk;k++) {
			pz_maggies[k]=maggies[i*nk+k];
			pz_maggies_ivar[k]=maggies_ivar[i*nk+k];
		} /* end for k */

		/* first lay out a grid and get chi^2 for each z value */
		for(j=0;j<nzsteps;j++) 
			chi2grid[j]=pz_fit_coeffs(zgrid[j]);

		/* find minimum on grid */
		jmin=0;
		chi2min=chi2grid[0];
		for(jmin=0,chi2min=chi2grid[0],j=1;j<nzsteps;j++) 
			if(chi2grid[j]<chi2min) {
				chi2min=chi2grid[j];
				jmin=j;
			} /* end if */

		/* then search for minimum more intelligently around it */
		if(jmin==0) {
			az=zgrid[jmin];
			bz=0.5*(zgrid[jmin]+zgrid[jmin+1]);
			cz=zgrid[jmin+1];
		} else if(jmin==nzsteps-1) {
			az=zgrid[jmin-1];
			bz=0.5*(zgrid[jmin-1]+zgrid[jmin]);
			cz=zgrid[jmin];
		} else {
			az=zgrid[jmin-1];
			bz=zgrid[jmin];
			cz=zgrid[jmin+1];
		} /* end if..else */
		chi2min=k_brent(az,bz,cz,pz_fit_coeffs,TOL,&(photoz[i]));

		/* evaluate coefficients at final z */
		chi2[i]=pz_fit_coeffs(photoz[i]);
		for(j=0;j<nv;j++)
			coeffs[i*nv+j]=pz_coeffs[j];
	} /* end for i */

	FREEVEC(pz_rmatrix);
	FREEVEC(pz_zvals);
	FREEVEC(pz_maggies);
	FREEVEC(pz_maggies_ivar);
	FREEVEC(pz_coeffs);
	FREEVEC(zgrid);
	FREEVEC(chi2grid);
	return(1);
} /* end k_fit_photoz */
