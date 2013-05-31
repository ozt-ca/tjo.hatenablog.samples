function y = proposal_pdf( myu0, myu_prime )
global data ;
y = 1 / sqrt( 2 * pi / data(2) ) * exp( -(1/2) * ( myu_prime - data(1) ) ^ 2 / ( 1/data(2) ) ) ;
end