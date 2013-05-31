function mh
x = [ 5.293437097;
6.786756911;
6.698467713;
5.216369926;
4.279878011;
3.550147211;
4.901963292;
4.477433903;
4.014444256;
5.7623089 ]
% x_mean が 5.0981 になってる。
x_mean = mean( x )
% サンプル数
n = size( x, 1 )
% 繰り返し回数
draw_no = 10000 ;
% 捨てるサンプル数
burn_in = 1000 ;
% 以下、MH アルゴリズムによるサンプリング
global data ;
data = [ 5.0981 10 ] ;
myu0 = 0 ;
for i = 1 : draw_no ;
myu_prime = proposal_ran( [] ) ;
y(i) = selection( myu0, myu_prime, data ) ;
if y(i) == myu0
hantei(i) = 0 ;
else
hantei(i) = 1 ;
end
myu0 = y(i) ;
time( i ) = i ;
end ;
saitakuritu = sum( hantei ) / ( draw_no - burn_in )
% 以下、サンプリング結果の図示
subplot( 2,1,1 )
plot( time( burn_in : draw_no ), y( burn_in : draw_no ) );
subplot( 2,1,2 )
hist( y( burn_in : draw_no ), 3:0.03:7 );
end