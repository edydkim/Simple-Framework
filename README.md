Simple-Framework
================

Stateless Integration Maintenance Page Loading Enhancement Framework

### Purpose
#### This is Lightweight MVC Framwork with daemon on distributed system.

### Requirment
   ```
  ・RHEL　5.6（Red Hat　4.1）
  ・Perl 5.8
  ・Apache 2.0
  ・Mac OS X Lion
  ・Perl 5.12.3
  ・Apache 2.0.64
  ・SQLite3
    
    or
　  
　  (Not implemented)
  ・Scalar 2.9.1-1 (Java HotSpot(TM) 64-Bit Server VM, Java 1.6.0_31)
  ・Apache 2.0.64
  ・SQLite3
  ```
  
### Architecture

  ```
　HTML（A.html, B.html･･･）-- Javascript <validation>
　   ||
　Control（CGI（Perl))
　　 ||
　Daemon 
      +-[Manager]-+-[Receiver]
      |           |
      |           +-[Sender]
      |
      |
  DB (SQLite) -- Web Page (HTML)
  ```
 
### Distribution
  ```
  ・Apache
  　htdocs - A.html, B.html, validation.js
  　cgi-bin - control (perl)

  ・DB
    overwhelm.sqlite - /Users/kimudaiki/Desktop/sqlite

  ・Modules (644, Main.pm(755))
    *.pm - /Users/kimudaiki/Desktop/Overwhelm
    *.dat.m - /tmp/overwhelm/work 
    *.dat.r - /tmp/overwhelm/send
    *.dat.s - /tmp/overwhelm/receive

  ・Log
  　overwhelm_stderr.log - /tmp/overwhelm/
    overwhelm_execute.log - /tmp/overwhelm/
    overwhelm_stdwarn.log - /tmp/overwhelm/
  ```

### Deploy & Run
  ```
  $ /Users/kimudaiki/Desktop/Overwhelm/MMF/Main.pm manager
　Manager daemon (pid38352) is started..
  $ /Users/kimudaiki/Desktop/Overwhelm/MMF/Main.pm receiver
　Receiver daemon (pid38361) is started..
　$ /Users/kimudaiki/Desktop/Overwhelm/MMF/Main.pm sender
　Sender daemon (pid38370) is started..

  overwhelm $ ls
  manager.pid  	overwhelm_stderr.log	receive			send			work
  overwhelm_execute.log	overwhelm_stdwarn.log	receiver.pid		sender.pid
  ```

### Task
  ```
  Converting perl to scalar
  Integrate with Spring
  Add some features on front
  ```
