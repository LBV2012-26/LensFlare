#version 460 core

#define STAR_COLOR_KELVIN

layout(location = 0) out vec4 FragColor;

uniform vec2  iResolution;
uniform float iTime;
uniform vec2  iStarPosNdc;
uniform vec3  iStarColor;
uniform float iEffTemp;
uniform float iBrightness;
uniform float iFlareWidth;
uniform float iDistance;

const float kPi = 3.141592653;

mat2x2 Rotate(float Angle) {
	float Sin = sin(Angle);
	float Cos = cos(Angle);
	
	return mat2x2(
		Cos, -Sin,
		Sin,  Cos
	);
}

float LensFlare(vec2 FragUv, float Flare) {
	float Color = 0;
	float Size  = iDistance / iBrightness;
	
	// float DiffSpike = max(0.0, 1.0 - abs(FragUv.x * FragUv.y * Size * 2));
	
	float FullSpikeDist = iBrightness * 5000;

	float FragDist  = length(FragUv);
	float DiffSpike = 0.0;
	if (abs(abs(FragUv.x) - abs(FragUv.y)) <= iFlareWidth) {
		DiffSpike = Flare;
		// DiffSpike = smoothstep(0.5, 0.2, FragDist);
		DiffSpike = smoothstep(FullSpikeDist / iDistance, FullSpikeDist / iDistance - 0.3, FragDist);
	}

	Color += DiffSpike;
	
	float StarPoint  = 500 / Size / FragDist;
	Color += StarPoint;
	
	return Color;
}

vec3 KelvinToRgb(float Kelvin) {
	float Temp  = Kelvin / 100.0;
	float Red   = 0;
	float Green = 0;
	float Blue  = 0;
	
	if (Temp <= 66.0) {
		Red = 255.0;
	} else {
		Red = Temp - 60.0;
		Red = 329.698727446 * pow(Red, -0.1332047592);
	}
	
	if (Temp <= 66.0) {
		Green = Temp;
		Green = 99.4708025861 * log(Green) - 161.1195681661;
	} else {
		Green = Temp - 66.0;
		Green = 288.1221695283 * pow(Green, -0.0755148492);
	}
	
	if (Temp >= 66.0) {
		Blue = 255.0;
	} else if (Temp <= 19.0) {
		Blue = 0.0;
	} else {
		Blue = Temp - 10.0;
		Blue = 138.5177312231 * log(Blue) - 305.0447927307;
	}

	Red   = clamp(Red,   0.0, 255.0);
	Green = clamp(Green, 0.0, 255.0);
	Blue  = clamp(Blue,  0.0, 255.0);
	
	vec3 Color = vec3(Red / 255.0, Green / 255.0, Blue / 255.0);
	return Color;
}

void main() {
	vec2 FragUv = (gl_FragCoord.xy - iStarPosNdc * iResolution.xy) / iResolution.y;
	vec3 Color  = vec3(0.0);

	// FragUv *= 2.0;
	// FragUv *= Rotate(kPi / sin(iTime));

	Color = vec3(LensFlare(FragUv, 1.0));
	
#ifdef STAR_COLOR_KELVIN
	Color *= KelvinToRgb(iEffTemp);
#else
	Color *= iStarColor;
#endif // STAR_COLOR_KELVIN

	FragColor = vec4(Color, 1.0);
}
