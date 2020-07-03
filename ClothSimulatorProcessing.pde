Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();
PShape[] rigidBodies = new PShape[1];
RopeSimulator rope = new RopeSimulator(50, new Vec3(1, -0.1, 0.81), new Vec3(0,8,0), 6.f);
RopeSimulator rope1 = new RopeSimulator(50, new Vec3(0.1, -0.1, 1), new Vec3(2,8,0), 6.f);
RopeSimulator rope2 = new RopeSimulator(50, new Vec3(0.1, -0.1, 1), new Vec3(0,8,2), 6.f);
OctreeTriangles ot = new OctreeTriangles(new OctantTris(new Vec3(0,0,0), new Vec3(20,17,20)), 20);
Vec3 bunnyPosition = new Vec3();
int clothWidth = 10;
int clothHeight = 10;

void setup() {
    size(1280,960,P3D);
    cam.setPerspective();
    surface.setTitle("Cloth Simulation [Max Omdal]");
    rigidBodies[0] = loadShape("stanford_bunny.obj");

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
    background(0);
    lights();
    updateRigidBodies();
    update(1/frameRate);
    push();
    translate(0,10,0);
    pop();

    shape(rigidBodies[0]);

    // Ray3 r = getMouseCast();
    // pushStyle();
    // ArrayList<PShape> tris = ot.rayIntersectsOctants(r);
    // for (PShape tri : tris) {
    //     shape(tri);
    // }
    // popStyle();

    // if (mousePressed) {
    //     // Find the triangle that intersectsP
    //     strokeWeight(10);
    //     stroke(0,255,0);
    //     // point(r.origin.plus(r.direction.times(5)).x, r.origin.plus(r.direction.times(5)).y, r.origin.plus(r.direction.times(5)).z);
    //     Vec3 closestPoint = null;
    //     float tMin = Float.MAX_VALUE;
    //     for (PShape tri : tris) {
    //         Vec3 p = rayTriangleCollision(r.origin, r.direction, tri);
    //         if (p != null) {
    //             closestPoint = r.origin.distanceTo(p) < tMin ? p : closestPoint;
    //             tMin = min(r.origin.distanceTo(p), tMin);
    //         }
    //     }
    //     if (closestPoint != null) {
    //         pushMatrix();
    //         translate(closestPoint.x, closestPoint.y, closestPoint.z);
    //         sphere(0.1);
    //         popMatrix();
    //     }
    // }

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