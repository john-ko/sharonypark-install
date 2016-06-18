# sharonypark-install

## INSTALL

### virtualbox setup
1. install virtualbox
2. click new
3. Type: `Linux` Version: `Ubuntu 64`
4. 1-2 gb ram, and 8gb hd
5. settings > network > Attach to: `Bridged adapter`
6. get `ubuntu 14.04 lts server` iso and install

### ubuntu setup
1. once booted up
2. `git clone https://github.com/john-ko/sharonypark-install.git`
3. `cd sharonypark-install`
4. `sudo chmod +x instll.sh`
5. `sudo ./install.sh`
6. find local ip, `ifconfig` example 192.168.1.x

## SETUP
## windows
- open explorer
- right click network places
- map network drive
- check `connect using different credentials`
- folder: `\\192.168.1.x\share`
- username: sharonypark, password: password