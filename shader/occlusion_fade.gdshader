shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back;

uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    ALBEDO = albedo.rgb;
    ALPHA = alpha;
}