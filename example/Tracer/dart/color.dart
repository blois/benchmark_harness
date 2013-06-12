// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class Colors {
  static Float32List empty() {
    return new Float32List(3);
  }

  static Float32List create(double r, double g, double b) {
    var list = new Float32List(3);
    list[0] = r;
    list[1] = g;
    list[2] = b;

    return list;
  }

  static void limit(Float32List a, Float32List dest) {
    dest[0] = a[0].clamp(0.0, 1.0);
    dest[1] = a[1].clamp(0.0, 1.0);
    dest[2] = a[2].clamp(0.0, 1.0);
  }

  static void add(Float32List a, Float32List b, Float32List dest) {
    dest[0] = a[0] + b[0];
    dest[1] = a[1] + b[1];
    dest[2] = a[2] + b[2];
  }

  static void addScalar(Float32List a, double s, Float32List dest) {
    dest[0] = (a[0] + s).clamp(0.0, 1.0);
    dest[1] = (a[1] + s).clamp(0.0, 1.0);
    dest[2] = (a[2] + s).clamp(0.0, 1.0);
  }

  static void multiply(Float32List a, Float32List b, Float32List dest) {
    dest[0] = a[0] * b[0];
    dest[1] = a[1] * b[1];
    dest[2] = a[2] * b[2];
  }

  static void multiplyScalar(Float32List a, double f, Float32List dest) {
    dest[0] = a[0] * f;
    dest[1] = a[1] * f;
    dest[2] = a[2] * f;
  }

  static void blend(Float32List a, Float32List b, double w, Float32List dest) {
    dest[0] = (1.0 - w) * a[0] + w * b[0];
    dest[1] = (1.0 - w) * a[1] + w * b[1];
    dest[2] = (1.0 - w) * a[2] + w * b[2];
  }

  static int brightness(Float32List a) {
    var r = (a[0] * 255).toInt();
    var g = (a[1] * 255).toInt();
    var b = (a[2] * 255).toInt();
    return (r * 77 + g * 150 + b * 29) >> 8;
  }
}
