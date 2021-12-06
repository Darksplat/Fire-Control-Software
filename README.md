# Fire-Control-Software
Using a RPI or another computer and Arduino, this is a current, fire control software

Installation

Hardware

Recommended setup for use of PSG 2021
RPI 4 - 4GB (8GB Recommended)
Flash Card
RPI Camera V2
Arduino UNO Rev3 or compatible board
Your Sentry Gun Device

Software

PSG 2021 files including Arduino sketch From Github and forcenet
Raspberry Pi imager
Raspberry OS - ‘Buster’ - This is because ‘Bullseye’ uses a different library for the PIcam and as such will break the install. See this webpage on how to install ‘Buster’
https://www.raspberrypi.com/news/new-old-functionality-with-raspberry-pi-os-legacy/

On the machine to which the Arduino is connected, download Python 3.9.9 not Python 3.10 as it doesn’t have the dependancies that are required at the time of writing. (06/12/2021). From python.org, and install.
This webpage shows how on multiple system types ie MacOS, Windows, Linux
https://wsvincent.com/install-python/

MacOS Instructions
It should install pip, the package installer. In a cmd/terminal window, run:(copy and paste this code)
python3 pip install --upgrade pip
This could take a while depending on your internet connection 
Sudo pip3 install Flask imutils opencv-contrib-python opencv-python pyserial
That installs the packages upon which PSG depends.
Download the files from Github, Forcenet

Windows Instructions
It should install pip, the package installer. In a cmd/terminal window, run:(copy and paste this code)
python3 pip install --upgrade pip
This could take a while depending on your internet connection 
Sudo pip3 install Flask imutils opencv-contrib-python opencv-python pyserial
That installs the packages upon which PSG depends.
Download the files from Github, Forcenet
Unzip into wherever you want it to run on the same machine.

Raspberry Pi/Linux/Unix Instructions
It should install pip, the package installer. In a cmd/terminal window, run:(copy and paste this code)
python3 pip install --upgrade pip
This could take a while depending on your internet connection 
Sudo pip3 install Flask imutils opencv-contrib-python opencv-python pyserial
That installs the packages upon which PSG depends.
Download the files from Github, Forcenet

Configuration
Under the unzip’d psg-2021 folder, you should find psg.ini:
To find usb devices on Mac OS open terminal and type this command 
ls /dev/tty.usb*
Type the usb location number into the red number next to com port below ie #com port:
[Web Server]
Host = localhost Port = 8080 

(MacOS)
[Arduino] COM Port = /dev/tty.usbmodom……. Baud rate = 9600 

(Windows)
[Arduino] COM Port = 123 (“COM7”) Baud rate = 9600

(RPI/Linux/Unix)
[Arduino] COM Port = /dev/ttyACMO……. Baud rate = 9600

[Controller] Command frequency (Hz): 2

Uncomment the “Arduino” section(If it is(#)), and set “COM Port” to whatever the Arduino is connected to. I’d suggest starting with “COM3”.
The baud rate should be correct (9600 symbols/second). But can be increased if you wish
The command frequency under “Controller” defines how often the PSG program sends the current set of parameters to the Arduino. If it doesn’t send it frequently, it looks the Arduino goes to sleep, returning the turret to the default position. I’ve set it to 2 (twice per second), though perhaps change it to 0.5 (once every two seconds).
In theory (!), you should now be able to run the program; from a cmd window, simply run:

python3 psg.py

Then open your browser and type this in the address bar localhost:8080

Operation
Firstly, it’s ugly. Secondly, functionality is very limited. This is a “minimum viable product”, as I went to test a few assumptions to make sure I’m on the right track.
Point a web browser at the machine (or from the machine) on which the Arduino is running, at port 8080. You should see something like this:

Calibration
There are two radio buttons, that let you switch between “Active” and “Calibrating”. The only difference is that when calibrating, when you click on the view window (which shows what the webcam sees), it’ll copy the screen coordinates into both the “Centre” and “Northwest” fields, until you’ve clicked [Set] for each one. Walking through the procedure:
Identify the left most pan that will still hit the screen. Enter a value manually (between 0 and 180 degrees) in the “pan” field, and click [Move]. If all goes well, the turret should obey. Then click [Fire]. The turret should fire, and you can see where it hits the screen. Adjust the “pan” field value until you’re happy it’s as far left as you want to go. Then click [Set Pan (left)].
Repeat the procedure, tilting the turret to the right. When happy, click [Set Pan (right)].
Now we adjust the “tilt” value until it’s as far down as required. Click [Set Tilt (down)].
Finally, adjust “tilt” to its maximum required value, and click [Set Tile (up)].
Now we calibrate the screen coordinates. Enter 90, 90 into the “pan” and “tilt”, and click [Move]. Once the turret has stopped moving, click [Fire]. Where you see it hit the screen in the view, left-click on that spot. Then click [Set] next to “Centre”.
Now, move the turret to the top-left (ideally with the same minimum pan and maximum tilt as noted earlier), and again [Fire]. Click where it hits, and click [Set] beside “Northwest”.
Click the [Calibrate] button, and you’re good to go!
Active use
Click on the “Active” radio button. You should now be able to click on the screen, and the pan/tilt values should be calculated so as to hit that point on the screen. Click [Move] to get the turret to get there, and then you can [Fire] at will.
