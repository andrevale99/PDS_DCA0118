function [Pxx,tPxx,f] = My_STFT(x,fs,windowLen,PercentOverlap)
    NSamples = length(x);
    %windowLen; % Window length in samples
    overlap = round(PercentOverlap*windowLen); % overlap between segments in samples
    nfft = 1024; % number of points in frequency for DFT
    Step = windowLen - overlap;
    EndSamples = windowLen:Step:NSamples;
    StartSamples = EndSamples - windowLen +1;
    f = linspace(0,fs/2,nfft/2+1);
    tPxx = 0.5*(StartSamples + EndSamples)/fs;
    NSteps = length(tPxx);

    % STFT implementation
    Pxx = zeros(nfft/2+1,NSteps);
    Window = hamming(windowLen);

    for iStep = 1:NSteps
        xWindow = x(StartSamples(iStep):EndSamples(iStep)).*Window;
        X = fft(xWindow,nfft);
        % Hold the first half part of the spectrum
        P2 = abs(X/(nfft));
        
        P1(2:nfft/2+1) = P2(2:nfft/2+1);
        P1(1) = P2(1);
        
        Pxx(:,iStep) = P1;
    end  
end