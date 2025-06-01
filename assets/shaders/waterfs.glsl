#version 460 core

// Output
out vec4 FragColor;

// input vertex attributes
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
in vec3 fragNormal;

struct WaterClick {
    int alive;
    vec3 position;
    float lifetime;
};
const int NumWaterClick = 20;

// Uniforms
uniform WaterClick waterclicks[NumWaterClick];

// Shader variables
const vec4 oceanBlue = vec4(0.616, 0.829, 0.91, 1.0);
const vec4 clickColor = vec4(0.994, 0.988, 0.98, 1.0);

float rippleLine(float length, float t_lifetime)
{
    const float fadeSpeed = 1.8;
    const float lengthMod = 1.4; // Thicker towards 0
    const int mod = 2;
    const float lifetime = t_lifetime * mod;
    return exp(-pow((length * lengthMod) - lifetime, 2) * ((10 * mod) - lifetime) - (lifetime * fadeSpeed));
}

// Interpolate the color for WaterClick to create the ripple effect
vec4 colorInterpolation(WaterClick[NumWaterClick] wcs, vec4 baseColor)
{
    // Interpolate between clickColor and baseColor based on lifetime
    float blend = 0;
    for (int i = 0; i < NumWaterClick; i++)
    {
        if (wcs[i].alive != 0)
        {
            const float l = length(fragPosition - wcs[i].position);
            blend += rippleLine(l, wcs[i].lifetime);
        }
    }

    blend = clamp(blend, 0.0, 2.0);
    return mix(baseColor, clickColor, blend);
}

void main()
{
    FragColor = colorInterpolation(waterclicks, oceanBlue);
}
