shader_type canvas_item;

// Cute pastel colors based on your reference
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);     // White
uniform vec4 color2 : source_color = vec4(1.0, 0.82, 0.82, 1.0);   // #FFD2D2 pink
uniform vec4 color3 : source_color = vec4(1.0, 0.9, 0.95, 1.0);    // Light pink
uniform float speed = 0.3;
uniform float wave_amount : hint_range(0.0, 50.0) = 8.0;           // In pixels
uniform float stripe_width : hint_range(10.0, 500.0) = 150.0;     // In pixels
uniform float sparkle_density : hint_range(0.0, 0.05) = 0.01;     // Per pixel
uniform float heart_size : hint_range(10.0, 100.0) = 30.0;        // In pixels
uniform bool show_hearts = true;

// Cute heart shape
float heart_shape(vec2 p) {
    p.y -= 0.15;
    p.x = abs(p.x);

    if (p.y + p.x > 1.0) return 0.0;

    float a = atan(p.x, p.y - 0.3);
    float r = length(p);

    return smoothstep(0.4, 0.3, r - 0.2 * (1.0 + 0.5 * cos(a * 2.0)));
}

// Simple hash for randomness
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Sparkle function using pixel coordinates
float sparkle(vec2 pixel_pos, float time) {
    vec2 id = floor(pixel_pos * sparkle_density);
    vec2 gv = fract(pixel_pos * sparkle_density) - 0.5;

    float rand = hash(id);
    float t = time + rand * 6.28318;

    float twinkle = pow(sin(t * 2.0) * 0.5 + 0.5, 4.0);
    float dist = length(gv);
    float sparkle_val = twinkle * (1.0 - smoothstep(0.0, 0.4, dist));

    // Only show sparkles randomly
    if (rand > 0.85) {
        return sparkle_val;
    }
    return 0.0;
}

void fragment() {
    // Work in pixel coordinates for consistent scaling
    vec2 pixel_pos = FRAGCOORD.xy;
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    float time = TIME * speed;

    // Wavy distortion in pixels
    float wave = sin(pixel_pos.y * 0.05 + time * 2.0) * wave_amount;
    pixel_pos.x += wave;

    // Diagonal stripes with fixed pixel width
    float u = (pixel_pos.x + pixel_pos.y * 0.5) + time * 100.0;
    float stripe = mod(floor(u / stripe_width), 3.0);

    // Pick colors in a cute pattern
    vec4 base_color;
    if (stripe < 1.0) {
        base_color = color1;
    } else if (stripe < 2.0) {
        base_color = color2;
    } else {
        base_color = color3;
    }

    // Add sparkles with pixel-based density
    float sparkles = sparkle(pixel_pos, TIME);
    base_color.rgb = mix(base_color.rgb, vec3(1.0, 1.0, 1.0), sparkles * 0.7);

    // Add floating hearts with fixed pixel size
    if (show_hearts) {
        for (float i = 0.0; i < 3.0; i++) {
            // Each heart has different position and timing
            float offset_time = time + i * 2.0;

            // Heart position in pixels
            vec2 heart_pixel_pos = vec2(
                screen_size.x * (0.2 + i * 0.3) + sin(offset_time * 0.8) * 100.0,
                mod(offset_time * 100.0 + i * screen_size.y * 0.33, screen_size.y + 100.0) - 50.0
            );

            vec2 diff = pixel_pos - heart_pixel_pos;
            diff /= heart_size; // Scale by heart size in pixels

            float h = heart_shape(diff);

            // Heart color pulses
            vec3 heart_color = color2.rgb * (0.8 + sin(offset_time * 3.0) * 0.2);
            base_color.rgb = mix(base_color.rgb, heart_color, h * 0.6);
        }
    }

    // Soft vignette for extra cuteness (still uses UV for screen-relative effect)
    float vignette = 1.0 - length(UV - 0.5) * 0.5;
    base_color.rgb *= mix(0.9, 1.0, vignette);

    COLOR = base_color;
}