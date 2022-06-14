%=======================================================
% INICO
%=======================================================

clear 
clear all
close all
clc

boolAudioRaw = false; %Plota o audio original
boolEspec = false; %Plota o espectrograma
boolRespImp = false; %Plota a resposta ao impulso
boolRespFreq = false; %Plota a resposta em frequencia
boolAudioBAIXA = false; %Plot do audio com filtro passa BAIXA
boolAudioALTA = false; %Plot do audio com filtro passa ALTA

pkg load signal;

[data,fs] = audioread('UnknownSound.wav');

if (boolAudioRaw == true)
aux = 0:length(data)-1;

fig = figure('Position',[300 100 1280 720],'color','w');
plot(aux, data);
grid();
title('Audio Original');
endif
%=====================================
% ESPECTROGRAMA DO AUDIO
%=====================================
if (boolEspec == true) 
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
endif
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

if (boolRespImp == true)
fig = figure('Position',[100 100 1280 720],'color','w');
stem(n1,hlp,'Marker','.');
title('Ideal Impulse response h_{lp}');
xlabel('Samples');
ylabel('Amplitude');
xlim([n1(1) n1(end)])
%Fim da parte do codigo do professor
endif

%===========================================================
% FILTRAGEM UTILIZNADO JANELA RETANGULAR KAISER (PASSA BAIXA)
%===========================================================

%Quantidades de coeficientes do filtro FIR
M = 101;
M1 = -(M-1)/2;
M2 = (M-1)/2;
Idx = (n1 >= M1) & (n1 <= M2);

w = ones(1, M);
h2 = hlp(Idx).*w;

%Atenuacao em decibeis
atenuacao = 100;

beta = 0.1102 * (atenuacao - 8.7);
w2 = kaiser(M, beta);

[H2 , f] = freqz(h2, 1, 500, fs);

%=================================================
% RESPOSTA EM FREQUENCIA (PASSA BAIXA)
%=================================================

Hw = fft(h2, 1000);
Hw = fftshift(Hw);

freq_plot = linspace(-fs/2, fs/2, length(Hw));

if (boolRespFreq == true)
fig = figure('Position',[100 100 1280 720],'color','w');
plot(freq_plot, abs(Hw));
title("Resposta em Frequencia");
grid();
xlabel("Hz");
ylabel("|H|");
endif
%=================================================
% SINAL FILTRADO (PASSA BAIXA)
%=================================================

x1 = filter(h2, 1, data);

t = 0:length(data)-1;

if (boolAudioBAIXA == true)
fig = figure('Position',[100 100 1280 720],'color','w');
l1 = plot(t/fs, data);
hold on
l2 = plot(t/fs, x1);
hold off
%legend([l1 l2], {"Raw", "Filtered"}, 'Location', 'best');
title("Sinal do Audio antes e depois do filtro (PASSA BAIXA)")
xticks([0.:0.25:max(t/fs)])
grid()
endif

if (boolEspec == true)
% number fft points for spectrogram (STFT)
nfft = 1024; 
% Number of samples for each window segment used in STFT 
WLength = round(.05*fs); 
% 80 percent overlap
PercentOverlap = 0.8; 
ax2 = subplot(3,1,[2 3]);
[Pxx,tPxx,f] = My_STFT(x1,fs,WLength,PercentOverlap);
Pxx_dB = 10*log10(Pxx);
surf(tPxx,f/1e3,Pxx_dB,'edgecolor','none');
axis tight, view(0,90)
tl = title('b) Signal spectrogram','Interpreter','latex');
xlabel('t(s)','Interpreter','latex');
ylabel('f(kHz)','Interpreter','latex');
yticks([0.:0.5:10.]);
%ylim([0.6 1.7]);
set(ax2,'TickLabelInterpreter','latex','FontSize',13);
endif

%=================================================
% SALVANDO O AUDIO (PASSA BAIXA)
%=================================================
audiowrite("Audio_passaBaixa.wav", x1, fs);

%===========================================================
% FILTRAGEM UTILIZNADO JANELA RETANGULAR KAISER (PASSA ALTA)
%===========================================================

%Frequencia de corte
fc = 6000;

%Parte retirara do codigo do Professor
wc = pi*fc/(fs/2);

N1 = 110;
n1 = -N1:N1;
NSamples = length(n1);

hlp = wc/pi*(sin(wc*n1))./(wc*n1);
hlp(n1==0) = wc/pi;

h2 = hlp(Idx).*w;

[~,Pos_M] = max(h2);
b_impulse = zeros(1,M);
b_impulse(Pos_M) = 1;
b_HP = b_impulse - h2;

x2 = filter(b_HP, 1, data);

if (boolAudioALTA == true)
fig = figure('Position',[100 100 1280 720],'color','w');
l1 = plot(t/fs, data);
hold on
l2 = plot(t/fs, x2);
hold off
%legend([l1 l2], {"Raw", "Filtered"}, 'Location', 'best');
title("Sinal do Audio antes e depois do filtro (PASSA ALTA)")
xticks([0.:0.25:max(t/fs)])
grid()
endif

if (boolEspec == true)
% number fft points for spectrogram (STFT)
nfft = 1024; 
% Number of samples for each window segment used in STFT 
WLength = round(.05*fs); 
% 80 percent overlap
PercentOverlap = 0.8; 
ax2 = subplot(3,1,[2 3]);
[Pxx,tPxx,f] = My_STFT(x2,fs,WLength,PercentOverlap);
Pxx_dB = 10*log10(Pxx);
surf(tPxx,f/1e3,Pxx_dB,'edgecolor','none');
axis tight, view(0,90)
tl = title('b) Signal spectrogram','Interpreter','latex');
xlabel('t(s)','Interpreter','latex');
ylabel('f(kHz)','Interpreter','latex');
yticks([0.:0.5:10.]);
%ylim([0.6 1.7]);
set(ax2,'TickLabelInterpreter','latex','FontSize',13);
endif

%=================================================
% SALVANDO O AUDIO (PASSA ALTA)
%=================================================
audiowrite("Audio_passaALTA.wav", x2, fs);

%=================================================
% PLOT DOS 3 AUDIOS
%=================================================
fig = figure('Position',[100 100 1280 720],'color','w');
hold on
l1 = plot(t/fs, data);
l3 = plot(t/fs, x2);
l2 = plot(t/fs, x1);
hold off
legend([l1 l2 l3], {"Raw", "PassaBaixa", "PassaALTA"}, 'Location', 'best');
title("Sinal do Audio Puro e apos os Filtros")
xticks([0.:0.25:max(t/fs)])
grid()
