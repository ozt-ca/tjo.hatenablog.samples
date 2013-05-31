function y = proposal_ran_rw( myu0 )
global tau_square ;
y = myu0 + sqrt( tau_square ) * randn( 1 ) ;
end