// http://wp.applesandoranges.eu/?p=14

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D textureSampler;
varying vec2 vUV;	

void main()
{
    vec4 sum = vec4(0);
    int j;
    int i;

    for(i= -4; i < 4; i++)
    {
        for (j = -3; j < 3; j++)
        {
            sum += texture2D(textureSampler, vUV + vec2(j, i) * 0.004) * 0.25;
        }
    }
    
	if (texture2D(textureSampler, vUV).r < 0.3)
    {
       gl_FragColor = sum * sum * 0.012 + texture2D(textureSampler, vUV);
    }
    else
    {
        if (texture2D(textureSampler, vUV).r < 0.5)
        {
            gl_FragColor = sum * sum * 0.009 + texture2D(textureSampler, vUV);
        }
        else
        {
            gl_FragColor = sum * sum * 0.0075 + texture2D(textureSampler, vUV);
        }
    }
}
