# orapatch
Shell script helping to apply CPU/PSU patches to Oracle RDBMS on Linux en masse.

Instructions

Copy Oracle PSU/CPU patchsets under /var/tmp eg. p24917069_121020_Linux-x86-64.zip
Change ownership to same as Oracle binaries owner. Unzip it. Run script. 

Note, it will bring everything down for patching immediately.

If patch rollback is required, you need to do it manually. Best if you are familiar with Oracle patching before using this to avoid headaches. I hope this makes it bit easier for all DBA's out there.

Good idea to always check patchset notes. In case apply method or order has changed from previous CPU/PSU or requiring custom steps.

Current script reflects patching instructions for August patchset for RDBMS/Java PSU/CPU 2017.