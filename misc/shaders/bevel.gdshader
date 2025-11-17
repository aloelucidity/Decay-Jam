shader_type canvas_item;

uniform vec4 highlight_color : source_color;
uniform vec4 shadow_color : source_color;
uniform float strength = 1.0;
uniform int bevel_type = 0;
uniform float bevel_offset = 3.0;
uniform bool knockout = false;


// The blur_radius dictates the extent of the blur (standard deviation, sigma)
uniform float blur_radius = 5.0; // Adjust to control the blur amount.

// The number of samples to take along one axis. 
// Must be an odd number. Lower values are faster but lower quality.
uniform int sample_count = 9; 
const int MAX_SAMPLES = 13; 


vec4 safe_texture_sample(sampler2D tex, vec2 uv) {
    // Check if UV is outside the valid range
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return vec4(0.0); // Transparent black border
    }
    // Otherwise, sample normally
    return texture(tex, uv);
}


// Calculates the un-normalized weight for a given offset using the Gaussian function.
float calculate_gaussian_weight(float offset, float sigma) {
    // Standard Gaussian formula: 1 / (sqrt(2*PI*sigma^2)) * exp(-x^2 / (2*sigma^2))
    // We only need the exponential part for un-normalized weights: exp(-x^2 / (2*sigma^2))
    float exponent = -(offset * offset) / (2.0 * sigma * sigma);
    return exp(exponent);
}


vec4 gaussian_2d_sample(sampler2D tex, vec2 uv, vec2 pixel_size, float sigma, int samples) {
    vec4 final_color = vec4(0.0);
    float total_weight = 0.0;
    
    // Determine the center offset for the loop (e.g., 4 for a 9-sample kernel)
    int center_index = samples / 2;
    
    // Arrays to hold the 1D calculated weights and offsets
    float weights[MAX_SAMPLES];
    float offsets[MAX_SAMPLES];
    
    for (int i = 0; i < samples; i++) {
        offsets[i] = float(i - center_index);
        weights[i] = calculate_gaussian_weight(offsets[i], sigma);
        total_weight += weights[i];
    }

    // Normalize weights
    for (int i = 0; i < samples; i++) {
        weights[i] /= total_weight;
    }
    
    // Loop over the horizontal axis (X)
    for (int x = 0; x < samples; x++) {
        // Loop over the vertical axis (Y)
        for (int y = 0; y < samples; y++) {
            // Calculate the sample UV coordinate using offsets
            vec2 sample_uv = uv + vec2(offsets[x], offsets[y]) * pixel_size;
            
            // The combined 2D weight is the product of the 1D weights
            float combined_weight = weights[x] * weights[y];
            
            // Accumulate the weighted color
            final_color += safe_texture_sample(tex, sample_uv) * combined_weight;
        }
    }
    
    // NOTE: The total combined weight is always 1.0 (since 1.0 * 1.0), 
    // so no final division is needed.
    return final_color;
}

void fragment() {
    vec2 offset = vec2(bevel_offset / 100.0);
    vec2 blur_uv_left = UV + offset;
    vec2 blur_uv_right = UV - offset;
     
    // Ensure the sample count doesn't exceed the array size and is odd.
    int clamped_samples = min(sample_count, MAX_SAMPLES);
    if (clamped_samples % 2 == 0) {
        clamped_samples -= 1; // Ensure it's odd
    }
	
    float blur_left = gaussian_2d_sample(TEXTURE, blur_uv_left, TEXTURE_PIXEL_SIZE, blur_radius, clamped_samples).a;
    float blur_right = gaussian_2d_sample(TEXTURE, blur_uv_right, TEXTURE_PIXEL_SIZE, blur_radius, clamped_samples).a;
    
    vec4 dest = texture(TEXTURE, UV);
    
    bool is_outer = bevel_type == 0 || bevel_type == 2;
    bool is_inner = bevel_type == 1 || bevel_type == 2;
    
    // Calculate highlight and shadow alpha values
    float highlight_alpha = clamp((blur_left - blur_right) * strength, 0.0, 1.0);
    float shadow_alpha = clamp((blur_right - blur_left) * strength, 0.0, 1.0);
    
    // Calculate the final glow/emboss color
    vec4 glow = highlight_color * highlight_alpha + shadow_color * shadow_alpha;
    
    if (is_inner && is_outer) {
        if (knockout) {
            COLOR = glow;
        } else {
            COLOR = dest - dest * glow.a + glow; 
        }
    } else if (is_inner) {
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