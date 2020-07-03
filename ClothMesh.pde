public class ClothMesh {
  // Constructor
  public ClothMesh(int width, int height, float ks, float kd,float restLength, float vertexMass, float gravity) {
    this.width = width;
    this.height = height;
    this.ks = ks;
    this.kd = kd;
    this.restLength = restLength;
    this.vertexMass = vertexMass;
    this.gravity = gravity;
    positions = new Vec3[height][width];
    velocities = new Vec3[height][width];
    
    
    // Initialize the vertices so that the cloth is flat.
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        positions[i][j] = new Vec3(i * restLength, 0, j * restLength);
        velocities[i][j] = new Vec3(0, 0, 0);
      }
    }
  }

  public void draw() {
    // Debug drawing for cloth.
    for (int i = 0; i < clothHeight - 1; i++) {
      for (int j = 0; j < clothWidth - 1; j++) {
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
  }
  
  
  // This updates the cloth using simple Eulerian integration.
  // Note: This requires an extremely small dt (<= 0.001).
  public void updateEulerian(float dt) {
    // Create a copy of the current velocities.
    Vec3[][] newVelocities = velocities; 
    
    // Compute the horizontal spring forces.
    for (int i = 0; i < height - 1; i++) {
      for (int j = 0; j < width; j++) {
        Vec3 springVector = positions[i+1][j].minus(positions[i][j]);
        float springLength = springVector.length();
        springVector.normalize();
        float v1 = dot(springVector, velocities[i][j]);
        float v2 = dot(springVector, velocities[i+1][j]);
        float force = -ks * (restLength - springLength) - kd * (v1 - v2);
        newVelocities[i][j].add(springVector.times(force / vertexMass * dt));
        newVelocities[i+1][j].subtract(springVector.times(force / vertexMass * dt));
      }
    }
    
    // Compute the vertical spring forces.
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width - 1; j++) {
        Vec3 springVector = positions[i][j+1].minus(positions[i][j]);
        float springLength = springVector.length();
        springVector.normalize();
        float v1 = dot(springVector, velocities[i][j]);
        float v2 = dot(springVector, velocities[i][j+1]);
        float force = -ks * (restLength - springLength) - kd * (v1 - v2);
        newVelocities[i][j].add(springVector.times(force / vertexMass * dt));
        newVelocities[i][j+1].subtract(springVector.times(force / vertexMass * dt));
      }
    }
    
    // Apply gravity and clamp the top of the cloth.
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (i == 0) { // Clamp
          newVelocities[i][j] = new Vec3(0, 0, 0);
        }
        else { // Gravity
          newVelocities[i][j].add(new Vec3(0, gravity, 0));
        }
      }
    }
    
    // Update the positions.
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        positions[i][j].add(velocities[i][j].times(dt));
      }
    }
    
    // Update the velocities array.
    velocities = newVelocities;
  }
  

  // This function updates the cloth using midpoint integration.
  public void updateMidpoint(float dt) {
    // Create copies of the current velocities and positions.
    Vec3[][] midpointVelocities = velocities; 
    Vec3[][] midpointPositions = positions;
    
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
          midpointVelocities[i][j] = new Vec3(0, 0, 0);
        }
        else { // Gravity
          midpointVelocities[i][j].add(new Vec3(0, gravity, 0));
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
          finalVelocities[i][j] = new Vec3(0, 0, 0);
        }
        else { // Gravity
          finalVelocities[i][j].add(new Vec3(0, gravity, 0));
        }
      }
    }
    
    // Update the final velocities and positions.
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        positions[i][j].add(velocities[i][j].times(dt));
        velocities[i][j] = finalVelocities[i][j];
      }
    }
  }

  
  public void checkForCollisions() {
      
  }

  
  private int width;
  private int height;
  private float ks;
  private float kd;
  private float restLength;
  private float vertexMass;
  private float gravity;
  public Vec3[][] positions;
  private Vec3[][] velocities;
}
