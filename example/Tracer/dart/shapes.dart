// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class BaseShape {
  final position;
  final material;

  BaseShape(this.position, this.material);

  String toString() {
    return 'BaseShape';
  }
}


class Plane extends BaseShape {
  final d;

  Plane(pos, this.d, material) : super(pos, material);

  IntersectionInfo intersect(Ray ray) {
    var Vd = Vectors.dot(this.position, ray.direction);
    if (Vd == 0) return null; // no intersection

    var t = -(Vectors.dot(this.position, ray.position) + this.d) / Vd;
    if (t <= 0) return null;

    var info = new IntersectionInfo();
    info.shape = this;
    info.position = Vectors.empty();
    Vectors.multiplyScalar(ray.direction, t, info.position);
    Vectors.add(ray.position, info.position, info.position);
    info.normal = this.position;
    info.distance = t;

    if(this.material.hasTexture){
      var vU = Vectors.create(this.position[1], this.position[2], -this.position[0]);
      var vV = Vectors.empty();
      Vectors.cross(vU, this.position, vV);
      var u = Vectors.dot(info.position, vU);
      var v = Vectors.dot(info.position, vV);
      info.color = this.material.getColor(u,v);
    } else {
      info.color = this.material.getColor(0,0);
    }

    return info;
  }

  String toString() {
    return 'Plane [$position, d=$d]';
  }
}


class Sphere extends BaseShape {
  var radius;
  Sphere(pos, radius, material) : super(pos, material), this.radius = radius;

  IntersectionInfo intersect(Ray ray){
    var dst = Vectors.empty();
    Vectors.sub(ray.position, this.position, dst);

    var B = Vectors.dot(dst, ray.direction);
    var C = Vectors.dot(dst, dst) - (this.radius * this.radius);
    var D = (B * B) - C;

    if (D > 0) { // intersection!
      var info = new IntersectionInfo();
      info.shape = this;
      info.distance = (-B) - sqrt(D);
      info.position = Vectors.empty();
      Vectors.multiplyScalar(ray.direction, info.distance, info.position);
      Vectors.add(info.position, ray.position, info.position);

      info.normal = Vectors.empty();
      Vectors.sub(info.position, this.position, info.normal);
      Vectors.normalize(info.normal, info.normal);

      info.color = this.material.getColor(0,0);

      return info;
    } else {
      return null;
    }
  }

  String toString() {
    return 'Sphere [position=$position, radius=$radius]';
  }
}

