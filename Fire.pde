
import peasy.PeasyCam;

PVector acceleration;
ArrayList<PVector> velocity;
ArrayList<PVector> position;
ArrayList<Float> lifetime;
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
  
  acceleration = new PVector(40, -20, 40);
  velocity = new ArrayList<PVector>();
  position = new ArrayList<PVector>();
  lifetime = new ArrayList<Float>();
  MAX_LIFE = .61;
  lifeDecay = 255.0 / MAX_LIFE;
  SCENE_SIZE = 100;
  strokeWeight(12);
  spawnRate = 750;
  sampleRadius = .1;
  
  render_x = 0;
  render_y = 0;
  render_z = 0;
  
  float cameraZ = ((SCENE_SIZE-2.0) / tan(PI*60.0 / 360.0));
  perspective(PI/3.0, 1, 0.1, cameraZ*10.0);
  
  //camera = new PeasyCam(this, SCENE_SIZE/2, SCENE_SIZE, (SCENE_SIZE/2.0) / tan (PI*30.0 / 180.0), SCENE_SIZE/2.0, SCENE_SIZE/2.0, 0, 0, 1, 0);

  camera = new PeasyCam(this, SCENE_SIZE/2, 19 * SCENE_SIZE / 20, (SCENE_SIZE/2.0) / tan (PI*30.0 / 180.0), 10);

  camera.setSuppressRollRotationMode();
  addPoint();  //get our first ball ready
  
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
  for(int i = 0; i < position.size(); i++){
    position.get(i).x += (velocity.get(i).x * dt);
    position.get(i).y += velocity.get(i).y * dt;
    position.get(i).z += (velocity.get(i).z * dt);
    
    velocity.get(i).y += (acceleration.y * (1 + abs(SCENE_SIZE/2 - position.get(i).x)) * dt);
    
    if(position.get(i).x > SCENE_SIZE/2) {
      velocity.get(i).x -= acceleration.x * dt;
    } else {
      velocity.get(i).x += acceleration.x * dt;
    }
    
    if(position.get(i).z > SCENE_SIZE/2) {
      velocity.get(i).z -= acceleration.z * dt;
    } else {
      velocity.get(i).z += acceleration.z * dt;
    }
    
    lifetime.set(i, lifetime.get(i) - dt);
    
    CheckBounds(position.get(i), velocity.get(i));  //simulate floor collision
  }
}


//getting user input for camera
void UserInput(){
  if(keyPressed){
    if(key == 'w'){
      for(int i = position.size() - 1; i > 0; i--){
        render_z += .0001;
      }
    }
    if(key == 's'){
      for(int i = position.size() - 1; i > 0; i--){
        render_z -=.0001;
      }
    }
    if(key == 'a'){
      for(int i = position.size() - 1; i > 0; i--){
       render_x +=.0001;
      }
    }
    if(key =='d'){
      for(int i = position.size() - 1; i > 0; i--){
        render_x -=.0001;
      }
    }
  }
}


//render the entire scene
void Simulate(){
  setupScene();  // setup lights and floor
  addPoint();  // add information to arraylists for new point
  renderPoints();  // transpose stores points, including our new ball
  
  println("Framerate: " + frameRate);
  println("Number of Balls: " + position.size());
}



/*  ~  HELPER FUNCTIONS  ~  */



//check if ball has gone outside of bounds
//if it has, send it back in
void CheckBounds(PVector pos, PVector vel){
  //energy lost due to collisions
  float energyLost = .20;
    if(pos.y > SCENE_SIZE){
      pos.set(pos.x, SCENE_SIZE, pos.z);
      vel.y *= (-1 * energyLost);
    }
}

void renderPoints(){
  for(int i = position.size() - 1; i >= 0; i--){
    
    //if point has been there too long, kill it before we move it
    if(lifetime.get(i) < 0){
      position.remove(i);
      velocity.remove(i);
      lifetime.remove(i);
    }  
    
    //color over time
    stroke(255, lifetime.get(i) * lifeDecay, 0);
    strokeWeight(6 + lifetime.get(i) * lifeDecay / 25.5);
    
    //moving to new position
    pushMatrix();
    translate(render_x, 0, render_z);
    point(position.get(i).x, position.get(i).y, position.get(i).z);
    popMatrix();    
  }
}

//inner fountain
void addPoint(){  
  for(int i = 0; i < spawnRate; i++) {
    //calculate uniform disk
    //use random and sqrt for uniform disk, but I just want edge
    float r = sampleRadius * sqrt(random(0, 1));
    float theta = 2 * PI * random(0, 1);

    velocity.add(new PVector(random(-12, 12), 0, random(-12, 12)));
    position.add(new PVector(SCENE_SIZE/2 + r * sin(theta), random(SCENE_SIZE - 1, SCENE_SIZE), SCENE_SIZE/2 + r * cos(theta)));
    lifetime.add(MAX_LIFE);
  }
}

//renders our floor
void setupScene(){
  pushMatrix();
  fill(#292900);
  noStroke();
  translate(render_x, 0, render_z);
  //floor
  translate(SCENE_SIZE/2, 1+SCENE_SIZE, SCENE_SIZE/2);
  box(SCENE_SIZE, 1, SCENE_SIZE);
  //firewood
  fill(#210100);
  translate(0, -0.75, 0);
  box(2, 1.5, 6);
  box(6, 1.5, 2);
  popMatrix();
}  