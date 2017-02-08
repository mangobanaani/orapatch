# orapatch
Shell script helping to apply CPU/PSU patches to Oracle RDBMS on Linux en masse.

Instructions

Copy Oracle PSU/CPU patchsets under /var/tmp eg. p24917069_121020_Linux-x86-64.zip
Change ownership to same as Oracle binaries owner. Unzip it. Run script. 

Note, it will bring everything down for patching immediately.

As Oracle recommends, it's good idea to check beforehand if there are patchset conflicts
$ cd <PATCH_TOP_DIR>/24917972
$ opatch prereq CheckConflictAgainstOHWithDetail -ph ./

If patch rollback is required, you need to do it manually. Best if you are familiar with Oracle patching before using this to avoid headaches. I hope this makes it bit easier for all DBA's out there.

Good idea to always check patchset notes. In case apply method or order has changed from previous CPU/PSU or requiring custom steps.
