!--------------------------------------------------------------------------------------------------!                              
! DFTB+XT: DFTB+ eXTended version for model and atomistic quantum transport at nanoscale.          !
!                                                                                                  !
! Copyright (C) 2017-2018 DFTB+ developers group.                                                  !
! Copyright (C) 2018 Dmitry A. Ryndyk.                                                             !
!                                                                                                  !
! GNU Lesser General Public License version 3 or (at your option) any later version.               !
! See the LICENSE file for terms of usage and distribution.                                        !
!--------------------------------------------------------------------------------------------------!
! This file is part of the TraNaS library for quantum transport at nanoscale.                      !
!                                                                                                  !
! Developer: Dmitry A. Ryndyk.                                                                     !
!                                                                                                  !
! Based on the LibNEGF library developed by                                                        !
! Alessandro Pecchia, Gabriele Penazzi, Luca Latessa, Aldo Di Carlo.                               !
!--------------------------------------------------------------------------------------------------!

!!--------------------------------------------------------------------------!
!! libNEGF: a general library for Non-Equilibrium Green's functions.        !
!! Copyright (C) 2012                                                       !
!!                                                                          ! 
!! This file is part of libNEGF: a library for                              !
!! Non Equilibrium Green's Function calculation                             ! 
!!                                                                          !
!! Developers: Alessandro Pecchia, Gabriele Penazzi                         !
!! Former Conctributors: Luca Latessa, Aldo Di Carlo                        !
!!                                                                          !
!! libNEGF is free software: you can redistribute it and/or modify          !
!! it under the terms of the GNU Lesser General Public License as published !
!! by the Free Software Foundation, either version 3 of the License, or     !
!! (at your option) any later version.                                      !
!!                                                                          !
!!  You should have received a copy of the GNU Lesser General Public        !
!!  License along with libNEGF.  If not, see                                !
!!  <http://www.gnu.org/licenses/>.                                         !  
!!--------------------------------------------------------------------------!

module lib_param

  use ln_precision, only : dp
  use globals
  use mat_def
  use ln_structure, only : TStruct_info, print_Tstruct
  use input_output
  use elph, only : init_elph_1, Telph, destroy_elph, init_elph_2, init_elph_3
  use phph
  use energy_mesh, only : mesh
  use tranas_types_mbngf, only : Interaction, Tmbngf
  use elphdd, only : ElPhonDephD, ElPhonDephD_create 
  use elphdb, only : ElPhonDephB, ElPhonDephB_create
  use elphds, only : ElPhonDephS, ElPhonDephS_create
  !use libmpifx_module, only : mpifx_comm
  
  use tranas_types_main   

  implicit none
  private

  !public :: Tnegf, intArray, TEnGrid
  public :: set_defaults, print_all_vars

  public :: set_elph_dephasing, destroy_elph_model
  public :: set_elph_block_dephasing, set_elph_s_dephasing
  public :: set_phph
  !integer, public, parameter :: MAXNCONT=10
  
