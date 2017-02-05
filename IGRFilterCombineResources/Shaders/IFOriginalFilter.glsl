precision lowp float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
    vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
    
    gl_FragColor = vec4(texel, 1.0);
}
