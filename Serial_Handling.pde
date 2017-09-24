void serialEvent(Serial port){
try{
   String inData = port.readStringUntil('\n');
   inData = trim(inData);                 // cut off white space (carriage return)

 
   if (inData.charAt(0) == 'B'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     BPM = int(inData);                   // convert the string to usable int
   }
   
    if (inData.charAt(0) == 'Q'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     pulseTime = int(inData);                   // convert the string to usable int
   }
   
   if (inData.charAt(0) == 'S'){          // leading 'B' for BPM data
     inData = inData.substring(1);        // cut off the leading 'B'
     Signal = int(inData);                   // convert the string to usable int
   }
   
   
} catch(Exception e) {
  // println(e.toString());
}
}