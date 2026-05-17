% DSP PROJECT
% Luis F. Canaza Ccari
% 202427520
%% Load clean signals from workspace
x = out.q(:,1);   % X position
y = out.q(:,2);   % Y position
z = out.q(:,3);   % Z position

t = out.t(:);
x = x(:);
y = y(:);
z = z(:);

% Sampling parameters
Ts = t(2) - t(1);      % sampling period
Fs = 1/Ts;             % sampling frequency
N  = length(t);        % number of samples
T_total = t(end) - t(1); % total signal duration

% Display sampling information
fprintf('===== SAMPLING INFO =====\n');
fprintf('Ts = %.6f s\n', Ts);
fprintf('Fs = %.2f Hz\n', Fs);
fprintf('N  = %d samples\n', N);
fprintf('Total time = %.2f s\n', T_total);

figure('Name','Clean Position Signals','Color','w');

subplot(3,1,1);
plot(t, x, 'b', 'LineWidth', 2);grid on;hold on
plot(t, x_deseado,'--','LineWidth',1.5,'Color','k');grid on;hold on
grid on;
xlabel('Time (s)');
ylabel('x (m)');
title('Clean X Position');

subplot(3,1,2);
plot(t, y, 'b', 'LineWidth', 2);grid on;hold on
plot(t, y_deseado,'--','LineWidth',1.5,'Color','k');grid on;hold on
grid on;
xlabel('Time (s)');
ylabel('y (m)');
title('Clean Y Position');

subplot(3,1,3);
plot(t, z, 'b', 'LineWidth', 2);grid on;hold on
plot(t, z_deseado,'--','LineWidth',1.5,'Color','k');grid on;hold on
grid on;
xlabel('Time (s)');
ylabel('z (m)');
title('Clean Z Position');

%% SENSOR MODEL
% Reproducibilidad del ruido aleatorio
rng(1);

% GPS model for x and y
bias_x = 0.02;     
bias_y = -0.015;   
sigma_x = 0.05;     
sigma_y = 0.05;     

% Barometer model for z
bias_z = 0.03;      
sigma_z = 0.03;     

% High-frequency sinusoidal disturbance
A_x = 0.03;         
A_y = 0.03;         
A_z = 0.02;         

f_x = 20;           
f_y = 25;           
f_z = 15;           

% RANDOM NOISE
nx = sigma_x * randn(N,1);
ny = sigma_y * randn(N,1);
nz = sigma_z * randn(N,1);

% SINUSOIDAL DISTURBANCE
dx = A_x * sin(2*pi*f_x*t);
dy = A_y * sin(2*pi*f_y*t);
dz = A_z * sin(2*pi*f_z*t);

% FINAL SENSOR MEASUREMENTS
x_sensor = x + bias_x + nx + dx;
y_sensor = y + bias_y + ny + dy;
z_sensor = z + bias_z + nz + dz;

% NOISY SENSOR POSITION SIGNALS

