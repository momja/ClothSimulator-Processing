class OctreePoints {
    Octant bounds;
    int capacity;
    ArrayList<Vec3> points;
    boolean divided = false;

    OctreePoints q111,q011,q001,q101,q110,q010,q000,q100;

    public OctreePoints(Octant bounds, int capacity) {
        this.bounds = bounds;
        this.capacity = capacity;
        this.points = new ArrayList<Vec3>();
    }

    public void insert(Vec3 p) {
        if (!this.bounds.contains(p)) {
            return;
        }

        if (this.points.size() < this.capacity) {
            this.points.add(p);
        } else {
            if (!this.divided) {
                subdivide();
            }

            q111.insert(p);
            q011.insert(p);
            q001.insert(p);
            q101.insert(p);
            q110.insert(p);
            q010.insert(p);
            q000.insert(p);
            q100.insert(p);
        }
    }

    public void show() {
        strokeWeight(0.8);
        stroke(255);
        noFill();
        pushMatrix();
        translate(bounds.origin.x, bounds.origin.y, bounds.origin.z);
        box(bounds.size.x, bounds.size.y, bounds.size.z);
        popMatrix();
        if (this.divided) {
            q111.show();
            q011.show();
            q001.show();
            q101.show();
            q110.show();
            q010.show();
            q000.show();
            q100.show();
        }
        pushStyle();
        strokeWeight(4);
        stroke(255,0,0);
        for (Vec3 p : points) {
            // point(p.x, p.y, p.z);
        }
        popStyle();
    }

    public ArrayList<Vec3> rayIntersectsOctants(Ray3 ray) {
        // Gets all octants that the ray is in and returns the points stored in those octants
        
        ArrayList<Vec3> pointsInOctants = new ArrayList<Vec3>();
        
        if (bounds.rayIntersects(ray)) {
            if (divided) {
                // Recursively divide
                pointsInOctants.addAll(q111.rayIntersectsOctants(ray));
                pointsInOctants.addAll(q011.rayIntersectsOctants(ray));
                pointsInOctants.addAll(q001.rayIntersectsOctants(ray));
                pointsInOctants.addAll(q101.rayIntersectsOctants(ray));
                pointsInOctants.addAll(q110.rayIntersectsOctants(ray));
                pointsInOctants.addAll(q010.rayIntersectsOctants(ray));
                pointsInOctants.addAll(q000.rayIntersectsOctants(ray));
                pointsInOctants.addAll(q100.rayIntersectsOctants(ray));
            } else {
                // Just add the points in this oct
                pointsInOctants.addAll(points);
            }
        }

        return pointsInOctants;
    }

    private void subdivide() {
        Vec3 origin = bounds.origin;
        Vec3 size = bounds.size;
        Vec3 subdivideSize = size.times(0.5);

        Octant q111_b = new Octant(origin.plus(subdivideSize.times(new Vec3(0.5,0.5,0.5))), subdivideSize);
        q111 = new OctreePoints(q111_b, capacity);
        Octant q011_b = new Octant(origin.plus(subdivideSize.times(new Vec3(-0.5,0.5,0.5))), subdivideSize);
        q011 = new OctreePoints(q011_b, capacity);
        Octant q001_b = new Octant(origin.plus(subdivideSize.times(new Vec3(-0.5,-0.5,0.5))), subdivideSize);
        q001 = new OctreePoints(q001_b, capacity);
        Octant q101_b = new Octant(origin.plus(subdivideSize.times(new Vec3(0.5,-0.5,0.5))), subdivideSize);
        q101 = new OctreePoints(q101_b, capacity);
        Octant q110_b = new Octant(origin.plus(subdivideSize.times(new Vec3(0.5,0.5,-0.5))), subdivideSize);
        q110 = new OctreePoints(q110_b, capacity);
        Octant q010_b = new Octant(origin.plus(subdivideSize.times(new Vec3(-0.5,0.5,-0.5))), subdivideSize);
        q010 = new OctreePoints(q010_b, capacity);
        Octant q000_b = new Octant(origin.plus(subdivideSize.times(new Vec3(-0.5,-0.5,-0.5))), subdivideSize);
        q000 = new OctreePoints(q000_b, capacity);
        Octant q100_b = new Octant(origin.plus(subdivideSize.times(new Vec3(0.5,-0.5,-0.5))), subdivideSize);
        q100 = new OctreePoints(q100_b, capacity);

        this.divided = true;
    }

}

class Octant {
    Vec3 origin;
    Vec3 size;
    int capacity;
    float xmin, xmax, ymin, ymax, zmin, zmax;
    Vec3[] bounds = new Vec3[2];

    public Octant(Vec3 origin, Vec3 size) {
        this.origin = origin;
        this.size = size;

        this.xmin = origin.x - size.x/2;
        this.xmax = origin.x + size.x/2;
        this.ymin = origin.y - size.y/2;
        this.ymax = origin.y + size.y/2;
        this.zmin = origin.z - size.z/2;
        this.zmax = origin.z + size.z/2;
        bounds[0] = new Vec3(xmin,ymin,zmin);
        bounds[1] = new Vec3(xmax,ymax,zmax);
    }

    public boolean contains(Vec3 p) {
        return (p.x >= xmin &&
                p.x < xmax &&
                p.y >= ymin &&
                p.y < ymax &&
                p.z >= zmin &&
                p.z < zmax);
    }

    public boolean rayIntersects(Ray3 ray) {
        // Credit goes to https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-box-intersection

        // 1.) Check if ray is contained inside the Octant
        if (contains(ray.origin)) {
            return true;
        }
        // 2.) Check if ray passes through the oct
        float tmin, tmax, tymin, tymax, tzmin, tzmax;

        tmin = (bounds[ray.sign[0]].x - ray.origin.x) * ray.invDir.x;
        tmax = (bounds[1-ray.sign[0]].x - ray.origin.x) * ray.invDir.x;
        tymin = (bounds[ray.sign[1]].y - ray.origin.y) * ray.invDir.y;
        tymax = (bounds[1-ray.sign[1]].y - ray.origin.y) * ray.invDir.y;

        if ((tmin > tymax) || (tymin > tmax)) {
            return false;
        }
        if (tymin > tmin) {
            tmin = tymin;
        }
        if (tymax < tmax) {
            tmax = tymax;
        }

        tzmin = (bounds[ray.sign[2]].z - ray.origin.z) * ray.invDir.z; 
        tzmax = (bounds[1-ray.sign[2]].z - ray.origin.z) * ray.invDir.z; 
    
        if ((tmin > tzmax) || (tzmin > tmax)) {
            return false;
        }
        if (tzmin > tmin) {
            tmin = tzmin;
        }
        if (tzmax < tmax) {
            tmax = tzmax;
        }

        // if (tmax < 0.f) {
        //     return false;
        // }

        // if (ray.magnitude > 0 && ray.magnitude < tmax) {
        //     return false;
        // }

        return true; 
    }
}

// Example:
/*

let boundary = new oct(new Vec3(0,0,0), 100,100,100)
let ot = new OctreePoints(boundary, 10);

for(int i = 0; i < 1; i++) {
    Vec3 p = new Vec3(random(width))
}

*/