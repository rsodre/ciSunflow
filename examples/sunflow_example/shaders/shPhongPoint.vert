uniform bool			u_FlagBackFaces;

//
// PHONG SHADER - POINT LIGTH
// Based on: http://www.ozone3d.net/tutorials/glsl_lighting_phong_p2.php
//
//uniform int u_ActiveLights;				// Uncomment for dynamic light count
//#define ACTIVE_LIGHTS	u_ActiveLights		// Uncomment for dynamic light count
#define ACTIVE_LIGHTS	1					// Edit for more lights
#define MAX_LIGHTS		8
varying vec3 v_Normal, v_LightDir[MAX_LIGHTS], v_EyeVec;
void save_phong_lights()
{
	vec3 vVertex = vec3(gl_ModelViewMatrix * gl_Vertex);
	v_EyeVec = -vVertex;
	v_Normal = (gl_NormalMatrix * gl_Normal);
	for (int l = 0 ; l < ACTIVE_LIGHTS ; l++)
	{
		v_LightDir[l] = vec3(gl_LightSource[l].position.xyz - vVertex);
		if (u_FlagBackFaces)
			v_LightDir[l] *= -1.0;	// invert light normal
	}
}

void main()
{
	// phong
	save_phong_lights();
	
	gl_Position = ftransform();
	gl_FrontColor = gl_Color;
}
