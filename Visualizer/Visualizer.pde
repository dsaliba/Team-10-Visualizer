import mqtt.*;
import java.util.Scanner;
import processing.sound.*;

MQTTClient client;

int s = 35;
//int s = 7;
SoundFile ding;

boolean ping = false;
String textBuffer = "";
boolean readingText = false;
String prompt;
int tbW = 500;
int tbH = 100;
int mask = -1;

String team = "team10";
String user = "group10";
String pass = "amager532";





enum State {IDLE, SET_MASK, SAVING, LOADING, BLURING, SIZING};
State state = State.IDLE;


int[][] grid = new int[s][s];
int[][] modGrid = new int[s][s];
boolean showText = false;
Scanner snr = new Scanner(System.in);
boolean typing = false;


void setup() {
  String[] lines = loadStrings("data/userinfo.txt");
  team = lines[0];
  user = lines[1];
  pass = lines[2];
  changeSize(parseInt(lines[3]));
  client = new MQTTClient(this);
  client.connect("mqtt://"+team+":"+pass+"@robomqtt.cs.wpi.edu", user);
  //client.connect("mqtt://team12:saltholm989@robomqtt.cs.wpi.edu", "group12");
  size(1050, 1050);
  //size(448, 448);
  ding = new SoundFile(this, "ding.mp3");
}

void update() {
   switch(state) {
     case SAVING:
       if (!readingText) {
         saveGrid(textBuffer);
         state = State.IDLE;
       }
       break;
     case LOADING:
       if (!readingText) {
         loadGrid(textBuffer);
         state = State.IDLE;
       }
       break;
     case SET_MASK:
       if (!readingText) {
         mask = parseInt(textBuffer);
         state = State.IDLE;
       }
       break;
     case BLURING:
       if (!readingText) {
         int counts = parseInt(textBuffer);
         for (int i = 0; i < counts; i++) {
           blur();
         }
         state = State.IDLE;
       }
       break;
     case SIZING:
       if (!readingText) {
         changeSize(parseInt(textBuffer));
         state = State.IDLE;
       }
       break;
   }
}

void colorSelect(int i) {
  if (i == 0) {
    fill(67, 69, 69);
    return;
  }
  float percent = (i/255.0);
  int red1 = 233;
  int green1 = 229;
  int blue1 = 70;
  int red2 = 16;
  int green2 = 212;
  int blue2 = 69;
  int resultRed = (int)(red1 + percent * (red2 - red1));
  int resultGreen = (int)(green1 + percent * (green2 - green1));
  int resultBlue = (int)(blue1 + percent * (blue2 - blue1));
  fill(resultRed, resultGreen, resultBlue);
  
}

void draw() {
  update();
  clear();
  background(255);
  rectMode(CORNER);
  alpha(255);
  for (int i = 0; i < s; i++) {
    for (int j = 0; j < s; j++) {
      if (mask > 1) {
        colorSelect((grid[i][j]>mask?255:0));
      } else {
        colorSelect(grid[i][j]);
      }
      
      //fill(grid[i][j]==0?255:0);
      float pixSize = width/s;
      rect(i*pixSize, j*pixSize, pixSize, pixSize);
      //rect(i*64, j*64, 64, 64);
      colorSelect(0);
      if(showText) {
        textSize(pixSize/2);
        text(""+grid[i][j], i*pixSize, j*pixSize+pixSize/2);
      }
      
    }
  }
  
  if (readingText) {
    rectMode(CENTER);
    strokeWeight(3);
    stroke(255);
    fill(67, 69, 69, 200);
    rect(width/2, height/2, tbW, tbH);
    strokeWeight(1);
    stroke(0);
    fill(255);
    textSize(24);
    text(prompt + ": " +textBuffer, width/2-tbW/3, height/2+16);
  }
}

void keyPressed() {
  if (readingText) {
    
    if (key == ENTER) {
      println(textBuffer);
      readingText = false;
    } else if (key == BACKSPACE) {
      if (textBuffer.length() > 0) textBuffer = textBuffer.substring(0, textBuffer.length()-1);
    }else {
      textBuffer += key;
    }
    return;
  }
  switch(key) {
    case 't':
      showText = !showText;
      break;
    case 'p':
      client.publish(team+"/(2, 2)", "255");
      //grid[2][2] = 155;
      break;
    case 'd':
        ding.play();
      break;
    case 'w':
        wipe();
      break;
    case 's':
      state = State.SAVING;
      readingText = true;
      prompt = "Save Grid As";
      textBuffer = "";
      break;
    case 'l':
      state = State.LOADING;
      readingText = true;
      prompt = "Load Grid From";
      textBuffer = "";
      break;
    case 'm':
      state = State.SET_MASK;
      readingText = true;
      prompt = "Mask Size";
      textBuffer = "";
      break;
    case 'b':
      state = State.BLURING;
      readingText = true;
      prompt = "Blur Strength";
      textBuffer = "";
      break;
    case 'r':
      state = State.SIZING;
      readingText = true;
      prompt = "New Grid Size";
      textBuffer = "";
      break;
      
  }
   
}

void clientConnected() {
  println("client connected");

  client.subscribe(team+"/#");
}

void wipe() {
  for (int r = 0; r < s; r++) {
    for (int c = 0; c < s; c++) {
      grid[r][c] = 0;
    }
  }
}

void messageReceived(String topic, byte[] payload) {
  if (!ping) {
    ding.play();
    ping = true;
  }
  String pay = new String(payload);
  String addy = topic;
  
  addy = addy.replace(team+"/(", "");
  addy = addy.replace(")", "");
  addy = addy.replace(" ", "");
  String[] ars = addy.split(",");
  int j = parseInt(ars[0]);
  int i = parseInt(ars[1]);
  int p = parseInt(pay);
  println("(" + i + ", " + j + "): " + pay);
  if (i<s && j<s){
    grid[i][j] = p;
  }
  
  
  
}

void connectionLost() {
  println("connection lost");
}

void saveGrid(String name) {
  Table ret = new Table();
  for (int j = 0; j < s; j++) {
    ret.addColumn(""+j);
  }
  for (int i = 0; i < s; i++) {
    TableRow newRow = ret.addRow();
    for (int j = 0; j < s; j++) {
      newRow.setInt(""+j, grid[i][j]);
    }
  }
  saveTable(ret, "data/saves/" + name + ".csv");
}

void loadGrid(String name) {
  Table t = loadTable("data/saves/"+name+".csv", "header");
  for (int i = 0; i < min(t.getRowCount(), s); i++) {
    for (int j = 0; j < min(t.getColumnCount(), s); j++) {
      grid[i][j] = t.getInt(i, j);
    }
  }
}

void changeSize(int ns) {
  s = ns;
  grid = new int[s][s];
  modGrid = new int[s][s];
}

void blur() {
  for (int r = 0; r < s; r++) {
    for (int c = 0; c < s; c++) {
      float avg = 0;
      int count = 0;
      for (int rMod = -1; rMod < 2; rMod++) {
        for (int cMod = -1; cMod < 2; cMod++) {
          if ((r+rMod) > -1 && (r+rMod) < s && (c+cMod) > -1 && (c+cMod) < s) {
            avg += grid[r+rMod][c+cMod];
            count++;
          }
        }
      }
      //Dampen blur
      avg += 50*grid[r][c];
      count += 50;
      avg /= count;
      modGrid[r][c] = (int)avg;
    }
  }
  for (int r = 0; r < s; r++) {
    for (int c = 0; c < s; c++) {
      grid[r][c] = modGrid[r][c];
    }
  }
}


/*
team10
group10
amager532

*/
