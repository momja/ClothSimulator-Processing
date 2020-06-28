class Camera {
    Vec3 camLocation = new Vec3(0,0,0);
    Vec3 camLookAt = new Vec3(0,0,0);
    Vec3 camUp = new Vec3(0,-1,0);
    float cameraRadius = 30;
    int slider = 0;
    float theta = 0;

    public void update() {
        if (keyPressed) {
            if (keyCode == UP) {
                slider++;
            } else if (keyCode == DOWN) {
                slider--;
            } else if (keyCode == LEFT) {
                theta -= 1.1;
            } else if (keyCode == RIGHT) {
                theta += 1.1;
            }
        }
        camLocation.x = cos(radians(theta))*cameraRadius;
        camLocation.y = float(slider)/5;
        camLocation.z = sin(radians(theta))*cameraRadius;
        camera(camLocation.x, camLocation.y, camLocation.z,
               camLookAt.x,   camLookAt.y,   camLookAt.z,
               camUp.x,       camUp.y,       camUp.z);
    }
}