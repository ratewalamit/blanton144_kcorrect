#ifndef IDL_LONG_DEFINED
typedef int IDL_LONG;
#define IDL_LONG_DEFINED
#endif

#define FREEVEC(a) {if((a)!=NULL) free((char *) (a)); (a)=NULL;}

/* Create the rmatrix, a lookup table which speeds analysis */
IDL_LONG k_projection_table(float *rmatrix, IDL_LONG nk, IDL_LONG nv,
														float *vmatrix, float *lambda, IDL_LONG nl,
														float *zvals, IDL_LONG nz, IDL_LONG *filter_n,
														float *filter_lambda, float *filter_pass,
														float band_shift, IDL_LONG maxn);

/* interpolate the rmatrix */
IDL_LONG k_reconstruct_maggies(float *zvals, IDL_LONG nz, float *rmatrix,    
															 IDL_LONG nk, IDL_LONG nv, float *coeffs,
															 float *galaxy_z, float *reconstruct_maggies,
															 IDL_LONG ngalaxy);

/* nonnegative solutions */
IDL_LONG k_fit_nonneg(float *coeffs, float *rmatrix, IDL_LONG nk,
											IDL_LONG nv, float *zvals, IDL_LONG nz, float *maggies,
											float *maggies_ivar, float *redshift, IDL_LONG ngalaxy,
											float tolerance, IDL_LONG maxiter, IDL_LONG *niter, 
											float *chi2, IDL_LONG verbose, IDL_LONG dontinit);
IDL_LONG k_nonneg_solve(float *xx, float *invcovar, float *bb,
												float offset, IDL_LONG nn, float tolerance, 
												IDL_LONG maxiter, IDL_LONG *niter, float *chi2, 
												IDL_LONG verbose);

/* photo-z */
IDL_LONG k_fit_photoz(float *photoz, float *coeffs, float *rmatrix, 
											IDL_LONG nk, IDL_LONG nv, float *lprior, float *zprior,
                      IDL_LONG nprior, float *zvals, 
											IDL_LONG nz, float *maggies, float *maggies_ivar, 
											IDL_LONG ngalaxy, float tolerance, IDL_LONG maxiter, 
											IDL_LONG *niter, float *chi2, IDL_LONG verbose);
float k_nonneg_chi2(float *xx, float *invcovar, float *bb, float offset,
										IDL_LONG nn);

/* linear solving */
void k_cholsl(float *a, int n, float p[], float b[], float x[]);
void k_choldc(float *a, int n, float p[]);

/* interpolation routines */
float k_interpolate_es(float currpos,
												float vals[],
												float pos[],
												IDL_LONG n);

/* string dealing with stuff */
void k_strparse(char *str, char *signal, int *nwrd, char ***wrd);
void k_strfree(char **str, int nwrd);

/* reading and writing files */
FILE *k_fileopen(const char *Filename, const char *Mode);
IDL_LONG k_read_ascii_table(float **table, IDL_LONG *ndim, IDL_LONG **sizes,
														char filename[]);

/* reading in filters as .par files */
IDL_LONG k_load_filters(IDL_LONG **filter_n, float **filter_lambda,
												float **filter_pass, IDL_LONG *maxn,
												IDL_LONG *nk, char filterfile[]);
IDL_LONG k_yanny_readone(char filename[255], void ***input_struct, int *nrows, 
												 void (*add_row_struct)(void ***input_struct, 
																								int *nrows, char *columns[],
																								int ncolumns, char **wrd,
																								int nwrds));
void k_print_filter_struct(void **input_struct, int nrows);
void k_add_row_filter_struct(void ***input_struct, int *nrows, 
														 char *columns[], int ncolumns, char **wrd, 
														 int nwrds);
void k_free_filter_struct(void ***input_struct, int nrows);
void k_copy_filter_struct(void **filter_struct, int filter_n,
													float *filter_lambda, float *filter_pass);

/* NR routines, renamed so as not to overload */
float *k_vector(long nl, long nh);
void k_free_vector(float *v, long nl, long nh);
float k_midpnt(float (*func)(float), float a, float b, IDL_LONG n);
float k_qromo(float (*func)(float), float a, float b,
							 float (*choose)(float(*)(float), float, float, IDL_LONG));
void k_polint(float xa[], float ya[], IDL_LONG n, float x, float *y, 
							float *dy);
void k_locate(float xx[], unsigned long n, float x, unsigned long *j);
float k_zbrent(float (*func)(float), float x1, float x2, float tol);
float k_brent(float ax, float bx, float cx, float (*f)(float), 
							 float tol, float *xmin);
