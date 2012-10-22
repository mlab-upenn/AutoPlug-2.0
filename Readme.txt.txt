A. TORCS and Autonet


Step 1: 

Download and install TORCS (for Linux) from http://torcs.sourceforge.net/ 
Follow the installation steps given in the website.

Step 2:

Place ESE519->TORCS->autonet in the folder where the other driver files are.

Step 3:

Apply the torcs-individual-brakes patch.

If you have problems with this step, look into the patch file and manually copy/paste the sections of code to the car.h and brakes.cpp files (if you go through them, you will see where the patch adds code).


B. Firware

Step 1:

Download and install CodeWarrior for the HCS12(X) series from http://www.freescale.com/webapp/sps/site/overview.jsp?code=CW_DOWNLOADS

Step 2:

For the basic version of AutoPlug 2.0 (without Nano-RK), goto the ESE519->Firmware folder.

ABS_new is the project for the brakes ECU.
CruiseControl is the project for the Engine ECU.
CAN_serial is the project for the TORCS ECU.
Serial_CAN is the project for the MATLAB ECU.

Use codewarrior to flash the ECUs with their respective code.


C. Using the WiiMote steering input with autonet

Once TORCS has been setup and the ECUs have been flashed, 

Step 1:

Download and install the PCAN-USB driver from http://www.peak-system.com/Produktdetails.49+M5c6d753fe9e.0.html?&L=1&tx_commerce_pi1[catUid]=6&tx_commerce_pi1[showUid]=16

Download and install the Wiiuse library and libbluetooth-dev (or any other bluetooth library).

Step 2:

(Make and) Run driver_input.c from ESE519->Firrmware->WiiMote_PCAN

Press the 1 & 2 buttons on the WiiMote after executing driver_input, and the WiiMote should be connected. 

Press the home button on the WiiMote and the WiiMote is ready to use.

D. Racing in TORCS

Run TORCS and goto the Practice mode. Select a track and select the autonet driver. 
Start the race and you're ready to go.

E. MATLAB interface

On the machine running MATLAB, run ESE519->Matlab Gui->test_serial.m
(change the COM# if needed)



Note: Refer to the documentation for the Architecture. Also, AutoNet_Current has the NanoRK version of the code.

Link to the video http://www.youtube.com/watch?v=vchbkNtnr-U