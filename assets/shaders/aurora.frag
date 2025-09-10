
#version 460 core
#include <flutter/runtime_effect.glsl>

uniform float iTime;
uniform vec2 iResolution;
uniform float iIntensity;

out vec4 fragColor;

// Function to generate a pseudo-random number
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D Noise function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion (FBM)
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 0.0;
    for (int i = 0; i < 6; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 st = (gl_FragCoord.xy * 2.0 - iResolution.xy) / iResolution.y;
    
    // Animate the noise over time, speed is affected by iIntensity
    float speed = 0.2 + iIntensity * 0.3;
    float f = fbm(st * 3.0 + vec2(0.0, iTime * speed));
    
    // Create color based on noise
    vec3 color = vec3(0.1, 0.5, 0.8); // Base blue color
    color = mix(color, vec3(0.8, 0.9, 1.0), f * f); // Mix with white based on noise^2
    color = mix(color, vec3(0.0, 0.2, 0.4), (f - 0.5) * 2.0); // Mix with dark blue
    
    // Add bright highlights that glow with intensity
    color = mix(color, vec3(0.9, 0.9, 0.9), smoothstep(0.7, 0.8, f) * iIntensity * 1.5);
    
    // Final color output
    fragColor = vec4(color, 1.0);
}
