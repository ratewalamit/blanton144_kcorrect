;+
; NAME:
;   k_fit_nonneg
; PURPOSE:
;   Fit nonnegative sum of given templates to given set of maggies
; CALLING SEQUENCE:
;   coeffs= k_fit_nonneg(maggies, maggies_ivar, vmatrix, lambda, redshift=, $
;      filterlist= [, chi2=, rmatrix=, zvals=, maxiter=, filterpath=, $ 
;      zmin=, zmax=, nz=, band_shift=, /verbose])
; INPUTS:
;   maggies - fluxes in each band for each galaxy
;   maggies_var - inverse variance in each band for each galaxy
;   vmatrix - templates
;   lambda - pixel edges for all templates
;   redshift - redshift of galaxies
;   filterlist - list of filternames
; OPTIONAL INPUTS:
;   filterpath - path to look for filters on
;   maxiter - maximum number of iterations in fit
;   z[min|max] - limits for redshift to use in making lookup table
;   nz - number of redshift rows in lookup table
;   band_shift - shifted bands if desired
;   /verbose - verbose output
; OUTPUTS:
;   chi2 - chi^2 value for each fit
;   rmatrix - projection table used
;   zvals - redshift list for projection table used
; OPTIONAL INPUT/OUTPUTS:
; COMMENTS:
; EXAMPLES:
; BUGS:
; PROCEDURES CALLED:
; REVISION HISTORY:
;   01-May-2003  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function k_fit_nonneg, maggies, maggies_ivar, vmatrix, lambda, $
                       redshift=redshift, filterlist=filterlist, chi2=chi2, $
                       rmatrix=rmatrix, zvals=zvals, maxiter=maxiter, $
                       filterpath=filterpath, zmin=zmin, zmax=zmax, nz=nz, $
                       band_shift=band_shift, tolerance=tolerance, $
                       verbose=verbose, niter=niter
                  
if(n_params() lt 2) then begin
    print,'Syntax - coeffs= k_fit_nonneg(maggies, maggies_ivar [, vmatrix, lambda, $'
    print,'          redshift=, filterlist=, chi2=, rmatrix=, zvals=, maxiter=, filterpath=, ]'
    print,'          zmin=, zmax=, nz=, band_shift=, /verbose ])'
    return,-1
endif 

if(NOT keyword_set(verbose)) then verbose=0L
if(NOT keyword_set(maxiter)) then maxiter=50000
if(NOT keyword_set(tolerance)) then tolerance=1.e-6

; Set source object name
soname=filepath('libkcorrect.'+kcorrect_so_ext(), $
                root_dir=getenv('KCORRECT_DIR'), subdirectory='lib')

; Create rmatrix if necessary
ngalaxy=long(n_elements(redshift))
nk=long(n_elements(maggies)/ngalaxy)
if (keyword_set(vmatrix) AND keyword_set(filterlist) AND keyword_set(lambda)) $
  then begin
    k_load_filters,filterlist,filter_n,filter_lambda,filter_pass, $
      filterpath=filterpath
    k_projection_table,rmatrix,vmatrix,lambda,zvals,filterlist, $ 
      zmin=zmin,zmax=zmax,nz=nz,band_shift=band_shift,filterpath=filterpath
endif else begin
    if (NOT keyword_set(rmatrix) and NOT keyword_set(zvals)) then begin
        klog, 'ERROR: need to specify (rmatrix,zvals) or (vmatrix,lambda,filterlist)'
    endif
endelse 
nz=long(n_elements(zvals))
nv=long(n_elements(rmatrix)/(nz*nk)) 	 

; Set rmatrix
coeffs=fltarr(nv,ngalaxy)
chi2=fltarr(ngalaxy)
niter=0L
retval=call_external(soname, 'idl_k_fit_nonneg', float(coeffs), $
                     float(rmatrix), long(nk), long(nv), $
                     float(zvals), long(nz), float(maggies), $
                     float(maggies_ivar), float(redshift), $
                     long(ngalaxy), float(tolerance), long(maxiter), $
                     long(niter),float(chi2),long(verbose)) 

return,coeffs

end
;------------------------------------------------------------------------------
