class RopeSimulator {
    int segments;
    float gravity;
    Vec3 ropeTop;
    float restLength;
    float mass;
    float k; // Spring Constant
    float kd; // Spring Damping Constant
    float ropeLength;

    // Rendering Attributes
    Vec3 ropeColor = new Vec3(0,0,0);
    PImage texture;

    private Vec3[] nodes; // Location of segment links along the rope
    private Vec3[] nodeVelocities;
    private Vec3[] nodeAccelerations;


    public RopeSimulator(int segments, Vec3 initialRopeDirection) {
        this.segments = segments;
        this.nodes = new Vec3[segments];
        this.nodeVelocities = new Vec3[segments];
        this.nodeAccelerations = new Vec3[segments];
        this.k = 1000;
        this.gravity = 40;
        this.ropeTop = new Vec3(0,10,0);
        this.restLength = 0.5;
        this.mass = 0.3;
        this.kd = 0; 
        this.ropeLength = 20;
        initialRopeDirection.normalize();
        float segmentLength = ropeLength / segments;
        // Initialize each segment
        for (int i = 0; i < segments; i++) {
            nodes[i] = ropeTop.plus(initialRopeDirection.times(segmentLength*i));
            nodeVelocities[i] = new Vec3();
            nodeAccelerations[i] = new Vec3();
        }
    }

    public void update(float dt) {
        // Compute Hooke's Law with Damping
        for (int i = 0; i < segments - 1; i++) {
            Vec3 dxyz = nodes[i+1].minus(nodes[i]);
            float segmentLength = dxyz.length();
            float segmentForce = -k * (segmentLength - restLength); // Hookes law

            Vec3 segmentDir = dxyz.normalized();
            float projVTop = dot(nodeVelocities[i], segmentDir);
            float projVBottom = dot(nodeVelocities[i+1], segmentDir);
            float dampingForce = -kd * (projVTop - projVBottom);

            Vec3 force = segmentDir.times(segmentForce + dampingForce);
            nodeAccelerations[i].subtract(force.times(0.5/mass));
            nodeAccelerations[i+1] = force.times(0.5/mass);
        }

        // Integration
        // TODO: Figure out how we are supposed to write this
        //       using the library
        for (int i = 1; i < segments; i++) {
            nodeVelocities[i].add(nodeAccelerations[i].times(dt));
            nodeVelocities[i].y += (gravity*dt);
            nodes[i].add(nodeVelocities[i].times(dt));
        }
    }

    public void checkForCollisions(PShape[] rigidBodies) {
        // TODO: Implement
    }

    public void draw() {
        pushStyle();
        fill(ropeColor.x,ropeColor.y,ropeColor.z);
        if (texture != null) {
            // TODO: Add texture to rope
        }
        for (int i = 0; i < segments - 1; i++) {
            line(nodes[i].x,   nodes[i].y,   nodes[i].z,
                 nodes[i+1].x, nodes[i+1].y, nodes[i+1].z);
        }
        popStyle();
    }
}