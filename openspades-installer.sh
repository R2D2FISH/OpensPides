#!/bin/bash												# find bash
echo "initializing..."

 sleep 1

if [ "$EUID" -ne 0 ]											#check if the script is being run as root
then
 echo "loading parameters..."
else
 echo "WARNING: The installer has been run as the root user (sudo command)."
 sleep 1
 echo "Are you sure you would like to continue? (type y or n)"

 read continue												# prompt

	if [ $continue = y ]										# check whether or not to continue
	then
	 echo "Continuing..."
	 sleep 1

	else
		if [ $continue != n ]
		then
		 echo "interpreting vague answer as..."
		 sleep 1
		 echo "no"
		fi
	 sleep 1
	 echo "Exiting..."
	 exit												# user did not want to run as root
	fi
fi

for var in "$@"												# set parameters (inefficient method, I know...)
do
	if [ $var = "-noupdate" ]
	then
	 noupdate=1
	else
		if [ $var = "-nodependencies" ]
		then
		 nodependencies=1
		else
			if [ $var = "-nosdl" ]
			then
			 nosdl=1
			else
				if [ $var = "-nosdl_image" ]
				then
				 noimage=1
				fi
			fi
		fi

	fi
done

sleep 1

echo "
   ____                                    ____     _        __              
  / __ \    ____   ___    ____    _____   / __ \   (_)  ____/ /  ___    _____
 / / / /   / __ \ / _ \  / __ \  / ___/  / /_/ /  / /  / __  /  / _ \  / ___/
/ /_/ /   / /_/ //  __/ / / / / (__  )  / ____/  / /  / /_/ /  /  __/ (__  ) 
\____/   / .___/ \___/ /_/ /_/ /____/  /_/      /_/   \__,_/   \___/ /____/  
        /_/                                                                  
OpensPides installer v1.0.  Intended for use with Raspbery Pi 2 and 3 (ARM)
"													# splash screen and text


sleep 3													# wait

if [ -d /usr/local/share/games/openspades ]								# check for old version
 then
 echo "
Previous version of Openspades discovered on your Pi.

Would you like to reinstall? (type y or n)"								# ask to reinstall

 read reinstall												# prompt

if [ $reinstall = y ]											# check whether or not to reinstall
then
 echo "Uninstalling old version..."
 sudo rm -rf /usr/local/share/games/openspades								# uninstall previous version

 sleep 1
 echo "Old version uninstalled"

else
	if [ $reinstall != n ]
	then
	 echo "interpreting vague answer as..."
	 sleep 1
	 echo "no"
	fi
 sleep 1
 echo "Exiting..."
 exit													# user did not want to reinstall openspades
fi
fi

if [ -d ~/OpensPides ]											# check if installation folder already exists
then
 echo "Installation folder found."
else
 mkdir ~/OpensPides											# create installation folder
 echo "Installation folder created"
fi

if [ -d ~/OpensPides/InstallerFiles ]									# check if folder already exists for installer files (variables)
then
 echo "InstallerFiles folder found."
else
 mkdir ~/OpensPides/InstallerFiles									# create folder for installer files
 echo "InstallerFiles folder created"
fi

sleep 1

if [ -n "$noupdate" ]											# check whether or not to skip update
then
 echo "Update skipped."
else
	if [ -e ~/OpensPides/InstallerFiles/updated ]							# check for previous updates
	then
	 echo "Already updated."
	else
	 echo "
#################################
#                               #
#     Installing Updates...	#
#				#
#################################
"
sleep 2
	 sudo apt-get update										# check for updates
	 sudo apt-get upgrade -y									# install required updates
	 touch ~/OpensPides/InstallerFiles/updated							# mark updates as done
		 if [ -f /var/run/reboot-required ]							# check whether a reboot is necessary
		 then
		  echo "Reboot required.  Rebooting in 10 seconds.  Please re-execute this script on startup"
		  sleep 10
		  sudo reboot
		 else
		  echo "Reboot not required"
		  sleep 1
		 fi
	 fi
fi

sleep 1

if [ -n "$nodependencies" ]										# check whether or not to install dependencies
then
 echo "WARNING: Dependencies not installed.  Program will most likely not work."
else
	if [ -e ~/OpensPides/InstallerFiles/dependencies ]						# check if dependencies were previously installed
	then
	 echo "Dependencies already installed"
	else
	 echo "
#################################
#				#
#   Installing Dependencies...	#
#				#
#################################
"
sleep 2
	 sudo apt-get update
	 sudo apt-get install build-essential cmake pkg-config libfltk1.3-dev libglew-dev libcurl3-openssl-dev libjpeg-dev libxinerama-dev libxft-dev mercurial git-core libopenal1 libopenal-dev mesa-utils libtiff-dev libpng12-dev libjpeg-dev wget zip tar imagemagick vim -y
	 touch ~/OpensPides/InstallerFiles/dependencies							# mark dependencies as installed
	 echo "All pre-built dependencies installed."
	fi
fi

if [ -n "$nosdl" ]											# check whether or not to install SDL
then
 echo "SDL Installation skipped.  Program will most likely not work"
else
	if [ -e ~/OpensPides/InstallerFiles/sdl ]							# check if dependencies were previously installed
	then
	 echo "SDL has a previous installation."
	else
	 echo "
