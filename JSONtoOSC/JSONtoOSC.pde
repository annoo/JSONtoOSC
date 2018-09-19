/**
 * Basic sketch to receive Serial messages from Microbit
 * and translates those to OSC-messages
 * 
 * You will need to adapt the USER PARAMETERS
 * and you will need to install a Library: oscP5
 * 
 * made for werkcollege AV&IT
 * by annoo
 * aug 2018
 *
 */

///////////////////// USER PARAMETERS /////////////////////////////

// this is the same as the default of your Microbit: 115200
final int baudRate = 115200;

// Go and look for the IP-address in the program you want to send to
// This is the address Processing sends to and this program listens to.
// Put this string in remoteIP, here.

//final String remoteIP = "192.168.1.43"; //eg. "127.0.0.1";
final String remoteIP = "127.0.0.1";

// Take note of the sendPort and fill this in in the program you want to send to.
// This is the port Processing sends to and the other program listens to.

final int sendPort   = 12000, 
          listenPort = 12020;
// The listenPort here is to actively debug.

// the portNames are here to debug as well.
// depending on your OS this is of genre "/dev/tty..." (linux and OSx) 
// or genre "COM..." (windows)
final String portName = "/dev/cu.usbmodem14312";

///////////////////// END of USER PARAMETERS /////////////////////////////

import processing.serial.*;
import java.util.*;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

Serial commsPort;       // The serial port

boolean messageArrived = false;
String incoming = "", 
       incomingOSCMessage = "";
           
//final char contactCharacter = '|',
 //         newLine = '\r\n';

JSONObject inputLine;

/*
//Take the names and values out of the json
void processIncoming () {
  try{
    int serialnumber = inputLine.getInt("s");  
    String name = inputLine.getString("n");
    int value = inputLine.getInt("v");
  }
  // if an error occurs, let's catch it display and exit.
  catch(Exception ex){
    println("Exception Message: " + ex);
    exit();
  }
}
*/
/*
void makeOSC() {
    OscMessage myMessage = new OscMessage("/"+ name);
    myMessage.add(value);
    oscP5.send(myMessage, myRemoteLocation);
 }


void translateMessage() {
  processIncoming();
  makeOSC();
}
*/

// When we want to print to the window
/*
void ShowIncoming() {
  // to see incoming message, as set in the HashMap
  text("Incoming from Arduino", 20, 20);
  int y = 20;
  for (String key : newParams.keySet()) {
    y = y+20;
    text(key, 20, y);
    text(newParams.get(key), 300, y);
  }
}

void showOsc() {
  text(IncomingOSCMessage, 300, 200);
  IncomingOSCMessage ="";
}
*/

void setup() {
  size(1000, 800);  // Stage size
  fill(255);
  background(0);

  printArray(Serial.list());
  
  //printArray(Serial.list());
  commsPort = new Serial(this, portName, baudRate);
  //commsPort.bufferUntil(125);

  /* start oscP5, listening for incoming messages */
  oscP5 = new OscP5(this, listenPort);

  /* myRemoteLocation is a NetAddress */
  myRemoteLocation = new NetAddress(remoteIP, sendPort);
}

void draw() {
  if (messageArrived) {
    background(0);
    //translateMessage();
    //ShowIncoming();
    messageArrived= false;
  }
  //showOsc();
}

void serialEvent(Serial commsPort) {
  //String incoming = commsPort.readString();
  /*
   if (incoming != null) {
    println("incoming string:", incoming);
    //JSONObject inObj = parseJSONObject(incoming);
    //createOSCMessage(inObj); 
   }
  */
  // read a byte from the serial port:
  //println("String", incoming);

  char inChar = commsPort.readChar();
  switch (inChar) {
    case '{':
      incoming = "{";
      println("starting...");
      break;
    case '}':
      incoming += '}';
      println("String", incoming);
      try {
      JSONObject inObj = parseJSONObject(incoming);
        if (inObj == null) {
          println("Object could not be parsed");
        } else {
          println("Object could be parsed");
          createOSCMessage(inObj); 
        }
      } catch (e) {
        println("Error parsing:");
        e.printStackTrace();
      }
      incoming= "";
      break;
    default:
      incoming += inChar;
      break;
  }
}

void createOSCMessage(JSONObject obj) {
  println("creating oscmessage", obj);
  try{
    int serialnumber = obj.getInt("s");  
    String name = obj.getString("n");
    int value = obj.getInt("v");
    OscMessage myMessage = new OscMessage("/"+ name);
    myMessage.add(value);
    oscP5.send(myMessage, myRemoteLocation);
  }
  // if an error occurs, let's catch it display and exit.
  catch(Exception ex){
    println("Exception Message: " + ex);
    exit();
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {  
  float value = theOscMessage.get(0).floatValue(); // get the 1st osc argument
  String IncomingOSCMessage = "";
  IncomingOSCMessage += "\n" + 
                        String.format("### received an osc message: " + 
                        " addrpattern: " + 
                        theOscMessage.addrPattern() + 
                        " :  %f", 
                        value);
  println(IncomingOSCMessage);
}
