;+
; NAME:
;   k_make_sdss_training_set
; PURPOSE:
;   Extract training set from VAGC and create a save file
; CALLING SEQUENCE:
;   k_make_sdss_training_set [, modelzlim=, zlimits=, nzchunks=, $
;       shiftband=, errband=, errlimit=, maglimit=, /nophotozplates ]
; INPUTS:
; OPTIONAL INPUTS:
;   modelzlim - at greater than this redshift, use model mags (default 0.15)
;   zlimits - redshift limits to impose on sample (default 1.e-3, 0.5)
;   nzchunks - number of chunks used to equalize redshift dist (default 8)
;   shiftband - mag=mag+shiftband (to get to ABy system)
;               (default -0.042,0.036,0.015,0.013,-0.002)
;   errband - error to add in quadrature (default 0.05,0.02,0.02, 0.02, 0.03)
;   maglimit - magnitude limit to impose in each band
;              (default [30,30,30,30,30])
;   errlimit - error limit (default [1,1,1,1,1])
;   name - name of sample (default 'test')
; OUTPUTS:
; OPTIONAL INPUT/OUTPUTS:
; COMMENTS:
; EXAMPLES:
; BUGS:
;   Needs to have VAGC extraction updated
; PROCEDURES CALLED:
; REVISION HISTORY:
;   18-Jan-2003  Written by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
pro k_stack_south, ra, dec, modelflux, modelflux_ivar
;   on southern equator, stack runs
    runs=sdss_runlist(/science)
    southern_runs=runs[where(runs.stripe eq 82 and runs.comments eq '')]
    nsouth=n_elements(southern_runs)
    modelflux=fltarr(5,n_elements(ra),nsouth)
    modelflux_ivar=fltarr(5,n_elements(ra),nsouth)
    for i=0L, nsouth-1L do begin 
        obj=sdss_findobj(ra, dec, run=southern_runs[i].run, rerun=137, $
                         childobj=childobj) 
        imatch=where(obj.matchdist*3600. lt 2. and obj.matchdist gt 0., $
                     nmatch) 
        if(nmatch gt 0) then begin 
            modelflux[*,imatch,i]=childobj[imatch].modelflux 
            modelflux_ivar[*,imatch,i]=childobj[imatch].modelflux_ivar 
        endif 
    endfor
end
;
pro k_make_sdss_training_set,modelzlim=modelzlim,zlimits=zlimits, $
                             nzchunks=nzchunks, shiftband=shiftband, $
                             errband=errband, errlimit=errlimit, $
                             maglimit=maglimit, name=name

if(NOT keyword_set(nophotozplates)) then mustdoplates=[669,670,671,672] 
if(NOT keyword_set(zlimits)) then zlimits=[1.e-3,0.8]
if(NOT keyword_set(nzchunks)) then nzchunks=8
if(NOT keyword_set(shiftband)) then shiftband=[-0.042,0.036,0.015,0.013,-0.002]
if(NOT keyword_set(errband)) then errband=[0.05,0.02,0.02,0.02,0.03]
if(NOT keyword_set(errlimit)) then errlimit=fltarr(5)+1.0d
if(NOT keyword_set(maglimit)) then maglimit=fltarr(5)+30.0d
if(NOT keyword_set(modelzlim)) then modelzlim=0.0001
if(NOT keyword_set(name)) then name='test'

; get data to search through
savfile='sdss_training_set.'+name+'.sav'
if(NOT file_test(savfile)) then begin
    
; add CNOC2 data 
    cnoc2=mrdfits(getenv('KCORRECT_DIR')+'/data/redshifts/cnoc2/cnoc2.fits',1) ;
    cnoc2_obj=mrdfits(getenv('KCORRECT_DIR')+ $
                      '/data/redshifts/cnoc2/cnoc2-obj.fits',1)
    cnoc2_childobj=mrdfits(getenv('KCORRECT_DIR')+ $
                           '/data/redshifts/cnoc2/cnoc2-childobj.fits',1)
    cnoc2_indx=where(cnoc2_obj.matchdist*3600. lt 10. and $
                     cnoc2_childobj.modelflux_ivar[2] gt 0.)
    cnoc2=cnoc2[cnoc2_indx]
    cnoc2_obj=cnoc2_obj[cnoc2_indx]
    cnoc2_childobj=cnoc2_childobj[cnoc2_indx]
    k_stack_south,cnoc2_childobj.ra, cnoc2_childobj.dec, $
      cnoc2_stack_mf, cnoc2_stack_mf_ivar
    save,filename=savfile
    
