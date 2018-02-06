
import peasy.PeasyCam;

PVector acceleration;
ArrayList<PVector> velocity;
ArrayList<PVector> position;
ArrayList<Float> lifetime;

ArrayList<PVector> smokeVel;
ArrayList<PVector> smokePos;
ArrayList<Float> smokeLife;

float MAX_LIFE;
float lifeDecay;
float SCENE_SIZE;
float spawnRate;
float sampleRadius;

float render_x, render_y, render_z;

float startTime;
float elapsedTime;
PeasyCam camera;

//Initialization
void setup(){
  size(1024, 960, P3D);
  
  acceleration = new PVector(0, -10, 0);
  velocity = new ArrayList<PVector>();
  position = new ArrayList<PVector>();
  lifetime = new ArrayList<Float>();
  smokeVel = new ArrayList<PVector>();
  smokePos = new ArrayList<PVector>();
  smokeLife = new ArrayList<Float>();
  
  MAX_LIFE = .8;
  lifeDecay = 255.0 / MAX_LIFE;
  SCENE_SIZE = 100;
  strokeWeight(12);
  spawnRate = 375;
  sampleRadius = 1.5;
  
  render_x = 0;
  render_y = 0;
  render_z = 0;
  
  float cameraZ = ((SCENE_SIZE-2.0) / tan(PI*60.0 / 360.0));
  perspective(PI/3.0, 1, 0.1, cameraZ*10.0);

  camera = new PeasyCam(this, SCENE_SIZE/2, 19 * SCENE_SIZE / 20, (SCENE_SIZE/2.0) / tan (PI*30.0 / 180.0), 10);

  camera.setSuppressRollRotationMode();
  addPoint();  //get our first fire point ready
  
  fill(172);
  stroke(0, 172, 255);
  
  startTime = millis();
}


//Called every frame
void draw(){
  background(0);
  
  TimeStep();
  Update(elapsedTime/1000.0);
  UserInput();
  Simulate();
}

//calculate how far to move balls
void TimeStep(){
  elapsedTime = millis() - startTime;
  startTime = millis();
}


//calculate how far to move points
void Update(float dt){
  float slowDown = 0.6;
  for(int i = 0; i < position.size(); i++){
    
    position.get(i).x += velocity.get(i).x * dt;
    position.get(i).y += velocity.get(i).y * dt;
    position.get(i).z += velocity.get(i).z * dt;

    velocity.get(i).y += acceleration.y * dt;
    velocity.get(i).x += random(-30, 30) * dt;
    velocity.get(i).z += random(-30, 30) * dt;
    
    Bounds(position.get(i), velocity.get(i));
   
    lifetime.set(i, lifetime.get(i) - dt);
  }
  if(smokePos.size() > 0) {
    for(int i = smokePos.size() - 1; i > 0; i--) {
        
      smokePos.get(i).x += smokeVel.get(i).x * dt * slowDown;
      smokePos.get(i).y += smokeVel.get(i).y * dt * slowDown;
      smokePos.get(i).z += smokeVel.get(i).z * dt * slowDown;

      smokeVel.get(i).y += acceleration.y * dt * slowDown;
      smokeVel.get(i).x += random(-20, 20) * dt * slowDown;
      smokeVel.get(i).z += random(-20, 20) * dt * slowDown;
      
      smokeLife.set(i, smokeLife.get(i) - dt * slowDown);
    }
  }  
}


//getting user input for camera
void UserInput(){
  if(keyPressed){
    if(key == 'w'){
        render_z += 1;
    }
    if(key == 's'){
        render_z -= 1;
    }
    if(key == 'a'){
       render_x += 1;
    }
    if(key =='d'){
        render_x -= 1;
    }
  }
}


//render the entire scene
void Simulate(){
  renderCamera();
  setupScene();  // setup lights and floor
  addPoint();  // add information to arraylists for new point
  renderFire();  // transpose stores points, including our new ball
  if(smokePos.size() > 0) {
    RenderSmoke();
  }
  println("Framerate: " + frameRate);
  println("Number of Balls: " + position.size());
}



/*  ~  HELPER FUNCTIONS  ~  */



//translate keyboard input
void renderCamera() {
  translate(render_x, render_y, render_z);
}

// check if particles are going out of bounds
void Bounds(PVector pos, PVector vel) {
  float damper = 0.8;
  
  if(sq(pos.x) + sq(pos.z) > sq(sampleRadius)) {
    if(random(1) >.7) {
      vel.x *= -1 * damper;
      vel.z *= -1 * damper;
    }
  }
  if(pos.y < SCENE_SIZE - 3) {
    if(random(1) >= 0.7) {
      float x = pos.x - SCENE_SIZE/2;
      x *= 0.7;
      x += SCENE_SIZE/2;
      pos.x = x;
      
      float z = pos.z - SCENE_SIZE/2;
      z *= 0.7;
      z += SCENE_SIZE/2;
      pos.z = z;
    }
  }   
}


//spawn points in fire
void addPoint(){  
  for(int i = 0; i < spawnRate; i++) {
    //calculate uniform disk
    //use random and sqrt for uniform disk, but I just want edge
    float r = sampleRadius * sqrt(random(0, 1));
    float theta = 2 * PI * random(0, 1);

    velocity.add(new PVector(r * sin(theta), random(-4, 0), r * cos(theta)));
    position.add(new PVector(SCENE_SIZE/2 + r * sin(theta), random(SCENE_SIZE - 2, SCENE_SIZE), SCENE_SIZE/2 + r * cos(theta)));
    lifetime.add(MAX_LIFE);
  }
}

//spawn points in smoke
void SpawnSmoke(PVector pos, PVector vel) {
  smokePos.add(new PVector(pos.x, pos.y, pos.z));
  smokeVel.add(new PVector(random(-1, 1), vel.y, random(-1, 1)));
  smokeLife.add(random(1, MAX_LIFE * 2));
}

//render fire points
void renderFire(){
  for(int i = position.size() - 1; i >= 0; i--){
    
    //if point has been there too long, kill it before we move it
    if(lifetime.get(i) < 0){
      SpawnSmoke(position.get(i), velocity.get(i));
      position.remove(i);
      velocity.remove(i);
      lifetime.remove(i);
    }  
    //color over time
    stroke(255, lifetime.get(i) * lifeDecay, 0, 255);
    strokeWeight(4 + lifetime.get(i) * lifeDecay / 25.5);
    
    //moving to new position
    point(position.get(i).x, position.get(i).y, position.get(i).z);  
  }
}

//render smoke points
void RenderSmoke() {
  for(int i = smokePos.size() - 1; i >= 0; i--){
    
    //if point has been there too long, kill it before we move it
    if(smokeLife.get(i) < 0){
      smokePos.remove(i);
      smokeVel.remove(i);
      smokeLife.remove(i);
    }      
    //color over time
    stroke(random(95, 105), random(95, 105), random(95, 15), 75);
    strokeWeight(smokeLife.get(i) * lifeDecay / 25.5);
    
    //moving to new position
    point(smokePos.get(i).x, smokePos.get(i).y, smokePos.get(i).z);  
  }
}

//renders our floor
void setupScene(){
  pushMatrix();
  fill(#292900);
  noStroke();
  //floor
  translate(SCENE_SIZE/2, 1+SCENE_SIZE, SCENE_SIZE/2);
  box(SCENE_SIZE, 1, SCENE_SIZE);
  //firewood
  fill(#210100);
  translate(0, -0.75, 0);
  box(1.5, 1.5, 7);
  box(7, 1.5, 1.5);
  popMatrix();
}  