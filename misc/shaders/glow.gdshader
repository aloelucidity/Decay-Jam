shader_type canvas_item;
render_mode unshaded;

uniform bool is_smooth = true;
uniform float width : hint_range(0.0, 32.0) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int pixel_size : hint_range(1, 10) = 4;

void fragment()
{
    vec2 inv_texture_size = 1.0 / vec2(textureSize(TEXTURE, 0));
    vec2 unit = inv_texture_size * (1.0 / float(pixel_size));

    vec4 pixel_color = texture(TEXTURE, UV);

    if (pixel_color.a > 0.0) {
        COLOR = pixel_color;
    }
	else {
	    vec4 final_outline_color = outline_color;
	    final_outline_color.a = 0.0;

	    float radius = max(1.0, width);
	    float ceil_radius = ceil(radius);

	    bool found_neighbor = false;

	    for (float x = -ceil_radius; x <= ceil_radius; x++) {
	        for (float y = -ceil_radius; y <= ceil_radius; y++) {
	            if (x == 0.0 && y == 0.0) {
	                continue;
	            }
	            vec2 neighbor_uv = UV + vec2(x, y) * unit;
	            if (texture(TEXTURE, neighbor_uv).a > 0.0) {
	                found_neighbor = true;
	                if (is_smooth) {
	                    final_outline_color.a += outline_color.a / (pow(x,2)+pow(y,2)) * (1.0-pow(2.0, -width));
	                    final_outline_color.a = min(final_outline_color.a, 1.0);
	                } else {
	                    final_outline_color.a = outline_color.a;
	                    break;
	                }
	            }
	        }
	        if (!is_smooth && found_neighbor) {
	            break;
	        }
	    }
	    if (final_outline_color.a > 0.0) {
	        final_outline_color.a = min(final_outline_color.a, 1.0);
	        COLOR = final_outline_color;
	    } else {
	        COLOR = vec4(0.0);
	    }
	}
}