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
    this.color = new Color(0.0, 0.0, 0.0);
  }

  String toString() => 'Intersection [$position]';
}


class Engine {
  int canvasWidth;
  int canvasHeight;
  int pixelWidth, pixelHeight;
  bool renderDiffuse, renderShadows, renderHighlights, renderReflections;
  int rayDepth;
  CanvasRenderingContext2D context;
  ImageData imageData;
  List<int> pixels;

  Engine({this.canvasWidth : 100, this.canvasHeight : 100,
          this.pixelWidth : 2, this.pixelHeight : 2,
          this.renderDiffuse : false, this.renderShadows : false,
          this.renderHighlights : false, this.renderReflections : false,
          this.rayDepth : 2}) {
    canvasHeight = canvasHeight ~/ pixelHeight;
    canvasWidth = canvasWidth ~/ pixelWidth;
  }

  // 'canvas' can be null if raytracer runs as benchmark
  void renderScene(Scene scene, canvas) {
    checkNumber = 0;
    /* Get canvas */
    context = canvas == null ? null : canvas.getContext("2d");

    if (context != null) {
      context.fillStyle = 'black';
      context.fillRect(0, 0, canvasWidth, canvasHeight);
      imageData = context.getImageData(0, 0, canvasWidth, canvasHeight);
      pixels = imageData.data;
    } else {
      // TODO: testing.
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

        pixels[pixelIndex++] = (color.red * 255).toInt();
        pixels[pixelIndex++] = (color.green * 255).toInt();
        pixels[pixelIndex++] = (color.blue * 255).toInt();
        pixelIndex++;

        if (canvas == null && x == y) {
          checkNumber += color.brightness();
        }
      }
    }
    if ((canvas == null) && (checkNumber != 2321)) {
      // Used for benchmarking.
      throw "Scene rendered incorrectly";
    }

    if (context != null) {
      context.putImageData(this.imageData, 0, 0);
    }
  }

  Color getPixelColor(Ray ray, Scene scene){
    var info = this.testIntersection(ray, scene, null);
    if(info != null){
      var color = this.rayTrace(info, ray, scene, 0);
      return color;
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

  Color rayTrace(IntersectionInfo info, Ray ray, Scene scene, int depth) {
    // Calc ambient
    Color color = info.color.multiplyScalar(scene.background.ambience);
    var oldColor = color;
    var shininess = pow(10, info.shape.material.gloss + 1);

    for(var i = 0; i < scene.lights.length; i++) {
      var light = scene.lights[i];

      // Calc diffuse lighting
      var v = (light.position - info.position).normalize();

      if (this.renderDiffuse) {
        var L = v.dot(info.normal);
        if (L > 0.0) {
          color = color + info.color * light.color.multiplyScalar(L);
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

          color = color.blend(reflColor, info.shape.material.reflection);
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
          var vA = color.multiplyScalar(0.5);
          var dB = (0.5 * pow(shadowInfo.shape.material.transparency, 0.5));
          color = vA.addScalar(dB);
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
        color = light.color.multiplyScalar(glossWeight) + color;
      }
    }
    color.limit();
    return color;
  }

  String toString() {
    return 'Engine [canvasWidth: $canvasWidth, canvasHeight: $canvasHeight]';
  }
}
