Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();
PShape[] rigidBodies = new PShape[1];
OctreeTriangles ot = new OctreeTriangles(new OctantTris(new Vec3(0,0,0), new Vec3(20,40,20)), 15);
Vec3 bunnyPosition = new Vec3();
int clothWidth = 15;
int clothHeight = 15;
ClothMesh cloth;

void setup() {
    size(1280,960,P3D);
    cam.setPerspective();
    surface.setTitle("Cloth Simulation [Max Omdal]");

    // initialize variables
    cloth = new ClothMesh(clothWidth, clothHeight);
    // cloth.debugMode = true;
    rigidBodies[0] = loadShape("sphere.obj");

    for (PShape rigidBody : rigidBodies) {
        int triCount = rigidBody.getChildCount();
        for (int i = 0; i < triCount; i++) {
            PShape triangle = rigidBody.getChild(i);
            ot.insert(triangle);
        }
    }
}

void draw() {
    cam.update();
    background(20,20,20);
    lights();
    updateRigidBodies();
    update(1.f/frameRate);

    cloth.draw();

    shape(rigidBodies[0]);
}

void update(float dt) {
    cloth.updateMidpoint(dt);
}

void updateRigidBodies() {
    if (keyPressed) {
        if (key == 'w') {
            cam.radius -= 0.1;
        } else if (key == 's') {
            cam.radius += 0.1;
        } else if (key == 'a') {
            bunnyPosition.x += 0.3;
        } else if (key == 'd') {
            bunnyPosition.x -= 0.3;
        }
        rigidBodies[0].resetMatrix();
        rigidBodies[0].translate(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);
    }
}