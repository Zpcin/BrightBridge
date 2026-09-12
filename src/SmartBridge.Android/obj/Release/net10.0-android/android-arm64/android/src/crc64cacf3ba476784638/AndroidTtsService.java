package crc64cacf3ba476784638;


public class AndroidTtsService
	extends java.lang.Object
	implements
		mono.android.IGCUserPeer,
		android.speech.tts.TextToSpeech.OnInitListener
{

	public AndroidTtsService ()
	{
		super ();
		if (getClass () == AndroidTtsService.class) {
			mono.android.TypeManager.Activate ("SmartBridge.Android.Services.AndroidTtsService, SmartBridge.Android", "", this, new java.lang.Object[] {  });
		}
	}

	public AndroidTtsService (android.content.Context p0)
	{
		super ();
		if (getClass () == AndroidTtsService.class) {
			mono.android.TypeManager.Activate ("SmartBridge.Android.Services.AndroidTtsService, SmartBridge.Android", "Android.Content.Context, Mono.Android", this, new java.lang.Object[] { p0 });
		}
	}

	public void onInit (int p0)
	{
		n_onInit (p0);
	}

	private native void n_onInit (int p0);

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
