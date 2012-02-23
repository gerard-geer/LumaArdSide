//Here's how the colors work. The arduino reads in a nine byte line:
//
//  [ContinuityByte A][Bank][Channel][Pattern][Param 1][Param 2][Param 3][Param 4][ContinuityByte B]
//  
//  Where each bracketed item is a byte.
//  
//  -The continuity bytes are a fixed value, and guard against signal corruption.
//  -The bank determines which set of PWM pins to use.
//  -The channel is any of the three color channels, or the preset channel. 
//  -The parameters are used by the patterns, noting that not all 4 will always be used.
//   While each byte will always be present in the signal, depending on the values in 
//   [channel] and [pattern] the arduino will read only the first [x] parameters in to use.
//   Note that all four parameter bytes must be present for the signal to be considered valid.



//The continuity bytes. If we recieve both of these, that means that the signal was not corrupted.
//The first one is a predefined value intended simply to flag the correct start of the signal.
//The second one however is a checksum that takes the integer-divided average of the previous 8 bytes.
//If the checksum value recieved is the same as the one computed at the time of reception,
//the signal is considered valid and its contents are copied from temporary storage to the appropriate
//variables.

byte cByteA;
byte cByteB;


//The color channel. 
//0: Red
//1: Green
//2: Blue
//3: All (For presets)
//If the channel is set to 0, 1 or 2, all three prescribed
//color channel patterns will be displayed. However, if channel
//is set to 3, only the preset will be displayed.

//Bank A value.
byte channelA;
//Bank B value.
byte channelB;

/*
The pattern. When on channel 3 this selects the preset.
 On other channels, this is the pattern of that channel.
 Presets:
 0: Police
 1: Lava
 2: Ocean
 3: Forest
 4: Defcon 1
 5: Rainbow
 6: Darkness
 7: RGB Spin
 8: White
 9: Random
 
 Patterns:
 0: Flash  (Maximum brightness, minimum brightness, speed, unused)
 1: Sine   (Maximum brightness, minimum brightness, speed, unused)
 2: Cosine (Maximum brightness, minimum brightness, speed, unused)
 3: Ramp   (Maximum brightness, minimum brightness, speed, unused)
 4: Reverse Ramp    (Maximum brightness, minimum brightness, speed, unused)
 5: Absolute Sine   (Maximum brightness, minimum brightness, speed, unused)
 6: Absolute Cosine (Maximum brightness, minimum brightness, speed, unused)
 7: Random (Maximum brightness, minimum brightness, min length, max length)
 8: Full (Brightness, unused, unused, unused)
 9: Zero sine    (Maximum brightness, speed, unused, unused)
 10:Zero cosine  (Maximum brightness, speed, unused, unused)
 */
//Bank A values.
byte patternRA;
byte patternGA;
byte patternBA;
byte patternPA;
//Bank B values.
byte patternRB;
byte patternGB;
byte patternBB;
byte patternPB;

//The parameters. Each can be any value between 0-255, and each must be
//present in the signal. When a parameter is used for time, one unit will represent
//1/25th of a second. When used for brightness, one unit will be equivalent to 
//1/255th of the total brightness.
//Bank A values
byte paramARA;
byte paramBRA;
byte paramCRA;
byte paramDRA;
byte paramAGA;
byte paramBGA;
byte paramCGA;
byte paramDGA;
byte paramABA;
byte paramBBA;
byte paramCBA;
byte paramDBA;
//Bank B values
byte paramARB;
byte paramBRB;
byte paramCRB;
byte paramDRB;
byte paramAGB;
byte paramBGB;
byte paramCGB;
byte paramDGB;
byte paramABB;
byte paramBBB;
byte paramCBB;
byte paramDBB;


//The representation of the pwm banks. We have two arrays to store the pin
//numbers for each bank. Index 0 is always the red pin, index 1 is green, and
//index 2 is blue.
byte bankToSet;
byte bankA[3];
byte bankB[3];

