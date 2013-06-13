// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class Ray {
  final position;
  final direction;

  Ray(this.position, this.direction);
  String toString() {
    return 'Ray [$position, $direction]';
  }
}


class Camera {
  final position;
  final lookAt;
  final up;
  var equator, screen;

  Camera(this.position, this.lookAt, this.up) {
    this.equator = Vectors.empty();
    var temp = Vectors.empty();
    Vectors.normalize(lookAt, temp);
    Vectors.cross(temp, this.up, this.equator);

    this.screen = Vectors.empty();
    Vectors.add(this.position, this.lookAt, this.screen);
  }

  Ray getRay(double vx, double vy) {
    var pos = Vectors.empty();
    Vectors.multiplyScalar(this.equator, vx, pos);

    var temp = Vectors.empty();
    Vectors.multiplyScalar(this.up, vy, temp);

    Vectors.sub(pos, temp, pos);
    Vectors.sub(screen, pos, pos);

    pos[1] = pos[1] * -1.0;

    var dir = Vectors.empty();
    Vectors.sub(pos, this.position, dir);
    Vectors.normalize(dir, dir);
    var ray = new Ray(pos, dir);
    return ray;
  }

  toString() {
    return 'Camera []';
  }
}


class Background {
  final Float32List color;
  final double ambience;

  Background(this.color, this.ambience);
}


class Scene {
  var camera;
  var shapes;
  var lights;
  var background;
  Scene() {
    camera = new Camera(Vectors.create(0.0, 0.0, -0.5),
                        Vectors.create(0.0, 0.0, 1.0),
                        Vectors.create(0.0, 1.0, 0.0));
    shapes = new List();
    lights = new List();
    background = new Background(Colors.create(0.0, 0.0, 0.5), 0.2);
  }
}
