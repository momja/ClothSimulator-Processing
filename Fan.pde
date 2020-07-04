class Fan {
    PShape frame;
    PShape wings;
    Vec3 position;
    Vec3 lookat;
    Vec3 lookDir;
    Vec3 up;
    float theta = 0;
    boolean hidden = false;
    ParticleSystem emitter = new ParticleSystem(1000);

    public Fan() {
        frame = loadShape("fan_frame.obj");
        wings = loadShape("fan_wings.obj");
        position = new Vec3(0,0,0);

        // Set up emitter
        emitter.emitterPosition = position;
        emitter.particleLifespanMax = 1;
        emitter.particleLifespanMin = 1.5;
        emitter.isActive = false;
        emitter.birthRate = 15;
        emitter.particleSpeed = 5;
        emitter.speedRange = 0.2;
        emitter.particleDirectionRange = 0.01;
        emitter.particleColor = new Vec3(255,255,255);
        emitter.r = 0.4;
        emitter.particleTexture = loadImage("dust.png");
    }

    public void updatePosition(Vec3 position, Vec3 lookat, Vec3 up, float dt) {
        this.position = position;
        this.lookat = lookat;
        this.lookDir = this.lookat.minus(this.position).normalized();
        this.up = up;
        theta += dt*20;
        theta = theta % (2*PI);

        // update emitter
        emitter.particleDirection = lookDir;
        emitter.emitterPosition = position;
    }

    public void updateWindParticles(float dt) {
        emitter.updateAll(dt, false);
    } 

    public void draw() {
        emitter.drawAllParticles();

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
        applyMatrix(u.x, v.x, w.x, 0f,
                    u.y, v.y, w.y, 0f,
                    u.z, v.z, w.z, 0f,
                    0,   0,   0,   1f);
        scale(0.2, 0.2, 0.2);
        shape(frame);
        rotateZ(theta);
        shape(wings);
        popMatrix();
    }

    public void hide(boolean hidden) {
        emitter.birthRate = hidden ? 0 : 10;
        this.hidden = hidden;
    }
}