;   get redshifts for all spectra
    sp=hogg_mrdfits(getenv('SPECTRO_REDUX')+'/spAll.fits', 1, $
                    columns=['specprimary','plug_ra','plug_dec','z','plate', $
                             'mjd','fiberid','zerr','zwarning','class', $
                             'modelflux', 'modelflux_ivar','extinction'], $
                    nrowchunk=40000)
    sp_indx=where(sp.specprimary gt 0 and $
                  sp.class eq 'GALAXY' and $
                  sp.z gt zlimits[0] and $
                  sp.z le zlimits[1] and $
                  sp.zwarning eq 0, sp_count) 
    sp=sp[sp_indx]

    tostack=where(sp.plug_dec gt -1.5 and sp.plug_dec lt 1.5 and $
                  sp.plug_ra gt 300. or sp.plug_ra lt 100.)
    k_stack_south,sp[tostack].plug_ra,sp[tostack].plug_dec, $
      stack_mf, stack_mf_ivar
    
; get twomass photometry
    columns=['ra','decl', $
             'k_m_k20fe','k_msig_k20fe', $
             'h_m_k20fe','h_msig_k20fe', $
             'j_m_k20fe','j_msig_k20fe', $
             'k_m_ext',  'k_msig_ext', $
             'h_m_ext',  'h_msig_ext', $
             'j_m_ext',  'j_msig_ext']
    oldtwomass_a= $
      hogg_mrdfits(getenv('TWOMASS_XSC_DIR')+'/data/xsc_aaa.fits',1, $
                   nrowchunk=5000,columns=columns)
    oldtwomass_b= $
      hogg_mrdfits(getenv('TWOMASS_XSC_DIR')+'/data/xsc_baa.fits',1, $
                   nrowchunk=5000,columns=columns)
    twomass=[oldtwomass_a,oldtwomass_b]
    oldtwomass_a=0
    oldtwomass_b=0
    
; match em
    spherematch, sp.plug_ra, sp.plug_dec, twomass.ra, twomass.decl, $
      2./3600., m1, m2, d12, chunksize=0.05
    tm=replicate(twomass[0],n_elements(sp))
    struct_assign,{junk:0},tm
    tm[m1]=twomass[m2]
    help,tm,sp
    k_add_stack, CNOC2_STACK_MF, CNOC2_STACK_MF_ivar, cnoc_stacked, $
      cnoc_stacked_ivar
    k_add_stack, STACK_MF, STACK_MF_ivar, stacked, stacked_ivar
    save,filename=savfile 
endif else begin
    restore,savfile
endelse

; now equalize the redshift bins (but include all mustdo plates)
sp=sp[tostack]
tm=tm[tostack]
mustdo=lonarr(n_elements(sp))
for i=0, n_elements(mustdoplates)-1L do begin
    inplate_indx=where(sp.plate eq mustdoplates[i],inplate_count)
    if(inplate_count gt 0) then mustdo[inplate_indx]=1
endfor
mustdo[tostack]=1
includegal=lonarr(n_elements(sp))
ninchunk=fltarr(nzchunks)
for i=nzchunks-1L,0,-1 do begin
    zchunk_lo=zlimits[0]+(zlimits[1]-zlimits[0])*float(i)/float(nzchunks)
    zchunk_hi=zlimits[0]+(zlimits[1]-zlimits[0])*float(i+1)/float(nzchunks)
    chunk_indx=where(sp.z gt zchunk_lo and $
                     sp.z lt zchunk_hi, chunk_count)
    ninchunk[i]=chunk_count
    if(i ne nzchunks-1L) then begin
        dice=randomu(seed,ninchunk[i])
        subsample=float(ninchunk[nzchunks-1L])/float(ninchunk[i])
        help,i,subsample[0]
        include_indx=where(dice lt subsample[0], include_count)
        if(include_count gt 0) then includegal[chunk_indx[include_indx]]=1
    endif else begin
        includegal[chunk_indx]=1L
    endelse
endfor
include_indx=where(includegal gt 0 or mustdo gt 0,include_count)
if(include_count eq 0) then begin
    klog,'no remaining galaxies after equalizing redshifts.'
    return
endif
tm=tm[include_indx]
sp=sp[include_indx]
help,sp,tm
stop

; set up which magnitudes are used
klog,'use model past z='+string(modelzlim)
mag=im.petrocounts
mag_err=im.petrocountserr
model_indx=where(sp.z ge modelzlim,model_count)
help,model_count
if(model_count gt 0) then begin
    mag[*,model_indx]=im[model_indx].counts_model
    mag_err[*,model_indx]=im[model_indx].counts_modelerr
endif

; cut out bad errors
klog,'cutting bad errors'
goodindx=where(abs(mag_err[0,*]) lt errlimit[0] and $
               abs(mag_err[1,*]) lt errlimit[1] and $
               abs(mag_err[2,*]) lt errlimit[2] and $
               abs(mag_err[3,*]) lt errlimit[3] and $
               abs(mag_err[4,*]) lt errlimit[4] and $
               abs(mag[0,*]) lt maglimit[0] and $
               abs(mag[1,*]) lt maglimit[1] and $
               abs(mag[2,*]) lt maglimit[2] and $
               abs(mag[3,*]) lt maglimit[3] and $
               abs(mag[4,*]) lt maglimit[4])
sp=sp[goodindx]
im=im[goodindx]
twomass=twomass[goodindx]
mag=mag[*,goodindx]
mag_err=mag_err[*,goodindx]
help,im

