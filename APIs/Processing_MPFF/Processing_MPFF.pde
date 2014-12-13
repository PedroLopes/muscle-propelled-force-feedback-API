import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import java.util.ArrayList;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
import android.content.Context;

//if you want to DEBUG_BT, check the variables below (TRUE means it will print more details)
boolean DEBUG_BT = false; //prints bluetooth information
boolean DEBUG_TOUCH = false; // prints touch events
boolean DEBUG_EVENTS = false; // prints events from android 

final int SEARCHING = 1;
final int SHOW_ERROR = 2;
final int RUN = 3;
int state;

private static final int REQUEST_ENABLE_BT = 3;
ArrayList devices;
BluetoothAdapter adapter;
BluetoothDevice device;
BluetoothSocket socket;
InputStream ins;
OutputStream ons;
boolean relay1 = false;
boolean relay2 = false;
PFont f1;
PFont f2;
String error;
PFont mono;

void setup() {
  size(1280, 720); //this should be the size of your display
  f1 = createFont("Arial", 20, true);
  f2 = createFont("Arial", 15, true);
  orientation(LANDSCAPE);
  smooth();
  fill(255);
  stroke(255);
  mono = createFont("Arial",100, true);
  textFont(mono);
}

void draw() {
    switch(state)
    {
    case SEARCHING: 
      device = (BluetoothDevice) devices.get(0);    //nowß
      println(device.getName());     
      connectDevice();
      break;
    case SHOW_ERROR:
      showError();
      break;
    case RUN:  
      background(204, 255, 255);
      noStroke();
      textFont(mono);
      color c1 = #FFCC00;
      fill(c1);
      rect(0, 0, width, height/4);
      fill(50);
      textSize(100);
      text("left hand", width/2, height/8);
      color c2 = #DFC100;
      fill(c2);
      rect(0, height/4, width, height/4);
      fill(50);
      textSize(100);
      text("right hand", width/2, height/4+height/8);
      color c3 = #1FC200;
      fill(c3);
      rect(0, height/2, width, height/4);
      fill(50);
      textSize(100);
      text("dance", width/2, height/2+height/8);
      color c4 = #AFC300;
      fill(c4);
      rect(0, (height/4)*3, width, height/4);
      fill(50);
      textSize(100);
      text("vibro", width/2, (height/4)*3+height/8);
  }
}

void toggleRelay(int r) {
  try
  {
    ons.write(r); 
    //read 1, RELAY 1 ON
    //read 2, RELAY 1 OFF
    //read 3, RELAY 2 ON 
    //read 4, RELAY 2 OFF
  }
  catch(Exception ex)
  {
    state = SHOW_ERROR;
    error = ex.toString();
    println(error);
  }
}

void showError()
{
  background(255, 0, 0);
  fill(255, 255, 0);
  textFont(f2, 50);
  textAlign(CENTER);
  translate(width / 2, height / 2);
  rotate(3 * PI / 2);
  text(error, 0, 0);
}

//BLUETOOTH
void getDevicesList()
{
  devices = new ArrayList();
  for (BluetoothDevice device : adapter.getBondedDevices())
  {
    devices.add(device);
  }
  state = SEARCHING;
}

void connectDevice() 
{   
  try   
  {     
    socket = device.createRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
    socket.connect();     
    ins = socket.getInputStream();     
    ons = socket.getOutputStream();     
    state = RUN;
  }   
  catch(Exception ex)   
  {     
    state = SHOW_ERROR;     
    error = ex.toString();     
    println(error);
  }
}


//EVENTS
public boolean surfaceTouchEvent(MotionEvent event) {
  int x = (int)event.getX();
  int y = (int)event.getY();
  if (DEBUG_TOUCH) println("TOUCH: surface event at " + x +"/" + y);
  switch (event.getAction()) {
  case MotionEvent.ACTION_DOWN:
    if (DEBUG_BT) print("BT: open relay ");
    if (y < height/4)
    {
      toggleRelay(1);
      if (DEBUG_BT) println("1 (left)");
    } else if (y > height/4 && y < height/2)
    {
      toggleRelay(3);
      if (DEBUG_BT) println("2 (right)");
    }
    break;
  case MotionEvent.ACTION_MOVE:
    if (y > height/2 && y < (height/4)*3)
    {
      if (DEBUG_BT) println("BT: dance START");
      toggleRelay(1);
      delay(100);
      toggleRelay(2);
      toggleRelay(3);
      delay(100);
      toggleRelay(4);
      if (DEBUG_BT) println("BT: dance END");
    } else if (y > (height/4)*3)
    {
      if (DEBUG_BT) println("BT: vibrate START");
      toggleRelay(1);
      delay(5);
      toggleRelay(2);
      toggleRelay(3);
      delay(5);
      toggleRelay(4);
      if (DEBUG_BT) println("BT: vibrate END");
    }
    break;
  case MotionEvent.ACTION_UP:
    if (DEBUG_BT)print("BT: closing relay 1 and 2 ");
    toggleRelay(2);
    toggleRelay(4);
    break;
  }
  return super.surfaceTouchEvent(event);
}

void onStart()
{
  super.onStart();
  if (DEBUG_EVENTS) println("onStart");
  adapter = BluetoothAdapter.getDefaultAdapter();
  if (adapter != null)
  {
    if (!adapter.isEnabled())
    {
      Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
      startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
    }
    else
    {
      getDevicesList();
    }
  }
}

void onStop()
{
  if (DEBUG_EVENTS) println("onStop");
  if (socket != null)
  {
    try
    {
      socket.close();
    }
    catch(IOException ex)
    {
      println(ex);
    }
  }
  super.onStop();
}


void onPause() {
  super.onPause();
}

void onResume() {
  super.onResume();
}

//utils
float distance(float px1, float py1, float px2, float py2) {
  return sqrt(pow((px1-px2), 2)+ pow((py1-py2), 2));
}

