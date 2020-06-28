class RopeSimulator {
    int segments;
    float gravity;
    float radius;
    Vec3 ropeTop;
    float restLength;
    float mass;
    float k; // Spring Constant
    float kv; // Spring Damping Constant
    float ropeLength;

    private Vec3[] nodes; // Location of segment links along the rope
    private Vec3[] nodeVelocities;

    public RopeSimulator(int segments, Vec3 initialRopeDirection) {
        this.segments = segments;
        this.nodes = new Vec3[segments];
        this.nodeVelocities = new Vec3[segments];
        initialRopeDirection.normalize();
        float segmentLength = ropeLength / segments;
        // Initialize each segment
        for (int i = 0; i < segments; i++) {
            nodes[i] = ropeTop.plus(initialRopeDirection.times(segmentLength*i));
            nodeVelocities = new Vec3();
        }
    }

    public void update(float dt) {
        for (int i = 0; i < segments; i++) {
            Vec3 dxyz = new Vec3()
        }
    }
}