Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();
PShape[] rigidBodies = new PShape[1];
Sphere[] collisionSpheres = new Sphere[1];
OctreeTriangles ot = new OctreeTriangles(new OctantTris(new Vec3(0,0,0), new Vec3(20,40,20)), 15);
Vec3 bunnyPosition = new Vec3();
int clothWidth = 21;
int clothHeight = 21;
ClothMesh cloth;
Fan fan;
boolean paused = false;

void setup() {
    size(1280,960,P3D);
    cam.setPerspective();
    surface.setTitle("Cloth Simulation [Max Omdal]");

    // initialize variables
    cloth = new ClothMesh(clothWidth, clothHeight, new Vec3(1,5,0));
    cloth.materialColor = new Vec3(255,152,19);
    // cloth.debugMode = true;
    fan = new Fan();
    rigidBodies[0] = loadShape("sphere.obj");
    collisionSpheres[0] = new Sphere(2f, new Vec3(0,0,0));

    // for (PShape rigidBody : rigidBodies) {
    //     int triCount = rigidBody.getChildCount();
    //     for (int i = 0; i < triCount; i++) {
    //         PShape triangle = rigidBody.getChild(i);
    //         ot.insert(triangle);
    //     }
    // }
}

int f = 0;
void draw() {
    cam.update();

    background(20,20,20);
    lights();
    directionalLight(1, -1, -1, 255, 255, 255);
    if (!paused) {
        update(1.f/frameRate);
    }

    cloth.draw();
    for (Sphere sphere : collisionSpheres) {
        sphere.draw();
    }
    fan.draw();

    f++;

    // shape(rigidBodies[0]);
}

void keyPressed() {
    if (key == ' ') {
        paused = !paused;
    }
}

void update(float dt) {
    cloth.updateMidpoint(dt);

    // Draw Fan
    if (mousePressed) {
        Ray3 mouseRay = getMouseCast();
        CollisionInfo c = raySphereCollision(mouseRay, cam.camLookAt, 4.3);
        if (c != null) {
            fan.hide(false);
            Vec3 fanPos = c.position;
            fan.updatePosition(fanPos, cam.camLookAt, cam.camUp, dt);
        } else {
            fan.hide(true);
        }
    } else {
        fan.hide(true);
    }
    fan.updateWindParticles(dt);
}