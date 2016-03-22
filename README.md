# raspberryPiSetup
Initial setup and steps to get a raspberry pi up and running.

After repeating all these steps over and over, I decide to make this repo and have all the steps clear so anyone can repeat then and get their raspberry pi up and running.  I will be setting up a MEAN environment using Nginx and some other tools to make life easier.  The hole purpose 

##Setup SD Card with Raspbian

After many tries, I found the best solution is to flash the SD Card and copy a Raspbian image **NOT** a NOOBS image. When using the NOOBS image, you'll get your card with weird partitions.  Here are the steps:

1. Download [ApplePi-Baker](http://www.tweaking4all.com/hardware/raspberry-pi/macosx-apple-pi-baker/) and install the latest version on your mac.  This tool will help you to flash your card (NOOBS Recipe).
2. Run ApplePi-Baker
3. Insert your card.
4. Press the refresh button 
5. Your card should appear on the list.  Select the card.
6. Run the NOOBS Recipe.  This will erase your card completely! Be careful!
7. Download the latest Raspbian image from [their download page](http://www.raspberrypi.org/downloads/). You can choose between the normal version or the Lite version. Because our server is going to be headless, I tend to install the **Lite** version.
8. After the download finishes, uncompress the zip file somewhere you can locate it easily (i.e. your Desktop)
9. After flashing your card, select your card again and run the IMG Recipe.  Make sure you select the file you just downloaded and then press IMG to SD Card.
10. After it finishes, eject your card and insert the card on your Pi.


##Raspi-config

After the OS gets installed, the Pi will reboot and load raspi-config for the first time. With the Lite version, you need to run `sudo raspi-config`.  These are the steps that I normally follow:

1. Expand Filesystem (Just in case)
2. Change Internationalization Options to suit my needs:
	+ Change Locale. (en_CA.UTF-8 UTF-8)
  	+ Change Timezone. (America -> Toronto)
3. Enable SSH access. (Advanced Options -> SSH)
4. Change the hostname (Advanced Options -> Hostname)
5. Enable SPI (if you have an Adafruit TFT)

Select Finish and let the Pi reboot.

##Find the Pi IP address

After rebooting, find the ip of your Pi by running `ifconfig`.  Look for this line `inet addr:192.168.1.116`.  In this case, my IP is 192.168.1.116.  Now I want to set that as a static IP for my Pi.  This step can also be done in the router config.  I do it in both places (router and pi) just to be safe.

##Enable SSH Without password (Public Key)

Now we need to ssh into the pi without entering a password. Follow these steps:

1. Generate a public key on your mac `ssh-keygen`
2. SSH into your pi `ssh pi@192.168.1.116`
3. Create a new folder for your keys `mkdir .ssh`
4. Exit the Pi `exit`
5. Go to the folder where your public key was stored `cd ~/.ssh`
5. Transfer your public key to your pi `scp id_rsa.pub pi@IPAddress:.ssh/authorized_keys`
6. Exit the Pi `exit` and SSH again into it.  You should not need to enter the password anymore. 

##Install [OSXFuse](http://osxfuse.github.io/), [SSHFS](http://osxfuse.github.io/) and [fuse-ext2](http://sourceforge.net/projects/fuse-ext2/)

While the previous transfer takes place, I like to install on my mac OSXFuse, SSHFS and fuse-ext2.  This has to be done once.  After installing these 3 applications, you will be able to mount your pi as a drive.  When installing OSXFuse, make sure to check: MacFUSE Compatibility Layer. This will be handy to mount any SD card with an actual OS to your mac. Download and install [fuse-ext2](http://sourceforge.net/projects/fuse-ext2/).  After the installation, open a terminal session and follow these steps:

1. `sudo nano -c /System/Library/Filesystems/fuse-ext2.fs/fuse-ext2.util`
2. If using nano press CONTROL + W.  This will trigger the search function.  Then search for "function mount"
3. Scroll down to `OPTIONS="auto_xattr,defer_permissions"` comment the line and add this bellow the commented line `OPTIONS="auto_xattr,defer_permissions,rw+"`.  You should end with something like this:


	````
	# compatibility on the options.
	#OPTIONS="auto_xattr,defer_permissions"
	OPTIONS="auto_xattr,defer_permissions,rw+"
	````

After doing that, you should be able to later mount an SD card with your Pi OS and look for your files, transfer them to another pi, etc.

Once they're installed, you can try mounting the pi following these steps:

1. Open a new terminal session and go to your home directory `cd ~`
2. Create an empty folder that will map to your drive.  In mi case `mkdir raspberryPi`
3. Now that you know your Pi IP (mine is 192.168.1.116) you can mount the home folder as an external drive.  Run `sshfs pi@192.168.1.116: raspberryPi`. The second argument is the folder you created above.  If you go to your finder, on your home folder you will see something like "OSXFUSE Volumen 2 sshfs". That's your home folder from your pi.  At this point you can move files from your mac to your pi.  You can even develop your apps on your mac and run them on your pi.

##Set a Static IP Address for your pi

Now that you know your ip address, let's make it static. Run these commands:

1. `sudo nano /etc/network/interfaces`
2. Find this line `iface eth0 inet dhcp` and comment it in case you want to revert.
3. At the end of the file add these lines:

	````
	iface eth0 inet static
	address 192.168.1.116					#IP of your pi
	netmask 255.255.255.0					#netmask from your router
	network 192.168.1.0						#network from your router
	broadcast 192.168.1.255					#broadcast from your router
	gateway 192.168.1.1						#this is normally the IP of your router
	````
	
	The *address* IP setting will be the IP address you wish to specify as static on your network.  The *gateway*, *netmask*, *network* and *broadcast* IP addresses are dependent on your network and can be obtained from the router.
	
4. Save your file and reboot `sudo reboot`


##Update and Upgrade with apt-get

At this point is probably a good idea to update and upgrade the system.  Run the following commands

	sudo apt-get update
	sudo apt-get upgrade
	
In case you want to know more about apt-get, [this](http://www.tecmint.com/useful-basic-commands-of-apt-get-and-apt-cache-for-package-management/) link is really useful.
	
##Rpi-update first time: install git and certifications to reach github.

	sudo apt-get install ca-certificates
	sudo apt-get install git-core
	sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update
	sudo chmod +x /usr/bin/rpi-update

Check for git version `git --version`
	
##Update firmware

	sudo rpi-update
	sudo ldconfig
	sudo reboot
	
##Rpi-update after

	sudo rpi-update
	sudo ldconfig
	sudo reboot
	
##Overclock your Pi
**Note**: Update the firmware before overclocking!! Mandatory!

Follow [This tutorial](http://haydenjames.io/raspberry-pi-2-overclock/) 

##Unattended-upgrades (Optional)

The `unattended-upgrades` package is the way to automate updating the OS in these debian-family distributions.  Follow these instructions:

1. Install the package:

	````
	sudo apt-get install unattended-upgrades
	````
	
2. Create the file:

	````
	sudo nano /etc/apt/apt.conf.d/10periodic
	````

3. Add these lines to the file and save:

	````
	APT::Periodic::Update-Package-Lists "1";
	APT::Periodic::Download-Upgradeable-Packages "1";
	APT::Periodic::AutocleanInterval "7";
	APT::Periodic::Unattended-Upgrade "1";
	````
	The above configuration updates the package list, downloads, and installs available upgrades every day. The local download archive is cleaned every week.
	
	The results of unattended-upgrades will be logged to `/var/log/unattended-upgrades`
	 
	
##Install apticron (Optional)

To follow this step you need to install SSMTP first.  [Follow this tutorial](http://iqjar.com/jar/sending-emails-from-the-raspberry-pi/)

apticron will configure a cron job to email an administrator information about any packages on the system that have updates available, as well as a summary of changes in each package.

To install it run:

	sudo apt-get install apticron

Configure it to send you messages:

	sudo nano /etc/apticron/apticron.conf
	EMAIL="root@example.com"
	
Configure it to run once a week: [Follow these steps](http://www.sysadminworld.com/2012/how-to-run-apticron-only-once-a-week/). This [link](http://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) is also useful to know more about cron jobs.

Test it:

	sudo apticron
	
Some things that you will find on the message if there's an update:

You can perform the upgrade by issuing the command:

	aptitude dist-upgrade
	
The upgrade may be simulated by issuing the command:

	aptitude -s -y dist-upgrade
	
Useful stuff.


##Install screen (Optional but really useful)

If we exit our SSH session while there's a long build happening, then the build will stop causing some breakage.  We don't want that.  We can solve that problem with screen.  Screen will let you run long builds and resume later when you SSH again to your Pi.  Is like running task in the background of your Pi.  After installing it, you could run the node.js installation using screen.  Here are the steps:

1. Run `sudo apt-get install screen`
2. After the installation, run `screen` to start a screen session.  You'll get a new terminal window.  From that terminal window you can run the node.js installation bellow and forget about broken pipes.

If you want to SSH again and resume your session, you just need to run `screen -r`. After the process has ended, you can exit the session and terminate it just by typing `exit`.  You can have multiple sessions and terminate them.  You can find more info about that [here](http://www.tecmint.com/screen-command-examples-to-manage-linux-terminals/).
	

##Install node.js (latest version 03/21/2016)
I found a new way to install the latest version (5.7.0). If the next instructions don't work, follow the long install.

###Short install
With this installation, I'm going to use **nvm** to manage node.js installations.

1. run the following:

	````
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
	````
	After running the above, reboot your pi and ssh again to it.

2. Now, let's install the latest version of node (v5.7.0)

	````
	nvm install v5.7.0
	nvm alias default v5.7.0
	````

3. Symlink your version

	````
	sudo ln -s /home/pi/.nvm/versions/node/v5.7.0/bin/node /usr/bin/node
	sudo ln -s /home/pi/.nvm/versions/node/v5.7.0/bin/npm /usr/bin/npm
	````
	
Follow [this](https://www.getstructure.io/blog/how-to-install-nodejs-on-raspberry-pi) tutorial for more info on the above and updating node versions. Credits to [Brandon Cannaday](https://twitter.com/TheReddest)

###Long Install
After trying many tutorials, I have found that this is the most reliable way to install node.js on the pi.  You can also follow [this tutorial](http://elinux.org/Node.js_on_RPi).

1. Create install-node.sh 

	````
	nano install-node.sh
	````
2. Paste the code bellow (change node version if needed.  I'm installing the latest as of this date)
	
	````
	wget https://nodejs.org/dist/v4.4.0/node-v4.4.0.tar.gz
	tar -xzf node-v4.4.0.tar.gz
	cd node-v4.4.0
	./configure
	make
	sudo make install
	````
3. Run the script and wait until it finishes. This process took an hour and a half in my case.

	````
	sudo sh install-node.sh
	````
4. After completing the installation, check your node.js version:

	````
	node -v										# Should print v4.4.0
	````
5. Check npm version:

	````
	npm -v										# Should print v3.6.0
	````
	
At this point you should be able to test the node server.  Download the `nodeLab` folder from this repo and place it on your home folder `/home/pi/nodeLab`. CD into your nodeLab folder and run `node server.js` (You need to install all the required `npm` packages first.)  You should see something like this on your prompt:

	Simple static server listening on port 3000
	
###Update npm version
1. Check for outdated global packages `npm outdated -g --depth=0`
2. If npm is outdated, run `npm install npm -g`
	
##Backup your SD Card
At this point I like to back up my SD Card and save an image I can re-use at any time.  If using the same image on another Pi, have in mind that you should change the host name running `sudo raspi-config`.

Again, I use [ApplePi-Baker](http://www.tweaking4all.com/downloads/raspberrypi/ApplePi-Baker-1.5.1.zip) to flash my SD cards and copy my backup image to them.  The third recipe is meant for backing up your image.

##SHHD Disable Password login

Now that I can login with my private key, I want to ONLY login with it.  If you want the same, follow the next steps:

1. Run `sudo nano /etc/ssh/sshd_config`
2. Change `PermitRootLogin yes` to `PermitRootLogin no`
3. Look for `PasswordAuthentication yes` It should be commented.  Uncomment it and change the value to NO.  Like this `PasswordAuthentication no` 

I like commenting the lines I'll be changing and creating a new one with my changes in case I want to revert.  My file looks like this:

	#Disable Password login
	#PermitRootLogin yes
	PermitRootLogin no
	.
	.
	.
	# Change to no to disable tunnelled clear text password 
	#Disable Password logins
	#PasswordAuthentication yes
	PasswordAuthentication no
	
I like it ;)

##Update Git to the latest version

	 sudo nano /etc/apt/sources.list

Add this line at the end of the file:

	deb http://http.debian.net/debian wheezy-backports main
	
Run `sudo apt-get update`.  You should get an error saying theres a missing key.  Something like this: 

	W: GPG error: http://mozilla.debian.net  ......   : NO_PUBKEY 85A3D26506C4AE2A
	
Copy the public key number and run this making sure to replace yours with the one of this example:

	gpg --keyserver pgpkeys.mit.edu --recv-key 85A3D26506C4AE2A
	gpg -a --export 85A3D26506C4AE2A | sudo apt-key add -
	
run `sudo apt-get update` again. Now you shouldn't get an error.

Now run:

	sudo apt-get -t wheezy-backports install git
	
That should do the trick.  You should be running the latest git for your version of Linux (Debian) After upgrading, I like to comment the source that I added to the source.list file just because the versions you get from backports sometimes are not stable.

	sudo reboot


##Install Watchdog

Its purpose is to automatically restart the raspberry pi if it becomes unresponsive.

	sudo apt-get install watchdog
	sudo modprobe bcm2708_wdog
	
Edit modules file:

	sudo nano /etc/modules
	##add the line bellow to the end of the file
	bcm2708_wdog
	
Add watchdog to startup applications:

	sudo update-rc.d watchdog defaults
	
edit watchdog config file

	sudo nano /etc/watchdog.conf
	
	#uncomment the following:
	max-load-1
	watchdog-device

Restart watchdog with:
	
	sudo service watchdog restart
	
You can also run these commands to check its status, stop it and start it:

	sudo service watchdog status
	sudo service watchdog stop
	sudo service watchdog start
	
##Install nginx

	sudo apt-get install nginx
	
Make sure to start the service and try to see something via network

	sudo service nginx start
	
Go to the IP address of your Pi on a browser (In my case http://192.168.1.116/) and you will see the Nginx Welcome message "Welcome to nginx!"

##Configure nginx for node.js hosting

Create a site for your domain (example uses `nodeLab` for a name)

	sudo nano /etc/nginx/sites-available/nodeLab
	
This is where we configure nginx to send any requests to the node.js app later on.

Insert the following content into the file. We will have nginx deliver existing files right away, everything else will be sent to node.

Change `nodeLab` for the domain that suits your needs.

	# the IP(s) on which your node server is running. I chose port 3000.
	upstream app_nodeLab {
    	server 127.0.0.1:3000;
    	keepalive 8;
	}

	# the nginx server instance
	server {
	    listen 80;
	    server_name nodeLab.pi nodeLab;
	    access_log /var/log/nginx/nodeLab.log;
	    root  /home/pi/nodeLab/app;
	    index index.html;
	    charset utf8;
	    sendfile off;
	
	    # pass the request to the node.js server with the correct headers
	    # and much more can be added, see nginx config options
	    location / {
	      proxy_set_header X-Real-IP $remote_addr;
	      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	      proxy_set_header Host $http_host;
	      proxy_set_header X-NginX-Proxy true;
	      proxy_redirect off;
	
	        # these are denied
	        location ~ \.(php|inc|conf|bak|tmp|htaccess|htpasswd)$ {
	            deny all;
	            break;
	        }
	        # serve existing files, put everything else to node
	        if (!-f $request_filename) {
	            proxy_pass http://app_nodeLab;
	            break;
	        }
	    }
	 }

Now enable the site

	cd /etc/nginx/sites-enabled/
	sudo ln -s /etc/nginx/sites-available/nodeLab nodeLab

Restart nginx

	sudo service nginx restart
	
At this point if you create a simple node project you will be able to see it on your Pi IP address on port 3000.

Double check that there's only one enabled site (in this case nodeLab) on your `sites-enabled` folder.  If for any reason there's a `default` site in that folder, nginx will serve that default site on port 80 and your `nodeLab` site on port 3000.  If you delete the default site, nginx will forward port 3000 to port 80 and you will be able to see your app just by typing your IP address without the port.  This comes useful if you want to later forward a public IP address to your app and make it public.

##Install Mongodb without building it

You can follow [this tutorial](http://blog.rongzou.us/?p=118).  And here are a couple of links that will help you solve issues if you have them.  [This one](http://stackoverflow.com/questions/12831939/couldnt-connect-to-server-127-0-0-127017) and [this one](https://ni-c.github.io/heimcontrol.js/get-started.html).

Because I have been running into some issues with Mongo, I decided to write a small bash script to repair it:

1. Create repair-mongo.sh on your home folder:

	````
	nano repair-mongo.sh
	````
2. Paste these commands:

	````
	sudo service mongodb stop
	sudo rm /var/lib/mongodb/mongod.lock
	sudo mongod --repair
	sudo service mongodb start
	sudo service mongodb status
	````
3. Run it:

	````
	sudo sh repair-mongo.sh
	````
	
###Authentication
In case you want to use authentication on your mongo database, follow [this](http://www.mkyong.com/mongodb/mongodb-authentication-example/) tutorial.

##Install zsh and oh-my-zsh (Optional)

	sudo apt-get install zsh
	wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
	chsh -s $(which zsh)
	sudo reboot

After that zsh and oh-my-zsh should be up and running.  You can customize it however you like.  I added a simple template I created for mine to this repo. If you want to use it, just follow these steps:

	cd ~/.oh-my-zsh/themes/
	wget https://raw.githubusercontent.com/miroamarillo/raspberryPiSetup/master/miroamarillo.zsh-theme

Activate the theme:

	nano ~/.zshrc

Find the line ZSH_THEME="..." and change it for
	
	ZSH_THEME="miroamarillo"
	
Done.  You should be running the new theme by now.

##SSH Welcome banner (Optional)

I like ti have a welcome banner on my pi.  I uploaded mine to this repo.  Feel free to use it. It is based on ZSH. It won't work with bash.

###Remove Debian default message

	sudo rm /etc/motd
	sudo nano /etc/motd

Now you should have a nice raspberry pi message every time that you ssh into your pi.

###Useful links on zsh and bash

- [Replacing Bash with ZSH on OSX](http://danny.is/writing/replacing-bash-with-zsh-141226)
- [Moving from bash to zsh](http://askubuntu.com/questions/1577/moving-from-bash-to-zsh)
- [dotfiles.org](dotfiles.org)
- [Bash Profile Gist](https://gist.github.com/natelandau/10654137)

###More to come...







