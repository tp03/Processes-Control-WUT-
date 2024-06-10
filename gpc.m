%wyznaczenie współczynników algorytmu
sample_size = 200;
N = 20;
Nu = 2;
lambda = 0.3;
step_time = 3;
step_value = 1;

%wyznaczenie współczynników obiektu
K = 7.7;
T0 = 5;
Tp = 0.5;

%inicjalizacja niemierzalnych zakłóceń
disturbance_time = 15;
disturbance_value = 0;
ds = ones(sample_size, 1).*disturbance_value;
for i = 1:disturbance_time-1
    ds(i) = 0;
end

%wyznaczenie transmitancji obiektu
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

%wyznaczenie odpowiedzi skokowej obiketu
y_prime = zeros(sample_size, 1);
u_prime = ones(sample_size, 1);

for i = 1:step_time-1
    u_prime(i) = 0;
end

y_prime(12) = -b1_prime*y_prime(11) - b0_prime*y_prime(10) + a1_prime*u_prime(1);

for i = 13:sample_size
    y_prime(i) = -b1_prime*y_prime(i-1) - b0_prime*y_prime(i-2) + a1_prime*u_prime(i-11) + a0_prime*u_prime(i-12);
end

%inicjalizacja wartości zadanej obiektu
yzad = ones(sample_size, 1).*step_value;
for i = 1:step_time-1
    yzad(i) = 0;
end

%inicjalizacja wektora s
s = y_prime(step_time+1:N+step_time);

%wyznaczenie macierzy M
M = zeros(N, Nu);

for i = 1:Nu
    for j = 1:N-i+1
        M(i-1+j, i) = s(j);
    end
end

%wyzanczenie macierzy K
K = inv(M'*M + lambda*eye(Nu)) * M';

%inicjalizacja wektora wartości wyjścia
y = zeros(sample_size+N, 1);
%inicjalizacja wektora sterowań
u = zeros(sample_size, 1);
%inicjalizacja wartości predykcji wyjścia w chwili k z chwili k-1
y_prev = 0;
%inicjalizacja wektora zakłóceń
d = zeros(sample_size, 1);

%główna pętla
for i = 1:sample_size

    %wyznaczenie wyjścia obiketu
    if i > 0 && i < (T0/Tp + 2)
        y(i) = ds(i);
    elseif i == (T0/Tp + 2)
        y(i) = -b1*y(i-1) - b0*y(i-2) + a1*u(i-(T0/Tp + 1)) + ds(i);
    else
        y(i) = -b1*y(i-1) - b0*y(i-2) + a1*u(i-(T0/Tp + 1)) + a0*u(i-(T0/Tp + 2)) + ds(i);
    end
    
    %wyznaczenie wektora wartości zadanych
    yz = ones(N, 1).*yzad(i);
    %inicjalizacja wektora horyzontu predykcji
    y0 = zeros(N, 1);
    %wyznaczenie wartości zakłócenia
    d(i) = y(i) - y_prev;

    %pętla wyznaczająca horyzont predykcji
    for k = 1:N
        
        %inicjalizacja wartości y(k-1) i y(k-2)
        y_kminus1 = 0;
        y_kminus2 = 0;

        %sprawdzenie i przypisanie wartości y, gdy któryś z nich wyjdzie
        %poza y(k)
        for j = 1:k
            if k-1 == j
                y_kminus1 = y0(j);
            end
            if k-2 == j
                y_kminus2 = y0(j);
            end
        end

        %przypisanie wartości y(k+p-1), jeśli jest niezerowa
        if y_kminus1 == 0
            y_kminus1 = y(i+k-1);
        end
        %przypisanie wartości y(k+p-2), jeśli jest niezerowa
        if y_kminus2 == 0 && i+k-2 >=1
            y_kminus2 = y(i+k-2);
        end

        %sprawdzanie wartości u(k-11) i u(k-12)

        %przypisanie u(k+p-11) do zera, gdy jest ono przed chwilą dyskretną
        %pierwszą
        if i+k-(T0/Tp + 1) <= 0
            u_kminus11 = 0;
        %przypisanie u(k+p-11) do u(k-1), gdy p >= 0
        elseif k-(T0/Tp + 1) >= 0 && i > 1
            u_kminus11 = u(i-1);
        else
            u_kminus11 = u(i+k-(T0/Tp + 1));
        end

        %przypisanie u(k+p-12) do zera, gdy jest ono przed chwilą dyskretną
        %pierwszą
        if i+k-(T0/Tp + 2) <= 0
            u_kminus12 = 0;
        %przypisanie u(k+p-12) do u(k-1), gdy p >= 0
        elseif k-(T0/Tp + 2) >= 0 && i > 1
            u_kminus12 = u(i-1);
        else
            u_kminus12 = u(i+k-(T0/Tp + 2));
        end

        %obliczenie y^0(k+p|k)
        y0(k) = -b1*y_kminus1 - b0*y_kminus2 + a1*u_kminus11 + a0*u_kminus12 + d(i) + ds(i);
    end

    %obliczenie przyrostu sterowania
    dukk = K(1,:)*(yz-y0);

    %obliczenie wartości sterowania
    if i == 1
        u(i) = dukk;
    else
        u(i) = u(i-1) + dukk;
    end

    %przypisanie y(k|k-1) do kolejnej iteracji
    y_prev = y0(1)-d(i);
end

figure(1)
hold on
stairs(y(1:sample_size))
xlabel('T [k]')
ylabel('Y')
legend('wartość zadana', 'wyjście obiektu z regulatorem DMC', 'wyjście obiektu z regulatorem GPC', 'Location','southeast');
title('')
print('zad8a.png' , '-dpng'   , '-r400')