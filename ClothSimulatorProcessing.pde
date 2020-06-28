Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();

void setup() {
    size(640,480,P3D);
    perspective(radians(60), 1+1.f/3, 1, 1000);
    surface.setTitle("Cloth Simulation [Max Omdal]");
}

void draw() {
    cam.update();
    background(0);
    // TODO : Insert Cloth Simulation Here
    box(20,20,20);

    // Heads Up Display
    hud.draw();
}