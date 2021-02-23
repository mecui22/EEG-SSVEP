Instructions
SETUP
1. Set matlab working directory to the Folder where Neuracle_data_process is kept (eg. eeg test). It is not necessary to change other directory names in the file. 
2. If running code for the first time on a new laptop, run eeglab in matlab console to add necessary paths. 
3. Add 'data process' folder to Path.

DATA
1. Keep data to be analysed in the data folder (2 layers) - first is for different subjects (eg. S1 contains all the files for children 1), second is for different data from the same subject (eg. 1 and 2 are data from the the same child). 
2. File names are not important, except for the Folder containing the data to be analysed, which must be named 'data'.

RESULTS
1. Results will be saved in a new Folder (eg. results dd-mm-yyyy hh-mm) under working directory.

average accuracy 95.3% 
91.04 ± 6.73%
average ITR - 58 ± 9.6 bit/min ; 319
267 ± 34.8bpm
319.2 bpm = 60 char/min

snr
fundamental: 22.11 dB, second harmonic: 18.70 dB, third harmonic: 18.89 dB, fourth harmonic: 16.37 dB, fifth harmonic: 14.74 dB, and sixth harmonic: 11.48 dB

> 40 Hz  Gamma waves  Higher mental activity, including perception, problem solving, and consciousness
13–39 Hz  Beta waves  Active, busy thinking, active processing , active concentration, arousal, and cognition
7–13 Hz  Alpha waves  Calm relaxed yet alert state
4–7 Hz  Theta waves  Deep meditation /relaxation, REM sleep
< 4 Hz  Delta waves  Deep dreamless sleep, loss of body awareness

S7E8

Pz, PO5, PO3, POz, PO4, PO6, O1, Oz, and O2

Spectrum show Oz, ok
- change pointer
Topographic combines all 64 channels, ok but maybe need to change time range
- change to use 12 only
SNR Analysis calculates specified 9 (or 5), ok
- involve calculateSNRprojection
BCIAnalysis calculates specified 9 (or 5) ok
- involve fbcca
Rhythm combines all 64 channels, ok but maybe need to change time range

bandpass filter of 3-100Hz

