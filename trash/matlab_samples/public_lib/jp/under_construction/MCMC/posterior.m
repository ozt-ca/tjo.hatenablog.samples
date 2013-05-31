function y = posterior( x, data )
y = prior( x ) * likelihood( x, data ) ;
end