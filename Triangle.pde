public Vec3 rayTriangleCollision(Vec3 origin, Vec3 dir, PShape[] rigidBodies) {
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
            if (abs(denominator) <= 0.000001) {
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

public CollisionInfo rayTriangleCollision(Ray3 ray, PShape triangle) {
 // Check each boid to see if it has collided with the collision meshes
    Vec3 rayOrigin = ray.origin;
    Vec3 rayDirection = ray.direction;

    PVector v1 = triangle.getVertex(0);
    PVector v2 = triangle.getVertex(1);
    PVector v3 = triangle.getVertex(2);

    Vec3 vert1 = new Vec3(v1.x, v1.y, v1.z);
    Vec3 vert2 = new Vec3(v2.x, v2.y, v2.z);
    Vec3 vert3 = new Vec3(v3.x, v3.y, v3.z);

    Vec3 e1 = vert2.minus(vert1);
    Vec3 e2 = vert3.minus(vert1);
    Vec3 surfaceNormal = cross(e1, e2).normalized();

    float denominator = dot(surfaceNormal, rayDirection);
    if (abs(denominator) <= 0) {
        // No ray plane intersection exists
        return null;
    }

    float D = dot(vert1, surfaceNormal);

    float numerator = -(dot(surfaceNormal, rayOrigin) - D);

    float t = numerator/denominator;

    if (t < 0 || (ray.magnitude > 0 && t > ray.magnitude)) {
        // Haven't hit yet
        return null;
    }

    Vec3 p = rayOrigin.plus(rayDirection.times(t));

    if (pointLiesOnTriangle(p, vert1, vert2, vert3, e1, e2)) {
        return new CollisionInfo(p, surfaceNormal, t);
    } else {
        return null;
    }
}

public Vec3 lineTriangleCollision(Vec3 p1, Vec3 p2, PShape[] rigidBodies) {
    // Check each boid to see if it has collided with the collision meshes
    Vec3 closestPoint = null;
    Vec3 dir = p2.minus(p1);
    float tMax = dir.length();
    float tMin = Float.MAX_VALUE;
    for (PShape rigidBody : rigidBodies) {
        int triCount = rigidBody.getChildCount();
        for (int i = 0; i < triCount; i++) {
            PShape triangle = rigidBody.getChild(i);
            int j = 0;
            Vec3 rayOrigin = p1;
            Vec3 rayDirection = dir;
            rayDirection.normalize();

            PVector v1 = triangle.getVertex(0).add(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);
            PVector v2 = triangle.getVertex(1).add(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);
            PVector v3 = triangle.getVertex(2).add(bunnyPosition.x, bunnyPosition.y, bunnyPosition.z);

            Vec3 vert1 = new Vec3(v1.x, v1.y, v1.z);
            Vec3 vert2 = new Vec3(v2.x, v2.y, v2.z);
            Vec3 vert3 = new Vec3(v3.x, v3.y, v3.z);

            Vec3 e1 = vert2.minus(vert1);
            Vec3 e2 = vert3.minus(vert1);

            Vec3 surfaceNormal = cross(e1, e2);
            // float x_0 = rayOrigin.x; float y_0 = rayOrigin.y; float z_0 = rayOrigin.z;
            // float x_d = rayDirection.x; float y_d = rayDirection.y; float z_d = rayDirection.z;
            float denominator = dot(surfaceNormal, rayDirection);
            if (abs(denominator) <= 0.00001) {
                // No ray plane intersection exists
                continue;
            }

            float D = dot(vert1, surfaceNormal);

            float numerator = -(dot(surfaceNormal, rayOrigin) - D);

            float t = numerator/denominator;

            if (t < 0 || t > tMax) {
                // Haven't hit yet
                continue;
            }
            
            Vec3 p = rayOrigin.plus(rayDirection.times(t));

            if (t < tMin && pointLiesOnTriangle(p, vert1, vert2, vert3, e1, e2)) {
                closestPoint = p;
                t = tMin;
                println("MOTHERLOAD");
            }
        }
    }
    return closestPoint;
}

class CollisionInfo {
    Vec3 position;
    Vec3 surfaceNormal;
    float t;
    PShape tri;
    public CollisionInfo(Vec3 position, Vec3 surfaceNormal, float t) {
        this.position = position;
        this.surfaceNormal = surfaceNormal;
        this.t = t;
    }
}