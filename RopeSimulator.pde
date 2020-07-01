class RopeSimulator {
    int segments;
    Vec3 gravity;
    Vec3 ropeTop;
    float restLength;
    float mass;
    float k; // Spring Constant
    float kd; // Spring Damping Constant
    PShape[] rigidBodies;

    // Rendering Attributes
    Vec3 ropeColor = new Vec3(0,0,0);
    PImage texture;

    private Vec3[] nodes; // Location of segment links along the rope
    private Vec3[] nodeVelocities;
    private Vec3[] nodeAccelerations;


    public RopeSimulator(int segments, Vec3 initialRopeDirection, Vec3 ropeTop, float ropeLength) {
        this.segments = segments;
        this.nodes = new Vec3[segments];
        this.nodeVelocities = new Vec3[segments];
        this.nodeAccelerations = new Vec3[segments];
        this.k = 500;
        this.gravity = new Vec3(0,-50,0);
        this.ropeTop = ropeTop;
        this.restLength = ropeLength/(segments-1);
        this.mass = 0.1;
        this.kd = 100;
        initialRopeDirection.normalize();
        // Initialize each segment
        for (int i = 0; i < segments; i++) {
            nodes[i] = ropeTop.plus(initialRopeDirection.times(restLength*i));
            nodeVelocities[i] = new Vec3();
            nodeAccelerations[i] = new Vec3();
        }
    }

    public void update(float dt) {
        int stepCount = 20;
        float timeStep = dt/stepCount;
        // Eulerian
        // --------
        // for (int j = 0; j < stepCount; j++) {
        //     updateHookes();
        //     for (int i = 1; i < segments; i++) {
        //         nodeVelocities[i].add(nodeAccelerations[i].times(timeStep));
        //         nodes[i].add(nodeVelocities[i].times(timeStep));
        //     }
        // }

        // Midpoint
        // --------
        for (int j = 0; j < stepCount; j++) {
            Vec3 k1 = new Vec3(), k2 = new Vec3(), k3 = new Vec3();
            updateHookes();
            for (int i = 1; i < segments; i++) {
                k1 = nodeAccelerations[i];
                nodeVelocities[i].add(k1.times(timeStep/4));
                Vec3 p1 = new Vec3(nodes[i]);
                nodes[i].add(nodeVelocities[i].times(timeStep/4));
                // checkForCollisions(i, p1, nodes[i]);
            }
            updateHookes();
            for (int i = 1; i < segments; i++) {
                k2 = nodeAccelerations[i];
                nodeVelocities[i].add(k2.times(timeStep/2));
                Vec3 p1 = new Vec3(nodes[i]);
                nodes[i].add(nodeVelocities[i].times(timeStep/2));         
                // checkForCollisions(i, p1, nodes[i]);
            }
            updateHookes();
            for (int i = 1; i < segments; i++) {
                k3 = nodeAccelerations[i];
                nodeVelocities[i].add(k3.times(timeStep/4));
                Vec3 p1 = new Vec3(nodes[i]);
                nodes[i].add(nodeVelocities[i].times(timeStep/4));
                // checkForCollisions(i, p1, nodes[i]);
            }
        }
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

    private void checkForCollisions(int idx, Vec3 p1, Vec3 p2) {
        if (rigidBodies == null) {
            return;
        }
        Vec3 collisionPoint = lineTriangleCollision(p1, p2, rigidBodies);
        if (collisionPoint != null) {
            // Handle collision 
            // nodes[idx] = collisionPoint;
            // nodeVelocities[idx].mul(-0.3);
        }
    }

    private void updateHookes() {
        for (int i = 0; i < segments - 1; i++) {
            Vec3 dxyz = nodes[i+1].minus(nodes[i]);
            float segmentLength = dxyz.length();
            float segmentForce = -k * (segmentLength - restLength); // Hookes law

            Vec3 segmentDir = dxyz.normalized();
            float projVBottom = dot(nodeVelocities[i], segmentDir);
            float projVTop = dot(nodeVelocities[i+1], segmentDir);
            float dampingForce = -kd * (projVTop - projVBottom);

            Vec3 force = segmentDir.times(segmentForce + dampingForce);
            nodeAccelerations[i].subtract(force.times(0.5/mass));
            nodeAccelerations[i+1] = force.times(0.5/mass).plus(gravity);
        }
    }
}