contains
 
  !> Set values for the local electron phonon dephasing model
  !! (elastic scattering only)
  subroutine set_elph_dephasing(negf, coupling, niter)

    type(Tnegf) :: negf
    type(ElPhonDephD) :: elphdd_tmp
    real(dp),  dimension(:), allocatable, intent(in) :: coupling
    integer :: niter
    
    call elphondephd_create(elphdd_tmp, negf%str, coupling, niter, 1.0d-7)
    if(.not.allocated(negf%inter)) allocate(negf%inter, source=elphdd_tmp)

  end subroutine set_elph_dephasing

  !> Set values for the semi-local electron phonon dephasing model
  !! (elastic scattering only)
  subroutine set_elph_block_dephasing(negf, coupling, orbsperatom, niter)

    type(Tnegf) :: negf
    type(ElPhonDephB) :: elphdb_tmp
    real(dp),  dimension(:), allocatable, intent(in) :: coupling
    integer,  dimension(:), allocatable, intent(in) :: orbsperatom
    integer :: niter
    
    call elphondephb_create(elphdb_tmp, negf%str, coupling, orbsperatom, niter, 1.0d-7)
    if(.not.allocated(negf%inter)) allocate(negf%inter, source=elphdb_tmp)

  end subroutine set_elph_block_dephasing

 !> Set values for the semi-local electron phonon dephasing model
  !! (elastic scattering only)
  subroutine set_elph_s_dephasing(negf, coupling, orbsperatom, niter)

    type(Tnegf) :: negf
    type(ElPhonDephS) :: elphds_tmp
    real(dp),  dimension(:), allocatable, intent(in) :: coupling
    integer,  dimension(:), allocatable, intent(in) :: orbsperatom
    integer :: niter

    call elphondephs_create(elphds_tmp, negf%str, coupling, orbsperatom, negf%S, niter, 1.0d-7)
    if(.not.allocated(negf%inter)) allocate(negf%inter, source=elphds_tmp)

  end subroutine set_elph_s_dephasing



  !> Destroy elph model. This routine is accessible from interface as 
  !! it can be meaningful to "switch off" elph when doing different
  !! task (density or current)
  subroutine destroy_elph_model(negf)
    type(Tnegf) :: negf
    
    if (allocated(negf%inter)) deallocate(negf%inter)
    call destroy_elph(negf%elph)

  end subroutine destroy_elph_model

  subroutine set_defaults(negf)
    type(Tnegf) :: negf    

     negf%verbose = 10

     negf%scratch_path = './GS/'
     negf%out_path = './'
     negf%DorE = 'D'           ! Density or En.Density

     negf%ReadoldSGF = 1       ! Compute Surface G.F. do not save
     negf%FolderSGF = 0        ! /GS 
     negf%FictCont = .false.   ! Ficticious contact 

     negf%mu = 0.d0            ! Potenziale elettrochimico
     negf%contact_DOS = 0.d0   ! Ficticious contact DOS

     negf%wght = 1.d0
     negf%kpoint = 1

     negf%mu_n = 0.d0
     negf%mu_p = 0.d0
     negf%Ec = 0.d0
     negf%Ev = 0.d0
     negf%DeltaEc = 0.d0
     negf%DeltaEv = 0.d0

     negf%E = 0.d0            ! Holding variable 
     negf%dos = 0.d0          ! Holding variable
     negf%eneconv = 1.d0      ! Energy conversion factor

     negf%isSid = .false.         
     negf%intHS = .true.
     negf%intDM = .true.

     negf%delta = 1.d-4      ! delta for G.F. 
     negf%dos_delta = 1.d-4  ! delta for DOS 
     negf%Emin = 0.d0        ! Transmission or dos interval
     negf%Emax = 0.d0        ! 
     negf%Estep = 0.d0       ! Transmission or dos E step
     negf%kbT = 0.d0         ! electronic temperature
     negf%g_spin = 2.d0      ! spin degeneracy

     negf%Np_n = (/20, 20/)  ! Number of points for n 
     negf%Np_p = (/20, 20/)  ! Number of points for p 
     negf%n_kt = 10          ! Numero di kT per l'integrazione
     negf%n_poles = 3        ! Numero di poli 
     negf%iteration = 1      ! Iterazione (SCC)
     negf%activecont = 0     ! contact selfenergy
     negf%ni = 0             ! ni
     negf%ni(1) = 1
     negf%nf = 0             ! nf
     negf%nf(1) = 2          !
     negf%min_or_max = 1     ! Set reference cont to max(mu)  
     negf%refcont = 1        ! call set_ref_cont()
     negf%outer = 2          ! Compute full D.M. L,U extra
     negf%dumpHS = .false.
     negf%int_acc = 1.d-3    ! Integration accuracy 
                             ! Only in adaptive refinement 
     negf%nldos = 0

   end subroutine set_defaults


   subroutine set_phph(negf, order, filename)
      type(Tnegf) :: negf
      integer, intent(in) :: order
      character(*), intent(in) :: filename
 
      print*,'(set_phph) init_phph' 
      call init_phph(negf%phph, negf%str%central_dim, order, negf%str%mat_PL_start, negf%str%mat_PL_end) 
      
      print*,'(set_phph) load_phph_coupl' 
      call load_phph_couplings(negf%phph, filename) 

   end subroutine set_phph



   subroutine print_all_vars(negf,io)
     type(Tnegf) :: negf    
     integer :: io

     call print_Tstruct(negf%str)

     write(io,*) 'verbose=',negf%verbose

     write(io,*) 'scratch= "'//trim(negf%scratch_path)//'"'
     write(io,*) 'output= "'//trim(negf%out_path)//'"'

     write(io,*) 'isSid= ',negf%isSid

     write(io,*) 'Contact Parameters:'
     write(io,*) 'mu= ', negf%mu
     write(io,*) 'WideBand= ', negf%FictCont
     write(io,*) 'DOS= ', negf%contact_DOS

     write(io,*) 'Contour Parameters:'
     write(io,*) 'mu_n= ', negf%mu_n
     write(io,*) 'mu_p= ', negf%mu_p
     write(io,*) 'Ec= ', negf%Ec 
     write(io,*) 'Ev= ', negf%Ev
     write(io,*) 'DEc= ', negf%DeltaEc 
     write(io,*) 'DEv= ', negf%DeltaEv
     write(io,*) 'ReadoldSGF= ',negf%ReadoldSGF
     write(io,*) 'Np_n= ',negf%Np_n
     write(io,*) 'Np_p= ', negf%Np_p
     write(io,*) 'nkT= ', negf%n_kt
     write(io,*) 'nPoles= ', negf%n_poles
     write(io,*) 'min_or_max= ', negf%min_or_max
     write(io,*) 'refcont= ', negf%refcont

     write(io,*) 'Transmission Parameters:'
     write(io,*) 'Emin= ',negf%Emin
     write(io,*) 'Emax= ',negf%Emax
     write(io,*) 'Estep= ',negf%Estep
     write(io,*) 'T= ',negf%kbT
     write(io,*) 'g_spin= ',negf%g_spin 
     write(io,*) 'delta= ',negf%delta
     write(io,*) 'dos_delta= ',negf%dos_delta
     write(io,*) 'ni= ', negf%ni
     write(io,*) 'nf= ', negf%nf
     write(io,*) 'DorE= ',negf%DorE

     write(io,*) 'Internal variables:'
     write(io,*) 'intHS= ',negf%intHS
     write(io,*) 'intDM= ',negf%intDM
     write(io,*) 'kp= ', negf%kpoint
     write(io,*) 'wght= ', negf%wght
     write(io,*) 'E= ',negf%E
     write(io,*) 'outer= ', negf%outer
     write(io,*) 'DOS= ',negf%dos
     write(io,*) 'Eneconv= ',negf%eneconv
     write(io,*) 'iter= ', negf%iteration
     write(io,*) 'activecont= ', negf%activecont 


  end subroutine print_all_vars

end module lib_param
 




