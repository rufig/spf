S" wincon_pipes.f" INCLUDED

4096 CONSTANT BUFSIZE
 
VARIABLE hChildStdinRd
VARIABLE hChildStdinWr
VARIABLE hChildStdinWrDup

VARIABLE hChildStdoutRd
VARIABLE hChildStdoutWr
VARIABLE hChildStdoutRdDup

VARIABLE hInputFile
VARIABLE hSaveStdin
VARIABLE hSaveStdout
 
VECT CreateChildProcess
VECT WriteToPipe
VECT ReadFromPipe
VECT ErrorExit
VECT ErrMsg

VARIABLE fSuccess
 

\ SECURITY_ATTRIBUTES
\ Set the bInheritHandle flag so pipe handles are inherited. 
\   saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
\   saAttr.lpSecurityDescriptor = NULL; 
\   saAttr.bInheritHandle = TRUE; 

CREATE saAttr 12 , 0 , 1 ,


: // POSTPONE \ ; IMMEDIATE

: MAIN
 
   // The steps for redirecting child process's STDOUT: 
   //     1. Save current STDOUT, to be restored later. 
   //     2. Create anonymous pipe to be STDOUT for child process. 
   //     3. Set STDOUT of the parent process to be write handle to 
   //        the pipe, so it is inherited by the child process. 
   //     4. Create a noninheritable duplicate of the read handle and
   //        close the inheritable read handle. 
 
// Save the handle to the current STDOUT. 
 
   STD_OUTPUT_HANDLE GetStdHandle hSaveStdout !
 
// Create a pipe for the child process's STDOUT. 
 
   0 saAttr hChildStdoutWr hChildStdoutRd CreatePipe
   0= IF S" Stdout pipe creation failed" ErrorExit THEN
 
// Set a write handle to the pipe to be STDOUT. 
 
   hChildStdoutWr @ STD_OUTPUT_HANDLE SetStdHandle
   0= IF S" Redirecting STDOUT failed" ErrorExit THEN
 
// Create noninheritable read handle and close the inheritable read 
// handle. 

   DUPLICATE_SAME_ACCESS FALSE 0 hChildStdoutRdDup
   GetCurrentProcess hChildStdoutRd @ GetCurrentProcess
   DuplicateHandle fSuccess !

   fSuccess @ 0= IF S" DuplicateHandle failed" ErrorExit THEN

   hChildStdoutRd @ CloseHandle DROP

   // The steps for redirecting child process's STDIN: 
   //     1.  Save current STDIN, to be restored later. 
   //     2.  Create anonymous pipe to be STDIN for child process. 
   //     3.  Set STDIN of the parent to be the read handle to the 
   //         pipe, so it is inherited by the child process. 
   //     4.  Create a noninheritable duplicate of the write handle, 
   //         and close the inheritable write handle. 
 
// Save the handle to the current STDIN. 
 
   STD_INPUT_HANDLE GetStdHandle hSaveStdin !
 
// Create a pipe for the child process's STDIN. 
 
   0 saAttr hChildStdinWr hChildStdinRd CreatePipe
   0= IF S" Stdin pipe creation failed" ErrorExit THEN
 
// Set a read handle to the pipe to be STDIN. 
 
   hChildStdinRd @ STD_INPUT_HANDLE SetStdHandle
   0= IF S" Redirecting Stdin failed" ErrorExit THEN
 
// Duplicate the write handle to the pipe so it is not inherited. 
 
   DUPLICATE_SAME_ACCESS FALSE 0 hChildStdinWrDup
   GetCurrentProcess hChildStdinWr @ GetCurrentProcess
   DuplicateHandle fSuccess !

   fSuccess @ 0= IF S" DuplicateHandle failed" ErrorExit THEN

   hChildStdinWr @ CloseHandle DROP
 
// Now create the child process. 
 
   CreateChildProcess 0= IF S" Create process failed" ErrorExit THEN
 
// After process creation, restore the saved STDIN and STDOUT. 
 
   hSaveStdin @ STD_INPUT_HANDLE SetStdHandle
   0= IF S" Re-redirecting Stdin failed" ErrorExit THEN
 
   hSaveStdout @ STD_OUTPUT_HANDLE SetStdHandle
   0= IF S" Re-redirecting Stdout failed" ErrorExit THEN
 
