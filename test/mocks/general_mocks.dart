import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart' show GenerateNiceMocks, MockSpec;
/*
Run `dart run build_runner watch` in the
command line to generate the mocks 
*/

// Create mock classes
@GenerateNiceMocks(
  <MockSpec<dynamic>>[
    MockSpec<http.Client>(),
  ],
)
void main() {}
