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


module distributions

  use ln_precision
  
  implicit none
  private

  public :: bose
  public :: fermi
  public :: diff_bose

  interface bose
    module procedure bose_r
    module procedure bose_c
  end interface
  
  interface fermi
    module procedure fermi_f
    module procedure fermi_fc
  end interface


contains
  
  real(kind=dp) function fermi_f(E,Ef,kT) 

    implicit none

    real(kind=dp), intent(in) :: E, Ef, kT

    ! the check over 0 is important otherwise the next fails
    if (kT.eq.0.d0) then
      if(E.gt.Ef) then
        fermi_f = 0.D0
      else
        fermi_f = 1.D0
      end if
      return
    endif

    if (abs((E-Ef)/kT).gt.50) then
      if(E.gt.Ef) then
        fermi_f = 0.0_dp
      else
        fermi_f = 1.D0
      end if
      return
    else        
      fermi_f = 1.d0/(exp((E-Ef)/kT)+1.d0);
      return
    endif

  end function fermi_f


  complex(kind=dp) function fermi_fc(Ec,Ef,kT)

    implicit none
    
    complex(kind=dp), intent(in) :: Ec
    real(kind=dp), intent(in) :: Ef, kT

    complex(kind=dp) :: Efc,kTc,ONE=(1.d0,0.d0)

    Efc=Ef*ONE
    kTc=kT*ONE

    if (kT.eq.0.d0) then
      if(real(Ec).gt.Ef) then
        fermi_fc = (0.D0,0.D0)
      else
        fermi_fc = (1.D0,0.D0)
      end if
      return
    endif

    if (abs( (real(Ec)-Ef)/kT ).gt.30) then
      if(real(Ec).gt.Ef) then
        fermi_fc = exp( -(Ec-Efc)/kTc )
      else
        fermi_fc = (1.D0,0.D0)
      end if
      return
    else        

      fermi_fc = ONE/(exp( (Ec-Efc)/kTc ) + ONE);
      return
    endif

  end function fermi_fc
  
  !////////////////////////////////////////////////////////////////////////
  real(dp) function bose_r(E,kT) 
    real(dp), intent(in) :: E, kT

    ! the check over 0 is important otherwise the next fails
    if (kT.eq.0.d0) then
      bose_r = 0.D0
      return
    endif

    if (abs(E/kT).gt.30.d0) then
      bose_r = exp(-E/kT);
    else        
      bose_r = 1.d0/(exp(E/kT) - 1.d0);
    endif
     
  end function bose_r   
  
  complex(kind=dp) function bose_c(Ec,Ef,kT)
    complex(kind=dp), intent(in) :: Ec
    real(kind=dp), intent(in) :: Ef, kT

    complex(kind=dp) :: Efc,kTc,ONE=(1.d0,0.d0)

    Efc=Ef*ONE
    kTc=kT*ONE

    if (kT.eq.0.d0) then
      bose_c = (0.D0,0.D0)
      return
    endif

    if (abs( real(Ec)/kT ).gt.30.d0) then
      bose_c = exp( -Ec/kTc )
    else        
      bose_c = ONE/(exp( Ec/kTc ) - ONE);
    endif

  end function bose_c
  
  !////////////////////////////////////////////////////////////////////////
  real(dp) function diff_bose(E,kT) 
    real(dp), intent(in) :: E, kT

    ! the check over 0 is important otherwise the next fails
    if (kT.eq.0.d0) then
      diff_bose = 0.D0
      return
    endif

    if (E.eq.0.d0) then
      diff_bose = 1.d0
      return
    endif

    if (abs(E/kT).gt.30.d0) then
      diff_bose = exp(-E/kT)*(E/kT)**2
    else        
      diff_bose = exp(E/kT)/((exp(E/kT)-1.d0)**2.d0)*(E/kT)**2
    endif
     
  end function diff_bose
  
end module distributions
