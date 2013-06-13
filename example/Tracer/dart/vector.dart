// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class Vectors {
  static Float32List empty() {
    return new Float32List(3);
  }

  static Float32List create(double x, double y, double z) {
    var list = new Float32List(3);
    list[0] = x;
    list[1] = y;
    list[2] = z;
    return list;
  }

  static void normalize(Float32List a, Float32List dest) {
    var m = magnitude(a);
    dest[0] = a[0] / m;
    dest[1] = a[1] / m;
    dest[2] = a[2] / m;
  }

  static double magnitude(Float32List a) {
    return sqrt((a[0] * a[0]) + (a[1] * a[1]) + (a[2] * a[2]));
  }

  static void cross(Float32List a, Float32List b, Float32List dest) {
    dest[0] = -a[2] * b[1] + a[1] * b[2];
    dest[1] = a[2] * b[0] - a[0] * b[2];
    dest[2] = -a[1] * b[0] + a[0] * b[1];
  }

  static double dot(Float32List a, Float32List b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
  }

  static void add(Float32List a, Float32List b, Float32List dest) {
    dest[0] = a[0] + b[0];
    dest[1] = a[1] + b[1];
    dest[2] = a[2] + b[2];
  }

  static void sub(Float32List a, Float32List b, Float32List dest) {
    dest[0] = a[0] - b[0];
    dest[1] = a[1] - b[1];
    dest[2] = a[2] - b[2];
  }

  static void mul(Float32List a, Float32List b, Float32List dest) {
    dest[0] = a[0] * b[0];
    dest[1] = a[1] * b[1];
    dest[2] = a[2] * b[2];
  }

  static void multiplyScalar(Float32List a, double w, Float32List dest) {
    dest[0] = a[0] * w;
    dest[1] = a[1] * w;
    dest[2] = a[2] * w;
  }
}
