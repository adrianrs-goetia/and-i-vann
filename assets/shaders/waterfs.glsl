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
    float maxLifetime;
    float strength;
};

// Uniforms
uniform WaterClick waterclick;

// Shader variables
const vec4 oceanBlue = vec4(0.616, 0.929, 0.98, 1.0);
const vec4 clickColor = vec4(0.994, 0.988, 0.98, 1.0);

float rippleLine(float length, float maxLength, WaterClick wc)
{
    const float fadeSpeed = 2.0;
    const float lengthMod = 1.0; // Thicker towards 0
    return exp(-pow((length * lengthMod) - wc.lifetime, 2) * (10 - wc.lifetime) - (wc.lifetime * fadeSpeed));
}

// Interpolate the color for WaterClick to create the ripple effect
vec4 colorInterpolation(WaterClick wc, vec4 baseColor)
{
    const float l = length(fragPosition - wc.position);
    const float maxLength = 8.8;
    if (l < maxLength && wc.alive != 0)
    {
        const float blend = rippleLine(l, maxLength, wc);

        // Interpolate between clickColor and baseColor based on strength/lifetime
        vec4 mixedBaseColor = baseColor * (1 - blend);

        vec4 rippleColor = clickColor * (blend);

        return mixedBaseColor + rippleColor;
    }
    else
    {
        return baseColor;
    }
}

void main()
{
    FragColor = colorInterpolation(waterclick, oceanBlue);
}
