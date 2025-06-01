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
vec4 oceanBlue = vec4(0.616, 0.929, 0.98, 1.0);
vec4 clickColor = vec4(0.894, 0.988, 0.98, 1.0);

// Interpolate the color for WaterClick to create the ripple effect
vec4 colorInterpolation(WaterClick wc, vec4 baseColor)
{
    float l = length(fragPosition - wc.position) * (wc.maxLifetime / wc.lifetime);
    float maxLength = 2.8;
    if (l < maxLength && wc.alive != 0)
    {
        // Interpolate between clickColor and baseColor based on strength/lifetime
        vec4 mixedBaseColor = baseColor * (1 - wc.strength);

        vec4 rippleColor = clickColor * (wc.strength);

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
