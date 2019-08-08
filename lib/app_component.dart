import 'package:angular/angular.dart';
import 'src/home/home_component.dart';
// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: [Home],
)
class AppComponent {
  // Nothing here yet. All logic is in TodoListComponent.
}
