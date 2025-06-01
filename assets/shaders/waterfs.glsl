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
    float strength;
};
vec4 colorInterpolation(WaterClick wc, vec4 baseColor)
{
    float l = length(fragPosition - wc.position);
    if (l < 1.5 &&  wc.alive != 0)
    {
        vec4 clickColor = vec4(1.0, 0.0, 0.0, 1.0);
        // Interpolate between clickColor and baseColor based on strength/lifetime
        return ((1 - wc.strength) * baseColor) + (clickColor * wc.strength);
    }
    else
    {
        return  baseColor;
    }
}

// Uniforms
uniform WaterClick waterclick;

// Shader variables
vec4 oceanBlue = vec4(0.616, 0.929, 0.98, 1.0);
float value = 0.91;

void main() {
    FragColor = colorInterpolation(waterclick, oceanBlue);
}
