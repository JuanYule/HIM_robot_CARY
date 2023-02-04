/** //<>//
   Robot CARY - ESE - ENSEA
   by Juan Yule.

   Sends a byte out the serial port, and reads 3 bytes in.
   Sets foregound color, xpos, and ypos of a circle onstage
   using the values returned from the serial port.
   Thanks to Daniel Shiffman  and Greg Shakar for the improvements.

   Note: This sketch assumes that the device on the other end of the serial
   port is going to send a single byte of value 65 (ASCII A) on startup.
   The sketch waits for that byte, then sends an ASCII A whenever
   it wants more data.
*/
import java.util.ArrayList;
import java.util.List;
import java.util.*;

import processing.serial.*;

Serial myPort;                       // The serial port

int serialCount = 0;                 // A count of how many bytes we receive
int xpos, ypos, dpos;                // Starting position of the ball
boolean firstContact = false;        // Whether we've heard from the microcontroller

int comp;
int robotX, robotY, robotD;
List<Integer> dataRx = new ArrayList<Integer>();

List<Integer> dataManito = new ArrayList<Integer>();

int width_robot, height_robot;
int opacity = 255;  //opacity of the image
int opacity_vert = 0;
int opacity_rouge = 0;
int div_taille = 17;

int canette_rouge = 0;  //variables pour compter les canettes
int canette_vert = 0;

boolean porte_open = false;
boolean porte_close = true;

int canetteDx, canettePosX, canetteDy, canettePosY;
boolean flag_canette = false;

PImage img;
PImage robot_ouverte, robot_ouverte_vert, robot_ouverte_rouge, robot_ouverte_gris;
PImage robot_ferme, robot_ferme_vert, robot_ferme_rouge, robot_ferme_gris;

boolean flag_vert = false;
boolean flag_rouge = false;

boolean validation1 = false;
boolean validation2 = false;

boolean flag_end = false;

void setup() {
  size(1000, 600);  // Stage size
  surface.setTitle("CARY - Robot trieur de canettes !");
  //surface.setResizable(true);
  //surface.setLocation(100, 100);

  noStroke();      // No border on the next thing drawn

  // Set the starting position of the ball (middle of the stage)
  xpos = width / 5;
  ypos = height / 2;
  dpos = 270;
  //load images
  img = loadImage("robot.png");

  robot_ouverte = loadImage("robot_port_ouverte.png");
  robot_ouverte_vert = loadImage("robot_port_ouverte_green.png");
  robot_ouverte_rouge = loadImage("robot_port_ouverte_rouge.png");
  robot_ouverte_gris = loadImage("robot_port_ouverte_gris.png");

  robot_ferme = loadImage("robot_port_ferme.png");
  robot_ferme_vert = loadImage("robot_port_ferme_green.png");
  robot_ferme_rouge = loadImage("robot_port_ferme_rouge.png");
  robot_ferme_gris = loadImage("robot_port_ferme_gris.png");

  // We have the size of the robot,
  // WE divise by 4 for reduce the size
  width_robot = robot_ferme.width / div_taille;
  height_robot = robot_ferme.height / div_taille;

  //print de la taille/ dimentions de robot
  //println(robot_ferme.width);
  //println(robot_ferme.height);

  //println(robot_ouverte.width);
  //println(robot_ouverte.height);
  //=====================//

  // I know that the first port in the serial list on my PC
  // is always my  /dev/tty* , so I open Serial.list()[0].
  String portName = "/dev/ttyUSB0";
  myPort = new Serial(this, portName, 115200);
}

