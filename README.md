# InnerPlanetCurves

### Draws Cubic Bezier Curve Between Earth &amp; Venus Using Mercury &amp; Mars as Control Points

Here's some frippery: after seeing a spate of Earth/Venus gifs, I wondered what a series of curves based on the movements of the iner planets would look like. This little project draws a series of cubic Bezier curves between the Earth and Venus using the positions of Mars and Mercury as control points. All the planets in my code have perfectly circular orbits, so it's not very accurate.

The code draws to a `CAShapeLayer` and draws that to a `CGImage` which is composited over previous images using Core Image.

The final result is a little like a funky, animated Spirograph. 
