package com.babylonhx.utils;

/**
 * ...
 * @author Krtolica Vujadin
 */

// GL defines

#if snow

    typedef GL                  = snow.modules.opengl.GL;
    typedef GLActiveInfo        = snow.modules.opengl.GL.GLActiveInfo;
    typedef GLBuffer            = snow.modules.opengl.GL.GLBuffer;
    typedef GLContextAttributes = snow.modules.opengl.GL.GLContextAttributes;
    typedef GLFramebuffer       = snow.modules.opengl.GL.GLFramebuffer;
    typedef GLProgram           = snow.modules.opengl.GL.GLProgram;
    typedef GLRenderbuffer      = snow.modules.opengl.GL.GLRenderbuffer;
    typedef GLShader            = snow.modules.opengl.GL.GLShader;
    typedef GLTexture           = snow.modules.opengl.GL.GLTexture;
    typedef GLUniformLocation   = snow.modules.opengl.GL.GLUniformLocation;

#elseif lime

    typedef GL                  = lime.graphics.opengl.GL;
    typedef GLActiveInfo        = lime.graphics.opengl.GLActiveInfo;
    typedef GLBuffer            = lime.graphics.opengl.GLBuffer;
    typedef GLContextAttributes = lime.graphics.opengl.GLContextAttributes;
    typedef GLFramebuffer       = lime.graphics.opengl.GLFramebuffer;
    typedef GLProgram           = lime.graphics.opengl.GLProgram;
    typedef GLRenderbuffer      = lime.graphics.opengl.GLRenderbuffer;
    typedef GLShader            = lime.graphics.opengl.GLShader;
    typedef GLTexture           = lime.graphics.opengl.GLTexture;
    typedef GLUniformLocation   = lime.graphics.opengl.GLUniformLocation;

#elseif kha

	/*typedef GL					= kha.graphics4.Graphics;
	typedef GLActiveInfo		= 
	typedef GLBuffer			= kha
	typedef GLContextAttributes = kha.
	typedef GLFramebuffer       = kha.Framebuffer;
	typedef GLProgram  			= kha.graphics4.Program;
	typedef GLShader			= kha.graphics4.shader
	typedef GLUniformLocation	= kha.graphics4.ConstantLocation;*/

#end 


