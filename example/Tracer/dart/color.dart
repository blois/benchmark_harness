// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class Colors {
  static final Float32x4 _lowerLimits = new Float32x4.splat(0.0);
  static final Float32x4 _upperLimits = new Float32x4.splat(1.0);

  static Float32x4 create(double r, double g, double b) {
    return new Float32x4(r, g, b, 0.0);
  }

  static Float32x4 limit(Float32x4 a) {
    return a.clamp(_lowerLimits, _upperLimits);
  }

  static Float32x4 addScalar(Float32x4 a, double s) {
    return limit(a + new Float32x4.splat(s));
  }

  static Float32x4 blend(Float32List a, Float32List b, double w) {
    return a.scale(1.0 - w) + b.scale(w);
  }

  static int brightness(Float32List a) {
    var r = (a.x * 255).toInt();
    var g = (a.y * 255).toInt();
    var b = (a.z * 255).toInt();
    return (r * 77 + g * 150 + b * 29) >> 8;
  }
}
