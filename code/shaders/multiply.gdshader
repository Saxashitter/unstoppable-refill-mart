shader_type canvas_item;

float blendAdd(float base, float blend) {
	return min(base+blend,1.0);
}

vec3 blendAdd(vec3 base, vec3 blend) {
	return min(base+blend,vec3(1.0));
}

vec3 blendAdd(vec3 base, vec3 blend, float opacity) {
	return (blendAdd(base, blend) * opacity + base * (1.0 - opacity));
}

void fragment() {
	//// Called for every pixel the material is visible on.
	vec3 color_vector = vec3(COLOR.r, COLOR.g, COLOR.b);
	vec3 color_add = blendAdd(color_vector, vec3(.5,.5,.5), .5);

	COLOR.r = color_add.r;
	COLOR.g = color_add.g;
	COLOR.b = color_add.b;
	//LOR = vec4(color_add.r, color_add.g, color_add.b, COLOR.a);
}