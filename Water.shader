shader_type canvas_item;

uniform vec4 blue_tint : hint_color;
uniform vec2 offset_scale = vec2(2.0, 2.0);
uniform vec2 amplitude = vec2(0.005, 0.001);
uniform vec2 time_scale = vec2(3, 1);

void fragment(){
	vec2 waves_uv_offset;
	waves_uv_offset.x = cos(time_scale.x * TIME + (SCREEN_UV.x + SCREEN_UV.y) * offset_scale.x);
	waves_uv_offset.y = sin(time_scale.y * TIME + (SCREEN_UV.x + SCREEN_UV.y) * offset_scale.x);
	
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV + waves_uv_offset * amplitude);
	color = mix(blue_tint, color, 0.8);
	
	COLOR = color;
}