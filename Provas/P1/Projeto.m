
%=======================================================
% INICO
%=======================================================

clear 
clear all
close all
clc

pkg load signal;

[data,fs] = audioread('Unknown_DTMF01.wav');

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
yticks([0.:0.05:2.]);
ylim([0.6 1.7]);
set(ax2,'TickLabelInterpreter','latex','FontSize',13);

%===============================
% FFT DO AUDIO
%===============================
data_fft = fft(data);

mag = abs(data_fft);
fase = angle(data_fft);

mag_filtered = mag;
mag_filtered(mag_filtered<50) = 0;

fase_filtered = fase;
%fase_filtered(fase_filtered<2) = 0;

%Codigo do Professor Ignacio
Nfft = length(data_fft);
w = linspace(0,1,Nfft);
w1 = linspace(-0.5,0.5,Nfft);

P2 = abs(data_fft/Nfft);
P1 = P2(1:Nfft/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% create frequency vector
% know that the high frequency 
%contained in sampled signal is fs/2 
% fs/2 ->(eqivalent pi/2)
f = linspace(0,fs/2,Nfft/2+1);
%FIM Codigo do Professor Ignacio

fig = figure('Position',[300 100 1280 720],'color','w');
subplot(2,2,1), plot(f, mag(1:length(f))), title('Magnitude');
subplot(2,2,2), plot(w, fase), title('Fase');
subplot(2,2,3), plot(w, mag_filtered), title('Magnitude Filtrada');
subplot(2,2,4), plot(w,fase_filtered), title('Fase Filtrada');

%=====================================
% FFT INVERSA DO AUDIO
%=====================================
data_recov = data_fft;

data_recov = mag_filtered.*exp(1i*fase_filtered);
data_recov = real(ifft(data_recov));

%data_recov = conv(data,h);
%data_recov = data_recov(1:(length(data)));

fig = figure('Position',[300 100 1280 720],'color','w');
plot(aux, data_recov);

fig = figure('Position',[300 100 1280 720],'color','w');
[Pxx,tPxx,f] = My_STFT(data_recov,fs,WLength,PercentOverlap);
Pxx_dB = 10*log10(Pxx);
surf(tPxx,f/1e3,Pxx_dB,'edgecolor','none');
axis tight, view(0,90)
tl = title('b) Signal spectrogram','Interpreter','latex');
xlabel('t(s)','Interpreter','latex');
ylabel('f(kHz)','Interpreter','latex');
yticks([0.:0.05:2.]);
ylim([0.6 1.7]);
set(ax2,'TickLabelInterpreter','latex','FontSize',13);