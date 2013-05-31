function y = proposal_pdf_rw( myu0, myu_prime )
global tau_square ;
y = 1 / sqrt( 2 * pi / tau_square ) * exp( -(1/2) * ( myu_prime - myu0 ) ^ 2 / tau_square ) ;
end