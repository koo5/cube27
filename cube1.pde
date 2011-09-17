int serial = 1;

int column_pins[3][3] = {
  {
    3,4,5              }
  ,
  {
    9,10,2              }
  ,
  {
    6,7,8              }
};

int layer_pins [3]= {
  12,11,13};

int skip = 10;
int mode = 0;

void setmode(int m){
  mode = m;
  if(mode==0)skip = 10;
  if(mode==1)skip = 3+random(15);
  if(serial)
  {
    Serial.print("mode: ");
    Serial.println(mode);
  } 
}

int led[3][3][3];

//

//
void set(int x,int y, int z, int val)
{
  if(x<0) return;
  if(y<0) return;
  if(z<0) return;
  if(x>2) return;
  if(y>2) return;
  if(z>2) return;
  led[x][y][z] = val;
}
void o(int x,int y, int z)
{
  set(x,y,z,1);
}
void c(int x,int y, int z)
{
  set(x,y,z,0);
}
//


void clearleds(){
  for(int x=0;x<3;x++)
    for(int y=0;y<3;y++)
      for(int z=0;z<3;z++)
        led[x][y][z] = 0; 

}

struct point{
  int x;
  int z;
};
struct flake{
  int dir; 
  int y;
};

flake flakes[3][3];

void callhome(){
  if(serial)
  {
    long randNumber = random(3000);
    Serial.println(randNumber);
  }
}

void setup() {  
  if(serial) Serial.begin(115200);
  randomSeed(5);
  for (int i=0;i<3;i++)
  {
    pinMode(layer_pins[i], OUTPUT);     
    digitalWrite(layer_pins[i], 0);
  }
  for(int x=0;x<3;x++)
    for(int z=0;z<3;z++)
    {
      pinMode(column_pins[z][x], OUTPUT);
      digitalWrite(column_pins[z][x], 0);
    }
  clearleds();
}



int ctol(int x, int z)
{
  int a;
  if(z == 0)a=x ;
  else if(z==1){
    if(x == 0)a=7;
    else if(x==2)a=3;
  }
  else if (z == 2)
    a=4+(2-x);
    else
        Serial.println("bad Z");


  return a;
}

struct point ltoc(int l){
  int x,z;
  l = l %8;
    if(l < 0) l+=8;

  if(l<3){
    x=l;
    z=0;
  }
  else if(l==3){
    x=2;
    z=1;
  }
  else if((l>3)&(l<7)){
    x=2-(l-4);
    z=2;
  }
  else if(l==7){
    x=0;
    z=1;
  }
  else
          Serial.println("bad L");
          
        // Serial.println(x,z);
  point ret ;
  ret.x = x;
  ret.z=z;
  return ret;
}



int flakator = 0;
long long buzerator = 0;
long long buzerplac = 29999;
int dir = 0;
int rot = 0;
int counter = 0;

void anim(){
  if(flakator % skip == 2)
  {

    switch(mode){
    case 0:



      buzerator += random(3000);

      //  callhome();
      for(int x=0;x<3;x++)
        for(int z=0;z<3;z++)
        {
          flakes[x][z].y +=       flakes[x][z].dir;
          if (flakes[x][z].y > 2) flakes[x][z].y = 2;
          if (flakes[x][z].y < 0) flakes[x][z].y = 0;
        }


    //  if((buzerator < buzerplac -5000) ? (random(1) == 0) : (random(buzerator-buzerplac+10000) < 100))
      
        flakes[random(3)][random(3)].dir = random(3) -1;
      /*else*/ if(buzerator > buzerplac)
      {
        dir = (buzerator % 3)-1;
        if (dir)
        {
          setmode(1);
          buzerator = 0;
          rot = 0;
        }
      }
      clearleds();

      for(int x=0;x<3;x++)
        for(int z=0;z<3;z++)
          led[x][flakes[x][z].y][z]=1;

      break;
    case 1:
      if (dir==0)setmode(0);
      clearleds();

      for(int x=0;x<3;x++)
        for(int z=0;z<3;z++)
        {

          if((x==1)&&(z == 1)){
            led[x][flakes[x][z].y][z]=1;//!led[x][flakes[x][z].y][z];//counter++%2;
          }
          else{

            point p = ltoc(ctol(x,z)+rot);
            led[p.x][flakes[x][z].y][p.z]=1;
          }
        }

  //if(flakator % 20 == 2)
//skip += (4-abs(abs(rot) -4))*(rot > 0?1:-1);
      if (abs(rot) == 8)
      {
        rot = 0;
        setmode(0);
      }
            rot += dir;
      break;
    }
  }
}

int l = 0;
int animathor = 0;

int loc[3] = {
  -1,-1,-1};

void loop() {
  if (animathor++ ==10) {
    flakator ++;
    anim();
    animathor = 0;


  }
  digitalWrite(layer_pins[l++], 0);
  if(l>2)l=0;

  for(int x=0;x<3;x++)
    for(int z=0;z<3;z++)
      digitalWrite(column_pins[x][z], led[x][l][z]);

  digitalWrite(layer_pins[l], 1);
  delay(1);

}


/*
void loop(){
 digitalWrite(column_pins[1][1], 1);
 digitalWrite(layer_pins[1], 1);
 }
 
 */











