shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec2 pixel_pos = FRAGCOORD.xy;

	// Wave parameters in pixels
	float wave_amplitude_px = 500.0; // Wave depth in pixels
	float wave_frequency_px = 0.015; // Waves per pixel (smaller = longer wavelength)
	float wave_speed = 2.0; // Animation speed

	// Sine wave based on pixel position
	float wave1 = sin(pixel_pos.y * wave_frequency_px + TIME * wave_speed);

	float wave_px = wave1 * wave_amplitude_px * 0.5;

	// Convert pixel-based wave to UV space
	float screen_width = 1.0 / SCREEN_PIXEL_SIZE.x;
	float wave = wave_px / screen_width;

	// Left edge
	float left_boundary = 0.1 + wave;
	// Right edge
	float right_boundary = 0.9 + wave;

	// Background color
	vec3 bg_color = vec3(0.933, 0.580, 0.502); // #ee9480

	// Show color only between the wavy boundaries
	if (uv.x > left_boundary && uv.x < right_boundary) {
		COLOR = vec4(bg_color, 1.0);
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Transparent outside
	}
}