//In order to do trignometry we need to have an incremented value that we can
//base the angle off of. We gain this functionality by incrementing this value every time
//through loop().
long count;

//These variables are used to store the signal before it is processed.
byte cbytea;
byte bankbyte;
byte chanbyte;
byte patbyte;
byte pbyte1;
byte pbyte2;
byte pbyte3;
byte pbyte4;
byte cbyteb;

//This boolean stores whether or not the signal has been verified AND not processed.
boolean hasNotBeenUsed;

//These booleans represent the validity of the continuity bytes.
boolean passA;
boolean passB;

//Stationary values used for the random preset.
//Bank A values
long randTimeRA;
byte randBrightRA;
long randTimeGA;
byte randBrightGA;
long randTimeBA;
byte randBrightBA;
//Bank B values
long randTimeRB;
byte randBrightRB;
long randTimeGB;
byte randBrightGB;
long randTimeBB;
byte randBrightBB;


/*==================================================================================================================*\
||  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  SETUP  || 
\*==================================================================================================================*/
//Set up all the values, filling some with placeholders.
void setup(){
  
  //Begin serial communication.
  Serial.begin(9600);
  
  //Set the flag value.
  cByteA = 153;

  //Put a placeholder in the other continuity byte.(The checksum)
  cByteB = 0;



  //Put a default in the channel byte.
  channelA = 3;
  channelB = 2;

  //Assign pins to the banks.
  bankA[0] = 3;
  bankA[1] = 5;
  bankA[2] = 6;

  bankB[0] = 9;
  bankB[1] = 10;
  bankB[2] = 11;

  //Set up those pins.
  for(int i = 0; i < 3; i++){
    pinMode(bankA[i], OUTPUT);
    pinMode(bankB[i], OUTPUT);
  }

  //Set defaults to the patterns.
  patternRA = 8;
  patternGA = 8;
  patternBA = 8;
  patternPA = 0;

  patternRB = 8;
  patternGB = 8;
  patternBB = 8;
  patternPB = 0;

  //Set default parameters.
  //Red
  paramARA = 255;
  paramBRA = 0;
  paramCRA = 60;
  paramDRA = 0;
  //Green
  paramAGA = 255;
  paramBGA = 0;
  paramCGA = 60;
  paramDGA = 0;
  //Blue
  paramABA = 255;
  paramBBA = 0;
  paramCBA = 60;
  paramDBA = 0;
  
  //Red
  paramARB = 0;
  paramBRB = 0;
  paramCRB = 60;
  paramDRB = 0;
  //Green
  paramAGB = 255;
  paramBGB = 0;
  paramCGB = 60;
  paramDGB = 0;
  //Blue
  paramABB = 255;
  paramBBB = 0;
  paramCBB = 60;
  paramDBB = 0;
  
  //Initialize random's values.
  randTimeRA   = 8000000;
  randBrightRA = 255;
  randTimeGA   = 8000000;
  randBrightGA = 255;
  randTimeBA   = 8000000;
  randBrightBA = 255;
  randTimeRA   = 8000000;
  randBrightRA = 255;
  randTimeGA   = 8000000;
  randBrightGA = 255;
  randTimeBA   = 8000000;
  randBrightBA = 255;
  
  //Initialize count to zero.
  count = 0;
  
  //Set up the booleans.
  hasNotBeenUsed = true;
  passA = false;
  passB = false;
}


