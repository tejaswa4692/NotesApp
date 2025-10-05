shader_type canvas_item;

uniform vec4 color1 = vec4(1.0, 1.0, 1.0, 1.0);     // White
uniform vec4 color2 = vec4(1.0, 0.823, 0.823, 1.0); // #FFD2D2
uniform float speed = 0.5;        // scroll speed
uniform float bar_width = 0.1;    // width of each bar (UV space)

void fragment() {
    // Shift UV horizontally over time
    float u = UV.x + TIME * speed;
    // Make stripes repeat
	
    float stripe = mod(floor(u / bar_width), 2.0);

    // Pick color based on stripe index
    vec4 col = mix(color1, color2, stripe);

    COLOR = col;
}
