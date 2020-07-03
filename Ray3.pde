class Ray3 {
    Vec3 origin;
    Vec3 direction;
    float magnitude = -1;
    Vec3 invDir;
    int[] sign = new int[3];
    
    public Ray3(Vec3 origin, Vec3 dir, float magnitude) {
        this.origin = origin;
        this.direction = dir.normalized();
        this.magnitude = magnitude;

        invDir = new Vec3(1.f/dir.x, 1.f/dir.y, 1.f/dir.z);
        sign[0] = int(invDir.x < 0);
        sign[1] = int(invDir.y < 0);
        sign[2] = int(invDir.z < 0);
    }

    public Ray3(Vec3 origin, Vec3 dir) {
        this.origin = origin;
        this.direction = dir.normalized();

        invDir = new Vec3(1.f/dir.x, 1.f/dir.y, 1.f/dir.z);
        sign[0] = int(invDir.x < 0);
        sign[1] = int(invDir.y < 0);
        sign[2] = int(invDir.z < 0);
    }
}