Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();
RopeSimulator rope = new RopeSimulator(10, new Vec3(1,1,1));

void setup() {
    size(640,480,P3D);
    perspective(radians(60), 1+1.f/3, 1, 1000);
    surface.setTitle("Cloth Simulation [Max Omdal]");
}

void draw() {
    cam.update();
    background(255,255,255);
    update(1/frameRate);
    // Heads Up Display
    hud.draw();
}

void update(float dt) {
    // TODO: Insert Cloth Simulation
    rope.update(dt);
    rope.draw();
}