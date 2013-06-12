// The ray tracer code in this file is written by Adam Burmister. It
// is available in its original form from:
//
//   http://labs.flog.co.nz/raytracer/
//
// Ported from the v8 benchmark suite by Google 2012.
part of ray_trace;

class Light {
  final position;
  final color;
  final intensity;

  Light(this.position, this.color, [this.intensity = 10.0]);
}

class RenderParams {
  int imageWidth = 100;
  int imageHeight = 100;
  bool renderDiffuse = true;
  bool renderShadows = true;
  bool renderHighlights = true;
  bool renderReflections = true;
  CanvasElement canvas = null;

  RenderParams() {}

  RenderParams.fromDocument() {
    imageWidth = int.parse(query('#imageWidth').value);
    imageHeight = int.parse(query('#imageHeight').value);
    renderDiffuse = query('#renderDiffuse').checked;
    renderShadows = query('#renderShadows').checked;
    renderHighlights = query('#renderHighlights').checked;
    renderReflections = query('#renderReflections').checked;
    canvas = query("#canvas");
  }
}


// 'event' null means that we are benchmarking
void renderScene(RenderParams params) {
  var scene = new Scene();
  scene.camera = new Camera(new Vector(0.0, 0.0, -15.0),
                            new Vector(-0.2, 0.0, 5.0),
                            new Vector(0.0, 1.0, 0.0));
  scene.background = new Background(Colors.create(0.5, 0.5, 0.5), 0.4);

  var sphere = new Sphere(
      new Vector(-1.5, 1.5, 2.0),
      1.5,
      new Solid(
          Colors.create(0.0, 0.5, 0.5),
          0.3,
          0.0,
          0.0,
          2.0
      )
  );

  var sphere1 = new Sphere(
      new Vector(1.0, 0.25, 1.0),
      0.5,
      new Solid(
          Colors.create(0.9,0.9,0.9),
          0.1,
          0.0,
          0.0,
          1.5
      )
  );

  var plane = new Plane(
      new Vector(0.1, 0.9, -0.5).normalize(),
      1.2,
      new Chessboard(
          Colors.create(1.0, 1.0, 1.0),
          Colors.create(0.0, 0.0, 0.0),
          0.2,
          0.0,
          1.0,
          0.7
      )
  );

  scene.shapes.add(plane);
  scene.shapes.add(sphere);
  scene.shapes.add(sphere1);

  var light = new Light(
      new Vector(5.0, 10.0, -1.0),
      Colors.create(0.8, 0.8, 0.8)
  );

  var light1 = new Light(
      new Vector(-3.0, 5.0, -15.0),
      Colors.create(0.8, 0.8, 0.8),
      100.0
  );

  scene.lights.add(light);
  scene.lights.add(light1);

  int rayDepth = 2;

  var raytracer = new Engine(canvasWidth:params.imageWidth,
                             canvasHeight:params.imageHeight,
                             renderDiffuse: params.renderDiffuse,
                             renderShadows: params.renderShadows,
                             renderReflections: params.renderReflections,
                             renderHighlights: params.renderHighlights,
                             rayDepth: rayDepth
                             );

  raytracer.renderScene(scene, params.canvas);
}
