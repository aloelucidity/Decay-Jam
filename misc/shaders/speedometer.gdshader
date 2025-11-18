//	Meter shader v2 by Brian Smith (steampunkdemon.itch.io)
//	MIT Licence

shader_type canvas_item;

// Replace the below references to source_color with hint_color if you are using a version of Godot before 4.
uniform vec4 indictor_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 border_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 centre_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 region1_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 region2_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 region3_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 scale_mark_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform bool show_edges = false;
uniform bool bottom_border = true;
uniform float meter_start_angle : hint_range(0.0, 0.4) = 0.15;
uniform float indicator_angle : hint_range(0.0, 1.0) = 0.0;
uniform float indicator_length : hint_range(0.1, 1.0) = 0.6;
uniform float indicator_width : hint_range(0.001, 0.02) = 0.01;
uniform float border_width : hint_range(0.0, 0.5) = 0.05;
uniform float centre_width : hint_range(0.0, 0.5) = 0.1;
uniform float region1 : hint_range(0.0, 1.0) = 0.5;
uniform float region2 : hint_range(0.0, 1.0) = 0.75;
uniform float region3 : hint_range(0.0, 1.0) = 0.9;
uniform float regions_end : hint_range(0.0, 1.0) = 1.0;
uniform float scale_marks : hint_range(0.0, 20.0, 1.0) = 10.0;
uniform float major_scale_marks : hint_range(0.0, 20.0, 1.0) = 2.0;
uniform float scale_mark_width : hint_range(0.01, 0.05) = 0.03;
uniform float scale_minor_outer : hint_range(0.0, 1.0) = 0.75;
uniform float scale_major_outer : hint_range(0.0, 1.0) = 0.80;
uniform float scale_inner : hint_range(0.0, 1.0) = 0.65;

float greater_than(float x, float y) {
  return max(sign(x - y), 0.0);
}

void fragment() {
	vec2 uv = UV;
	uv.x = uv.x * 2.0 - 1.0;
	
//	If you do not want to render the border replace the following line of code with:
//	uv.y = uv.y - 1.0;
	uv.y = uv.y * (1.0 + border_width * float(bottom_border)) - 1.0;
	
	float scale_factor = 1.0 - meter_start_angle * 2.0;
	float adjusted_scale_mark_width = scale_mark_width / scale_factor;
	float a = ((atan(uv.y, uv.x) + 3.141592656) / 3.141592656 - meter_start_angle) / scale_factor;
	float l = length(uv);

//	Uncomment the following line if you are applying the shader to a TextureRect and using a version of Godot before 4.
//	COLOR = texture(TEXTURE,UV);

//	If you do not want to render all the colored regions remove the appropriate lines from the following block of code.
	float region3_alpha = region3_color.a * (greater_than(a, region3) * greater_than(regions_end, a));
	COLOR.rgb = mix(COLOR.rgb, region3_color.rgb, region3_alpha);
	COLOR.a = max(COLOR.a, region3_alpha);
//	COLOR.rgb = mix(COLOR.rgb, region2_color.rgb, region2_color.a * (greater_than(a, region2) * greater_than(region3, a)));
//	COLOR.rgb = mix(COLOR.rgb, region1_color.rgb, region1_color.a * (greater_than(a, region1) * greater_than(region2, a)));

//	If you do not want to render the scale marks remove the following code block.
//	If you do not want to render the major scale marks remove the second following line.
	float scale_mark_alpha = scale_mark_color.a * greater_than(a, 0.0 - scale_mark_width) * greater_than(1.0 + scale_mark_width, a) * greater_than(abs(mod(a, 1.0 / scale_marks) * scale_marks * 2.0 - 1.0), 1.0 - (adjusted_scale_mark_width / 6.283185312 / l) * scale_marks) * (greater_than(scale_minor_outer, l) * greater_than(l, scale_inner));;
	COLOR.rgb = mix(COLOR.rgb, scale_mark_color.rgb, scale_mark_alpha);
	COLOR.a = max(COLOR.a, scale_mark_alpha);
	
	float indictor_alpha = indictor_color.a * greater_than(indicator_length, l) * greater_than(indicator_width / scale_factor / l, abs(indicator_angle - a));
	COLOR.rgb = mix(COLOR.rgb, indictor_color.rgb, indictor_alpha);
	COLOR.a = max(COLOR.a, indictor_alpha);
	
	
//	If you do not want to render the centre remove the following line.
	float centre_alpha = centre_color.a * greater_than(centre_width, l);
	COLOR.rgb = mix(COLOR.rgb, centre_color.rgb, centre_alpha);
	COLOR.a = max(COLOR.a, centre_alpha);

//	If you do not want to render the border remove the following line.
	float border_alpha = border_color.a * min(greater_than(l, 1.0 - border_width) + greater_than(uv.y, 0.0), 1.0);
	COLOR.rgb = mix(COLOR.rgb, border_color.rgb, border_alpha);
	COLOR.a = max(COLOR.a, border_alpha);

//	If you do not want the edges to be transparent remove the following line of code.
//	If you always want the edges to be transparent replace the following line of code with:
//	COLOR.a *= greater_than(1.0, l);
	COLOR.a *= max(sign(1.0 - l), float(show_edges));
}