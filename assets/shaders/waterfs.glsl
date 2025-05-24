#version 330 core

// input vertex attributes
in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
in vec3 fragNormal;

out vec4 FragColor;

vec4 oceanBlue = vec4(0.616, 0.929, 0.98, 1.0);
float value = 0.8;

void main() {
    // FragColor = fragColor;
    FragColor = oceanBlue * value;
}
