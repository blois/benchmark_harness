library ray_trace;

import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

part 'color.dart';
part 'engine.dart';
part 'materials.dart';
part 'scene.dart';
part 'shapes.dart';
part 'vector.dart';
part 'renderscene.dart';

// used to check if raytrace was correct (used by benchmarks)
var checkNumber;

main() { 
  var button = query('#render');
  button.onClick.listen((e) {
    render();
  });

  render();
}

void render() {
  CanvasElement canvas = query('#canvas');
  var time = query('#time');

  canvas.width = int.parse(query('#imageWidth').value);
  canvas.height = int.parse(query('#imageHeight').value);
  var sw = new Stopwatch()..start();
  renderScene(new RenderParams.fromDocument());
  sw.stop();
  time.text = sw.elapsedMilliseconds.toString();
}
