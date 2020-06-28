import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ClothSimulatorProcessing extends PApplet {

Camera cam = new Camera();
HeadsUpDisplay hud = new HeadsUpDisplay();

public void setup() {
    
    perspective(radians(60), 1+1.f/3, 1, 1000);
    surface.setTitle("Cloth Simulation [Max Omdal]");
}

public void draw() {
    cam.update();
    background(0);
    // TODO : Insert Cloth Simulation Here
    box(20,20,20);

    // Heads Up Display
    hud.draw();
}
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
                theta -= 1.1f;
            } else if (keyCode == RIGHT) {
                theta += 1.1f;
            }
        }
        camLocation.x = cos(radians(theta))*cameraRadius;
        camLocation.y = PApplet.parseFloat(slider)/5;
        camLocation.z = sin(radians(theta))*cameraRadius;
        camera(camLocation.x, camLocation.y, camLocation.z,
               camLookAt.x,   camLookAt.y,   camLookAt.z,
               camUp.x,       camUp.y,       camUp.z);
    }
}
class HeadsUpDisplay {
    public boolean showFrameRate = true;
    public PFont font;
    public float fontSize;
    public int defaultColor = color(0, 0, 0);

    public HeadsUpDisplay() {
    }

    public void draw() {
        camera();
        hint(DISABLE_DEPTH_TEST);
        push();
        noLights();
        textMode(MODEL);
        textSize(24);
        textAlign(LEFT, TOP);
        text("fps "+round(frameRate), 10, 10);
        pop();
        hint(ENABLE_DEPTH_TEST);
    }

    public void setFont(PFont font) {
        this.font = font;
    }

    public void setFontSize(float fontSize) {
        this.fontSize = fontSize;
    }

    public void setColor(int c) {
        this.defaultColor = c;
    }
}
public Vec3 testForCollisions(Vec3 origin, Vec3 dir, PShape[] rigidBodies) {
 // Check each boid to see if it has collided with the collision meshes
 Vec3 closestPoint = null;
 float tMin = Float.MAX_VALUE;
        for (PShape rigidBody : rigidBodies) {
        int triCount = rigidBody.getChildCount();
        for (int i = 0; i < triCount; i++) {
            PShape triangle = rigidBody.getChild(i);
            int j = 0;
            Vec3 boidPosition = origin;

            Vec3 rayOrigin = boidPosition;
            Vec3 rayDirection = dir;
            rayDirection.normalize();

            PVector v1 = triangle.getVertex(0);
            PVector v2 = triangle.getVertex(1);
            PVector v3 = triangle.getVertex(2);

            Vec3 vert1 = new Vec3(v1.x, v1.y, v1.z);
            Vec3 vert2 = new Vec3(v2.x, v2.y, v2.z);
            Vec3 vert3 = new Vec3(v3.x, v3.y, v3.z);

            Vec3 e1 = vert2.minus(vert1);
            Vec3 e2 = vert3.minus(vert1);

            Vec3 surfaceNormal = cross(e1, e2);
            // float x_0 = rayOrigin.x; float y_0 = rayOrigin.y; float z_0 = rayOrigin.z;
            // float x_d = rayDirection.x; float y_d = rayDirection.y; float z_d = rayDirection.z;
            float denominator = dot(surfaceNormal, rayDirection);
            if (abs(denominator) <= 0.0001f) {
                // No ray plane intersection exists
                continue;
            }

            float D = dot(vert1, surfaceNormal);

            float numerator = -(dot(surfaceNormal, rayOrigin) - D);

            float t = numerator/denominator;

            if (t < 0) {
                // Haven't hit yet
                continue;
            }
            
            Vec3 p = rayOrigin.plus(rayDirection.times(t));

            if (t < tMin && pointLiesOnTriangle(p, vert1, vert2, vert3, e1, e2)) {
                closestPoint = p;
                t = tMin;
            }
            
        }
        }
    return closestPoint;
}
//Vector Library [2D]
//CSCI 5611 Vector 3 Library [Incomplete]

//Instructions: Add 3D versions of all of the 2D vector functions
//              Vec3 must also support the cross product.
public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x + ", " + y + ")";
  }
  
  public float length(){
    return sqrt(x*x + y*y);
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(rhs.x+this.x, rhs.y+this.y);
  }
  
  public void add(Vec2 rhs){
    this.x += rhs.x;
    this.y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(this.x-rhs.x, this.y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    this.x -= rhs.x;
    this.y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(this.x*rhs, this.y*rhs);
  }
  
  public void mul(float rhs){
    this.x *= rhs;
    this.y *= rhs;
  }
  
  public void normalize(){
    float magnitude = this.length();
    this.x /= magnitude;
    this.y /= magnitude;
  }
  
  public Vec2 normalized(){
    float magnitude = this.length();
    return new Vec2(this.x/magnitude, this.y/magnitude);
  }
  
  public float distanceTo(Vec2 rhs){
    return this.minus(rhs).length();
  }
}

public Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

public float interpolate(float a, float b, float t) {
   return a + (b - a)*t; 
}

public float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

public Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(dot(a, b));
}
//Vector Library [2D]
//CSCI 5611 Vector 3 Library [Incomplete]

//Instructions: Add 3D versions of all of the 2D vector functions
//              Vec3 must also support the cross product.
public class Vec3 {
  public float x, y, z;
  
  public Vec3(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public Vec3(Vec3 copyVec) {
    this.x = copyVec.x;
    this.y = copyVec.y;
    this.z = copyVec.z;
  }
  
  public String toString(){
    return "(" + x + ", " + y + ", " + z + ")";
  }
  
  public float length(){
    return sqrt(x*x + y*y + z*z);
  }
  
  public Vec3 plus(Vec3 rhs){
    return new Vec3(rhs.x+this.x, rhs.y+this.y, rhs.z+this.z);
  }
  
  public void add(Vec3 rhs){
    this.x += rhs.x;
    this.y += rhs.y;
    this.z += rhs.z;
  }
  
  public Vec3 minus(Vec3 rhs){
    return new Vec3(this.x-rhs.x, this.y-rhs.y, this.z-rhs.z);
  }
  
  public void subtract(Vec3 rhs){
    this.x -= rhs.x;
    this.y -= rhs.y;
    this.z -= rhs.z;
  }
  
  public Vec3 times(float rhs){
    return new Vec3(this.x*rhs, this.y*rhs, this.z*rhs);
  }

  public Vec3 times(Vec3 v) {
    return new Vec3(this.x*v.x, this.y*v.y, this.z*v.z);
  }
  
  public void mul(float rhs){
    this.x *= rhs;
    this.y *= rhs;
    this.z *= rhs;
  }
  
  public void normalize(){
    float magnitude = this.length();
    this.x /= magnitude;
    this.y /= magnitude;
    this.z /= magnitude;
  }
  
  public Vec3 normalized(){
    float magnitude = this.length();
    return new Vec3(this.x/magnitude, this.y/magnitude, this.z/magnitude);
  }
  
  public float distanceTo(Vec3 rhs){
    return this.minus(rhs).length();
  }

  public void clamp(float minLength, float maxLength) {
    float curLength = length();
    if (curLength > maxLength) {
      this.normalize();
      this.mul(maxLength);
    } else if (curLength < minLength) {
      this.normalize();
      this.mul(minLength);
    }
  }
}

public Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return a.plus((b.minus(a)).times(t));
}

public float dot(Vec3 a, Vec3 b){
  return a.x*b.x + a.y*b.y + a.z*b.z;
}

public Vec3 cross(Vec3 a, Vec3 b){
  return new Vec3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);
}

public Vec3 projAB(Vec3 a, Vec3 b){
  return b.times(dot(a, b));
}

public Vec3 reflect(Vec3 d, Vec3 n) {
  Vec3 r = d.minus(n.times(dot(d,n.normalized())*2));
  return r;
}

public boolean pointLiesOnTriangle(Vec3 point, Vec3 vert1, Vec3 vert2, Vec3 vert3, Vec3 e1, Vec3 e2) {
  // See if point on a plane is within a triangle
  // Vec3 ep = point.minus(vert1);
  // float d11 = dot(e1,e1);
  // float d12 = dot(e1,e2);
  // float d22 = dot(e2,e2);
  // float dp1 = dot(ep,e1);
  // float dp2 = dot(ep,e2);
  // float D       = d11*d22 - d12*d12;
  // float D_beta  = d22*dp1 - d12*dp2;
  // float D_gamma = d11*dp2 - d12*dp1;
  // float beta = D_beta/D;
  // float gamma = D_gamma/D;
  // float alpha = 1 - beta + gamma;
  // print(alpha);
  // print(" ");
  // print(beta);
  // print(" ");
  // print(gamma);
  // println();
  // return (alpha > 0.0000001 && alpha < 1.0000001);

  // Source inspired by Scratchapixel:
  // https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle/barycentric-coordinates

  Vec3 surfaceNormal = cross(e1, e2);
  Vec3 C;

  Vec3 edge0 = vert2.minus(vert1);
  Vec3 vp0 = point.minus(vert1);
  C = cross(edge0, vp0);
  if (dot(surfaceNormal, C) < 0) { return false; }

  Vec3 edge1 = vert3.minus(vert2);
  Vec3 vp1 = point.minus(vert2);
  C = cross(edge1, vp1);
  if (dot(surfaceNormal, C) < 0) { return false; }

  Vec3 edge2 = vert1.minus(vert3);
  Vec3 vp2 = point.minus(vert3);
  C = cross(edge2, vp2);
  if (dot(surfaceNormal, C) < 0) { return false; }

  return true;
}
  public void settings() {  size(640,480,P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ClothSimulatorProcessing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