/*==================================================================================================================*\
|| LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP  LOOP || 
\*==================================================================================================================*/
void loop(){
  //Load in a signal if there is one.
  if(Serial.available() > 8){
    //The serial buffer is a stack, so we have
    //to read in the items in reverse order.
    cbytea   = byte(Serial.read());
    bankbyte = byte(Serial.read());
    //Serial.print(" bankbyte: "+bankbyte);
    chanbyte = byte(Serial.read());
    //Serial.print(pbyte3);
    patbyte  = byte(Serial.read());
    //Serial.print(pbyte2);
    pbyte1   = byte(Serial.read());
    //Serial.print(pbyte1);
    pbyte2   = byte(Serial.read());
    //Serial.print(patbyte);
    pbyte3   = byte(Serial.read());
    //Serial.print(chanbyte);
    pbyte4   = byte(Serial.read());
    //Serial.print(bankbyte);
    cbyteb   = byte(Serial.read());
    //Serial.print(cbytea); 
//    //Verify the continuity bytes.
////    if(true){
////      passA = true;
////    }
////    if(cbyteb == (int)((pbyte4 + pbyte3 + pbyte2 + pbyte1 + patbyte + chanbyte + bankbyte + cbytea)/8)){
////      passA = true;
////    }
//    
//    //Based on the above conclusions, copy the signal data to our local craps.
   // if(true)
//      //Use the value of bankbyte to set the appropriate bank's characteristics.
//      bankToSet = bankbyte;
      if(bankbyte == 0){
        channelA = chanbyte;
        switch(channelA){
          case 0: patternRA = patbyte;
                  paramARA = pbyte1;
                  paramBRA = pbyte2;
                  paramCRA = pbyte3;
                  paramDRA = pbyte4;
                  break;
          case 1: patternGA = patbyte;
                  paramAGA = pbyte1;
                  paramBGA = pbyte2;
                  paramCGA = pbyte3;
                  paramDGA = pbyte4;
                  break;
          case 2: patternBA = patbyte;
                  paramABA = pbyte1;
                  paramBBA = pbyte2;
                  paramCBA = pbyte3;
                  paramDBA = pbyte4;
                  break;
          case 3: patternPA = patbyte;
                  break;
          default:break;
        }
      }
      else if(bankbyte == 1){
        channelB = chanbyte;
        switch(channelB){
          case 0: patternRB = patbyte;
                  paramARB = pbyte1;
                  paramBRB = pbyte2;
                  paramCRB = pbyte3;
                  paramDRB = pbyte4;
                  break;
          case 1: patternGB = patbyte;
                  paramAGB = pbyte1;
                  paramBGB = pbyte2;
                  paramCGB = pbyte3;
                  paramDGB = pbyte4;
                  break;
          case 2: patternBB = patbyte;
                  paramABB = pbyte1;
                  paramBBB = pbyte2;
                  paramCBB = pbyte3;
                  paramDBB = pbyte4;
                  break;
           case 3:patternPB = patbyte;
                  break;
          default:break;
        }
      }
    
//    
//    //At this point all needed message bytes have been accounted for. So we can now churn
//    //through the rest of the buffer clearing out extra craps. This can void a next 
//    //command, if it was recieved within a few microseconds. But since we are no longer sending
//    //three packets of three bytes sent over the course of a second, reliability is greatly improved.
//    while(Serial.available()>=0){
//      Serial.read();
//    }
  }
     
  //Drive lights. Based on the most recent signal per bank we modulate the current sent to each
  //transistor.
  //Bank 1:
  if(channelA == 3){//If the channel chosen by the most recent signal is 3(fourth), use the predefined channel.
    switch(patternPA){
      case 0: police(bankA);break;
      case 1: lava(bankA);break;
      case 2: ocean(bankA);break;
      case 3: forest(bankA);break;
      case 4: defcon(bankA);break;
      case 5: rainbow(bankA);break;
      case 6: dark(bankA);break;
      case 7: rgb(bankA);break;
      case 8: white(bankA);break;
      case 9: rand(bankA, 0);break;
      default: break;
    }
  }
  else{//If it is not channel 3, write to all three of the other channels.(0, 1, 2).
    //Channel 0
    switch(patternRA){
      case 0: flash(  bankA, paramARA, paramBRA, paramCRA, 0);break;
      case 1: sine(   bankA, paramARA, paramBRA, paramCRA, 0);break;
      case 2: cosine( bankA, paramARA, paramBRA, paramCRA, 0);break;
      case 3: ramp(   bankA, paramARA, paramBRA, paramCRA, 0);break;
      case 4: revRamp(bankA, paramARA, paramBRA, paramCRA, 0);break;
      case 5: absSin( bankA, paramARA, paramBRA, paramCRA, 0);break;
      case 6: absCos( bankA, paramARA, paramBRA, paramCRA, 0);break;
      case 7: rand(   bankA, paramARA, paramBRA, paramCRA, paramDRA, byte(0), 0);break;
      case 8: full(   bankA, paramARA, 0);break;
      case 9: zeroSin(bankA, paramARA, paramBRA, 0);break;
      case 10:zeroCos(bankA, paramARA, paramBRA, 0);break;
      default: break;
    }
    //Channel 1
    switch(patternGA){
      case 0: flash(  bankA, paramAGA, paramBGA, paramCGA, 1);break;
      case 1: sine(   bankA, paramAGA, paramBGA, paramCGA, 1);break;
      case 2: cosine( bankA, paramAGA, paramBGA, paramCGA, 1);break;
      case 3: ramp(   bankA, paramAGA, paramBGA, paramCGA, 1);break;
      case 4: revRamp(bankA, paramAGA, paramBGA, paramCGA, 1);break;
      case 5: absSin( bankA, paramAGA, paramBGA, paramCGA, 1);break;
      case 6: absCos( bankA, paramAGA, paramBRA, paramCGA, 1);break;
      case 7: rand(   bankA, paramAGA, paramBGA, paramCGA, paramDRA, byte(1), 0);break;
      case 8: full(   bankA, paramAGA, 1);break;
      case 9: zeroSin(bankA, paramAGA, paramBGA, 1);break;
      case 10:zeroCos(bankA, paramAGA, paramBGA, 1);break;
      default: break;
    }
    //Channel 2
    switch(patternBA){
      case 0: flash(  bankA, paramABA, paramBBA, paramCBA, 2);break;
      case 1: sine(   bankA, paramABA, paramBBA, paramCBA, 2);break;
      case 2: cosine( bankA, paramABA, paramBBA, paramCBA, 2);break;
      case 3: ramp(   bankA, paramABA, paramBBA, paramCBA, 2);break;
      case 4: revRamp(bankA, paramABA, paramBBA, paramCBA, 2);break;
      case 5: absSin( bankA, paramABA, paramBRA, paramCBA, 2);break;
      case 6: absCos( bankA, paramABA, paramBBA, paramCBA, 2);break;
      case 7: rand(   bankA, paramABA, paramBBA, paramCBA, paramDRA, byte(2), 0);break;
      case 8: full(   bankA, paramABA, 2);break;
      case 9: zeroSin(bankA, paramABA, paramBBA, 2);break;
      case 10:zeroCos(bankA, paramABA, paramBBA, 2);break;
      default: break;
    }
  }
  
  //Bank 2
  if(channelB == 3){//If the channel chosen by the most recent signal is 3(fourth), use the predefined channel.
      switch(patternPB){
        case 0: police(bankB);break;
        case 1: lava(bankB);break;
        case 2: ocean(bankB);break;
        case 3: forest(bankB);break;
        case 4: defcon(bankB);break;
        case 5: rainbow(bankB);break;
        case 6: dark(bankB);break;
        case 7: rgb(bankB);break;
        case 8: white(bankB);break;
        case 9: rand(bankB, 0);break;
        default: break;
      }
  }
  else{//If it is not channel 3, write to all three of the other channels.(0, 1, 2).
    //Channel 0
    switch(patternRB){
      case 0: flash(  bankB, paramARB, paramBRB, paramCRB, 0);break;
      case 1: sine(   bankB, paramARB, paramBRB, paramCRB, 0);break;
      case 2: cosine( bankB, paramARB, paramBRB, paramCRB, 0);break;
      case 3: ramp(   bankB, paramARB, paramBRB, paramCRB, 0);break;
      case 4: revRamp(bankB, paramARB, paramBRB, paramCRB, 0);break;
      case 5: absSin( bankB, paramARB, paramBRB, paramCRB, 0);break;
      case 6: absCos( bankB, paramARB, paramBRB, paramCRB, 0);break;
      case 7: rand(   bankB, paramARB, paramBRB, paramCRB, paramDRB, byte(0), 1);break;
      case 8: full(   bankB, paramARB, 0);break;
      case 9: zeroSin(bankB, int(paramARB), int(paramBRB), 0);break;
      case 10:zeroCos(bankB, int(paramAGB), int(paramBGB), 0);break;
      default: break;
    }
    //Channel 1
    switch(patternGB){
      case 0: flash(  bankB, paramAGB, paramBGB, paramCGB, 1);break;
      case 1: sine(   bankB, paramAGB, paramBGB, paramCGB, 1);break;
      case 2: cosine( bankB, paramAGB, paramBGB, paramCGB, 1);break;
      case 3: ramp(   bankB, paramAGB, paramBGB, paramCGB, 1);break;
      case 4: revRamp(bankB, paramAGB, paramBGB, paramCGB, 1);break;
      case 5: absSin( bankB, paramAGB, paramBGB, paramCGB, 1);break;
      case 6: absCos( bankB, paramAGB, paramBGB, paramCGB, 1);break;
      case 7: rand(   bankB, paramAGB, paramBGB, paramCGB, paramDRB, byte(1), 1);break;
      case 8: full(   bankB, paramAGB, 1);break;
      case 9: zeroSin(bankB, int(paramAGB), int(paramBGB), 0);break;
      case 10:zeroCos(bankB, int(paramAGB), int(paramBGB), 0);break;
      default: break;
    }
    //Channel 2
    switch(patternBB){
      case 0: flash(  bankB,  paramABB, paramBBB, paramCBB, 2);break;
      case 1: sine(   bankB,  paramABB, paramBBB, paramCBB, 2);break;
      case 2: cosine( bankB,  paramABB, paramBBB, paramCBB, 2);break;
      case 3: ramp(   bankB,  paramABB, paramBBB, paramCBB, 2);break;
      case 4: revRamp(bankB, paramABB, paramBBB, paramCBB, 2);break;
      case 5: absSin( bankB, paramABB, paramBBB, paramCBB, 2);break;
      case 6: absCos( bankB, paramABB, paramBBB, paramCBB, 2);break;
      case 7: rand(   bankB, paramABB, paramBBB, paramCBB, paramDRB, byte(2), 1);break;
      case 8: full(   bankB, paramABB, 2);break;
      case 9: zeroSin(bankB, int(paramABB), int(paramBBB), 2);break;
      case 10:zeroCos(bankB, int(paramABB), int(paramBBB), 2);break;
      default: break;
    }
  }
  iterateCounter();
}


