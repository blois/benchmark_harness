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
    info.position = ray.position + ray.direction.scale(t);
    info.normal = this.position;
    info.distance = t;

    if(this.material.hasTexture){
      var vU = Vectors.create(this.position.y, this.position.z, -this.position.x);
      var vV = Vectors.cross(vU, this.position);
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
    var dst = ray.position - this.position;

    var B = Vectors.dot(dst, ray.direction);
    var C = Vectors.dot(dst, dst) - (this.radius * this.radius);
    var D = (B * B) - C;

    if (D > 0) { // intersection!
      var info = new IntersectionInfo();
      info.shape = this;
      info.distance = (-B) - sqrt(D);
      info.position = ray.position +
          ray.direction.scale(info.distance);
      info.normal = Vectors.normalize(info.position - this.position);

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

