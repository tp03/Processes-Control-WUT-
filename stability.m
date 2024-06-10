%PID
Tp = 1:0.1:2;
Kp = [1.96, 1.87, 1.78, 1.7, 1.64, 1.57, 1.51, 1.45, 1.4, 1.34, 1.31];

% figure(1)
% plot(Tp, Kp);
% xlabel('T/T_{nom}')
% ylabel('K/K_{nom}')
% title('')
% axis([1 2 0 2.5]);
% hold on

%DMC

Td = 1:0.1:2;
Kd = [2.013, 1.97, 1.3, 0.714, 0.36, 0.19, 0.16, 0.14, 0.14, 0.14, 0.14];

figure(1);
plot(Td, Kd);
xlabel('T/T_{nom}')
ylabel('K/K_{nom}')
title('')
axis([1 2 0 4]);
hold on

%GPC

Kg = [2.22, 3.94, 0.07, 0.04, 0.03, 0.025, 0.021, 0.018, 0.016, 0.014, 0.013];




plot(Td, Kg);
legend('DMC', 'GPC');
print('zad9.png' , '-dpng'   , '-r400')