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
uniform float iTime;
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

// https://github.com/ashima/webgl-noise
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec3 permute(vec3 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}
float simplexNoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, // (3.0 - sqrt(3.0)) / 6.0
            0.366025403784439, // 0.5 * (sqrt(3.0) - 1.0)
            -0.577350269189626, // -1.0 + 2.0 * C.x
            0.024390243902439); // 1.0 / 41.0

    // First corner
    vec2 i = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    // Determine simplex triangle
    vec2 i1 = x0.x > x0.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 x1 = x0.xy - i1 + C.xx;
    vec2 x2 = x0.xy - 1.0 + 2.0 * C.xx;

    // Permutations
    i = mod289(i);
    vec3 p = permute(permute(vec3(0.0, i1.y, 1.0) + i.y) + vec3(0.0, i1.x, 1.0) + i.x);

    // Gradients
    vec3 x_ = fract(p * C.w) * 2.0 - 1.0;
    vec3 h = abs(x_) - 0.5;
    vec3 ox = floor(x_ + 0.5);
    vec3 a0 = x_ - ox;

    // Compute contributions
    vec2 g0 = vec2(a0.x, h.x);
    vec2 g1 = vec2(a0.y, h.y);
    vec2 g2 = vec2(a0.z, h.z);

    float t0 = 0.5 - dot(x0, x0);
    float t1 = 0.5 - dot(x1, x1);
    float t2 = 0.5 - dot(x2, x2);

    float n0 = t0 < 0.0 ? 0.0 : pow(t0, 4.0) * dot(g0, x0);
    float n1 = t1 < 0.0 ? 0.0 : pow(t1, 4.0) * dot(g1, x1);
    float n2 = t2 < 0.0 ? 0.0 : pow(t2, 4.0) * dot(g2, x2);

    return 70.0 * (n0 + n1 + n2); // Final noise value
}
vec4 noisedBaseColor(vec4 baseColor)
{
    const float negativeSize = 0.35; // Larger towards zero
    const float offset = 200;
    const float timeScale = 0.8;
    const float xCoord = fragPosition.x - offset + (iTime * timeScale);
    const float zCoord = fragPosition.z - offset + (iTime * timeScale);
    const vec2 noiseCoord = vec2(xCoord * negativeSize, zCoord * negativeSize);

    const float n = simplexNoise(noiseCoord); // [-1,1] range
    const float shade = n * 0.5 + 0.5; // remap to [0,1]

    return mix(baseColor, baseColor * 1.12, shade);
}

void main()
{
    const vec4 color = noisedBaseColor(oceanBlue);
    FragColor = colorInterpolation(waterclicks, color);
}
