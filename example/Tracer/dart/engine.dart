// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class IntersectionInfo {
  var shape, position, normal, color, distance;

  IntersectionInfo() {
    this.color = Colors.create(0.0, 0.0, 0.0);
  }

  String toString() => 'Intersection [$position]';
}


class Engine {
  int canvasWidth;
  int canvasHeight;
  bool renderDiffuse, renderShadows, renderHighlights, renderReflections;
  int rayDepth;

  Engine({this.canvasWidth : 100, this.canvasHeight : 100,
          this.renderDiffuse : false, this.renderShadows : false,
          this.renderHighlights : false, this.renderReflections : false,
          this.rayDepth : 2}) {
  }

  // 'canvas' can be null if raytracer runs as benchmark
  void renderScene(Scene scene, canvas) {
    checkNumber = 0;
    /* Get canvas */
    var context = canvas == null ? null : canvas.getContext("2d");
    var imageData;
    var pixels;

    if (context != null) {
      context.fillStyle = 'black';
      context.fillRect(0, 0, canvasWidth, canvasHeight);
      imageData = context.getImageData(0, 0, canvasWidth, canvasHeight);
      pixels = imageData.data;
    } else {
      // TODO: testing.
      pixels = new Uint8ClampedList(canvasWidth * canvasHeight * 4);
    }

    var canvasHeight = this.canvasHeight;
    var canvasWidth = this.canvasWidth;

    var pixelIndex = 0;
    for(var y = 0; y < canvasHeight; y++){
      for(var x = 0; x < canvasWidth; x++){
        var yp = y * 1.0 / canvasHeight * 2 - 1;
        var xp = x * 1.0 / canvasWidth * 2 - 1;

        var ray = scene.camera.getRay(xp, yp);
        var color = this.getPixelColor(ray, scene);

        pixels[pixelIndex++] = (color[0] * 255).toInt();
        pixels[pixelIndex++] = (color[1] * 255).toInt();
        pixels[pixelIndex++] = (color[2] * 255).toInt();
        pixelIndex++;

        if (canvas == null && x == y) {
          checkNumber += Colors.brightness(color);
        }
      }
    }
    if ((canvas == null) && (checkNumber != 2321)) {
      // Used for benchmarking.
      throw "Scene rendered incorrectly";
    }

    if (context != null) {
      context.putImageData(imageData, 0, 0);
    }
  }

  Float32List getPixelColor(Ray ray, Scene scene){
    var info = this.testIntersection(ray, scene, null);
    if(info != null){
      return this.rayTrace(info, ray, scene, 0);
    }
    return scene.background.color;
  }

  IntersectionInfo testIntersection(Ray ray, Scene scene, BaseShape exclude) {
    int hits = 0;
    IntersectionInfo best = null;

    for(var i=0; i < scene.shapes.length; i++){
      var shape = scene.shapes[i];

      if(shape != exclude){
        var info = shape.intersect(ray);
        if (info != null &&
            (info.distance >= 0) &&
            (best == null || (info.distance < best.distance))) {
          best = info;
          hits++;
        }
      }
    }
    return best;
  }

  Ray getReflectionRay(Vector P, Vector N, Vector V){
    var c1 = -N.dot(V);
    var R1 = N.multiplyScalar(2*c1) + V;
    return new Ray(P, R1);
  }

  Float32List rayTrace(IntersectionInfo info, Ray ray, Scene scene, int depth) {
    // Calc ambient
    var color = Colors.empty();
    Colors.multiplyScalar(info.color, scene.background.ambience, color);
    var shininess = pow(10, info.shape.material.gloss + 1);

    for(var i = 0; i < scene.lights.length; i++) {
      var light = scene.lights[i];

      // Calc diffuse lighting
      var v = (light.position - info.position).normalize();

      if (this.renderDiffuse) {
        var L = v.dot(info.normal);
        if (L > 0.0) {
          var temp = Colors.empty();
          Colors.multiplyScalar(light.color, L, temp);
          Colors.multiply(info.color, temp, temp);
          Colors.add(color, temp, color);
        }
      }

      // The greater the depth the more accurate the colours, but
      // this is exponentially (!) expensive
      if (depth <= this.rayDepth) {
        // calculate reflection ray
        if (this.renderReflections && info.shape.material.reflection > 0) {
          var reflectionRay = this.getReflectionRay(info.position,
                                                    info.normal,
                                                    ray.direction);
          var refl = this.testIntersection(reflectionRay, scene, info.shape);

          var reflColor;
          if (refl != null && refl.distance > 0){
            reflColor = this.rayTrace(refl, reflectionRay, scene, depth + 1);
          } else {
            reflColor = scene.background.color;
          }

          Colors.blend(color, reflColor, info.shape.material.reflection, color);
        }
        // Refraction
        /* TODO */
      }
      /* Render shadows and highlights */

      IntersectionInfo shadowInfo = new IntersectionInfo();

      if (this.renderShadows) {
        var shadowRay = new Ray(info.position, v);

        shadowInfo = this.testIntersection(shadowRay, scene, info.shape);
        if (shadowInfo != null &&
            shadowInfo.shape != info.shape
            /*&& shadowInfo.shape.type != 'PLANE'*/) {
          var vA = Colors.empty();
          Colors.multiplyScalar(color, 0.5, vA);

          var dB = (0.5 * pow(shadowInfo.shape.material.transparency, 0.5));

          Colors.addScalar(vA, dB, color);
        }
      }
      // Phong specular highlights
      if (this.renderHighlights &&
          shadowInfo == null &&
          (info.shape.material.gloss > 0)) {
        var Lv = (info.shape.position - light.position).normalize();

        var E = (scene.camera.position - info.shape.position).normalize();

        var H = (E - Lv).normalize();

        var glossWeight = pow(max(info.normal.dot(H), 0), shininess);

        var temp = Colors.empty();
        Colors.multiplyScalar(light.color, glossWeight, temp);
        Colors.add(color, temp, color);
      }
    }
    Colors.limit(color, color);
    return color;
  }

  String toString() {
    return 'Engine [canvasWidth: $canvasWidth, canvasHeight: $canvasHeight]';
  }
}
