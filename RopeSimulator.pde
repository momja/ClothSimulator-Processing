class RopeSimulator {
    int segments;
    Vec3 gravity;
    Vec3 ropeTop;
    float restLength;
    float mass;
    float k; // Spring Constant
    float kd; // Spring Damping Constant
    PShape[] rigidBodies;
    boolean debugMode = false;

    // Rendering Attributes
    Vec3 ropeColor = new Vec3(255,0,0);
    PImage texture;

    private Vec3[] nodesPrev;
    private Vec3[] nodes; // Location of segment links along the rope
    private Vec3[] nodesOnSurfaceNormals;
    private Vec3[] nodeVelocities;
    private Vec3[] nodeAccelerations;
    private ArrayList<PShape> triangleCollisionsDebug;


    public RopeSimulator(int segments, Vec3 initialRopeDirection, Vec3 ropeTop, float ropeLength) {
        this.segments = segments;
        this.nodesPrev = new Vec3[segments];
        this.nodes = new Vec3[segments];
        this.nodesOnSurfaceNormals = new Vec3[segments];
        this.nodeVelocities = new Vec3[segments];
        this.nodeAccelerations = new Vec3[segments];
        this.triangleCollisionsDebug = new ArrayList<PShape>();
        this.k = 2500;
        this.gravity = new Vec3(0,-50,0);
        this.ropeTop = ropeTop;
        this.restLength = ropeLength/(segments-1);
        this.mass = 0.1;
        this.kd = 250;
        initialRopeDirection.normalize();
        // Initialize each segment
        for (int i = 0; i < segments; i++) {
            nodes[i] = ropeTop.plus(initialRopeDirection.times(restLength*i));
            nodesPrev[i] = new Vec3(nodes[i]);
            nodesOnSurfaceNormals[i] = null;
            nodeVelocities[i] = new Vec3();
            nodeAccelerations[i] = new Vec3();
        }
    }

    public void update(float dt) {
        int stepCount = 80;
        float timeStep = dt/stepCount;
        if (debugMode) {
            triangleCollisionsDebug = new ArrayList<PShape>();
        }
        // Eulerian
        // --------
        for (int j = 0; j < stepCount; j++) {
            for (int i = 1; i < segments; i++) {
                nodeVelocities[i].add(nodeAccelerations[i].times(timeStep));
                if (nodesOnSurfaceNormals[i] != null) {
                    // Exclude velocity moving into the triangle
                    if (dot(nodeVelocities[i], nodesOnSurfaceNormals[i]) < 0) {
                        nodeVelocities[i].subtract(projAB(nodeVelocities[i], nodesOnSurfaceNormals[i]));
                    }
                    // Subtract friction
                    nodeVelocities[i].mul(0.99);
                }
                // assert Double.isNaN(nodeVelocities[i].x+nodeVelocities[i].y+nodeVelocities[i].z);
            }
            for (int i = 1; i < segments; i++) {
                nodesPrev[i] = new Vec3(nodes[i]);
                nodes[i].add(nodeVelocities[i].times(timeStep));

                // assert Double.isNaN(nodes[i].x+nodes[i].y+nodes[i].z);
            }
            updateHookes();
            checkForCollisions();
        }

        // Midpoint
        // --------
        // for (int j = 0; j < stepCount; j++) {
        //     Vec3 k1 = new Vec3(), k2 = new Vec3(), k3 = new Vec3();
        //     updateHookes();
        //     for (int i = 1; i < segments; i++) {
        //         k1 = nodeAccelerations[i];
        //         nodeVelocities[i].add(k1.times(timeStep/4));
        //         nodesPrev[i] = new Vec3(nodes[i]);
        //         nodes[i].add(nodeVelocities[i].times(timeStep/4));
        //     }
        //     checkForCollisions();
        //     updateHookes();
        //     for (int i = 1; i < segments; i++) {
        //         k2 = nodeAccelerations[i];
        //         nodeVelocities[i].add(k2.times(timeStep/2));
        //         nodesPrev[i] = new Vec3(nodes[i]);
        //         nodes[i].add(nodeVelocities[i].times(timeStep/2));         
        //     }
        //     checkForCollisions();
        //     updateHookes();
        //     for (int i = 1; i < segments; i++) {
        //         k3 = nodeAccelerations[i];
        //         nodeVelocities[i].add(k3.times(timeStep/4));
        //         nodesPrev[i] = new Vec3(nodes[i]);
        //         nodes[i].add(nodeVelocities[i].times(timeStep/4));
        //     }
        //     checkForCollisions();
        // }
    }

    public void draw() {
        pushStyle();
        stroke(ropeColor.x,ropeColor.y,ropeColor.z);
        if (texture != null) {
            // TODO: Add texture to rope
        }
        for (int i = 0; i < segments - 1; i++) {
            strokeWeight(0.5);
            line(nodes[i].x,   nodes[i].y,   nodes[i].z,
                 nodes[i+1].x, nodes[i+1].y, nodes[i+1].z);
            strokeWeight(10);
            point(nodes[i+1].x, nodes[i+1].y, nodes[i+1].z);
        }
        popStyle();

        if (debugMode) {
            drawDebug();
        }
    }

    private void drawDebug() {
        pushStyle();
        stroke(0, 255, 0);
        for (int i = 0; i < segments; i++) {
            strokeWeight(1);
            Vec3 velDir = nodes[i].plus(nodeVelocities[i].times(0.3));
            line(nodes[i].x,   nodes[i].y,   nodes[i].z,
                 velDir.x, velDir.y, velDir.z);
            strokeWeight(5);
        }
        for (PShape tri : triangleCollisionsDebug) {
            fill(0,0,255);
            shape(tri);
        }
        popStyle();
    }

    private void checkForCollisions() {
        for (int i = 1; i < segments; i++) {
            Vec3 p1 = nodesPrev[i];
            Vec3 p2 = nodes[i];
            if (rigidBodies == null) {
                return;
            }
            Vec3 motionVec = p2.minus(p1);
            if (motionVec.length() == 0) {
                // The previous and current posiitions are the same, nothing required
                break;
            }
            Ray3 r = new Ray3(p1, motionVec, motionVec.length());
            ArrayList<PShape> tris = ot.rayIntersectsOctants(r);
            CollisionInfo closestColl = null;
            float minT = Float.MAX_VALUE;
            PShape closestTri = null;
            int cnt = 0;
            for (PShape tri : tris) {
                CollisionInfo coll = rayTriangleCollision(r, tri);
                if (coll != null && coll.t < minT) {
                    closestColl = coll;
                    minT = coll.t;
                    closestTri = tri;
                }
            }
            if (closestColl == null) {
                nodesOnSurfaceNormals[i] = null;
            } else {
                if (nodesOnSurfaceNormals[i] == null || !nodesOnSurfaceNormals[i].equals(closestColl.surfaceNormal)) {
                    // nodes[i] = closestColl.position;
                    nodes[i] = closestColl.position.plus(closestColl.surfaceNormal.times(0.01));
                }
                nodesOnSurfaceNormals[i] = closestColl.surfaceNormal;
                if (debugMode) {
                    triangleCollisionsDebug.add(closestTri);
                    // Show green dot where collision occurs
                    pushStyle();
                    strokeWeight(15);
                    stroke(0,255,0);
                    point(closestColl.position.x, closestColl.position.y, closestColl.position.z);
                    popStyle();
                }
            }
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

            assert !Double.isNaN(nodeAccelerations[i].x + nodeAccelerations[i].y + nodeAccelerations[i].z) : "Hookes Law Failure";
        }
    }
}