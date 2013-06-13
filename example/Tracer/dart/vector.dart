// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;


class Vectors {
  static Float32x4 create(double x, double y, double z) {
    return new Float32x4(x, y, z, 0.0);
  }

  static Float32x4 normalize(Float32x4 a) {
    var m = magnitude(a);
    return a.scale(1 / m);
  }

  static double magnitude(Float32x4 a) {
    return sqrt((a.x * a.x) + (a.y * a.y) + (a.z * a.z));
  }

  static Float32x4 cross(Float32x4 a, Float32x4 b) {
    return new Float32x4(
      -a.z * b.y + a.y * b.z,
      a.z * b.x - a.x * b.z,
      -a.y * b.x + a.x * b.y,
      0.0
    );
  }

  static double dot(Float32x4 a, Float32x4 b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
  }
}