/*==================================================================================================================*\
||   LIGHTING  LIGHTING  LIGHTING  LIGHTING  LIGHTING  LIGHTING  LIGHTING  LIGHTING  LIGHTING  LIGHTING  LIGHTING   || 
\*==================================================================================================================*/

/*==========================\
|| COUNTER ITERATION       ||
\==========================*/

/*This iterates the counter (count). Ideally this should be called
every time through loop(). It resets down to zero at 32,765 to avoid
overflow.*/
void iterateCounter(){
  count = count+1;
  if(count >= 999999999){
    count = 0;
  }
}


/*==========================\
|| COLOR WRITING UTILITIES ||
\==========================*/

/*This writes a color to a given channel in a given bank.*/
void writeColor(byte channel, float value, byte bank[]){
  if(channel < 3 && channel >= 0){
    analogWrite(bank[channel], value);
  }
}

/*This writes to all pins of a bank*/
void writeColors(float r, float g, float b, byte bank[]){
  writeColor(0, r, bank);
  writeColor(1, g, bank);
  writeColor(2, b, bank);
}

/*==========================\
|| SINGLE CHANNEL PATTERNS ||
\==========================*/

/*Uses modulus and the counter to generate a square wave the given parameters on the
 given channel in a given */
void flash(byte bank[], byte maxB, byte minB, byte time, byte channel){
  //Prevent multiplication by zero.
  if(time == 0){
    time = 1;
  }
  if(count%(2*time*100) < time*100){
    writeColor(channel, maxB, bank);
  }
  else{
    writeColor(channel, minB, bank);
  }
}

