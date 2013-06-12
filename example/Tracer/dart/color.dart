// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class Color {
  double red;
  double green;
  double blue;

  Color(this.red, this.green, this.blue);

  void limit() {
    this.red = (this.red > 0.0) ? ((this.red > 1.0) ? 1.0 : this.red) : 0.0;
    this.green = (this.green > 0.0) ?
        ((this.green > 1.0) ? 1.0 : this.green) : 0.0;
    this.blue = (this.blue > 0.0) ?
        ((this.blue > 1.0) ? 1.0 : this.blue) : 0.0;
  }

  Color operator +(Color c2) {
    return new Color(red + c2.red, green + c2.green, blue + c2.blue);
  }

  Color addScalar(double s){
    var result = new Color(red + s, green + s, blue + s);
    result.limit();
    return result;
  }

  Color operator *(Color c2) {
    var result = new Color(red * c2.red, green * c2.green, blue * c2.blue);
    return result;
  }

  Color multiplyScalar(double f) {
    var result = new Color(red * f, green * f, blue * f);
    return result;
  }

  Color blend(Color c2, double w) {
    var result = this.multiplyScalar(1.0 - w) + c2.multiplyScalar(w);
    return result;
  }

  int brightness() {
    var r = (this.red * 255).toInt();
    var g = (this.green * 255).toInt();
    var b = (this.blue * 255).toInt();
    return (r * 77 + g * 150 + b * 29) >> 8;
  }

  String toString() {
    var r = (this.red * 255).toInt();
    var g = (this.green * 255).toInt();
    var b = (this.blue * 255).toInt();

    return 'rgb($r,$g,$b)';
  }
}


class Colors {
  static Float32List create(double r, double g, double b) {
    var list = new Float32List(3);
    list[0] = r;
    list[1] = g;
    list[2] = b;

    return list;
  }

  static void add(Float32List a, Float32List b, Float32List dest) {
    dest[0] = a[0] + b[0];
    dest[1] = a[1] + b[1];
    dest[2] = a[2] + b[2];
  }

  static void addScalar(Float32List a, Float32List b, Float32List dest) {
    dest[0] = (a[0] + b[0]).clamp(0.0, 1.0);
    dest[1] = (a[1] + b[1]).clamp(0.0, 1.0);
    dest[2] = (a[2] + b[2]).clamp(0.0, 1.0);
  }

  static void multiply(Float32List a, Float32List b, Float32List dest) {
    dest[0] = a[0] * b[0];
    dest[1] = a[1] * b[1];
    dest[2] = a[2] * b[2];
  }

  static void multiplyScalar(Float32List a, Float32List b, Float32List dest) {
    dest[0] = (a[0] * b[0]).clamp(0.0, 1.0);
    dest[1] = (a[1] * b[1]).clamp(0.0, 1.0);
    dest[2] = (a[2] * b[2]).clamp(0.0, 1.0);
  }

  static void blend(Float32List a, Float32List b, Float32List dest, double w) {
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