void draw() {
  background(255, 255, 255);

//Zone rouge
  fill(255, 0, 0);
  stroke(0);
  rectMode(CENTER);
  rect(0, height, 400, 600);
  noStroke();

    //Zone vert
  fill(0, 255, 0);
  stroke(0);
  rectMode(CENTER);
  rect(0, 0, 400, 600);
  noStroke();

  
  //=====Text position du robot======
  String str_pos_x = "x: " + str(xpos);
  String str_pos_y = "y: " + str(ypos);
  String str_angle = "A: " + str(dpos);
  
  textSize(20);
  fill(0);
  text(str_pos_x, 900, 20);  
  text(str_pos_y, 900, 40);
  text(str_angle, 900, 60);
  //================================
  
  //================================
  //Line axes
  stroke(0);
  line(width / 2, 0, width / 2, width);
  line(0, height / 2, width, height / 2);
  noStroke();

  if(validation1 == true && validation2 == true)
  {
    ypos = robotY;
    xpos = robotX;
    validation1 = false;
    validation2 = false;
  }

  // Draw the shape ROBOT
  pushMatrix();

  translate(xpos, ypos);
  point(0, 0);
  rotate(radians(dpos));
  //rectMode(CENTER);
  fill(255, 0, 0);
  
  if(xpos < 200)
  {
    if(ypos > 300)
    {
      flag_rouge = false;
    }
    else
    {
      flag_vert = false;
    }
  }


  if (porte_open == true)
  {
    if(porte_open == true && flag_rouge == true)
    {
      image(robot_ouverte_rouge, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    }
    else if(porte_open == true && flag_vert == true)
    {
      image(robot_ouverte_vert, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    }
    else
    {
      image(robot_ouverte, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    }
  }
  else if (porte_close == true)
  {
    if(porte_close == true && flag_rouge == true)
    {
      image(robot_ferme_rouge, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    }
    else if(porte_close == true && flag_vert == true)
    {
      image(robot_ferme_vert, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    }
    else
    {
      image(robot_ferme, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    }
    //tint(255, opacity);
    //image(robot_ouverte, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    //tint(255, opacity_rouge);
    //image(robot_ouverte_rouge, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
    //tint(255, opacity_vert);
    //image(robot_ouverte_green, -width_robot / 2, -height_robot / 5, width_robot, height_robot);
  }

  popMatrix();

  //dessing of circle
  if (flag_canette == true)
  {
    fill(#867F7F);
    circle(canettePosX, canettePosY, 45);
  }
}
// Function to modify the arrayList
public int valuesProcess(List<Integer> parameterList)
{
  int val_1 = 0;
  int val_2 = 0;
  int val_3 = 0;
  int val_4 = 0;
  
  int end_value = 0;
  boolean flag = false;

  Integer[] numbers = new Integer[] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  List<Integer> intNumbers = new ArrayList<>(Arrays.asList(numbers));

  for (int k = 1; k < 5; k++)
  {
    if (intNumbers.contains(parameterList.get(k) - 48))
    {
      //println("OK");
    }
    else
    {
      flag = true;
      //println("Erreur les valeurs ne sont pas chiffres");
      break;
    }
  }
  if (flag == false)
  {
    val_1 = (parameterList.get(1) - 48) * 1000;
    val_2 = (parameterList.get(2) - 48) * 100;
    val_3 = (parameterList.get(3) - 48) * 10;
    val_4 = (parameterList.get(4) - 48) * 1;
    end_value = val_1 + val_2 + val_3 + val_4;
  }
  else if (flag == true)
  {
    if (parameterList.get(0) == 'x')
    {
      end_value = xpos;
    }
    else if (parameterList.get(0) == 'y')
    {
      end_value = ypos;
    }
  }

  parameterList.clear();

  return end_value;
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  int inByte = myPort.read();
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller.
  // Otherwise, add the incoming byte to the array:
  if (firstContact == true) {
    myPort.clear();          // clear the serial port buffer
    firstContact = true;     // you've had first contact from the microcontroller
    myPort.write('A');       // ask for more
    dataRx.clear();
  }
  else {
    // Add the latest byte from the serial port to array:
    //serialInArray[serialCount] = inByte;
    if(inByte != 0){
      dataRx.add(inByte);
      serialCount++;
    }
    if(inByte == 'p')
    {
      //
      flag_end = true;
      dataManito.add(dataRx.get(serialCount-6));
      dataManito.add(dataRx.get(serialCount-5));
      dataManito.add(dataRx.get(serialCount-4));
      dataManito.add(dataRx.get(serialCount-3));
      dataManito.add(dataRx.get(serialCount-2));
      println(dataManito);
    }
    //println("%c", dataRx.get(serialCount-1));

    //Si, on a 4 bytes
    
    if (flag_end == true)
    {
      flag_end = false;
     // println(dataRx);
      serialCount = 0;
      comp = dataManito.get(0);
      if (comp == 'x')
      {
        validation1 = true;
        myPort.write('H'); //Position X de canette
        robotX = valuesProcess(dataManito);
        dataManito.clear();
        dataRx.clear();
        //println(robotX);
      }
      else if (comp == 'y') //Position y de canette
      {
        validation2 = true;
        myPort.write('H'); //imprime H = OK
        robotY = valuesProcess(dataManito);
        dataManito.clear();
        dataRx.clear();
        //println(robotY);
      }
      else if (comp == 'g') // Angle de robot
      {
        myPort.write('H'); //imprime H = OK
        robotD = valuesProcess(dataManito);
        dpos = robotD;
        dataManito.clear();
        dataRx.clear();
        
        //println(robotD);
      }
      else if (comp == 'v') // Position X de canette
      {
        myPort.write('H'); //imprime H = OK
        canetteDx = valuesProcess(dataManito);
        canettePosX = canetteDx;
        dataManito.clear();
        dataRx.clear();
        //println(robotD);
      }
      else if (comp == 'b') // Position Y de canette
      {
        flag_canette = true;
        myPort.write('H'); //imprime H = OK
        canetteDy = valuesProcess(dataManito);
        canettePosY = canetteDy;
        dataRx.clear();
        //println(robotD);
      }
      else if (comp == 'G') // Coleur vert
      {
        flag_vert = true;
        flag_rouge = false;
        flag_canette = false;
        myPort.write('H'); //imprime H = OK
        println("Green couleur good");
        dataManito.clear();
        dataRx.clear();
      }
      else if (comp == 'R') // Coleur rouge
      {
        flag_rouge = true;
        flag_vert = false;
        flag_canette = false;
        myPort.write('H'); //imprime H = OK
        println("Red couleur good");
        dataManito.clear();
        dataRx.clear();
      }
      else if (comp == 'o') // Commande porte ouverte
      {
        porte_open =  true;
        porte_close = false;
        myPort.write('H'); //imprime H = OK
        println("Porte ouverte");
        dataManito.clear();
        dataRx.clear();
      }
      else if (comp == 'c') // Commande porte ferme
      {
        porte_open =  false;
        porte_close = true;
        myPort.write('H'); //imprime H = OK
        println("porte close");
        dataManito.clear();
        dataRx.clear();
      }
      else if (comp == 'J') // Commande porte ferme
      {
        myPort.write('H'); //imprime H = OK
        println("porte close");
        dataManito.clear();
        dataRx.clear();
      }
      else if (comp == 'K') // Commande porte ferme
      {
        myPort.write('H'); //imprime H = OK
        println("porte close");
        dataManito.clear();
        dataRx.clear();
      }
      else
      {
        println(dataManito);
        dataManito.clear();
        dataRx.clear();
        println("erreur dans la reception\n\r");
        myPort.write("Erreur données\n\r");
      }
    }
  }
}
