import glfw;
import gui;
import derelict.imgui.imgui;
import renderer;
import std.typecons;


alias GuiData=Tuple!(
        bool, "show_test_window"
        , bool, "show_another_window"
        , float[3], "clear_color"
        );


void build(T...)(ref Tuple!T data)
{
    // 1. Show a simple window
    // Tip: if we don't call ImGui::Begin()/ImGui::End() the widgets appears in a window automatically called "Debug"
    {
        static float f = 0.0f;
        igText("Hello, world!");
        igSliderFloat("float", &f, 0.0f, 1.0f);
        igColorEdit3("clear color", data.clear_color);
        if (igButton("Test Window")) data.show_test_window ^= 1;
        if (igButton("Another Window")) data.show_another_window ^= 1;
        igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / igGetIO().Framerate, igGetIO().Framerate);
    }

    // 2. Show another simple window, this time using an explicit Begin/End pair
    if (data.show_another_window)
    {
        igSetNextWindowSize(ImVec2(200,100), ImGuiSetCond_FirstUseEver);
        igBegin("Another Window", &data.show_another_window);
        igText("Hello");
        if (igTreeNode("Tree"))
        {
            for (size_t i = 0; i < 5; i++)
            {
                if (igTreeNodePtr(cast(void*)i, "Child %d", i))
                {
                    igText("blah blah");
                    igSameLine();
                    igSmallButton("print");
                    igTreePop();
                }
            }
            igTreePop();
        }
        igEnd();
    }

    // 3. Show the ImGui test window. Most of the sample code is in ImGui::ShowTestWindow()
    if (data.show_test_window)
    {
        igSetNextWindowPos(ImVec2(650, 20), ImGuiSetCond_FirstUseEver);
        igShowTestWindow(&data.show_test_window);
    }
}


class FpsClock(int Target, int MarginMsecs = 5)
{
	import std.datetime;
	SysTime m_lastTime;

	static immutable Duration frameDuration=dur!"msecs"(1000/Target - MarginMsecs);

	this()
	{
		m_lastTime=Clock.currTime;
	}

	Duration newFrame()
	{
		auto now=Clock.currTime;
		auto duration=now-m_lastTime;
		m_lastTime=now;
		return duration;
	}

	void waitNextFrame()
	{
		import core.thread;

		auto now=Clock.currTime;
		auto delta=now-m_lastTime;
		if(delta < frameDuration)
		{
			auto wait=frameDuration-delta;
			Thread.sleep(wait);
		}
	}
}

void main()
{
    // window
    auto scope glfw=new GLFW();
    if(!glfw.createWindow()){
        return;
    }

    // opengl
    auto scope renderer=new Renderer();
    renderer.CreateDeviceObjects(ImDrawVert.sizeof
            , ImDrawVert.uv.offsetof, ImDrawVert.col.offsetof);

    // gui
    WindowContext windowContext;
	MouseContext mouseContext;

    // guiの変数
    GuiData data;
    data.show_test_window=true;
    data.show_another_window=false;
    data.clear_color=[0.3f, 0.4f, 0.8f];

    // setup font
    {
        ubyte* pixels;
        int width, height;
        gui.getTexDataAsRGBA32(&pixels, &width, &height);
        auto textureId=renderer.CreateFonts(pixels, width, height);
        gui.setTextureID(textureId);
    }

    // main loop
	auto clock=new FpsClock!(30, 5);
    while (true)
    {
        // time
		auto delta=clock.newFrame.total!"msecs" * 0.001;

		if(!glfw.loop()){
			break;
		}

        // update WindowContext
        glfw.updateContext(windowContext, mouseContext);
        // gui
        gui.newFrame(delta, windowContext, mouseContext);
        // update cursor
        glfw.setMouseCursor(mouseContext.enableCursor);

        // buidGUI
        build(data);

        // rendering 3D scene
        renderer.clearRenderTarget(data.clear_color);
        renderer.setViewport(windowContext.frame_w, windowContext.frame_h);

        // render gui
        gui.renderDrawLists(renderer);

        // present
        glfw.flush();

		clock.waitNextFrame();
    }

    gui.shutdown();
}
