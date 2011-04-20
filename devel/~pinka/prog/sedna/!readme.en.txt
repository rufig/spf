  Sedna XML DBMS as Windows service

The se_svc.exe -- is a small program that works as a service and controls Sedna
by its own rules. It should be placed to the sedna/bin/ folder.

Example of installation a service (arguments order is important):

     se_svc.exe -db "auction auctionarc" -install

       -- there will be created a service named "sedna". se_gov.exe and 
       specified databases' managers (auction and auctionarc) start while
       running the service.

In order Sedna to work properly the user "LOCAL SERVICE" (or another user
under whom the service is run) should have R/W access rights to folders DATA
and CFG (and all nested files).

To check permissions use the following commands:

  sc qc sedna

  cacls sedna/data

Put your own path to data directory according to the sedna/etc/sednaconf.xml config. 


The file se_svc.status will appear in the same folder as se_svc.exe on
starting. It contains information about the last run.

The source code se_svc.f is available at 
  http://spf.cvs.sourceforge.net/spf/devel/~pinka/prog/sedna/

Binary is available at 
  http://www.forth.org.ru/~ruvim/files/sedna/se_svc.exe  (128Kb)

To build binary the SP-Forth 4.21 is required (http://spf.sf.net/).
