Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();
PShape[] rigidBodies = new PShape[1];
RopeSimulator rope = new RopeSimulator(5, new Vec3(1, -0.1, 1), new Vec3(0,10,0), 2.f);
RopeSimulator rope1 = new RopeSimulator(5, new Vec3(0.1, -0.1, 1), new Vec3(5,10,0), 2.f);
RopeSimulator rope2 = new RopeSimulator(5, new Vec3(0.1, -0.1, 1), new Vec3(0,10,5), 2.f);
OctreePoints ot = new OctreePoints(new Octant(new Vec3(0,0,0), new Vec3(13,15,13)), 100);
Vec3 bunnyPosition = new Vec3();

void setup() {
    size(1280,960,P3D);
    cam.setPerspective();
    surface.setTitle("Cloth Simulation [Max Omdal]");
    rigidBodies[0] = loadShape("stanford_bunny.obj");

    rope.rigidBodies = rigidBodies;
    rope1.rigidBodies = rigidBodies;
    rope2.rigidBodies = rigidBodies;

    for (int i = 0; i < 100; i++) {
        ot.insert(new Vec3(random(-2,2),random(-2,2),random(-2,2)));
    }

    for (PShape rigidBody : rigidBodies) {
        int triCount = rigidBody.getChildCount();
        for (int i = 0; i < triCount; i++) {
            PShape triangle = rigidBody.getChild(i);
            PVector v1 = triangle.getVertex(0).add(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);
            PVector v2 = triangle.getVertex(1).add(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);
            PVector v3 = triangle.getVertex(2).add(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);

            ot.insert(new Vec3(v1));
            ot.insert(new Vec3(v2));
            ot.insert(new Vec3(v3));
        }
    }
}

void draw() {
    cam.update();
    background(0);
    lights();
    updateRigidBodies();
    update(1/frameRate);
    push();
    translate(0,10,0);
    box(1,1,1);
    pop();

    shape(rigidBodies[0]);

    // ot.show();
    // Ray3 r = getMouseCast();
    // Vec3 r1 = r.origin.plus(r.direction.times(10));
    // pushStyle();
    // strokeWeight(10);
    // stroke(0,255,0);
    // point(r1.x, r1.y, r1.z);
    // ArrayList<Vec3> points = ot.rayIntersectsOctants(r);
    // for (Vec3 p : points) {
    //     point(p.x, p.y, p.z);
    // }
    // popStyle();

    // Heads Up Display
    // hud.draw();
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