;+
; NAME:
;   k_project_filters
; PURPOSE:
;   project a flux onto a bandpass or set of bandpasses
; CALLING SEQUENCE:
;   maggies=k_project_filters(lambda, flux [, filterlist=, $
;      filterpath=, band_shift=])
; INPUTS:
;   lambda - [N+1] wavelength in angstroms at pixel edges
;   flux   - [N] flux in ergs/cm^2/s/A at pixel centers
; OPTIONAL INPUTS:
;   filterlist - list of filters (default to sdss set)
;   filterpath - paths to look for filters in
;   band_shift - blueward shift of bandpasses
; COMMENTS:
;   More or less a wrapper on k_create_r.
;   Outputs are in maggies (10.^(-0.4*magnitude)). 
; EXAMPLES:
; BUGS:
; PROCEDURES CALLED:
;   k_load_filters 
; REVISION HISTORY:
;   17-Jan-2002  Translated to IDL by Mike Blanton, NYU
;-
;------------------------------------------------------------------------------
function k_project_filters,lambda,flux,filterlist=filterlist, $
                           filterpath=filterpath,band_shift=band_shift

if(NOT keyword_set(band_shift)) then band_shift=0.
if(NOT keyword_set(filterlist)) then $
  filterlist=['sdss_u0.par','sdss_g0.par','sdss_r0.par','sdss_i0.par', $
              'sdss_z0.par']

k_projection_table, maggies, flux, lambda, zvals, filterlist, $
  zmin=0., zmax=0., nz=1, filterpath=filterpath, band_shift=band_shift
maggies=maggies

return,maggies

end
;------------------------------------------------------------------------------