; finally, shift the bands, add errors in quadrature
for i=0L, n_elements(shiftband)-1L do $
  mag[i,*]=mag[i,*]+shiftband[i]
for i=0L, n_elements(errband)-1L do $
  mag_err[i,*]=sqrt(mag_err[i,*]^2+errband[i]^2)

;   HACK to rid of bad u-band (bad uband!)
indx=where(mag[0,*]-mag[1,*] lt 1.6 and $
           mag[1,*]-mag[2,*] gt 1.4,count)
if(count gt 0) then mag_err[0,indx]=-9999.

; now output 
outfile='sdss_training_set.'+name+'.fits'
hdr=strarr(1)
sxaddpar,hdr,'DATE',systime(),'date of creation'
sxaddpar,hdr,'KVERSION',k_version(),'version of kcorrect'
outstr1={maggies:fltarr(8), maggies_ivar:fltarr(8), redshift:0.D, ra:0.D, $
         dec:0.D, objc_rowc:0.D, objc_colc:0.D, sdss_imaging_tag:long64(0L), $
         sdss_spectro_tag:long64(0L)}
outstr=replicate(outstr1,n_elements(sp)+n_elements(cnoc2))
isdss=0L+lindgen(n_elements(sp))
icnoc2=n_elements(sp)+lindgen(n_elements(cnoc2))
outstr[isdss].ra=im.ra
outstr[isdss].dec=im.dec
outstr[isdss].redshift=sp.z
outstr[isdss].maggies[0:4]=lups2maggies(mag[0:4,*])
outstr[isdss].maggies_ivar[0:4]= $
  reform(sdss_err2ivar(mag_err[0:4,*]),5,n_elements(isdss))/ $
  (outstr[isdss].maggies[0:4]*0.4*alog(10.))^2
twomass_indx=where(twomass.j_m_k20fe gt 0. and $
                   twomass.h_m_k20fe gt 0. and $
                   twomass.k_m_k20fe gt 0., twomass_count)
if(twomass_count gt 0) then begin
    outstr[isdss[twomass_indx]].maggies[5]= $
      10.^(-0.4*(twomass[twomass_indx].j_m_k20fe+ $
                 (k_vega2ab(filterlist='twomass_J.par',/kurucz))[0]))
    outstr[isdss[twomass_indx]].maggies_ivar[5]= $
      1./(0.4*alog(10.)*outstr[isdss[twomass_indx]].maggies[5]* $
          twomass[twomass_indx].j_msig_k20fe)^2
    outstr[isdss[twomass_indx]].maggies[6]= $
      10.^(-0.4*(twomass[twomass_indx].h_m_k20fe+ $
                 (k_vega2ab(filterlist='twomass_H.par',/kurucz))[0]))
    outstr[isdss[twomass_indx]].maggies_ivar[6]= $
      1./(0.4*alog(10.)*outstr[isdss[twomass_indx]].maggies[6]* $
          twomass[twomass_indx].h_msig_k20fe)^2
    outstr[isdss[twomass_indx]].maggies[7]= $
      10.^(-0.4*(twomass[twomass_indx].k_m_k20fe+ $
                 (k_vega2ab(filterlist='twomass_Ks.par',/kurucz))[0]))
    outstr[isdss[twomass_indx]].maggies_ivar[7]= $
      1./(0.4*alog(10.)*outstr[isdss[twomass_indx]].maggies[7]* $
          twomass[twomass_indx].k_msig_k20fe)^2
endif
outstr[isdss].sdss_imaging_tag=im.sdss_imaging_tag
outstr[isdss].sdss_spectro_tag=sp.sdss_spectro_tag
outstr[icnoc2].ra=cnoc2_childobj.ra
outstr[icnoc2].dec=cnoc2_childobj.dec
outstr[icnoc2].redshift=cnoc2.z
; AB shifts
for i=0, 4 do begin
    outstr[icnoc2].maggies[i]=cnoc2_childobj.modelflux[i]*1.e-9* $
      10.^(-0.4*shiftband[i])
    outstr[icnoc2].maggies_ivar[i]=cnoc2_childobj.modelflux_ivar[i]*1.e+18* $
      10.^(0.8*shiftband[i])
endfor
outstr[icnoc2].sdss_imaging_tag=-1
outstr[icnoc2].sdss_spectro_tag=-1

; now reddening correct all
euler,outstr.ra,outstr.dec,ll,bb,1
red_fac = [5.155, 3.793, 2.751, 2.086, 1.479, 0.902, 0.576, 0.367]
extinction= $
  red_fac # dust_getval(ll, bb, /interp, /noloop)
outstr.maggies=outstr.maggies*10.^(0.4*extinction)
outstr.maggies_ivar=outstr.maggies_ivar*10.^(-0.8*extinction)

mwrfits,dummy,outfile,hdr,/create
mwrfits,outstr,outfile

end
;------------------------------------------------------------------------------
