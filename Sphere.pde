class Sphere {
    Vec3 fillColor = new Vec3(255,255,255);
    Vec3 center;
    float radius;
    public Sphere(float radius, Vec3 center) {
        this.radius = radius;
        this.center = center;
    }

    public void draw() {
        push();
        fill(fillColor.x, fillColor.y, fillColor.z);
        noStroke();
        translate(center.x, center.y, center.z);
        sphere(radius);
        pop();
    }

    public boolean pointInSphere(Vec3 p) {
        return (p.minus(center).length() < radius);
    }
}