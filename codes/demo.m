% Demonstration of how to use LF generation function

clear all;
% set desired parameter values
fs = 8000;              % sampling frequency
framelength = 0.2;      % length of singal (sec)
f0 = 100;               % fundamental frequency (Hz)
vowel = 'ae';            % 'a','e','i','o','u', or 'ae'

% LF_params = [1.23 0.008 1.13 0.2];  % LF mid parameters [Ee Ra Rg Rk]
LF_params = [1.23 2.7];  % LF high parameters [Ee Rd]
phonation = 'b';
level = 'high';

% For reference, LF_params for different phonation types:
%===mid level===
%breathy [1.08 0.025 0.88 0.41];
%modal [1 0.01 1.17 0.34];
%pressed [1.23 0.008 1.13 0.2];

%===high level===
%modal [1 2.0];
%breathy [1.08 2.7];
%pressed [1.23 0.4];

[S, dU, U, a] = synthFrame(vowel,phonation,framelength,f0,fs, LF_params, level);

sound(S, fs);
fname = sprintf('%s_%s_%s.wav', phonation, level, vowel);
audiowrite(fname, S, fs);

time = (0:length(S)-1)/fs;
figure
subplot(3,1,1)
plot(time,S); xlabel('Time (s)'); ylabel('Speech pressure signal');
subplot(3,1,2)
plot(time,U); xlabel('Time (s)'); ylabel('Glottal flow')
subplot(3,1,3)
plot(time,dU); xlabel('Time (s)'); ylabel('Derivative of glottal flow')