function y = selection( myu0, myu_prime, data )
u = rand( 1, 1 ) ; % (0,1)‹æŠÔ‚Ìˆê—l—”
bunsi = posterior( myu_prime, data ) * proposal_pdf( myu_prime, myu0 ) ;
bunbo = posterior( myu0 , data) * proposal_pdf( myu0, myu_prime ) ;
selection_p = min( 1, bunsi / bunbo ) ;
if u < selection_p
y = myu_prime ;
else
y = myu0 ;
end ;
end