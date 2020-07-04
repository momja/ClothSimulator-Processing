Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();
PShape[] rigidBodies = new PShape[1];
OctreeTriangles ot = new OctreeTriangles(new OctantTris(new Vec3(0,0,0), new Vec3(20,40,20)), 15);
Vec3 bunnyPosition = new Vec3();
int clothWidth = 15;
int clothHeight = 15;
ClothMesh cloth;
Fan fan;

void setup() {
    size(1280,960,P3D);
    cam.setPerspective();
    surface.setTitle("Cloth Simulation [Max Omdal]");

    // initialize variables
    cloth = new ClothMesh(clothWidth, clothHeight);
    cloth.debugMode = true;
    fan = new Fan();
    rigidBodies[0] = loadShape("cube.obj");

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
    update(1.f/frameRate);

    cloth.draw();


    shape(rigidBodies[0]);

}

void update(float dt) {
    cloth.updateMidpoint(dt);

    // Draw Fan
    if (mousePressed) {
        Ray3 mouseRay = getMouseCast();
        CollisionInfo c = raySphereCollision(mouseRay, cam.camLookAt, 4);
        if (c != null) {
            Vec3 fanPos = c.position;
            fan.updatePosition(fanPos, cam.camLookAt, cam.camUp, dt);
            fan.draw();
        }
    }
}