figure('Name','Noisy Sensor Position Signals','Color','w');
subplot(3,1,1);
plot(t, x_sensor, 'r', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('x_{sensor} (m)');
title('Noisy X Position Measurement');
ylim([-2.8 2.8]);

subplot(3,1,2);
plot(t, y_sensor, 'r', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('y_{sensor} (m)');
title('Noisy Y Position Measurement');
ylim([-2.8 2.8]);

subplot(3,1,3);
plot(t, z_sensor, 'r', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('z_{sensor} (m)');
title('Noisy Z Position Measurement');

% VISUALIZATION AND COMPARISON

figure('Name','Phase 3 - Clean vs Sensor Signals','Color','w');

subplot(3,1,1);
plot(t, x_sensor, 'r', 'LineWidth', 2); hold on;
plot(t, x, 'b', 'LineWidth', 2); hold on;
grid on;
xlabel('Time (s)');
ylabel('x (m)');
title('X Position: Clean vs Sensor');
legend('Clean x','Sensor x');
ylim([-2.8 2.8]);

subplot(3,1,2);
plot(t, y_sensor, 'r', 'LineWidth', 2); hold on;
plot(t, y, 'b', 'LineWidth', 2); hold on;
grid on;
xlabel('Time (s)');
ylabel('y (m)');
title('Y Position: Clean vs Sensor');
legend('Clean y','Sensor y');
ylim([-2.8 2.8]);

subplot(3,1,3);
plot(t, z_sensor, 'r', 'LineWidth', 2); hold on;
plot(t, z, 'b', 'LineWidth', 2); hold on;
grid on;
xlabel('Time (s)');
ylabel('z (m)');
title('Z Position: Clean vs Sensor');
legend('Clean z','Sensor z');


%% FFT ANALYSIS
% Remove DC component
x_d = x - mean(x);
y_d = y - mean(y);
z_d = z - mean(z);

x_sensor_d = x_sensor - mean(x_sensor);
y_sensor_d = y_sensor - mean(y_sensor);
z_sensor_d = z_sensor - mean(z_sensor);

% FFT of clean signals
X = fft(x_d);
Y = fft(y_d);
Z = fft(z_d);

% FFT of sensor signals
X_sensor = fft(x_sensor_d);
Y_sensor = fft(y_sensor_d);
Z_sensor = fft(z_sensor_d);

% Frequency axis
f = Fs*(0:floor(N/2))/N;

X_mag = 2*abs(X(1:floor(N/2)+1))/N;
Y_mag = 2*abs(Y(1:floor(N/2)+1))/N;
Z_mag = 2*abs(Z(1:floor(N/2)+1))/N;

X_sensor_mag = 2*abs(X_sensor(1:floor(N/2)+1))/N;
Y_sensor_mag = 2*abs(Y_sensor(1:floor(N/2)+1))/N;
Z_sensor_mag = 2*abs(Z_sensor(1:floor(N/2)+1))/N;

X_mag(1) = X_mag(1)/2;
Y_mag(1) = Y_mag(1)/2;
Z_mag(1) = Z_mag(1)/2;

X_sensor_mag(1) = X_sensor_mag(1)/2;
Y_sensor_mag(1) = Y_sensor_mag(1)/2;
Z_sensor_mag(1) = Z_sensor_mag(1)/2;

% FFT OF CLEAN POSITION SIGNALS
figure('Name','FFT of Clean Position Signals','Color','w');

subplot(3,1,1);
plot(f, X_mag, 'b', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('FFT of Clean X Position');
xlim([0 50]);
ylim([0 0.05]);
subplot(3,1,2);
plot(f, Y_mag, 'b', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('FFT of Clean Y Position');
xlim([0 50]);
ylim([0 0.05]);
subplot(3,1,3);
plot(f, Z_mag, 'b', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Z(f)|');
title('FFT of Clean Z Position');
xlim([0 50]);
ylim([0 0.05]);

% FFT OF NOISY SENSOR POSITION SIGNALS
figure('Name','FFT of Noisy Sensor Position Signals','Color','w');

subplot(3,1,1);
plot(f, X_sensor_mag, 'r', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X_{sensor}(f)|');
title('FFT of Noisy X Position Measurement');
xlim([0 50]);
ylim([0 0.05]);
subplot(3,1,2);
plot(f, Y_sensor_mag, 'r', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Y_{sensor}(f)|');
title('FFT of Noisy Y Position Measurement');
xlim([0 50]);
ylim([0 0.05]);
subplot(3,1,3);
plot(f, Z_sensor_mag, 'r', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Z_{sensor}(f)|');
title('FFT of Noisy Z Position Measurement');
xlim([0 50]);
ylim([0 0.05]);

% Plot FFT comparison
figure('Name','Phase 4 - FFT Analysis','Color','w');
subplot(3,1,1);
plot(f, X_mag, 'b', 'LineWidth', 2); hold on;
plot(f, X_sensor_mag, 'r', 'LineWidth', 2.0);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('FFT of X Position');
legend('Clean x','Sensor x');
xlim([0 50]);
ylim([0 0.1]);
subplot(3,1,2);
plot(f, Y_mag, 'b', 'LineWidth', 2); hold on;
plot(f, Y_sensor_mag, 'r', 'LineWidth', 2.0);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('FFT of Y Position');
legend('Clean y','Sensor y');
xlim([0 50]);
ylim([0 0.1]);
subplot(3,1,3);
plot(f, Z_mag, 'b', 'LineWidth', 2); hold on;
plot(f, Z_sensor_mag, 'r', 'LineWidth', 2.0);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Z(f)|');
title('FFT of Z Position');
legend('Clean z','Sensor z');
xlim([0 50]);
ylim([0 0.1]);


%% IIR LOW-PASS FILTER DESIGN

fc = 8;              
filter_order = 4;  

Wn = fc/(Fs/2);

% Butterworth low-pass filter
[b, a] = butter(filter_order, Wn, 'low');

% IIR FILTER FREQUENCY RESPONSE
figure('Name','IIR Filter Frequency Response','Color','w');
freqz(b, a, 2048, Fs);
title('Frequency Response of the Butterworth IIR Low-Pass Filter');


%% FILTER APPLICATION
x_filt = filtfilt(b, a, x_sensor);
y_filt = filtfilt(b, a, y_sensor);
z_filt = filtfilt(b, a, z_sensor);

% TIME-DOMAIN COMPARISON
figure('Name','IIR Filter - Time Domain Comparison','Color','w');

subplot(3,1,1);
plot(t, x, 'g', 'LineWidth', 2); hold on;
plot(t, x_sensor, 'r', 'LineWidth', 2);
plot(t, x_filt, 'b', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('x (m)');
title('X Position');
legend('Clean x','Sensor x','Filtered x (IIR)');
ylim([-2.8 2.8]);

subplot(3,1,2);
plot(t, y, 'g', 'LineWidth', 2); hold on;
plot(t, y_sensor, 'r', 'LineWidth', 2);
plot(t, y_filt, 'b', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('y (m)');
title('Y Position');
legend('Clean y','Sensor y','Filtered y (IIR)');
ylim([-2.8 2.8]);

subplot(3,1,3);
plot(t, z, 'g', 'LineWidth', 2); hold on;
plot(t, z_sensor, 'r', 'LineWidth', 2);
plot(t, z_filt, 'b', 'LineWidth', 2);
grid on;
xlabel('Time (s)');
ylabel('z (m)');
title('Z Position');
legend('Clean z','Sensor z','Filtered z (IIR)');

% FINAL SPECTRAL COMPARISON

x_filt_d = x_filt - mean(x_filt);
y_filt_d = y_filt - mean(y_filt);
z_filt_d = z_filt - mean(z_filt);

% FFT of filtered signals
X_filt = fft(x_filt_d);
Y_filt = fft(y_filt_d);
Z_filt = fft(z_filt_d);

X_filt_mag = 2*abs(X_filt(1:floor(N/2)+1))/N;
Y_filt_mag = 2*abs(Y_filt(1:floor(N/2)+1))/N;
Z_filt_mag = 2*abs(Z_filt(1:floor(N/2)+1))/N;

X_filt_mag(1) = X_filt_mag(1)/2;
Y_filt_mag(1) = Y_filt_mag(1)/2;
Z_filt_mag(1) = Z_filt_mag(1)/2;

% FREQUENCY-DOMAIN COMPARISON

figure('Name','IIR Filter - Frequency Domain Comparison','Color','w');
subplot(3,1,1);
plot(f, X_mag, 'g', 'LineWidth', 2); hold on;
plot(f, X_sensor_mag, 'r', 'LineWidth', 2.0);
plot(f, X_filt_mag, 'b', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('FFT of X Position');
legend('Clean x','Sensor x','Filtered x (IIR)');
xlim([0 50]);
ylim([0 0.05]);

subplot(3,1,2);
plot(f, Y_mag, 'g', 'LineWidth', 2); hold on;
plot(f, Y_sensor_mag, 'r', 'LineWidth', 2.0);
plot(f, Y_filt_mag, 'b', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title('FFT of Y Position');
legend('Clean y','Sensor y','Filtered y (IIR)');
xlim([0 50]);
ylim([0 0.05]);

subplot(3,1,3);
plot(f, Z_mag, 'g', 'LineWidth', 2); hold on;
plot(f, Z_sensor_mag, 'r', 'LineWidth', 2.0);
plot(f, Z_filt_mag, 'b', 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('|Z(f)|');
title('FFT of Z Position');
legend('Clean z','Sensor z','Filtered z (IIR)');
xlim([0 50]);
ylim([0 0.05]);