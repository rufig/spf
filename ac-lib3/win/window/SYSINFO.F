WINAPI: SystemParametersInfoA USER32.DLL

  48 CONSTANT SPI_GETWORKAREA

CREATE RECT 0 , 0 , 0 , 0 , \ window coordinates and size

: GetWorkArea ( -- )
  \ get desktop work area coordinates

  0 RECT 0 SPI_GETWORKAREA SystemParametersInfoA DROP
\  0 = IF S" GetWorkArea error!" MESSAGE BYE THEN
;
