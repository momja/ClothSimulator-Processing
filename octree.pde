// class Octree {
//     Oct bounds;
//     int capacity;
//     ArrayList<Vec3> points;
//     bool divided = false;

//     Oct q111,q011,q001,q101,q110,q010,q000,q100;

//     public Octree(Oct bounds, int n) {
//         this.bounds = bounds;
//         this.capacity = n;
//         this.points = new ArrayList<Vec3>();
//     }

//     public void insert(Vec3 p) {
//         if (this.points.size() < this.capacity) {
//             this.points.add(p);            
//         } else {
//             if (!this.divided) {
//                 subdivide();
//                 this.divided = true;
//             }

//             q111.insert(p);
//             q011.insert(p);
//             q001.insert(p);
//             q101.insert(p);
//             q110.insert(p);
//             q010.insert(p);
//             q000.insert(p);
//             q100.insert(p);
//         }
//     }

//     private subdivide() {
//         Vec3 origin = boundary.origin;
//         Vec3 size = boundary.size;
//         Vec3 subdivideSize = size.times(0.5);

//         float q111_b = Oct(origin.plus(subdivideSize.times(new Vec3(0.5,0.5,0.5))), subdivideSize);
//         q111 = new Octree(q111_b, n);
//         float q011_b = Oct(origin.plus(subdivideSize.times(new Vec3(-0.5,0.5,0.5))), subdivideSize);
//         q011 = new Octree(q011_b, n);
//         float q001_b = Oct(origin.plus(subdivideSize.times(new Vec3(-0.5,-0.5,0.5))), subdivideSize);
//         q001 = new Octree(q001_b, n);
//         float q101_b = Oct(origin.plus(subdivideSize.times(new Vec3(0.5,-0.5,0.5))), subdivideSize);
//         q101 = new Octree(q101_b, n);
//         float q110_b = Oct(origin.plus(subdivideSize.times(new Vec3(0.5,0.5,-0.5))), subdivideSize);
//         q110 = new Octree(q110_b, n);
//         float q010_b = Oct(origin.plus(subdivideSize.times(new Vec3(-0.5,0.5,-0.5))), subdivideSize);
//         q010 = new Octree(q010_b, n);
//         float q000_b = Oct(origin.plus(subdivideSize.times(new Vec3(-0.5,-0.5,-0.5))), subdivideSize);
//         q000 = new Octree(q000_b, n);
//         float q100_b = Oct(origin.plus(subdivideSize.times(new Vec3(0.5,-0.5,-0.5))), subdivideSize);
//         q100 = new Octree(q100_b, n);
//     }
// }

// class Oct {
//     Vec3 origin;
//     Vec3 size;
//     int capacity;
//     public Oct(Vec3 origin, Vec3 size) {
//         this.origin = origin;
//         this.size = size;
//     }

//     public contains(Vec3 p) {
//         return (p.x > origin.x - )
//     }  
// }

// // Example:
// /*

// let boundary = new oct(new Vec3(0,0,0), 100,100,100)
// let ot = new Octree(boundary, 10);

// for(int i = 0; i < 1; i++) {
//     Vec3 p = new Vec3(random(width))
// }

// /*