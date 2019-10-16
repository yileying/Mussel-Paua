
The setup consists of MyoWare™ Muscle Sensor output connected to the analog pin (A0) of Arduino board which is in turn connected to a PC running the [Processing](https://processing.org) (Java) program that is reading the data from the serial port (over USB connection).  

In our setup the arduino board is only used to digitize the analog signal and send it to serial port, you can find the Arduino code in [send2serial.ino](send2serial.ino) file.  

The Java program running on the PC analyses the signal from the MyoWare™ Muscle Sensor and triggers actions like playing an animation with sound or emulating a keyboard or mouse action depending on muscle activity, you can find the PC program code in [mussel_paua.pde](mussel_paua.pde) file.  

[![Creative Commons Licence](https://i.creativecommons.org/l/by-nc/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc/4.0/)  
This work is licensed under a [Creative Commons Attribution-NonCommercial 4.0 International License](http://creativecommons.org/licenses/by-nc/4.0/).