uniform int			u_NormalColorMode;

//
// PHONG SHADER - POINT LIGTH
// Based on: http://www.ozone3d.net/tutorials/glsl_lighting_phong_p2.php
//
//uniform int u_ActiveLights;				// Uncomment for dynamic light count
//#define ACTIVE_LIGHTS	u_ActiveLights		// Uncomment for dynamic light count
#define ACTIVE_LIGHTS	1					// Edit for more lights
#define MAX_LIGHTS		8
varying vec3 v_Normal, v_LightDir[MAX_LIGHTS], v_EyeVec;
vec4 get_phong_light( int l )
{
	vec4 color = (gl_FrontLightModelProduct.sceneColor * gl_FrontMaterial.ambient) + 
				 (gl_LightSource[l].ambient * gl_FrontMaterial.ambient);
	vec3 N = normalize( v_Normal );
	vec3 L = normalize( v_LightDir[l] );
	float lambertTerm = dot(N,L);
	if(lambertTerm > 0.0)
	{
		color += gl_LightSource[l].diffuse * gl_FrontMaterial.diffuse * lambertTerm;
		vec3 E = normalize(v_EyeVec);
		vec3 R = reflect(-L, N);
		float specular = pow( max(dot(R, E), 0.0), gl_FrontMaterial.shininess );
		color += gl_LightSource[l].specular * gl_FrontMaterial.specular * specular;
	}
	return color;
}
vec4 get_phong_light_sum()
{
	vec4 color = vec4(0,0,0,0);
	for (int l = 0 ; l < ACTIVE_LIGHTS ; l++)
		color += get_phong_light(l);
	return color;
}

void main (void)
{
	vec4 final_color = get_phong_light_sum();

	gl_FragColor = final_color;			
	gl_FragColor *= gl_Color;
	
	// Normal color
	if (u_NormalColorMode == 1)
		gl_FragColor.xyz *= normalize( v_Normal );
	else if (u_NormalColorMode == 2)
		gl_FragColor.xyz += normalize( v_Normal );
}