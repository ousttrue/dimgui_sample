import derelict.glfw3.glfw3;
import irenderer;


extern(C) nothrow void error_callback(int error, const(char)* description)
{
	import std.stdio;
    import std.conv;
	try writefln("glfw err: %s ('%s')",error, to!string(description));
	catch{}
}


class GLFW
{
	GLFWwindow *m_window;
	@property public GLFWwindow* window()
	{
		return m_window;
	}

	static this()
	{
		DerelictGLFW3.load();
	}

	~this()
	{
		glfwTerminate();
	}

	bool createWindow()
	{
		// Setup window
		glfwSetErrorCallback(&error_callback);
		if (!glfwInit()){
			return false;
		}
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, true);

		m_window = glfwCreateWindow(1280, 720, "ImGui OpenGL3 example", null, null);
		if(!m_window){
			return false;
		}
		glfwMakeContextCurrent(m_window);
		glfwInit();
		return true;
	}

    void updateContext(ref WindowContext w, ref MouseContext m)
    {
		glfwGetWindowSize(m_window, &w.window_w, &w.window_h);
		glfwGetFramebufferSize(m_window, &w.frame_w, &w.frame_h);
		w.hasFocus=glfwGetWindowAttrib(m_window, GLFW_FOCUSED)!=0;

		glfwGetCursorPos(m_window, &m.x, &m.y);
		for(int i=0; i<3; ++i)
		{
			m.pressed[i]=glfwGetMouseButton(m_window, i) != 0;
		}
    }

	bool loop()
	{
		if(glfwWindowShouldClose(m_window)){
			return false;
		}
		glfwPollEvents();
		return true;
	}

	void setMouseCursor(bool mouseCursor)
	{
		glfwSetInputMode(m_window, GLFW_CURSOR
						 , mouseCursor ? GLFW_CURSOR_HIDDEN : GLFW_CURSOR_NORMAL);
	}

	void flush()
	{
		glfwSwapBuffers(m_window);
	}
}
