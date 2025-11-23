shader_type canvas_item;

uniform vec4 highlight_color : source_color;
uniform vec4 shadow_color : source_color;
uniform float strength = 0.7;
uniform int bevel_type;
uniform float bevel_offset = 3;
uniform bool knockout;

uniform float pixel_detail = 4;
uniform float blur_strength = 3;
vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize, float strengthFloat) {
	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

	vec2 pixel = fragCoord / pixelSize;
	int x_min = max(int(pixel.x - strengthFloat), 0);
	int x_max = min(int(pixel.x + strengthFloat), int(1.0 / pixelSize.x));
	int y_min = max(int(pixel.y - strengthFloat), 0);
	int y_max = min(int(pixel.y + strengthFloat), int(1.0 / pixelSize.y));

	int count = 0;

	// Sum the pixels colors
	for(int x = x_min; x <= x_max; x++) {
		for(int y = y_min; y <= y_max; y++) {
			color += texture(tex, vec2(float(x), float(y)) * pixelSize);
			count++;
		}
	}

	// Divide the color by the number of colors you summed up
	color /= float(count);

	return color;
}


varying vec2 vert;
void vertex(){
	vert = VERTEX;
}


float saturate(float e) {
	return clamp(e, 0.0, 1.0);
}

void fragment() {
	vec2 offset = vec2(bevel_offset / 100.0);
	vec2 blur_uv_left = UV + offset;
	vec2 blur_uv_right = UV - offset;

	vec2 pixel_size = TEXTURE_PIXEL_SIZE * vec2(1.0 / pixel_detail);
	float blur_left = blur_size(TEXTURE, blur_uv_left, pixel_size, blur_strength).a;
	float blur_right = blur_size(TEXTURE, blur_uv_right, pixel_size, blur_strength).a;
	vec4 dest = texture(TEXTURE, UV);

	bool outer = bevel_type == 0 || bevel_type == 2;
	bool inner = bevel_type == 1 || bevel_type == 2;

	if (blur_uv_left.x < 0.0 || blur_uv_left.x > 1.0 || blur_uv_left.y < 0.0 || blur_uv_left.y > 1.0) {
		blur_left = 0.0;
	}
	if (blur_uv_right.x < 0.0 || blur_uv_right.x > 1.0 || blur_uv_right.y < 0.0 || blur_uv_right.y > 1.0) {
		blur_right = 0.0;
	}

	float highlight_alpha = saturate((blur_left - blur_right) * strength);
	float shadow_alpha = saturate((blur_right - blur_left) * strength);
	vec4 glow = highlight_color * highlight_alpha + shadow_color * shadow_alpha;

	if (inner && outer) {
		if (knockout) {
			COLOR = glow;
		} else {
			COLOR = dest - dest * glow.a + glow;
		}
	} else if (inner) {
		if (knockout) {
			COLOR = glow * dest.a;
		} else {
			COLOR = glow * dest.a + dest * (1.0 - glow.a);
		}
	} else {
		if (knockout) {
			COLOR = glow - glow * dest.a;
		} else {
			COLOR = dest + glow - glow * dest.a;
		}
	}
}
