!--------------------------------------------------------------------------------------------------!
! DFTB+XT open software package for quantum nanoscale modeling                                     !
! Copyright (C) 2017-2018 DFTB+ developers group                                                   !
! Copyright (C) 2018 Dmitry A. Ryndyk                                                              !
!--------------------------------------------------------------------------------------------------!
! GNU Lesser General Public License version 3 or (at your option) any later version.               !
! See the LICENSE file for terms of usage and distribution.                                        !
!--------------------------------------------------------------------------------------------------!
! This file is a part of the TraNaS library for quantum transport at nanoscale.                    !
! Developer: Dmitry A. Ryndyk.                                                                     !
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

!> Module includes main container types for TraNaS library.
module tranas_types_main

  use tranas_types_mbngf, only : Interaction, TMBNGF

  use ln_precision, only : dp
  use globals
  use mat_def
  use ln_structure, only : TStruct_info, print_Tstruct
  use input_output
  use elph, only : init_elph_1, Telph, destroy_elph, init_elph_2, init_elph_3
  use phph
  use energy_mesh, only : mesh
  use libmpifx_module

  implicit none
  private

  public :: TTraNaS
  public :: TTraNaSInput
  public :: Tnegf, intArray, TEnGrid

  integer, public, parameter :: MAXNCONT=10

  !------------------------------------------------------------------------------------------------!
  !------------------------------------------------------------------------------------------------!   

  !------------------------------------------------------------------------------------------------!   
  type intArray
    integer, dimension(:), allocatable :: indexes
  end type intArray 


 !! Structure used to define energy points for the integration
 !! For every point we define
 !!     path (1,2 or 3): the energy point belongs to a real axis 
 !!     integration (1), a complex plane integration (2) or a 
 !!     pole summation (3)
 !!     pt_path: relative point number within a single path
 !!     pt: absolute point number along the whole integration path
 !!     cpu: cpu assigned to the calculation of the given energy point
 !!     Ec: energy value
 !!     wght: a weight used in final summation to evaluate integrals
 type TEnGrid   
     integer :: path
     integer :: pt_path
     integer :: pt
     integer :: cpu
     complex(dp) :: Ec
     complex(dp) :: wght
  end type TEnGrid

  !DAR begin - in Tnegf
  !------------------------------------------------------------------------------------------------!

  type :: Tdeph_bp

    real(dp), allocatable, dimension(:) :: coupling
     
  end type Tdeph_bp

  type :: Tdephasing

    type(Tdeph_bp) :: bp

    real(kind=dp) :: Tolerance = 0.001 
     
  end type Tdephasing
 
  !------------------------------------------------------------------------------------------------!
  
  type Tcontact

     character(132) :: name
     logical :: tWriteSelfEnergy = .false.
     logical :: tReadSelfEnergy = .false.
     complex(kind=dp), dimension(:,:,:), allocatable :: SelfEnergy ! Electrode Self-Energy
     logical :: tWriteSurfaceGF = .false.
     logical :: tReadSurfaceGF = .false.
     complex(kind=dp), dimension(:,:,:), allocatable :: SurfaceGF ! Electrode Surface Green Function
     logical :: tUnformatted = .false.
     logical :: tWriteSeparatedSGF = .false.
     logical :: tReadSeparatedSGF = .false.

  end type Tcontact

  type Telectrons

     integer :: IndexEnergy

  end type Telectrons

  type Ttranas_old

     type(Telectrons) :: e
     type(Tcontact), dimension(:), allocatable :: cont

  end type Ttranas_old

  !------------------------------------------------------------------------------------------------!
  
  !> General LibNEGF container.
  !> Contains input data, runtime quantities and output data used by LibNEGF.
  !> Is included now in the general TTraNaS container.
  type Tnegf
     
    !! Input parameters: set by library user
    !! General
    integer :: verbose
    type(mpifx_comm) :: mpicomm
    integer :: ReadOldSGF         ! 0: Read; 1: compute; 2: comp & save
    integer :: FolderSGF          ! 0: /GS; 1: /SGF
    character(len=LST) :: scratch_path    ! Folder for scratch work
    character(len=LST) :: out_path        ! Folder for output data
    real(dp) :: g_spin            ! spin degeneracy
    real(dp) :: delta             ! delta for G.F. 
    real(dp) :: dos_delta         ! additional delta to force more broadening in the DOS 
    real(dp) :: eneconv           ! Energy conversion factor
    integer :: iteration          ! Number of current SCC itaration
    integer  :: spin              ! spin component
    real(dp) :: wght              ! k-point weight 
    integer :: kpoint             ! k-point index
    character(1) :: DorE          ! Density or En.Density

    !! Contacts info
    real(dp) :: mu_n(MAXNCONT)    ! electrochemical potential (el)
    real(dp) :: mu_p(MAXNCONT)    ! electrochemical potential (hl)
    real(dp) :: mu(MAXNCONT)          ! Electrochemical Potential (dft calculation)   
    real(dp) :: contact_DOS(MAXNCONT) ! Ficticious contact DOS
    logical  :: FictCont(MAXNCONT)    ! Ficticious contact 
    real(dp) :: kbT(MAXNCONT)         ! Electronic temperature 

    !! Contour integral
    integer :: Np_n(2)            ! Number of points for n 
    integer :: Np_p(2)            ! Number of points for p 
    integer :: Np_real(11)        ! Number of points for integration over real axis
    integer :: n_kt               ! Number of kT extending tranas_ngf_mbngf.integrations
    integer :: n_poles            ! Number of poles 
    real(dp) :: Ec                ! conduction band edge 
    real(dp) :: Ev                ! valence band edge

    !! Real axis
    real(dp) :: Emin              ! Transmission or dos interval
    real(dp) :: Emax              ! 
    real(dp) :: Estep             ! Transmission or dos E step 

    !! Emitter and collector for transmission or Meir-Wingreen 
    !! (only emitter in this case)
    integer :: ni(MAXNCONT)       ! ni: emitter contact list 
    integer :: nf(MAXNCONT)       ! nf: collector contact list


    integer  :: nldos                 ! Number of LDOS intervals
    type(intArray), dimension(:), allocatable :: LDOS !Array of LDOS descriptor 
                                                     !(contain only index of atoms 
                                                     !for LDOS projection)  
    real(dp) :: DeltaEc           ! safe guard energy below Ec
    real(dp) :: DeltaEv           ! safe guard energy above Ev

    !! Runtime variables: used internally by the library
    type(format) :: form              ! Form of file-Hamiltonian
    logical  :: dumpHS                ! Used for debug
    real(dp) :: muref             ! reference elec.chem potential
    real(dp) :: E                 ! Holding variable 
    real(dp) :: dos               ! Holding variable
    integer :: activecont         ! contact selfenergy
    integer :: min_or_max         ! in input: 0 take minimum, 1 take maximum mu  
    integer :: refcont            ! reference contact (for non equilib)
    integer :: outer              ! flag switching computation of     
                                 ! the Device/Contact DM
                                 ! 0 none; 1 upper block; 2 all


    !! Note: H,S are partitioned immediately after input, therefore they are 
    !! built runtime from input variable
    type(z_CSR), pointer :: H => null()    ! Points to externally allocated H
    type(z_CSR), pointer :: S => null()
    type(z_DNS) :: HC(MAXNCONT)
    type(z_DNS) :: SC(MAXNCONT)
    type(z_DNS) :: HMC(MAXNCONT)
    type(z_DNS) :: SMC(MAXNCONT)
    type(z_CSR), pointer :: rho => null()      ! Holding output Matrix
    type(z_CSR), pointer :: rho_eps => null()  ! Holding output Matrix
    logical    :: isSid           ! True if overlap S == Id
    logical    :: intHS           ! tells HS are internally allocated
    logical    :: intDM           ! tells DM is internally allocated

    type(TStruct_Info) :: str     ! system structure
    integer :: iE                 ! Energy point (integer point)
    complex(dp) :: Epnt           ! Energy point (complex)
    integer :: local_en_points    ! Local number of energy points
    type(TEnGrid), dimension(:), allocatable :: en_grid
    real(dp) :: int_acc           ! integration accuracy
    real(dp), dimension(:), pointer :: E_singular => null()
    real(dp) :: delta_singular
    type(Telph) :: elph           ! electron-phonon data
    type(Tphph) :: phph           ! phonon-phonon data

    type(mesh) :: emesh           ! energy mesh for adaptive Simpson

    !! Many Body Interactions
    class(Interaction), allocatable :: inter
    class(TMBNGF), allocatable :: mbngf                                      !DAR

    !! Output variables: these are filled by internal subroutines to stor
    !! library output
    real(dp), dimension(:,:), pointer :: tunn_mat => null()
    real(dp), dimension(:,:), pointer :: tunn_mat_bp => null()               !DAR
    real(dp), dimension(:,:), pointer :: ldos_mat => null()
    real(dp), dimension(:), pointer :: currents => null() ! value of contact currents 

    logical :: tNoGeometry = .false.
    logical :: tReadOverlap = .false.
    logical :: tWriteDFTB = .false.
    logical :: tReadDFTB = .false.
    logical :: tOrthonormal = .false.
    logical :: tOrthonormalDevice = .false.
    logical :: tWriteOrthonormal = .false.
    logical :: tModel = .false.
    logical :: tSpinDegeneracy = .false.
    logical :: tReadU = .false.
    logical :: tRead_negf_in = .false.
    logical :: tTrans = .false.
    logical :: tCalcSelfEnergies = .true.
    integer :: NumStates       
    character(len=LST) :: FileName
    character(len=LST) :: OverlapFile
    character(len=LST) :: units_energy
    real(kind=dp), dimension(:,:), allocatable :: H_dev
    real(kind=dp), dimension(:,:), allocatable :: S_dev
    real(kind=dp), dimension(:,:), allocatable :: H_all
    real(kind=dp), dimension(:,:), allocatable :: S_all
    real(kind=dp), dimension(:,:), allocatable :: U
    logical :: tManyBody = .false.
    logical :: tElastic = .true.
    logical :: tDephasingVE = .false.
    logical :: tDephasingBP = .false.
    logical :: tZeroCurrent = .false.
    logical :: tMBNGF = .false.
    real(kind=dp) :: Mixing = 0.5
    real(kind=dp) :: Tolerance = 0.001
    integer :: MaxIter = 1000
    logical :: tWrite_negf_params = .false.
    type(Ttranas_old) :: tranas
    type(Tdephasing) :: deph
    logical :: tWriteTagged = .false.

  end type Tnegf

  !------------------------------------------------------------------------------------------------!
  !------------------------------------------------------------------------------------------------!

  type TPhotons

    integer :: NumModes = 0 
    real(dp), dimension(:), allocatable :: Frequencies
    real(dp), dimension(:,:,:), allocatable :: Coupling
    
  end type TPhotons

  !----------------------------------------------------------------------------!

  !> Container for TraNaS input.
  !> Contains input data. Is not changed inside the library.
  type TTraNaSInput

    logical :: tPhotons = .false.          
    type(TPhotons) :: photons
    
  end type TTraNaSInput

  !------------------------------------------------------------------------------------------------!
  !------------------------------------------------------------------------------------------------!

  !> Container for Green function methods.
  !> Contains all new Green function runtime quantities.
  type TNGF

    !> Container for many-body nonequilibrium Green function method.
    !> Classes for many-body self-energies.
    type(TMBNGF) :: mbngf

    !> Container for time-dependent nonequilibrium Green function method.
    !type(TTDNGF) :: tdngf

  end type TNGF
  
  !------------------------------------------------------------------------------------------------!
  !------------------------------------------------------------------------------------------------!
  
  !> General TraNaS container.
  !> Contains all input data, runtime quantities and output data used by the TraNaS library.
  type TTraNaS

    !> Input container. Is not changed inside the library.
    type(TTraNaSInput) :: input    

    !> Container for Green function methods.
    type(TNGF) :: ngf

    !> Container for many-body quantum master equation methods.
    !type(TQME) :: qme

    !> Old LibNEGF container. For DFT+NEGF and consistency with LibNEGF in future. 
    type(TNEGF) :: negf
    
  end type TTraNaS

  !------------------------------------------------------------------------------------------------!
  
end module tranas_types_main
 




