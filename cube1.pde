
int column_pins[3][3] = {
  {
    4,8,6                        }
  ,
  {
    3,9,7                        }
  ,
  {
    2,5,A0                        }
};

int layer_pins [4]= {
  10,11,12,13};
  
int layer_bits [3][4] = {{0,1,0,0},{1,1,0,1},{0,0,0,1}};

int skip;
int mode;

void setmode(int m){
  mode = m;
  switch (mode){
  case -2: 
    skip = 30; 
    break;
  case -1: 
    skip = 30; 
    break;
  case 0: 
    skip = 16; 
    break;
  }
}

int led[3][3][3];

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

void setup() {  
  setmode(-1);
  clearleds();
  randomSeed(5);
  for (int i=0;i<4;i++)
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
}



int ctol(int x, int z)
{
  int a;
  if(z == 0)a=x ;
  else if(z==1){
    if(x == 0)a=7;
    else if(x==2)a=3;
    else
    {
      a=1;
      setmode(-2);
    }
  }
  else if (z == 2)
    a=4+(2-x);
  else
  {
    a=1;
    setmode(-2);
  }


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
  {
    x=1;
    z=1;
    setmode(-2);
  }

  point ret ;
  ret.x = x;
  ret.z=z;
  return ret;
}



int flakator = 0;
long long buzerator = 0;
int dir = 0;
int rot = 0;
int counter = 0;
int len;
float sine;

void invert()
{
  for(int x=0;x<3;x++)
    for(int y=0;y<3;y++)
      for(int z=0;z<3;z++)
        led[x][y][z] = !led[x][y][z];
}

void all(int val)
{
  for(int x=0;x<3;x++)
    for(int y=0;y<3;y++)
      for(int z=0;z<3;z++)
        led[x][y][z] = val;
}

void blinker(int countmax)
{
  if(counter++ > countmax){
    counter = 0;
    setmode(0);
  }
  else
    invert();
}

void anim(){
  if(flakator++ == skip)
  {
    flakator = 0;
    switch(mode){
      //panic
    case -2:
      blinker(4);
      break;
      //boot
    case -1:
      blinker(0);
      break;


    case 0:
      for(int x=0;x<3;x++)
        for(int z=0;z<3;z++)
        {
          flakes[x][z].y +=       flakes[x][z].dir;
          if (flakes[x][z].y > 2) flakes[x][z].y = 2;
          if (flakes[x][z].y < 0) flakes[x][z].y = 0;
        }

      flakes[random(3)][random(3)].dir = random(3) -1;

      buzerator += random(500);
      if(buzerator > 10000)
      {
        dir = (buzerator % 2) ? 1 : -1;
        setmode(1);
        buzerator = 0;
        rot = 0;
        len = 1+random(2);
        sine = 5.0 + random(15);
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

          if((x==1)&&(z == 1))
            led[1][flakes[x][z].y][1]=1;
          else{

            point p = ltoc(ctol(x,z)+rot);
            led[p.x][flakes[x][z].y][p.z]=1;
          }
        }

      skip = 5+sine * abs(cos (PI * (float)abs(rot)/7.0/(float)len));
      if (abs(rot) == 7*len+1)
        setmode(0);
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

    anim();
    animathor = 0;


  }
  for (int bitpin=0;bitpin<4;bitpin++)
    digitalWrite(layer_pins[bitpin], layer_bits[l][bitpin]);

  for(int x=0;x<3;x++)
    for(int z=0;z<3;z++)
      digitalWrite(column_pins[x][z], led[x][l][z]);

  if(++l>2)l=0;

  delay(1);
  
}


/*
void loop(){
 digitalWrite(column_pins[1][1], 1);
 digitalWrite(layer_pins[1], 1);
 }
 
 */
















