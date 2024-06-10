%1

%wyznaczenie transmitancji dyskretnej
gc = tf(7.7,[10.0485 6.98 1],'IODelay',5.5); 
gd = c2d(gc,0.5);

set (0 , 'defaulttextinterpreter' , 'latex') ;
set (0 , 'DefaultLineLineWidth' ,1) ;
set (0 , 'DefaultStairLineWidth' ,1) ;

%porównanie na wykresie obu transmitacji

% step(gc, '-r');
% hold on;
% step(gd);
% hold on
% legend('transmitancja ciągła', 'transmitancja dyskretna', 'Location', 'southeast');
% xlabel('T [s]')
% ylabel('Y')
% title('')
% print('zad1.png' , '-dpng'   , '-r400')

%dobieranie regulatora pid

%0.17118, 10, 2.4, 10
C = pidstd(0.14, 9, 2.4, 10);

t = 0:0.5:100;
% figure(3);
% step(feedback(C*gc, 1), t);
% hold on
% xlabel('T [s]')
% ylabel('Y')
% title('')
% print('zad3-2.png' , '-dpng'   , '-r400')

[num, den] = tfdata(gd, 'v');

a1 = 0.08542275175;
a0 = 0.0760847668;
b1 = 1.68560735;
b0 = 0.7065823524;

%wyznaczenie odpowiedzi skokowej równania różnicowego

y_prime = zeros(100, 1);
u_prime = ones(100, 1);

y_prime(12) = b1*y_prime(11) - b0*y_prime(10) + a1*u_prime(1);

for i = 13:100
    if i == 12
        y_prime(i) = b1*y_prime(i-1) - b0*y_prime(i-2) + a1*u_prime(i-11);
    else
        y_prime(i) = b1*y_prime(i-1) - b0*y_prime(i-2) + a1*u_prime(i-11) + a0*u_prime(i-12);
    end
end

%step(gd);
%hold on
%plot(0.5:0.5:50, y_prime);