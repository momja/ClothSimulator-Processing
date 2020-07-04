class Fan {
    PShape frame;
    PShape wings;
    Vec3 position;
    Vec3 lookat;
    Vec3 up;
    float theta = 0;
    boolean hidden = false;

    public Fan() {
        frame = loadShape("fan_frame.obj");
        wings = loadShape("fan_wings.obj");
        position = new Vec3(0,0,0);
    }

    public void updatePosition(Vec3 position, Vec3 lookat, Vec3 up, float dt) {
        this.position = position;
        this.lookat = lookat;
        this.up = up;
        theta += dt*20;
        theta = theta % (2*PI);
    }

    public void draw() {
        if (hidden) {
            return;
        }

        Vec3 w = lookat.minus(position).normalized();
        Vec3 u = cross(w, up).normalized();
        Vec3 v = cross(u, w).normalized();

        float m3dx_world = 1*u.x + 0*v.x + 0*w.x + this.position.x;
        float m3dy_world = 0*u.y + 1*v.y + 0*w.y + this.position.y;
        float m3dz_world = 0*u.z + 0*v.z + 1*w.z + this.position.z;

        pushMatrix();
        translate(position.x, position.y, position.z);
        scale(0.2, 0.2, 0.2);
        applyMatrix(u.x, v.x, w.x, 0f,
                    u.y, v.y, w.y, 0f,
                    u.z, v.z, w.z, 0f,
                    0,   0,   0,   1f);
        shape(frame);
        rotateZ(theta);
        shape(wings);
        popMatrix();
    }
}