function y = likelihood( myu, data ) 
y = ( 1 / sqrt( 2*pi* ( 1/data(2)) ) ) * exp( -(1/2) * ( myu - data(1) ) ^ 2 / (1/data(2)) ) ;
end