/*Uses trig to make a sine flash the given channel in the given bank with the current parameters.*/
void sine(byte bank[], byte maxB, byte minB, byte time, byte channel){  
  writeColor(channel, minB + ((maxB-minB)*sq(sin(count*(.000001*(255-time))))), bank);
}

/*Uses trig to make a cosine flash the given channel in the given bank with the current parameters.*/
void cosine(byte bank[], byte maxB, byte minB, byte time, byte channel){  
  writeColor(channel, minB + ((maxB-minB)*sq(cos(count*(.000001*(255-time))))), bank);
}

/*An ascending saw wave function.*/
void ramp(byte bank[], byte maxB, byte minB, byte time, byte channel){
  if(time == 0){time = 1;}
  float bstep = float(maxB-minB)/float(10+10*time);
  writeColor(channel, byte((maxB-minB)%int(count*bstep)), bank);
}

/*A descending saw wave fun*/
void revRamp( byte bank[], byte maxB, byte minB, byte time, byte channel){
  if(time == 0){time = 1;}
  float timestep = float(maxB-minB)/float(10+10*time);
  writeColor(channel, maxB-byte((maxB-minB)%long((count/100)*timestep)), bank);
}

/*As opposed to the other sine which uses the square of sine, this uses the
absolute value of sine, which gives a more bouncy effect.*/
void absSin(byte bank[], byte maxB, byte minB, byte time, byte channel){  
  writeColor(channel, minB + ((maxB-minB)*abs(sin(count*(.00001*(255-time))))), bank);
}

