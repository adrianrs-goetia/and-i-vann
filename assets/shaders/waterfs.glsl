#version 330 core

// Output
out vec4 FragColor;

// input vertex attributes
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
in vec3 fragNormal;

// Uniforms
uniform vec3 clickPosition;

// Shader variables
vec4 oceanBlue = vec4(0.616, 0.929, 0.98, 1.0);
float value = 0.91;

void main() {
    FragColor = oceanBlue * value * ((clickPosition.x + 100) / 100);
}
