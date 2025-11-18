shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform vec3 tint : source_color = vec3(1.0);
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;
uniform float blur = 0.0;
uniform float mix_amount = 1.0;

void fragment() {
	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
    vec3 c = textureLod(screen_texture, SCREEN_UV, blur).rgb;

    c.rgb = mix(vec3(0.0), c.rgb, brightness);
    c.rgb = mix(vec3(0.5), c.rgb, contrast);
    c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);
	c *= tint;

    COLOR.rgb = mix(screen, c, mix_amount);
}