// Get a handle to the parent's input file. 
 
\   if (argc > 1) 
\      hInputFile = CreateFile(argv[1], GENERIC_READ, 0, NULL, 
\         OPEN_EXISTING, FILE_ATTRIBUTE_READONLY, NULL); 
\   else 
\ это к делу не относится

      hSaveStdin @ hInputFile !
 
\   if (hInputFile == INVALID_HANDLE_VALUE) 
\      ErrorExit("no input file\n"); 
 
// Write to pipe that is the standard input for a child process. 
 
   WriteToPipe
 
// Read from pipe that is the standard output for child process. 
 
   ReadFromPipe
 
   0
;

\   PROCESS_INFORMATION piProcInfo; 
\   STARTUPINFO siStartInfo; 

CREATE piProcInfo 0 , 0 , 0 , 0 , 0 ,
CREATE siStartInfo /STARTUPINFO ALLOT
 
: CreateChildProcess_ ( -- flag )
 
// Set up members of STARTUPINFO structure. 
 
   siStartInfo /STARTUPINFO ERASE
   /STARTUPINFO siStartInfo cb !
 
// Create the child process. 
 
      piProcInfo   // receives PROCESS_INFORMATION 
      siStartInfo  // STARTUPINFO pointer 
      0            // use parent's current directory 
      0            // use parent's environment 
      0            // creation flags 
      TRUE         // handles are inherited 
      0            // primary thread security attributes 
      0            // process security attributes 
      S" php.exe" DROP    // command line 
      0 CreateProcessA
;
' CreateChildProcess_ TO CreateChildProcess
 
VARIABLE dwRead
VARIABLE dwWritten
CREATE chBuf BUFSIZE ALLOT

: WriteToPipe_ ( -- )
 
// Read from a file and write its contents to a pipe. 
 
   BEGIN
     0 dwRead BUFSIZE chBuf hInputFile @ ReadFile 0= dwRead @ 0= OR
     0 dwWritten dwRead @ chBuf hChildStdinWrDup @ WriteFile 0= OR
   UNTIL
 
// Close the pipe handle so the child process stops reading. 
 
   hChildStdinWrDup @ CloseHandle
   0= IF S" Close pipe failed" ErrorExit THEN
;
' WriteToPipe_ TO WriteToPipe
 
: ReadFromPipe_ ( -- )

\   HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE); 
\ не понял - где они используют hStdout в этой функции?

// Close the write end of the pipe before reading from the 
// read end of the pipe. 
 
   hChildStdoutWr @ CloseHandle
   0= IF S" Closing handle failed" ErrorExit THEN
 
// Read output from the child process, and write to parent's STDOUT. 
 
   BEGIN
     0 dwRead BUFSIZE chBuf hChildStdoutRdDup @ ReadFile 0= dwRead @ 0= OR
     0 dwWritten dwRead @ chBuf hSaveStdout @ WriteFile 0= OR
   UNTIL 
;
' ReadFromPipe_ TO ReadFromPipe
 
: ErrorExit_ ( S" Message" -- )
  TYPE CR
  0 ExitProcess
;
' ErrorExit_ TO ErrorExit

SOURCE-ID FILE-SIZE THROW SOURCE-ID REPOSITION-FILE THROW
 
// The code for the child process. 

#include <windows.h> 
#define BUFSIZE 4096 
 
VOID main(VOID) 
{ 
   CHAR chBuf[BUFSIZE]; 
   DWORD dwRead, dwWritten; 
   HANDLE hStdin, hStdout; 
   BOOL fSuccess; 
 
   hStdout = GetStdHandle(STD_OUTPUT_HANDLE); 
   hStdin = GetStdHandle(STD_INPUT_HANDLE); 
   if ((hStdout == INVALID_HANDLE_VALUE) || 
      (hStdin == INVALID_HANDLE_VALUE)) 
      ExitProcess(1); 
 
   for (;;) 
   { 
   // Read from standard input. 
      fSuccess = ReadFile(hStdin, chBuf, BUFSIZE, &dwRead, NULL); 
      if (! fSuccess || dwRead == 0) 
         break; 
 
   // Write to standard output. 
      fSuccess = WriteFile(hStdout, chBuf, dwRead, &dwWritten, NULL); 
      if (! fSuccess) 
         break; 
   } 
} 
 
 
