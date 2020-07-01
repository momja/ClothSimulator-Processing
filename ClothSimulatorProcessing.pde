Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();
PShape[] rigidBodies = new PShape[1];
RopeSimulator rope = new RopeSimulator(5, new Vec3(1, -0.1, 1), new Vec3(0,10,0), 2.f);
RopeSimulator rope1 = new RopeSimulator(5, new Vec3(0.1, -0.1, 1), new Vec3(5,10,0), 2.f);
RopeSimulator rope2 = new RopeSimulator(5, new Vec3(0.1, -0.1, 1), new Vec3(0,10,5), 2.f);

Vec3 bunnyPosition = new Vec3();

void setup() {
    size(640,480,OPENGL);
    perspective(radians(60), 1+1.f/3, 1, 1000);
    surface.setTitle("Cloth Simulation [Max Omdal]");
    rigidBodies[0] = loadShape("stanford_bunny.obj");

    rope.rigidBodies = rigidBodies;
    rope1.rigidBodies = rigidBodies;
    rope2.rigidBodies = rigidBodies;
}

void draw() {
    cam.update();
    background(255,255,255);
    lights();
    updateRigidBodies();
    update(1/frameRate);
    push();
    translate(0,10,0);
    box(1,1,1);
    pop();

    shape(rigidBodies[0]);

    // Heads Up Display
    hud.draw();
}

void update(float dt) {
    // TODO: Insert Cloth Simulation
    rope.update(dt);
    rope.draw();

    rope1.update(dt);
    rope1.draw();

    rope2.update(dt);
    rope2.draw();
}

void updateRigidBodies() {
    if (keyPressed) {
        if (key == 'w') {
            bunnyPosition.z += 0.3;
        } else if (key == 's') {
            bunnyPosition.z -= 0.3;
        } else if (key == 'a') {
            bunnyPosition.x += 0.3;
        } else if (key == 'd') {
            bunnyPosition.x -= 0.3;
        }
        rigidBodies[0].resetMatrix();
        rigidBodies[0].translate(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);
    }
}