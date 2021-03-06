class Hand {
  int id;
  float[] lowPass;
  float[] raw, praw;
  float[] pos, ppos;
  long timeout;
  long ttl=25;
  Hand(int _id, float _x, float _y, float _z) {
    id=_id;
    lowPass=new float[3];
    lowPass[0]=_x;
    lowPass[1]=_y;
    lowPass[2]=_z;
    raw=new float[3];
    praw=new float[3];
    pos = new float[3];
    ppos = new float[3];
    initPos();
    timeout=ttl;
  }
  void calcPos() {
    arrayCopy(raw, praw);
    arrayCopy(lowPass, raw);
    arrayCopy(pos, ppos);
    pos= cm.getTransformed(raw);
  };
  void initPos() {
    arrayCopy(lowPass, raw);
    arrayCopy(raw, praw);
    pos= cm.getTransformed(raw);
    arrayCopy(pos, ppos);
  };
  void update(float _x, float _y, float _z) {
    timeout=ttl;
    lowPass[0]=0.9*lowPass[0]+0.1*_x;
    lowPass[1]=0.9*lowPass[1]+0.1*_y;
    lowPass[2]=0.9*lowPass[2]+0.1*_z;
  }

  void frame(int _i) {
    calcPos();

    float attackThreshold=10;
    float attack=constrain(map(pos[2], attackThreshold, 0, 0, 1), 0, 1);
    if (_i == 0 && gloveOn) {
      //port.write((byte)round(constrain(attack*mp.fft.getBand(0)*mp.fft.getBand(0)/100.0, 0, 100)));
      port.write((byte)round(attack*50));
    }
    println("attack: "+attack);
    if (attack>0.5) {
      float normX = (pos[0]+width/2) * invWidth;
      float normY = (pos[1]+height/2) * invHeight;
      float velX = (pos[0] - ppos[0]) * invWidth;
      float velY = (pos[1] - ppos[1]) * invHeight;
      addForce(normX, normY, velX, velY, attack);
    }
  }

  void age() {
    timeout--;
  }
}

