:: Multi-Client launcher script by Chalwk
:: Version: 1.0

:: Description:
:: This script will launch N number of Halo Generic Multi-Clients
:: Where N is the number of ports defined (see config below).

:: Config Starts -----------------------------------------
:: Define your server IP Address and Port(s) ...
:: Note: Halo can also resolve domain names. For example, mydomain.net
set ip=
set ports=

:: EXAMPLE:
:: set ip=xxx.xxx.xxx.xxx
:: set ports=2308 2309 2310 2311 2312 2313
:: Config Ends -------------------------------------------

cd "%~dp0"

(for %%a in (%ports%) do (
   multiclient.exe haloce.exe -window -vidmode 800,600 -connect %ip%:%%a
   timeout /t 0.700 /nobreak
))

exit