#################################
#				#
#   	 Building SDL...	#
#				#
#################################
"
sleep 2
		if [ -d ~/OpensPides/SDL ]								# check if SDL installation folder already exists
		then
		 echo "SDL installation folder found.  Updating previous installation..."
		 hg pull
		 hg update --clean
		else
		 mkdir ~/OpensPides/SDL									# create SDL installation folder
		 echo "SDL installation folder created"
		 echo "Downloading source..."
		 hg clone http://hg.libsdl.org/SDL "~/OpensPides/SDL"					# download SDL
		fi
	pushd ~/OpensPides/SDL										# move to SDL folder
	echo "Configuring..."
	./configure											# configure SDL
	echo "Building..."
	make												# build SDL
	echo "Installing..."
	sudo make install										 install SDL
	touch ~/OpensPides/InstallerFiles/sdl								# mark SDL as installed
	fi
fi

if [ -n "$noimage" ]											# check whether or not to install SDL_Image
then
 echo "SDL_Image Installation skipped.  Program will most likely not work"
else
	if [ -e ~/OpensPides/InstallerFiles/sdl_image ]							# check if dependencies were previously installed
	then
	 echo "SDL_Image has a previous installation."
	else
	 echo "
#################################
#				#
#     Building SDL_Image...	#
#				#
#################################
"
sleep 2
		if [ -d ~/OpensPides/SDL2_image-2.0.0 ]							# check if SDL_Image installation folder already exists
		then
		 echo "Unbuilt SDL_Image installation folder found. Deleting..."
		 rm -rf ~/OpensPides/SDL2_image-2.0.0							# delete previous installation folder
		 rm ~/OpensPides/SDL2_image-2.0.0.tar.gz						# delete old archive
		fi
	 echo "Downloading source..."
	 wget https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.0.tar.gz -P ~/OpensPides	# download SDL_Image
	 echo "Unpacking..."
	 pushd ~/OpensPides										# move to Installation folder
	 tar xvf SDL2_image-2.0.0.tar.gz
	 pushd ~/OpensPides/SDL2_image-2.0.0								# move to SDL_Image folder
	 echo "Configuring..."
	 ./configure --disable-png-shared								# configure SDL_Image
	 echo "Building..."
	 make												# build SDL_Image
	 echo "Installing..."
	 sudo make install										 install SDL_Image
	 touch ~/OpensPides/InstallerFiles/sdl_image							# mark SDL_Image as installed
	fi
fi

sleep 1
echo "
#################################
#				#
#    Building OpenSpades...	#
#				#
#################################
"
sleep 2
if [ -d ~/OpensPides/OpensPides ]									# check for previous openspades folder
then
 echo "Previous installation found.  Deleting and redownloading..."
 sudo rm -rf ~/OpensPides/OpensPides										# delete previous folder
else
 echo "Downloading OpenSpades..."
fi
pushd ~/OpensPides											# move to main folder
git clone https://github.com/R2D2FISH/OpensPides.git							# clone OpensPides repository
echo "Creating Build Folder..."
mkdir ~/OpensPides/OpensPides/Build									# make build directory
pushd ~/OpensPides/OpensPides/Build									# move to build directory
echo "Running CMAKE..."
cmake .. -DCMAKE_BUILD_TYPE=Release									# configuring
echo "Compiling..."
make													# compile Openspades
echo "Installing..."
sudo make install											# install Openspades

if [ -d ~/.local/share/openspades/Resources ]								# check for resources folder
then
 echo "Resources folder found."
else
 echo "Creating user resources folder..."
 mkdir -p ~/.local/share/openspades/Resources								# create resources folder
fi

pushd ~/OpensPides/OpensPides										# move to SPConfig.cfg directory
if [ -e ~/OpensPides/OpensPides/SPConfig.cfg ]								# check for tampering
then
	if [ -e ~/.local/share/openspades/Resources/SPConfig.cfg ]					# check for previous config file
	then
	 echo "Previous config file found."
	else
	 echo "Copying SPConfig.cfg..."
	 cp -p SPConfig.cfg ~/.local/share/openspades/Resources/SPConfig.cfg				# copy SPConfig
	fi
else
 echo "WARNING: SPConfig.cfg not found!  Installation folder was most likely tampered with during the installation!"
fi

echo "

  ____    ___    __  __   ____    _       _____   _____   _____   _ 
 / ___|  / _ \  |  \/  | |  _ \  | |     | ____| |_   _| | ____| | |
| |     | | | | | |\/| | | |_) | | |     |  _|     | |   |  _|   | |
| |___  | |_| | | |  | | |  __/  | |___  | |___    | |   | |___  |_|
 \____|  \___/  |_|  |_| |_|     |_____| |_____|   |_|   |_____| (_)


I cannot guarantee that the program will run, but there is only one way to figure that out...  The game must be run from the desktop; it will not run from the command line.  Overclocking is basically required in order to make the game playable.  Settings can be changed both ingame and through the SPConfig.cfg file.  The three settings which will significantly change the game's performance are r_videoHeight, r_videoWidth, and r_swUndersampling.  Don't freak out about the framerate at the main menu, it gets somewhat better ingame...

This is in no way practical.  It is just a testament to both the scalability of the game, and the versatility of the Raspberry Pi.  I only attempted this for the memes, as I am sure you did too.  Hope you enjoy gaming at 20FPS!

-R2D2_FISH"
