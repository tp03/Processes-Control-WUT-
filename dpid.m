%wyznaczenie współczynników obiektu i algorytmu
K = 7.7;
T0 = 5;
Tp = 0.5;
sample_size = 150;
step_time = 3;
step_value = 1;

%wektor wyjść obiektu
y = zeros(sample_size, 1);
%wektor wartości sterowania obiektu
u = zeros(sample_size, 1);
%wektor uchybów obiektu
e = zeros(sample_size, 1);

%inicjalizacja wektora wartości zadanych
yzad = ones(sample_size, 1).*step_value;
for i = 1:step_time-1
    yzad(i) = 0;
end

%współczynniki PIDa
Kr = 0.14;
Ti = 9;
Td = 2.4;

%wyznaczenie transmitacnji obiektu
gc = tf(K,[10.0485 6.98 1],'IODelay',T0); 
gd = c2d(gc,Tp);

[num, den] = tfdata(gd, 'v');

a1 = num(2);
a0 = num(3);
b1 = den(2);
b0 = den(3);

%wyzanczenie współczynników cyfrowego PIDa
r0 = Kr*(1 + Tp/(2*Ti) + Td/Tp);
r1 = Kr*(-1 + Tp/(2*Ti) - 2*Td/Tp);
r2 = Kr*Td/Tp;


%główna pętla
for i = 1:sample_size

    %wyznaczenie wartości wyjścia obiektu
    if i > 0 && i < (T0/Tp + 2)
        y(i) = 0;
    elseif i == (T0/Tp + 2)
        y(i) = -b1*y(i-1) - b0*y(i-2) + a1*u(i-(T0/Tp + 1));
    else
        y(i) = -b1*y(i-1) - b0*y(i-2) + a1*u(i-(T0/Tp + 1)) + a0*u(i-(T0/Tp + 2));
    end

    %wyznaczenie uchybu
    e(i) = yzad(i) - y(i);

    %wyznaczenie wartości sterowania
    if i == 1
        u(i) = r0*e(i);
    elseif i == 2
        u(i) = r1*e(i-1) + r0*e(i) + u(i-1);
    else
        u(i) = r2*e(i-2) + r1*e(i-1) + r0*e(i) + u(i-1);
    end
end

figure(1)
hold on
stairs(y);
hold on
xlabel('T [k]')
ylabel('Y')
legend('wartość zadana', 'obiekt z regulatorem DMC', 'obiekt z regulatorem PID', 'Location','southeast');
title('')
print('zad6a.png' , '-dpng'   , '-r400')
