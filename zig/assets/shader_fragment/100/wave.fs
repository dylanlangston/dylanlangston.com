#version 100

precision mediump float;

// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;
varying vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

uniform float seconds;

uniform vec2 size;

float freqX = 5.0;
float freqY = 5.0;
float ampX = 20.0;
float ampY = 20.0;
float speedX = 4.0;
float speedY = 2.0;

void main() {
    float pixelWidth = 1.0 / size.x;
    float pixelHeight = 1.0 / size.y;
    float aspect = pixelHeight / pixelWidth;
    float boxLeft = 0.0;
    float boxTop = 0.0;

    vec2 p = fragTexCoord;
    p.x += cos((fragTexCoord.y - boxTop) * freqX / ( pixelWidth * 750.0) + (seconds * speedX)) * ampX * pixelWidth;
    p.y += sin((fragTexCoord.x - boxLeft) * freqY * aspect / ( pixelHeight * 750.0) + (seconds * speedY)) * ampY * pixelHeight;

    gl_FragColor = texture2D(texture0, p)*colDiffuse*fragColor;
}