;+
; NAME:
;   k_bc03_grid
; PURPOSE:
;   make grid of BC03 model spectra
; CALLING SEQUENCE:
;   k_bc03_grid
; REVISION HISTORY:
;   29-Jul-2004  Michael Blanton (NYU)
;-
;------------------------------------------------------------------------------
pro k_mmatrix

norm_lmin=1500.
norm_lmax=23000.
lmin=1300.
lmax=25000.
navloglam=8000L
nagesmax=10
minzf=0.
maxzf=1.
;;nmets=6
;;mets=[0,1,2,3,4,5]
nmets=2
mets=[2,3]

;; make stellar pops
bc03= k_im_read_bc03()
iwave=where(bc03.wave gt norm_lmin and bc03.wave lt norm_lmax, nwave)

nages=3000L + nagesmax
tol=5.
while(nages gt nagesmax) do begin
    iuse=n_elements(bc03.age)-1L 
    i=iuse
    while i ge 1 do begin
        j=iuse[0]-1L
        scalefact=total(bc03.flux[iwave,i]*bc03.flux[iwave,j])/ $
          total(bc03.flux[iwave,i]*bc03.flux[iwave,i])
        diff=total(((bc03.flux[iwave,i]*scalefact- $
                     bc03.flux[iwave,j])/ $
                    bc03.flux[iwave,j])^2,/double) 
        while(diff lt tol AND j gt 0L) do begin
            j=j-1L
            scalefact=total(bc03.flux[iwave,i]*bc03.flux[iwave,j])/ $
              total(bc03.flux[iwave,i]*bc03.flux[iwave,i])
            diff=total(((bc03.flux[iwave,i]*scalefact- $
                         bc03.flux[iwave,j])/ $
                        bc03.flux[iwave,j])^2,/double) 
        endwhile
        if(j ge 0 and diff ge tol) then begin
            iuse=[j,iuse]
        endif
        i=j
    endwhile
    tol=tol/0.85
    ages=bc03.age[iuse]
    nages=n_elements(ages)
    help,tol, nages
endwhile

tmp_bc03= k_im_read_bc03(age=1.)
nl=n_elements(tmp_bc03.flux)

wave=tmp_bc03.wave
loglam=alog10(wave)
grid=fltarr(nl, nages, nmets)

for im= 0L, nmets-1L do $
  grid[*,*,im]= (k_im_read_bc03(met=mets[im])).flux[*,iuse]

avloglam=double(alog10(lmin)+(alog10(lmax)-alog10(lmin))* $
                (dindgen(navloglam)+0.5)/float(navloglam))
sfgrid=fltarr(navloglam, nages*nmets)

ninterloglam=20000L
interloglam=double(alog10(lmin)+(alog10(lmax)-alog10(lmin))* $
                   (dindgen(ninterloglam)+0.5)/float(ninterloglam))

for im= 0L, nmets-1L do $
  for ia= 0L, nages-1L do begin & $
  splog, string(im)+string(ia) & $
  intergrid=interpol(grid[*,ia,im], loglam, interloglam) & $
  combine1fiber, interloglam, intergrid, fltarr(ninterloglam)+1., $
  newloglam=avloglam, newflux=tmp1, maxiter=0 & $
  sfgrid[*,ia+im*nages]=tmp1 & $
  endfor

ndust=3L
dust1={dusty_str, geometry:'', dust:'', structure:'', tauv:0.}
dust=replicate(dust1,3)
dust.geometry=['dusty', $
               'dusty','dusty']
dust.dust=['MW', $
           'MW','MW']
dust.structure=['c', $
                'c','c']
dust.tauv=[0.,1.,3.]

dustygrid=fltarr(navloglam, nages*nmets, ndust)
dustfact=fltarr(navloglam, ndust)
for i=0L, ndust-1L do $
  dustfact[*,i]=exp(-witt_ext(dust[i],dust[i].tauv,10.^(avloglam)))
for i=0L, ndust-1L do $
  for j=0L, nages*nmets-1L do $
  dustygrid[*,j,i]=sfgrid[*,j]*dustfact[*,i]

spgrid=reform(dustygrid,navloglam,nages*nmets*ndust)
tauv=fltarr(nages,nmets,ndust)
for i=0L, ndust-1L do tauv[*,*,i]=dust[i].tauv
met=fltarr(nages,nmets,ndust)
for i=0L, nmets-1L do met[*,i,*]=mets[i]
age=fltarr(nages,nmets,ndust)
for i=0L, nages-1L do age[i,*,*]=ages[i]

;; now make emission lines 
readcol, getenv('HOME')+'/eplusa/data/linelist.txt', f='(a,f,a)', $
  comment=';', name, lambda, type
ii=where(type eq 'em' OR type eq 'both' and $
         lambda gt 10.^(avloglam[0]) and $
         lambda lt 10.^(avloglam[navloglam-1L]))
name=name[ii]
lambda=lambda[ii]
emgrid=fltarr(navloglam, n_elements(name))
sigma=2.
for i=0L, n_elements(name)-1L do $
  emgrid[*, i]= exp(-(10.^avloglam-lambda[i])^2/(sigma)^2)/ $
  (sqrt(2.*!DPI)*sigma)

;; now make all filters at all redshifts
filterlist=['galex_FUV.par', $
            'galex_NUV.par', $
            'sdss_u0.par', $
            'sdss_g0.par', $
            'sdss_r0.par', $
            'sdss_i0.par', $
            'sdss_z0.par', $
            'twomass_J.par', $
            'twomass_H.par', $
            'twomass_Ks.par']
zf=minzf+(maxzf-minzf)*(findgen(nzf)+0.5)/float(nzf)
lambda=fltarr(navloglam+1L)
davloglam=avloglam[1]-avloglam[0]
lambda[0:navloglam-2L]=10.^(avloglam-davloglam)
lambda[1:navloglam-1L]=10.^(avloglam+davloglam)
k_projection_table, rmatrix, spgrid, lambda, zf, filterlist

stop

;; output
outgrid=fltarr(navloglam,nages*nmets*ndust+n_elements(name))
outgrid[*,0L:nages*nmets*ndust-1L]=spgrid
outgrid[*,nages*nmets*ndust:nages*nmets*ndust+n_elements(name)-1L]=emgrid
mwrfits, outgrid, 'mmatrix.fits', /create
mwrfits, tauv, 'mmatrix.fits'
mwrfits, met, 'mmatrix.fits'
mwrfits, age, 'mmatrix.fits'
mwrfits, name, 'mmatrix.fits'


end