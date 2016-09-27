package com.babylonhx.utils;

/**
 * ...
 * @author Krtolica Vujadin
 */

// GL defines

#if purejs

    typedef GL                  = js.html.webgl.GL;
    typedef GLBuffer            = js.html.webgl.Buffer;
    typedef GLFramebuffer       = js.html.webgl.Framebuffer;
    typedef GLProgram           = js.html.webgl.Program;
    typedef GLRenderbuffer      = js.html.webgl.Renderbuffer;
    typedef GLShader            = js.html.webgl.Shader;
    typedef GLTexture           = js.html.webgl.Texture;
    typedef GLUniformLocation   = js.html.webgl.UniformLocation;

#elseif snow

    typedef GL                  = snow.modules.opengl.GL;
    typedef GLBuffer            = snow.modules.opengl.GL.GLBuffer;
    typedef GLFramebuffer       = snow.modules.opengl.GL.GLFramebuffer;
    typedef GLProgram           = snow.modules.opengl.GL.GLProgram;
    typedef GLRenderbuffer      = snow.modules.opengl.GL.GLRenderbuffer;
    typedef GLShader            = snow.modules.opengl.GL.GLShader;
    typedef GLTexture           = snow.modules.opengl.GL.GLTexture;
    typedef GLUniformLocation   = snow.modules.opengl.GL.GLUniformLocation;
	
#elseif openfl

    typedef GL                  = openfl.gl.GL;
    typedef GLBuffer            = openfl.gl.GLBuffer;
    typedef GLFramebuffer       = openfl.gl.GLFramebuffer;
    typedef GLProgram           = openfl.gl.GLProgram;
    typedef GLRenderbuffer      = openfl.gl.GLRenderbuffer;
    typedef GLShader            = openfl.gl.GLShader;
    typedef GLTexture           = openfl.gl.GLTexture;
    typedef GLUniformLocation   = openfl.gl.GLUniformLocation;	

#elseif lime

    typedef GL                  = lime.graphics.opengl.GL;
    typedef GLBuffer            = lime.graphics.opengl.GLBuffer;
    typedef GLFramebuffer       = lime.graphics.opengl.GLFramebuffer;
    typedef GLProgram           = lime.graphics.opengl.GLProgram;
    typedef GLRenderbuffer      = lime.graphics.opengl.GLRenderbuffer;
    typedef GLShader            = lime.graphics.opengl.GLShader;
    typedef GLTexture           = lime.graphics.opengl.GLTexture;
    typedef GLUniformLocation   = lime.graphics.opengl.GLUniformLocation;
	
#elseif nme

    typedef GL                  = nme.gl.GL;
    typedef GLBuffer            = nme.gl.GLBuffer;
    typedef GLFramebuffer       = nme.gl.GLFramebuffer;
    typedef GLProgram           = nme.gl.GLProgram;
    typedef GLRenderbuffer      = nme.gl.GLRenderbuffer;
    typedef GLShader            = nme.gl.GLShader;
    typedef GLTexture           = nme.gl.GLTexture;
    typedef GLUniformLocation   = nme.gl.GLUniformLocation;

#elseif kha

	typedef GL					= kha.graphics4.Graphics;
	typedef GLBuffer			= Dynamic;// kha.graphics4.IndexBuffer || kha.graphics4.VertexBuffer;
	typedef GLFramebuffer       = kha.Framebuffer;
	typedef GLProgram  			= kha.graphics4.Program;
	typedef GLShader			= Dynamic;// kha.graphics4.FragmentShader || kha.graphics4.VertexShader;
	typedef GLUniformLocation	= kha.graphics4.ConstantLocation;

#end 