/*As opposed to the other cosine which uses the square of sine, this uses the
absolute value of cosine, which gives a more bouncy effect.*/
void absCos(byte bank[], byte maxB, byte minB, byte time, byte channel){  
  writeColor(channel, minB + ((maxB-minB)*abs(cos(count*(.00001*(255-time))))), bank);
}

/*Full. Just a steady color.*/
void full(byte bank[], byte brightness, byte channel){
  writeColor(channel, brightness, bank);
}

/*This sine function is not accounted for dropping below zero, which gives it a period
of full off.*/
void zeroSin(byte bank[], int maxB, int time, byte channel){  
  if((maxB*sin(double(count*(.00001*(255-time)))))> 0){
    writeColor(channel, (maxB*sin(count*(.00001*(255-time)))), bank);
  }
  else{
    writeColor(channel, 0, bank);
  }
}

/*This cosine function is also not accounted for zero, and also goes full off.*/
void zeroCos(byte bank[], int maxB, int time, byte channel){
  if((maxB*cos(double(count*(.00001*(255-time)))))> 0){
    writeColor(channel, (maxB*cos(count*(.00001*(255-time)))), bank);
  }
  else{
    writeColor(channel, 0, bank);
  }
}

/*Maximum brightness, minimum brightness, min length, max length)*/
void rand(byte bank[], byte minB, byte maxB, long minTime, long maxTime, byte channel, byte bankval){

  if(bankval == 0){
    switch(channel){
      case 0:  if(count%randTimeRA == 0){
                 randTimeRA = long(random(minTime, maxTime));
                 randBrightRA = random(minB, maxB);
               }
               writeColor(channel, byte(randBrightRA), bank);
               break;
      case 1:  if(count%randTimeGA == 0){
                 randTimeGA= long(random(minTime, maxTime));
                 randBrightGA = byte(random(minB, maxB));
               }
               writeColor(channel, byte(randBrightGA), bank);
               break;
      case 2:  if(count%randTimeBA == 0){
                 randTimeBA = long(random(minTime, maxTime));
                 randBrightBA = byte(random(minB, maxB));
               }
               writeColor(channel, byte(randBrightBA), bank);
               break;
    }
  }
  if(bankval == 1){
    switch(channel){
      case 0:  if(count%randTimeRB == 0){
                 randTimeRB = random(maxTime, minTime);
                 randBrightRB = byte(random(minB, maxB));
               }
               writeColor(channel, byte(randBrightRB), bank);
               break;
      case 1:  if(count%randTimeGB == 0){
                 randTimeGB= random(maxTime, minTime);
                 randBrightGB = byte(random(minB, maxB));
               }
               writeColor(channel, byte(randBrightGB), bank);
               break;
      case 2:  if(count%randTimeBB == 0){
                 randTimeBB = random(maxTime, minTime);
                 randBrightBB = byte(random(minB, maxB));
               }
               writeColor(channel, byte(randBrightBB), bank);
               break;
    }
  }
}

