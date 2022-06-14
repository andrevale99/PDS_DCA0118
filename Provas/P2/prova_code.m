%=======================================================
% INICO
%=======================================================

clear 
clear all
close all
clc

pkg load signal;

[data,fs] = audioread('UnknownSound.wav');

aux = 0:length(data)-1;

fig = figure('Position',[300 100 1280 720],'color','w');
plot(aux, data);
grid();
title('Audio Original');

%=====================================
% ESPECTROGRAMA DO AUDIO
%=====================================
% number fft points for spectrogram (STFT)
nfft = 1024; 
% Number of samples for each window segment used in STFT 
WLength = round(.05*fs); 
% 80 percent overlap
PercentOverlap = 0.8; 
ax2 = subplot(3,1,[2 3]);
[Pxx,tPxx,f] = My_STFT(data,fs,WLength,PercentOverlap);
Pxx_dB = 10*log10(Pxx);
surf(tPxx,f/1e3,Pxx_dB,'edgecolor','none');
axis tight, view(0,90)
tl = title('b) Signal spectrogram','Interpreter','latex');
xlabel('t(s)','Interpreter','latex');
ylabel('f(kHz)','Interpreter','latex');
yticks([0.:0.5:10.]);
%ylim([0.6 1.7]);
set(ax2,'TickLabelInterpreter','latex','FontSize',13);

%=================================================
% RESPOSTA AO IMPULSO
%=================================================

%Frequencia de corte
fc = 3500;

%Parte retirara do codigo do Professor
wc = pi*fc/(fs/2);

N1 = 110;
n1 = -N1:N1;
NSamples = length(n1);

hlp = wc/pi*(sin(wc*n1))./(wc*n1);
hlp(n1==0) = wc/pi;

fig = figure('Position',[100 100 1280 720],'color','w');
stem(n1,hlp,'Marker','.');
title('Ideal Impulse response h_{lp}');
xlabel('Samples');
ylabel('Amplitude');
xlim([n1(1) n1(end)])
%Fim da parte do codigo do professor


%=================================================
% FILTRAGEM UTILIZNADO JANELA RETANGULAR KAISER
%=================================================

%Quantidades de coeficientes do filtro FIR
qtd_coefs = 101;
M1 = -(qtd_coefs-1)/2;
M2 = (qtd_coefs-1)/2;
Idx = (n1 >= M1) & (n1 <= M2);

w = ones(1, qtd_coefs);
h2 = hlp(Idx).*w;

%Atenuacao em decibeis
atenuacao = 100;

beta = 0.1102 * (atenuacao - 8.7);
w2 = kaiser(qtd_coefs, beta);

[H2 , f] = freqz(h2, 1, 500, fs);

%=================================================
% RESPOSTA EM FREQUENCIA
%=================================================

Hw = fft(h2, 1000);
Hw = fftshift(Hw);

freq_plot = linspace(-fs/2, fs/2, length(Hw));

fig = figure('Position',[100 100 1280 720],'color','w');
plot(freq_plot, abs(Hw));
title("Resposta em Frequencia");
grid();
xlabel("Hz");
ylabel("|H|");

%=================================================
% SINAL FILTRADO
%=================================================

x1 = filter(h2, 1, data);

t = 0:length(data)-1;

fig = figure('Position',[100 100 1280 720],'color','w');
l1 = plot(t/fs, data)
hold on
l2 = plot(t/fs, x1);
hold off
%legend([l1 l2], {"Raw", "Filtered"}, 'Location', 'best');
title("Sinal do Audio antes e depois do filtro")
xticks([0.:0.25:max(t/fs)])
grid()

%=================================================
% SALVANDO O AUDIO
%=================================================
audiowrite("Audio_passaBaixa.wav", x1, fs);