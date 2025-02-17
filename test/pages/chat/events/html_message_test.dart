/*
 * TIM-Referenzumgebung
 * Copyright (C) 2024 - akquinet GmbH
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:fluffychat/pages/chat/events/html_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mockito/annotations.dart';

import 'html_message_test.mocks.dart';

void _expectStrippedMaths(String html, String exp) {
  final widget = HtmlMessage(
    html: html,
    room: MockRoom(),
  );
  expect(widget.html, exp);
}

@GenerateNiceMocks([MockSpec<Room>()])
void main() {
  test('HtmlMessage strips inline maths, but leaves other markup', () async {
    _expectStrippedMaths(
      r'Some maths: <span data-mx-maths="\(\frac{1}{2}\)"><code>\(\frac{1}{2}\)</code></span>, <em>enjoy</em>!',
      r"Some maths: <span>\(\frac{1}{2}\)</span>, <em>enjoy</em>!",
    );
  });

  test('HtmlMessage strips block maths', () async {
    _expectStrippedMaths(
      r'<p>A <strong>block</strong> of maths:</p><div data-mx-maths="\pi \approx 3.14159"><pre><code>\pi \approx 3.14159</code></pre></div>',
      r'<p>A <strong>block</strong> of maths:</p><div>\pi \approx 3.14159</div>',
    );
  });

  test('HtmlMessage strips mixed maths', () async {
    _expectStrippedMaths(
      r'<p><span data-mx-maths="\pi = 3"><code>\pi = 3</code></span>, or, for non-engineers:</p><div data-mx-maths="\pi \approx 3.14159"><pre><code>\pi \approx 3.14159</code></pre></div>',
      r'<p><span>\pi = 3</span>, or, for non-engineers:</p><div>\pi \approx 3.14159</div>',
    );
  });

  test('HtmlMessage strips multiple maths', () async {
    _expectStrippedMaths(
      r'Some maths: <span data-mx-maths="\(\frac{1}{2}\)"><code>\(\frac{1}{2}\)</code></span>, <em>enjoy</em>!<br/>Enjoyed? Some more:<br/><span data-mx-maths="\forall x \in X, \quad \exists y \leq \epsilon"><code>\forall x \in X, \quad \exists y \leq \epsilon</code></span>',
      r"Some maths: <span>\(\frac{1}{2}\)</span>, <em>enjoy</em>!<br>Enjoyed? Some more:<br><span>\forall x \in X, \quad \exists y \leq \epsilon</span>",
    );
  });

  test('HtmlMessage does nothing on no maths', () async {
    _expectStrippedMaths(
      "No maths: <em>enjoy</em>!",
      "No maths: <em>enjoy</em>!",
    );
  });

  test("HtmlMessage doesn't try to strip maths on malformed HTML message", () async {
    _expectStrippedMaths(
      "expected parser failure: <span",
      "expected parser failure: <span",
    );
  });
}
