shader_type canvas_item;

uniform vec4 highlight_color : source_color;
uniform vec4 shadow_color : source_color;
uniform float strength = 1.0;
uniform int bevel_type = 0;
uniform float bevel_offset = 5.0;
uniform bool knockout = false;
uniform bool do_size_correction = true;


uniform float blur_radius = 5.0;
uniform int sample_count = 9; 
const int MAX_SAMPLES = 13;


// Workaround to make modulate work again.
varying vec4 modulate;
// Workaround to make aspect ratio work properly.
varying vec2 pixel_pos;


varying float v_weights[MAX_SAMPLES];
varying float v_offsets[MAX_SAMPLES];
varying flat int v_samples;


float calculate_gaussian_weight(float offset, float sigma) {
	float exponent = -(offset * offset) / (2.0 * sigma * sigma);
	return exp(exponent);
}


void vertex() {
	modulate = COLOR;
	pixel_pos = VERTEX;

	int center_index = sample_count / 2;
	float total_weight = 0.0;

	// Ensure the sample count doesn't exceed the array size and is odd.
	v_samples = min(sample_count, MAX_SAMPLES);
	if (v_samples % 2 == 0) {
		v_samples -= 1; // Ensure it's odd
	}

	for (int i = 0; i < v_samples; i++) {
	    // Calculate offset and un-normalized weight
		v_offsets[i] = float(i - center_index);
		v_weights[i] = calculate_gaussian_weight(v_offsets[i], blur_radius);
		total_weight += v_weights[i];
	}

	// Normalize weights
	for (int i = 0; i < v_samples; i++) {
		v_weights[i] /= total_weight;
	}
}


vec4 safe_texture_sample(sampler2D tex, vec2 uv) {
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return vec4(0.0);
	}
	return texture(tex, uv);
}


// Horizontal Pass (returns only the alpha channel's blurred value)
float gaussian_1d_sample_h(sampler2D tex, vec2 uv, vec2 pixel_size) {
	float final_alpha = 0.0;
	for (int i = 0; i < MAX_SAMPLES; i++) {
		if (i >= v_samples) {
		    break;
		}
		vec2 sample_uv = uv + vec2(v_offsets[i], 0.0) * pixel_size;
		final_alpha += safe_texture_sample(tex, sample_uv).a * v_weights[i];
	}
	return final_alpha;
}

// Vertical Pass (returns only the alpha channel's blurred value)
float gaussian_1d_sample_v(sampler2D tex, vec2 uv, vec2 pixel_size) {
	float final_alpha = 0.0;
	for (int i = 0; i < MAX_SAMPLES; i++) {
		if (i >= v_samples) {
			break;
		}
		vec2 sample_uv = uv + vec2(0.0, v_offsets[i]) * pixel_size;
		final_alpha += safe_texture_sample(tex, sample_uv).a * v_weights[i];
	}
	return final_alpha;
}


void fragment() {
	vec2 node_size = pixel_pos / UV;
	float aspect_ratio = node_size.x / node_size.y;
	
	vec2 offset_dir;
	if (do_size_correction) {
		offset_dir = vec2(bevel_offset / (aspect_ratio * 2.0), bevel_offset * (aspect_ratio / 2.0)) / length(node_size);
	}
	else {
		offset_dir = vec2(bevel_offset) / length(node_size);
	}
	
	vec2 blur_uv_left = UV + offset_dir;
	vec2 blur_uv_right = UV - offset_dir;

	float blur_left_h = gaussian_1d_sample_h(TEXTURE, blur_uv_left, TEXTURE_PIXEL_SIZE);
	float blur_left_v = gaussian_1d_sample_v(TEXTURE, blur_uv_left, TEXTURE_PIXEL_SIZE);
	float blur_right_h = gaussian_1d_sample_h(TEXTURE, blur_uv_right, TEXTURE_PIXEL_SIZE);
	float blur_right_v = gaussian_1d_sample_v(TEXTURE, blur_uv_right, TEXTURE_PIXEL_SIZE);

	float blur_left = blur_left_h + blur_left_v;
	float blur_right = blur_right_h + blur_right_v;

	float normalize_factor = 2.0; 
	blur_left /= normalize_factor;
	blur_right /= normalize_factor;
	
	vec4 dest = texture(TEXTURE, UV);
	
	bool is_outer = bevel_type == 0 || bevel_type == 2;
	bool is_inner = bevel_type == 1 || bevel_type == 2;
	
	float highlight_alpha = clamp((blur_left - blur_right) * strength, 0.0, 1.0);
	float shadow_alpha = clamp((blur_right - blur_left) * strength, 0.0, 1.0);
	
	vec4 glow = highlight_color * highlight_alpha + shadow_color * shadow_alpha;
	
	COLOR = modulate;
	if (is_inner && is_outer) {
		if (knockout) {
			COLOR *= glow;
		} else {
			COLOR *= dest - dest * glow.a + glow; 
		}
	} else if (is_inner) {
		if (knockout) {
			COLOR *= glow * dest.a; 
		} else {
			COLOR *= glow * dest.a + dest * (1.0 - glow.a); 
		}
	} else {
		if (knockout) {
			COLOR *= glow - glow * dest.a; 
		} else {
			COLOR *= dest + glow - glow * dest.a; 
		}
	}
}