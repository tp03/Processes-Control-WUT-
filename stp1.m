%stworzenie modelu w przestrzeni stanu na podstawie transmitancji
[A, B, C, D] = tf2ss([1, 6, 8], [1, 25/2, 51, 135/2]);

%powrotne wyliczenie transmitancji numerycznie
[num, den] = ss2tf(A, B, C, D);

%powrtotne wyliczenie transmitancji symbolicznie
syms s
G = C*inv((s*eye(3) - A))*B + D;

%wyznaczenie parametrów regulatora
s = -4;
x1_0 = 2;
x2_0 = 1;
x3_0 = -1;

K = acker(A, B, [s s s]);

%wykresy zadanie 3
set (0 , 'defaulttextinterpreter' , 'latex') ;
set (0 , 'DefaultLineLineWidth' ,1) ;
set (0 , 'DefaultStairLineWidth' ,1) ;

%sim("stp1_3sym.slx")
%figure(3);
%hold on;
%plot(out.x.time, out.x.signals.values);
%hold on;
%legend({'x1(t)', 'x2(t)', 'x3(t)'}, 'Location', 'northeast');
%xlabel('t(s)');
%ylabel('x(t)');
%print('reg_x_3.png' , '-dpng'   , '-r400')

%figure(4);
%hold on;
%plot(out.u.time, out.u.signals.values);
%hold on;
%xlabel('t(s)');
%ylabel('u(t)');
%print('reg_u_3.png' , '-dpng'   , '-r400')

%wyznaczenie parametrów obserwatora

s0 = -5;

x1_05 = 2;
x2_05 = 1;
x3_05 = -1;
x_ob = [0 0 0];

L = acker(A', C', [s0 s0 s0]);
%Dla x_ob = [0 0 0] s0 pomiędzy -4 a -5
%Dla [10 20 30] około 3.8, ale i tak jest średnio

%Wykresy obserwator

%sim("stp1_5sym.slx")
%figure(1);
%hold on;
%plot(out.x1.time, out.x1.Data);
%%hold on;
%plot(out.x1_obs.time, out.x1_obs.Data);
%hold on;
%legend({'x1(t)', 'x1(t) from observer'}, 'Location', 'northeast');
%xlabel('t(s)');
%ylabel('x1(t)');
%print('obs_x_1_32.png' , '-dpng'   , '-r400')

%figure(2);
%hold on;
%hold on;
%plot(out.x2.time, out.x2.Data);
%hold on;
%plot(out.x2_obs.time, out.x2_obs.Data);
%hold on;
%legend({'x2(t)', 'x2(t) from observer'}, 'Location', 'northeast');
%xlabel('t(s)');
%ylabel('x2(t)');
%print('obs_x_2_32.png' , '-dpng'   , '-r400')

%figure(3);
%hold on;
%plot(out.x3.time, out.x3.Data);
%hold on;
%plot(out.x3_obs.time, out.x3_obs.Data);
%hold on;
%legend({'x3(t)', 'x3(t) from observer'}, 'Location', 'northeast');
%xlabel('t(s)');
%ylabel('x3(t)');
%print('obs_x_3_32.png' , '-dpng'   , '-r400')

%Wykresy całego układu

%figure(1);
%hold on;
%plot(out.u.time, out.u.Data);
%hold on;
%xlabel('t(s)');
%ylabel('u(t)');
%print('u2.png' , '-dpng'   , '-r400')

%figure(2);
%hold on;
%plot(out.x.time, out.x.Data);
%hold on;
%legend('x1(t)', 'x2(t)', 'x3(t)', 'Location', 'northeast');
%xlabel('t(s)');
%ylabel('x(t)');
%print('x2.png' , '-dpng'   , '-r400')

%wyznaczenie parametrów regulatora z całkowaniem

se = -10;
B_gain = 1.5;

Ar = [-12.5 -51 -67.5 0;
    1 0 0 0;
    0 1 0 0;
    -1 -6 -8 0];
Br = [1*B_gain 0 0 0]';

Kr = acker(Ar, Br, [se se se se]);
Ke = Kr(4);
K2 = Kr(1:3);

%szybki s = -10, wolny se = -0.5

%Wykresy układu z całkowaniem

% figure(1);
% hold on;
% plot(out.u.time, out.u.Data);
% hold on;
% xlabel('t(s)');
% ylabel('u(t)');
% print('4_u.png' , '-dpng'   , '-r400')
% 
% figure(2);
% hold on;
% plot(out.x.time, out.x.Data);
% hold on;
% xlabel('t(s)');
% ylabel('x(t)');
% legend({'x1(t)', 'x2(t)', 'x3(t)'}, 'Location', 'northeast');
% print('4_x.png' , '-dpng'   , '-r400')
% 
% figure(3);
% hold on;
% plot(out.y.time, out.y.Data);
% hold on;
% xlabel('t(s)');
% ylabel('y(t)');
% print('4_y.png' , '-dpng'   , '-r400')
% 
% figure(4);
% hold on;
% plot(out.yzad.time, out.yzad.Data);
% hold on;
% xlabel('t(s)');
% ylabel('yzad(t)');
% print('42_yzad.png' , '-dpng'   , '-r400')