public class ClothMesh {
  public float ks = 2600;
  public float kd = 1800;
  public float restLength = 0.25;
  public float vertexMass = 2.8;
  public Vec3 gravity = new Vec3(0,-5,0);
  public boolean debugMode = false;

  private int width;
  private int height;
  private Vec3[][] prevPositions;
  public Vec3[][] positions;
  private Vec3[][] velocities;
  private Vec3[][] nodesOnSurfaceNormals;
  private int stepCount = 30;
  private Vec3 spawnPoint;

  // Constructor
  public ClothMesh(int width, int height, Vec3 spawnPoint) {
    this.width = width;
    this.height = height;
    this.restLength = restLength;
    this.vertexMass = vertexMass;
    this.gravity = gravity;
    this.spawnPoint = spawnPoint;
    prevPositions = new Vec3[height][width];
    positions = new Vec3[height][width];
    velocities = new Vec3[height][width];
    nodesOnSurfaceNormals = new Vec3[height][width];
    
    // Initialize the vertices so that the cloth is flat.
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        positions[i][j] = new Vec3(i * restLength - restLength*height/2, 0, j * restLength - restLength*width/2);
        positions[i][j].add(spawnPoint);
        prevPositions[i][j] = new Vec3(positions[i][j]);
        velocities[i][j] = new Vec3(0, 0, 0);
        nodesOnSurfaceNormals[i][j] = null;
      }
    }
  }

  public void draw() {
    for (int i = 0; i < height-1; i++) {
    beginShape(TRIANGLE_STRIP);
        for (int j = 0; j < width-1; j++) {
            Vec3 node1 = positions[i+1][j];
            Vec3 node2 = positions[i][j];
            Vec3 node3 = positions[i+1][j+1];
            Vec3 node4 = positions[i][j+1];
            vertex(node1.x, node1.y, node1.z);
            vertex(node2.x, node2.y, node2.z);
            vertex(node3.x, node3.y, node3.z);
            vertex(node4.x, node4.y, node4.z);
        }
    endShape();
    }
    if (debugMode) {
        debugDraw();
    }
  }

  public void debugDraw() {
    // Debug drawing for cloth.
    pushStyle();
    stroke(255,0,0);
    for (int i = 0; i < height - 1; i++) {
      for (int j = 0; j < width - 1; j++) {
        Vec3 topLeft = cloth.positions[i][j];
        Vec3 topRight = cloth.positions[i][j+1];
        Vec3 bottomLeft = cloth.positions[i+1][j];
        Vec3 bottomRight = cloth.positions[i+1][j+1];
        line(topLeft.x, topLeft.y, topLeft.z, topRight.x, topRight.y, topRight.z);
        line(topRight.x, topRight.y, topRight.z, bottomRight.x, bottomRight.y, bottomRight.z);
        line(bottomRight.x, bottomRight.y, bottomRight.z, bottomLeft.x, bottomLeft.y, bottomLeft.z);
        line(bottomLeft.x, bottomLeft.y, bottomLeft.z, topLeft.x, topLeft.y, topLeft.z);
      }
    }
    popStyle();
    pushStyle();
    for (int i = 0; i < clothHeight; i++) {
        for (int j = 0; j < clothWidth; j++) {
            strokeWeight(1);
            stroke(0, 255, 0);
            Vec3 velDir = positions[i][j].plus(velocities[i][j].times(0.1));
            line(positions[i][j].x,   positions[i][j].y,   positions[i][j].z,
                    velDir.x, velDir.y, velDir.z);
            strokeWeight(5);
            stroke(0, 0, 255);
            point(positions[i][j].x, positions[i][j].y, positions[i][j].z);
        }
    }
    popStyle();
  }
  

  // This function updates the cloth using midpoint integration.
  public void updateMidpoint(float dt) {
    dt = dt/stepCount;
    for (int w = 0; w < stepCount; w++) {
        // Create copies of the current velocities and positions.
        Vec3[][] midpointVelocities = velocities;
        Vec3[][] midpointPositions = positions;
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            prevPositions[i][j] = new Vec3(positions[i][j]);
        }
        }
        
        // Compute the horizontal spring forces for the midpoint.
        for (int i = 0; i < height - 1; i++) {
        for (int j = 0; j < width; j++) {
            Vec3 springVector = positions[i+1][j].minus(positions[i][j]);
            float springLength = springVector.length();
            springVector.normalize();
            float v1 = dot(springVector, velocities[i][j]);
            float v2 = dot(springVector, velocities[i+1][j]);
            float force = -ks * (restLength - springLength) - kd * (v1 - v2);
            midpointVelocities[i][j].add(springVector.times(force / vertexMass * (dt/2)));
            midpointVelocities[i+1][j].subtract(springVector.times(force / vertexMass * (dt/2)));
        }
        }
        
        // Compute the vertical spring forces for the midpoint.
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width - 1; j++) {
            Vec3 springVector = positions[i][j+1].minus(positions[i][j]);
            float springLength = springVector.length();
            springVector.normalize();
            float v1 = dot(springVector, velocities[i][j]);
            float v2 = dot(springVector, velocities[i][j+1]);
            float force = -ks * (restLength - springLength) - kd * (v1 - v2);
            midpointVelocities[i][j].add(springVector.times(force / vertexMass * (dt/2)));
            midpointVelocities[i][j+1].subtract(springVector.times(force / vertexMass * (dt/2)));
        }
        }
        
        // Apply gravity and clamp the top of the cloth.
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            if (i == 0) { // Clamp
            // midpointVelocities[i][j] = new Vec3(0, 0, 0);
            }
            else { // Gravity
            midpointVelocities[i][j].add(gravity.times(dt));
            }
        }
        }
        
        // Update the midpoint positions.
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            midpointPositions[i][j].add(midpointVelocities[i][j].times(dt/2));
        }
        }
        
        // Create another velocity array for the complete timestep.
        Vec3[][] finalVelocities = velocities;
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            finalVelocities[i][j] = velocities[i][j];
        }
        }
        
        // Compute the horizontal spring forces for the final step.
        for (int i = 0; i < height - 1; i++) {
        for (int j = 0; j < width; j++) {
            Vec3 springVector = midpointPositions[i+1][j].minus(midpointPositions[i][j]);
            float springLength = springVector.length();
            springVector.normalize();
            float v1 = dot(springVector, midpointVelocities[i][j]);
            float v2 = dot(springVector, midpointVelocities[i+1][j]);
            float force = -ks * (restLength - springLength) - kd * (v1 - v2);
            finalVelocities[i][j].add(springVector.times(force / vertexMass * dt));
            finalVelocities[i+1][j].subtract(springVector.times(force / vertexMass * dt));
        }
        }
        
        // Compute the vertical spring forces for the final step.
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width - 1; j++) {
            Vec3 springVector = midpointPositions[i][j+1].minus(midpointPositions[i][j]);
            float springLength = springVector.length();
            springVector.normalize();
            float v1 = dot(springVector, midpointVelocities[i][j]);
            float v2 = dot(springVector, midpointVelocities[i][j+1]);
            float force = -ks * (restLength - springLength) - kd * (v1 - v2);
            finalVelocities[i][j].add(springVector.times(force / vertexMass * dt));
            finalVelocities[i][j+1].subtract(springVector.times(force / vertexMass * dt));
        }
        }
        
        // Apply gravity and clamp the top of the cloth (again).
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            if (i == 0) { // Clamp
            // finalVelocities[i][j] = new Vec3(0, 0, 0);
            }
            else { // Gravity
            finalVelocities[i][j].add(gravity.times(dt));
            }
        }
        }
        
        // Update the final velocities and positions.
        for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            positions[i][j].add(velocities[i][j].times(dt));
            velocities[i][j] = finalVelocities[i][j];
            Vec3 normal = nodesOnSurfaceNormals[i][j];
            if (normal != null) {
                // Exclude velocity in direction of surface
                if (dot(velocities[i][j], normal) < 0) {
                    velocities[i][j].subtract(projAB(velocities[i][j], normal));
                }
            }
        }
        }
        checkForCollisions();
    }
  }


  public void checkForCollisions() {
      for (int i = 0; i < height; i++) {
          for (int j = 0; j < width; j++) {
            Vec3 p1 = prevPositions[i][j];
            Vec3 p2 = positions[i][j];
            Vec3 motionVec = p1.minus(p2);
            if (motionVec.length() == 0) {
                // The previous and current posiitions are the same, nothing required
                break;
            }
            Ray3 r = new Ray3(p1, motionVec, motionVec.length());
            if (debugMode) {
                r.debugDraw();
            }
            ArrayList<PShape> tris = ot.rayIntersectsOctants(r);
            CollisionInfo furthestColl = null;
            float maxT = -1;
            for (PShape tri : tris) {
                CollisionInfo coll = rayTriangleCollision(r, tri);
                if (coll != null) {
                    if (coll.t > maxT) {
                        furthestColl = coll;
                        maxT = coll.t;
                    }
                }
            }
            if (maxT >= 0) {
                if (nodesOnSurfaceNormals[i][j] == null || !nodesOnSurfaceNormals[i][j].equals(furthestColl.surfaceNormal)) {
                        // positions[i][j] = furthestColl.position;
                        positions[i][j] = furthestColl.position.plus(furthestColl.surfaceNormal.times(0.01));
                        nodesOnSurfaceNormals[i][j] = furthestColl.surfaceNormal;
                }
                if (debugMode) {
                    // Show green dot where collision occurs
                    pushStyle();
                    strokeWeight(15);
                    stroke(0,255,0);
                    point(furthestColl.position.x, furthestColl.position.y, furthestColl.position.z);
                    popStyle();
                }
            }
            for (Sphere sphere : collisionSpheres) {
                if (sphere.pointInSphere(positions[i][j])) {
                    // Move point out of sphere
                    positions[i][j] = sphere.center.plus(positions[i][j].minus(sphere.center).normalized().times(sphere.radius));
                    velocities[i][j].subtract(projAB(velocities[i][j], positions[i][j].minus(sphere.center).normalized()));
                }
            }
          }
      }
  }
}
