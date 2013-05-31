function y = proposal_ran( myu0 )
global data ;
y = data( 1 ) + sqrt( 1/data(2) ) * randn( 1 ) ;
end