PROGRAM mat_eval
  USE sobol
  IMPLICIT NONE
  
  INTEGER :: Nsobol                           
  INTEGER :: n, i, j, k, m, o, p         
  INTEGER, PARAMETER :: d = 1                 ! Code for 1D case Only
  INTEGER:: deg                             
  INTEGER*8 :: skip                          
  DOUBLE PRECISION, ALLOCATABLE:: norm(:,:)   
  DOUBLE PRECISION, DIMENSION(1:10) :: herm, coef    
  DOUBLE PRECISION, DIMENSION(1:10, 1:10) :: A     
	REAL :: initial_time, final_time
!==========================================================================================!
!=================================Variables to set=========================================!
!================deg: highest polynomial, Nsobol: # iterations, skip: seed ================!
!==========================================================================================!
  deg = 10                                
  Nsobol = 100
  skip = 100
  CALL CPU_TIME(initial_time)
  ALLOCATE (norm(d,Nsobol))
  A=0d0
!==========================================================================================!
!===================Generate array of normally distributed sobol points====================!
!==========================================================================================!
  DO n = 1, Nsobol                
    CALL sobol_stdnormal(d,skip,norm(:,n))
  END DO
  norm=norm/SQRT(2.)    ! Factor from Normal Distribution
!==========================================================================================!
!=============================Coeficients each Polynomial==================================!
!==========================================================================================!
  coef(1) = 1
  coef(2) = 1.0 / (SQRT(2.0))
  DO p = 3,deg
    coef(p) = coef(p-1)*(1 /SQRT(2.0*REAL(p-1)))
  END DO
  OPEN(UNIT=9, FILE='converge.dat')
!==========================================================================================!
!=================================Evaluate Polynomials=====================================!
!==========================================================================================!
  DO i = 1, Nsobol              
        herm(1) = 1.0             
        herm(2) = 2.0*norm(1,i)       
        DO j = 3,deg      
             herm(j) =(2.0*norm(d,i)*herm(j-1)) - (2.0*(j-2)*herm(j-2))
        END DO
!==========================================================================================!
!===============================Potential Energy Matrix====================================!
!==========================================================================================!
        DO k = 1, deg
             DO m = 1, deg
                 A(k,m) = A(k,m) + coef(k)*herm(k)*coef(m)*herm(m)
             END DO
        END DO
!==========================================================================================!
!=================================Convergence Analysis=====================================!
!==========================================================================================!
        IF (mod(i,1)==0) THEN
            WRITE(9,*) (A) / REAL(i)
        END IF
  END DO ! loop over sobol points
  CLOSE(9)
!==========================================================================================!
!======================================Final Matrix========================================!
!==========================================================================================!
  A = A / Nsobol
  OPEN(UNIT=10, FILE='final_matrix.dat')
  do o=1,deg
     Write(10,*) A(1:deg,o)
  enddo
  CLOSE(10)
CALL CPU_TIME(final_time)
WRITE(*,*) 'Total Time:', final_time - initial_time
!==========================================================================================!
!=======================================Output File========================================!
!==========================================================================================!
OPEN(UNIT=83, FILE='output.dat')
WRITE(83,*) 'Sobol Numers = ', Nsobol
WRITE(83,*) 'Polynomial Degree= ', deg
WRITE(83,*) 'This calculation ran for (s): ', final_time - initial_time
CLOSE(UNIT=83)

END PROGRAM mat_eval
