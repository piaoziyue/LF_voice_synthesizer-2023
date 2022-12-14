function [ synth, exc, EXC, a ] = synthFrame( vowel, phonation, t, f0, fs, lfvector, level)
%SYNTHFRAME produces a LF-pulse excitation - output pressure pair for given
%VT and phonation specifications
%   [synth, exc, EXC, a ] = synthFrame(vowel, phonation, t, f0, fs, lfvector)
%
%   INPUTS
%       vowel = string specifying vowel 'a','i','e','u','o', or 'ae'
%       phonation = string specifying phonation mode:
%                   'm' - modal
%                   'b' - breathy
%                   'p' - pressed
%                   'custom' - phonation mode is determined by input lfvector
%       t = duration of synthesized signals
%       f0 = fundamental frequency
%       fs = sampling frequency
%       lfvector = LF parameters [Ee Ra Rg Rk] if phonation='custom'
%
%   OUTPUTS
%       synth = synthesized audio (pressure) signal
%       exc = derivative of glottal flow
%       EXC = glottal flow
%       a = VT filter coefficients



switch vowel
    case 'a'
        f1 = 730; f2 = 1090; f3 = 2440;
    case 'i'
        f1 = 390; f2 = 1990; f3 = 2550;
    case 'e'
        f1 = 530; f2 = 1840; f3 = 2480;
    case 'u'
        f1 = 440; f2 = 1020; f3 = 2240;
    case 'o'
        f1 = 570; f2 = 840; f3 = 2410;
    case 'ae'
        f1 = 660; f2 = 1720; f3 = 2410;
    otherwise
        error('Specified vowel unknown. Supported vowel options: a, i, e, u, o, and ae.')
end

switch phonation
    case 'm'
        if level == 'high'
            EE = 10^(0.7/20);
            Rd = 0.8;
            Ra = (-1+4.8*Rd)/100;
            Rk = (22.4+11.8*Rd)/100;
            Rg = (Rk*(0.5+1.2*Rk))/(0.44*Rd-4*Ra*(0.5+1.2*Rk));
        else
            EE=1;Ra=0.01;Rg=1.17;Rk=0.34; % Modal
        end
    case 'b'
        if level == 'high'
            EE = 10^(0.7/20);
            Rd = 2.5;
            Ra = (-1+4.8*Rd)/100;
            Rk = (22.4+11.8*Rd)/100;
            Rg = (Rk*(0.5+1.2*Rk))/(0.44*Rd-4*Ra*(0.5+1.2*Rk));
        else
            EE=10^(0.7/20);Ra=0.025;Rg=0.88;Rk=0.41; % Breathy
        end
    case 'p'
        if level == 'high'
            EE = 10^(-1.8/20);
            Rd = 0.4;
            Ra = (-1+4.8*Rd)/100;
            Rk = (22.4+11.8*Rd)/100;
            Rg = (Rk*(0.5+1.2*Rk))/(0.44*Rd-4*Ra*(0.5+1.2*Rk));
        else
            EE=10^(-1.8/20);Ra=0.003;Rg=2;Rk=0.2; % Pressed
        end
    otherwise
        if level == 'high'
            EE = lfvector(1);
            Rd = lfvector(2);
            Ra = (-1+4.8*Rd)/100;
            Rk = (22.4+11.8*Rd)/100;
            Rg = (Rk*(0.5+1.2*Rk))/(0.44*Rd-4*Ra*(0.5+1.2*Rk));
        else
            EE=lfvector(1);Ra=lfvector(2);Rg=lfvector(3);Rk=lfvector(4);
        end
end

[b, a] = makeVT(f1,f2,f3,fs);

gain = 0.1;

switch level
    case 'mid'
        [U, u] = lf_mid(gain*EE,Ra,Rg,Rk,f0,fs);
    case 'high'
        [U, u] = lf_high(gain*EE,Rd,f0,fs);

Npulses = floor(t*f0)+1;
Npulse = length(u);
exc = [];
EXC = [];
for i=1:Npulses
    exc = [exc u];
    EXC = [EXC U];
end

if round(t*fs)-(Npulses-1)*Npulse > 0
   exc = [exc u(1:round(t*fs)-(Npulses-1)*Npulse)];
   EXC = [EXC U(1:round(t*fs)-(Npulses-1)*Npulse)];
end

place = 0;

gain = sum(a);

synth = filter(gain,a,exc);

Nlength = round(fs*t);

synth = synth(length(u)-place+1:end-place);

exc = exc(length(u)-place+1:end-place);
EXC = EXC(length(u)-place+1:end-place);

if length(synth) < Nlength
    synth = [synth zeroes(1,Nlength-synth)];
    exc = [exc zeroes(1,Nlength-synth)];
    EXC = [EXC zeroes(1,Nlength-synth)];
elseif length(synth) > Nlength
        synth = synth(1:Nlength);
        exc = exc(1:Nlength);
        EXC = EXC(1:Nlength);
end
    
end