/*==========================\
||  PRESET LIGHT PATTERNS  ||
\==========================*/

/*Police flashes between red and blue. Green stays on 
for general brightness.*/
void police(byte bank[]){
  if(count%3000<1500){
    writeColors(255, 30, 0, bank);
  }
  else{
    writeColors(0, 30, 200, bank);
  }
}

/*Lava pulses between red and yellow through orange, similar to how
sterotypical lava would glow.*/
void lava(byte bank[]){
  writeColors(255, 100+(100*sq(sin(count*.0001))), 0, bank);
}

/*Goes from blue to that shitty white of 255, 255, 255. That white
is however greenish blue white, which fits the motif of "ocean.*/
void ocean(byte bank[]){
  writeColors(255*sq(cos(count*.0001)), 255*sq(cos(count*.0001)), 255, bank);
}

/*Similar the forest preset, this goes from green to that shitty 
white of 255, 255, 255. That white is however greenish blue white, 
which fits the motif of "forest.*/
void forest(byte bank[]){
  writeColors(255*sq(cos(count*.0001)), 255, 255*sq(cos(count*.0001)), bank);
}

/*Simulates a flashing red alarm light. Essentially, this is red alert.*/
void defcon(byte bank[]){
  writeColors(255*sq(cos(count*.0004)), 6*sq(cos(count*.0004)), 6*sq(cos(count*.0004)), bank);
}

/*Dawg, it uses trig to go through a wide variety of hues. Aka rainbow.*/
void rainbow(byte bank[]){
  writeColors(255*sq(sin((count*.0001)+((0)))), 255*sq(sin((count*.0001)+(TWO_PI/3))), 255*sq(sin((count*.0001)+((2*TWO_PI)/3))), bank);
}


/*Cycles through some purple-y hues to calm the current mood.*/
void dark(byte bank[]){
  writeColors(255*abs(sin(count*.0001)), 0, 55+200*abs(sin((count*.0001)+(PI/4))), bank);
}

/*cycles through full r, g, and b.*/
void rgb(byte bank[]){
  if(count%10000 < 3333){
    writeColors(255, 0, 0, bank);
  }
  else if(count%10000 < 6666){
    writeColors(0, 255, 0, bank);
  }
  else{
    writeColors(0, 0, 255, bank);
  }
}

/*A nice clean white.*/
void white(byte bank[]){
  writeColors(255, 160, 60, bank);
}
  

/*Randomizes all three channels for you.*/
void rand(byte bank[], byte bankValue){
  rand(bank, byte(5), byte(255), byte(1000), byte(6000), byte(0), bankValue);
  rand(bank, byte(5), byte(255), byte(1000), byte(6000), byte(1), bankValue);
  rand(bank, byte(5), byte(255), byte(1000), byte(6000), byte(2), bankValue);
}