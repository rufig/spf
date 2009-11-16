-1 CONSTANT WAVE_MAPPER
 0 CONSTANT CALLBACK_NULL

WINAPI: waveInOpen            WINMM.DLL
WINAPI: waveInClose           WINMM.DLL
WINAPI: waveInPrepareHeader   WINMM.DLL
WINAPI: waveInAddBuffer       WINMM.DLL
WINAPI: waveInStart           WINMM.DLL
WINAPI: waveInUnprepareHeader WINMM.DLL

CREATE WAVEFORMATEX
1 W,       \ WORD  wFormatTag; = WAVE_FORMAT_PCM
1 W,       \ WORD  nChannels; 
8000 ,     \ DWORD nSamplesPerSec; 8.0 kHz, 11.025 kHz, 22.05 kHz, and 44.1 kHz
8000 2 * , \ DWORD nAvgBytesPerSec; \ should be equal to the product of nSamplesPerSec and nBlockAlign
2 W,       \ WORD  nBlockAlign; \ nBlockAlign must be equal to the product of nChannels and wBitsPerSample divided by 8 (bits per byte)
16 W,      \ WORD  wBitsPerSample; 
0 W,       \ WORD  cbSize; 

CREATE WAVEHDR
HERE 0 ,   \ LPSTR      lpData; 
8000 2 * , \ DWORD      dwBufferLength; 
0 ,        \ DWORD      dwBytesRecorded; 
0 ,        \ DWORD_PTR  dwUser; 
0 ,        \ DWORD      dwFlags; 
0 ,        \ DWORD      dwLoops; 
0 ,        \ struct wavehdr_tag * lpNext; 
0 ,        \ DWORD_PTR reserved; 
HERE SWAP !
8000 2 * ALLOT

: TEST
  10 0 DO
   CALLBACK_NULL 0 0 WAVEFORMATEX WAVE_MAPPER PAD DUP 0! waveInOpen . PAD @ .
   200 PAUSE
   PAD @ waveInClose .
   100 PAUSE
  LOOP
;
\ TEST

: TEST
  CALLBACK_NULL 0 0 WAVEFORMATEX WAVE_MAPPER PAD DUP 0! waveInOpen . PAD @ .
  32 WAVEHDR PAD @ waveInPrepareHeader .
  32 WAVEHDR PAD @ waveInAddBuffer .
  PAD @ waveInStart .
  10 0 DO
    1000 PAUSE
    WAVEHDR 100 DUMP CR
    WAVEHDR 16 + @ 3 =
    IF
      32 WAVEHDR PAD @ waveInUnprepareHeader .
      32 WAVEHDR PAD @ waveInPrepareHeader .
      32 WAVEHDR PAD @ waveInAddBuffer . CR
    THEN
  LOOP
  PAD @ waveInClose .
;
TEST
