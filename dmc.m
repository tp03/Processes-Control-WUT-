%dobranie współczynników
sample_size = 200;
D = 70;
N = 20;
Nu = 2;
lambda = 0.3;
step_time = 3;
step_value = 1;

%konfiguracja niemierzalnego zakłócenia
disturbance_time = 15;
disturbance_value = 0;
d = ones(sample_size, 1).*disturbance_value;

for i = 1:disturbance_time-1
    d(i) = 0;
end

%określenie współczynników obiektu
K = 7.7;
T0 = 5;
Tp = 0.5;


%wyliczenie transmitancji
gc = tf(K,[10.0485 6.98 1],'IODelay',T0); 
gd = c2d(gc,Tp);  

[num, den] = tfdata(gd, 'v');

a1 = num(2);
a0 = num(3);
b1 = den(2);
b0 = den(3);

a1_prime = 0.0854;
a0_prime = 0.0761;
b1_prime = -1.6856;
b0_prime = 0.7066;

%wyznaczenie odpowiedzi skokowej
y_prime = zeros(sample_size, 1);
u_prime = ones(sample_size, 1);

for i = 1:step_time-1
    u_prime(i) = 0;
end

y_prime(12) = -b1_prime*y_prime(11) - b0_prime*y_prime(10) + a1_prime*u_prime(1);
 
for i = 13:sample_size
     y_prime(i) = -b1_prime*y_prime(i-1) - b0_prime*y_prime(i-2) + a1_prime*u_prime(i-11) + a0_prime*u_prime(i-12);
end

% stairs(u_prime);
% hold on;
% stairs(y_prime);
% xlabel('T [k]')
% ylabel('Y')
% legend('wartość sterowania', 'obiekt z regulatorem PID', 'Location','northwest');
% title('')
% print('zad5a.png' , '-dpng'   , '-r400')


%inicjalizacja wektora wartości zadanych
yzad = ones(sample_size, 1).*step_value;
for i = 1:step_time-1
    yzad(i) = 0;
end

%inicjalizacja wektora s odpowiedzi skokowych
s = y_prime(step_time+1:D+step_time);


%wyznaczenie macierzy M
M = zeros(N, Nu);

for i = 1:Nu
     for j = 1:N-i+1
         M(i-1+j, i) = s(j);
     end
end

%wyznaczenie macierzy Mp
Mp = zeros(N, D-1);

for i = 1:D-1
    for j = 1:N
        if i+j > length(s)
            Mp(j, i) = s(end) - s(i);
        else
            Mp(j, i) = s(i+j) - s(i);
        end
    end
end

%wyznaczenie macierzy K
K = inv(M'*M + lambda*eye(Nu)) * M';

%wektor wyjścia obiektu w chwili k
y = zeros(sample_size, 1);
%wektor wartości sterowania w chwili k
u = zeros(sample_size, 1);
%wektor zmiany wartości sterowania w chwili k
du = zeros(sample_size, 1);

%główna pętla
for i = 1:sample_size

    %wyznaczenie wektora dup D-1 poprzednich zmian sterowania
    dup = zeros(D-1, 1);
    for j = 1:D-1
        if i-j > 0
            dup(j) = du(i-j);
        else
            dup(j) = 0;
        end
    end

    %wyznaczenie wartości wyjścia obiektu w chwili k
    if i > 0 && i < (T0/Tp + 2)
        y(i) = d(i);
    elseif i == (T0/Tp + 2)
        y(i) = -b1*y(i-1) - b0*y(i-2) + a1*u(i-(T0/Tp + 1)) + d(i);
    else
        y(i) = -b1*y(i-1) - b0*y(i-2) + a1*u(i-(T0/Tp + 1)) + a0*u(i-(T0/Tp + 2)) + d(i);
    end

    %wektor wartości wyjścia obiektu w chwili k
    yk = ones(N, 1).*y(i);
    %wektor wartości zadanej obiektu w chwili k
    yz = ones(N, 1).*yzad(i);

    %obliczenie zmiany sterowania w chwili k
    dukk = K(1,:)*(yz-yk-Mp*dup);
    du(i) = dukk;

    %obliczenie wartości sterowania w chwili k
    if i == 1
        u(i) = dukk;
    else
        u(i) = u(i-1) + dukk;
    end
end

figure(1)
stairs(yzad);
hold on
stairs(y);
xlabel('T [k]')
ylabel('Y')
legend('wartość zadana', 'wyjście obiektu z regulatorem DMC', 'Location','northeast');
title('')
print('zad8a.png' , '-dpng'   , '-r400')
% figure(2)
% hold on
% stairs(u);
% xlabel('T[k]');
% ylabel('U');
% legend('sterowanie dla lambda = 0.1', 'sterowanie dla lambda = 0.3', 'sterowanie dla lambda = 0.7', 'sterowanie dla lambda = 1', 'Location','southeast');
% title('');
% print('zad5du.png', '-dpng', '-r400');
