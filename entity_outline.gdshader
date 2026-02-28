shader_type canvas_item;
render_mode unshaded;

uniform bool active = false;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.5, 5.0) = 1.0;
uniform float alpha_threshold : hint_range(0.1, 0.9) = 0.5;

varying vec4 modulate_color;
uniform bool is_bright = false;
global uniform float screen_dim_amount;

const vec2 OFFSETS[8] = {
	vec2(-1,0), vec2(0,-1), vec2(1,0), vec2(0,1),
	vec2(-1,-1), vec2(1,1), vec2(-1,1), vec2(1,-1)
};

float has_solid_neightbor(sampler2D texture_sampler, vec2 uv_coord, vec2 pixel_size){
	vec2 offset = outline_thickness * pixel_size;
	float sum_alpha = 0.0;
	
	for(int x=0; x < OFFSETS.length(); x++){
		sum_alpha += texture(texture_sampler, uv_coord + OFFSETS[x] * offset).a;
	};
	return smoothstep(0.0, 1.0, sum_alpha);
}

void vertex(){
	modulate_color = COLOR;
}

void fragment() {
	if (active){
		float outline_mask = has_solid_neightbor(TEXTURE, UV, TEXTURE_PIXEL_SIZE);
		float alpha_blend_factor = smoothstep(0.0, alpha_threshold, COLOR.a);
		COLOR.rgb = mix(outline_color.rgb, COLOR.rgb, alpha_blend_factor);
		COLOR.a = max(COLOR.a, outline_mask);
	} else {
		vec4 tex_color = texture(TEXTURE, UV);
		COLOR = tex_color;
	}
	
	if (!is_bright){
		COLOR.rgb *= screen_dim_amount;
	}
	
	COLOR *= modulate_color;
}