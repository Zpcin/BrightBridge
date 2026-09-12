package crc641e85548e048e352e;


public class MainActivity_GuideCanvas
	extends android.view.View
	implements
		mono.android.IGCUserPeer
{

	public MainActivity_GuideCanvas (android.content.Context p0, android.util.AttributeSet p1, int p2)
	{
		super (p0, p1, p2);
		if (getClass () == MainActivity_GuideCanvas.class) {
			mono.android.TypeManager.Activate ("SmartBridge.Android.MainActivity+GuideCanvas, SmartBridge.Android", "Android.Content.Context, Mono.Android:Android.Util.IAttributeSet, Mono.Android:System.Int32, System.Private.CoreLib", this, new java.lang.Object[] { p0, p1, p2 });
		}
	}

	public MainActivity_GuideCanvas (android.content.Context p0, android.util.AttributeSet p1)
	{
		super (p0, p1);
		if (getClass () == MainActivity_GuideCanvas.class) {
			mono.android.TypeManager.Activate ("SmartBridge.Android.MainActivity+GuideCanvas, SmartBridge.Android", "Android.Content.Context, Mono.Android:Android.Util.IAttributeSet, Mono.Android", this, new java.lang.Object[] { p0, p1 });
		}
	}

	public MainActivity_GuideCanvas (android.content.Context p0)
	{
		super (p0);
		if (getClass () == MainActivity_GuideCanvas.class) {
			mono.android.TypeManager.Activate ("SmartBridge.Android.MainActivity+GuideCanvas, SmartBridge.Android", "Android.Content.Context, Mono.Android", this, new java.lang.Object[] { p0 });
		}
	}

	public void onDraw (android.graphics.Canvas p0)
	{
		n_onDraw (p0);
	}

	private native void n_onDraw (android.graphics.Canvas p0);

	public boolean onTouchEvent (android.view.MotionEvent p0)
	{
		return n_onTouchEvent (p0);
	}

	private native boolean n_onTouchEvent (android.view.MotionEvent p0);

	private java.util.ArrayList refList;
	public void monodroidAddReference (java.lang.Object obj)
	{
		if (refList == null)
			refList = new java.util.ArrayList ();
		refList.add (obj);
	}

	public void monodroidClearReferences ()
	{
		if (refList != null)
			refList.clear ();
	}
}
