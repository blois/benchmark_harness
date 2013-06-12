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
    var Vd = this.position.dot(ray.direction);
    if (Vd == 0) return null; // no intersection

    var t = -(this.position.dot(ray.position) + this.d) / Vd;
    if (t <= 0) return null;

    var info = new IntersectionInfo();
    info.shape = this;
    info.position = ray.position + ray.direction.multiplyScalar(t);
    info.normal = this.position;
    info.distance = t;

    if(this.material.hasTexture){
      var vU = new Vector(this.position.y, this.position.z, -this.position.x);
      var vV = vU.cross(this.position);
      var u = info.position.dot(vU);
      var v = info.position.dot(vV);
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

    var B = dst.dot(ray.direction);
    var C = dst.dot(dst) - (this.radius * this.radius);
    var D = (B * B) - C;

    if (D > 0) { // intersection!
      var info = new IntersectionInfo();
      info.shape = this;
      info.distance = (-B) - sqrt(D);
      info.position = ray.position +
          ray.direction.multiplyScalar(info.distance);
      info.normal = (info.position - this.position).normalize();

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

