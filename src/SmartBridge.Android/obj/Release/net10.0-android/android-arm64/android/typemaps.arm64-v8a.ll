; ModuleID = 'typemaps.arm64-v8a.ll'
source_filename = "typemaps.arm64-v8a.ll"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-android21"

%struct.TypeMapJava = type {
	i32, ; uint32_t module_index
	i32, ; uint32_t type_token_id
	i32 ; uint32_t java_name_index
}

%struct.TypeMapModule = type {
	[16 x i8], ; uint8_t module_uuid[16]
	i32, ; uint32_t entry_count
	i32, ; uint32_t duplicate_count
	ptr, ; TypeMapModuleEntry map
	ptr, ; TypeMapModuleEntry duplicate_map
	ptr, ; char* assembly_name
	ptr, ; MonoImage image
	i32, ; uint32_t java_name_width
	ptr ; uint8_t java_map
}

%struct.TypeMapModuleEntry = type {
	i32, ; uint32_t type_token_id
	i32 ; uint32_t java_map_index
}

@map_module_count = dso_local local_unnamed_addr constant i32 3, align 4

@java_type_count = dso_local local_unnamed_addr constant i32 75, align 4

; Managed modules map
@map_modules = dso_local local_unnamed_addr global [3 x %struct.TypeMapModule] [
	%struct.TypeMapModule {
		[16 x i8] [ i8 u0x00, i8 u0x00, i8 u0x1b, i8 u0xf7, i8 u0x4b, i8 u0x12, i8 u0xdc, i8 u0x48, i8 u0xb7, i8 u0x02, i8 u0x5f, i8 u0x78, i8 u0x8a, i8 u0xee, i8 u0xeb, i8 u0x93 ], ; module_uuid: f71b0000-124b-48dc-b702-5f788aeeeb93
		i32 3, ; uint32_t entry_count
		i32 0, ; uint32_t duplicate_count
		ptr @module0_managed_to_java, ; TypeMapModuleEntry* map
		ptr null, ; TypeMapModuleEntry* duplicate_map
		ptr @.TypeMapModule.0_assembly_name, ; assembly_name: SmartBridge.Android
		ptr null, ; MonoImage* image
		i32 0, ; uint32_t java_name_width
		ptr null; uint8_t* java_map
	}, ; 0
	%struct.TypeMapModule {
		[16 x i8] [ i8 u0x3e, i8 u0x9b, i8 u0x48, i8 u0x75, i8 u0xf5, i8 u0xab, i8 u0xa2, i8 u0x40, i8 u0x80, i8 u0x08, i8 u0x97, i8 u0xce, i8 u0x4b, i8 u0x06, i8 u0xa1, i8 u0xdb ], ; module_uuid: 75489b3e-abf5-40a2-8008-97ce4b06a1db
		i32 60, ; uint32_t entry_count
		i32 14, ; uint32_t duplicate_count
		ptr @module1_managed_to_java, ; TypeMapModuleEntry* map
		ptr @module1_managed_to_java_duplicates, ; TypeMapModuleEntry* duplicate_map
		ptr @.TypeMapModule.1_assembly_name, ; assembly_name: Mono.Android
		ptr null, ; MonoImage* image
		i32 0, ; uint32_t java_name_width
		ptr null; uint8_t* java_map
	}, ; 1
	%struct.TypeMapModule {
		[16 x i8] [ i8 u0x97, i8 u0x5a, i8 u0x7d, i8 u0x55, i8 u0x9f, i8 u0x82, i8 u0x80, i8 u0x45, i8 u0xb2, i8 u0x74, i8 u0x20, i8 u0xbe, i8 u0xf5, i8 u0x37, i8 u0xcc, i8 u0x7c ], ; module_uuid: 557d5a97-829f-4580-b274-20bef537cc7c
		i32 14, ; uint32_t entry_count
		i32 2, ; uint32_t duplicate_count
		ptr @module2_managed_to_java, ; TypeMapModuleEntry* map
		ptr @module2_managed_to_java_duplicates, ; TypeMapModuleEntry* duplicate_map
		ptr @.TypeMapModule.2_assembly_name, ; assembly_name: Java.Interop
		ptr null, ; MonoImage* image
		i32 0, ; uint32_t java_name_width
		ptr null; uint8_t* java_map
	} ; 2
], align 8

; Java types name hashes
@map_java_hashes = dso_local local_unnamed_addr constant [75 x i64] [
	i64 u0x0304e457b1d15194, ; 0 => android/view/ViewGroup$MarginLayoutParams
	i64 u0x0b1da699fb29019a, ; 1 => android/os/BaseBundle
	i64 u0x0bf5b117ed695981, ; 2 => crc64cacf3ba476784638/AndroidTtsService
	i64 u0x194b32fbae047fc7, ; 3 => net/dot/jni/internal/JavaProxyObject
	i64 u0x1e04bf19f9c14045, ; 4 => android/util/AttributeSet
	i64 u0x1e69018626ef9ffb, ; 5 => android/os/Handler
	i64 u0x225c20a45cb91cd7, ; 6 => java/lang/Error
	i64 u0x228edb5145b4bbc1, ; 7 => android/view/InputEvent
	i64 u0x32d6a1d6ee9f6d5a, ; 8 => android/content/Intent
	i64 u0x39f1c81500ddb55b, ; 9 => [F
	i64 u0x406e54c64b3bee74, ; 10 => android/runtime/JavaProxyThrowable
	i64 u0x40c05cff47992547, ; 11 => android/view/ViewGroup
	i64 u0x516bd5763f07d608, ; 12 => android/net/Uri
	i64 u0x5181b129b1a25949, ; 13 => java/lang/Class
	i64 u0x529da4201fa0d461, ; 14 => net/dot/jni/internal/JavaProxyThrowable
	i64 u0x54c5d3387059fe2c, ; 15 => mono/android/view/View_OnClickListenerImplementor
	i64 u0x560a92597b121e00, ; 16 => [C
	i64 u0x56365290d5a06704, ; 17 => java/lang/LinkageError
	i64 u0x5a6af884fe3c181e, ; 18 => android/os/Bundle
	i64 u0x5b905726d9bc975f, ; 19 => android/widget/TextView
	i64 u0x5bfd65ae1a6e6ffc, ; 20 => android/app/Activity
	i64 u0x5f5a9fc3430795a4, ; 21 => android/content/ContextWrapper
	i64 u0x61428f9f249ac534, ; 22 => [Z
	i64 u0x65f6b14b7e978927, ; 23 => java/io/IOException
	i64 u0x6e0fb15bd0f04d15, ; 24 => java/lang/StackTraceElement
	i64 u0x6e9ff973248919e1, ; 25 => android/speech/tts/TextToSpeech$OnInitListener
	i64 u0x6ef4975bdb7af18f, ; 26 => android/view/MotionEvent
	i64 u0x6ef7816e17e24358, ; 27 => android/graphics/Canvas
	i64 u0x75591c18ddf5e52d, ; 28 => mono/android/TypeManager
	i64 u0x76cbd2104dd555ed, ; 29 => android/content/Context
	i64 u0x7b90c42bde036cae, ; 30 => [I
	i64 u0x7ef93854923e0913, ; 31 => java/util/Locale
	i64 u0x84f94178aab6cc34, ; 32 => java/lang/CharSequence
	i64 u0x852b5457ebdd5c87, ; 33 => android/view/ViewGroup$LayoutParams
	i64 u0x88f7510c649f4a97, ; 34 => java/io/InputStream
	i64 u0x90b4aeb45636cd6a, ; 35 => mono/android/runtime/OutputStreamAdapter
	i64 u0x92188d393e2af2d2, ; 36 => java/lang/Throwable
	i64 u0x92b59c839bc46278, ; 37 => java/lang/Thread
	i64 u0x965bfaf1ff1da014, ; 38 => java/lang/ReflectiveOperationException
	i64 u0x9868475bfed4967d, ; 39 => crc641e85548e048e352e/MainActivity
	i64 u0x99df91bab800c287, ; 40 => mono/android/runtime/InputStreamAdapter
	i64 u0x9a23c2d41060f81e, ; 41 => java/io/File
	i64 u0x9e10a0b3efa170dc, ; 42 => android/view/ContextThemeWrapper
	i64 u0xa3d3c9e462460eb7, ; 43 => android/graphics/Paint$Style
	i64 u0xa865adbdd81d9951, ; 44 => java/io/OutputStream
	i64 u0xabc3cd0f40f748aa, ; 45 => java/lang/String
	i64 u0xacaf4fe23af1f72a, ; 46 => [S
	i64 u0xada6872f699d2ae8, ; 47 => [J
	i64 u0xb18d71343ca8e96f, ; 48 => java/lang/Exception
	i64 u0xb3ea8750328eba6b, ; 49 => android/graphics/RectF
	i64 u0xb4fc3e21cc054bc7, ; 50 => android/graphics/Paint
	i64 u0xb6c4749da9477c3a, ; 51 => [B
	i64 u0xb8df224d6b778ca3, ; 52 => android/view/View
	i64 u0xbb41c32523812652, ; 53 => android/widget/Button
	i64 u0xbb84ccbe48f6c18b, ; 54 => android/os/Looper
	i64 u0xbf6d427143271cb3, ; 55 => java/lang/Object
	i64 u0xc00f4c2f11efdcff, ; 56 => java/lang/ClassNotFoundException
	i64 u0xc2a8e50a5f08afc6, ; 57 => mono/java/lang/RunnableImplementor
	i64 u0xc3eb0cbb47f178b9, ; 58 => java/lang/Enum
	i64 u0xcabf871ef950ad91, ; 59 => android/view/View$OnClickListener
	i64 u0xcc306823503920e9, ; 60 => android/app/Application
	i64 u0xd2fc750314fd2213, ; 61 => [D
	i64 u0xd3158fc01ef05c82, ; 62 => android/speech/tts/TextToSpeech
	i64 u0xdefbe04fed538321, ; 63 => android/os/SystemClock
	i64 u0xdfabd9351f4351a6, ; 64 => [Ljava/lang/Object;
	i64 u0xe0446bf91fb0c2dd, ; 65 => java/lang/NoClassDefFoundError
	i64 u0xe1b3c5871398eb28, ; 66 => java/nio/channels/FileChannel
	i64 u0xe5abbaa9de37d34b, ; 67 => net/dot/jni/ManagedPeer
	i64 u0xed49ed70aa9be1b3, ; 68 => java/nio/channels/spi/AbstractInterruptibleChannel
	i64 u0xef2f2996a1d369cc, ; 69 => java/io/FileInputStream
	i64 u0xefd8c7aa4b48418e, ; 70 => android/widget/LinearLayout
	i64 u0xfb0541dba11b69d9, ; 71 => android/graphics/Color
	i64 u0xfd2b1a3de667eb51, ; 72 => java/lang/Runnable
	i64 u0xfe07df0b35277433, ; 73 => android/widget/LinearLayout$LayoutParams
	i64 u0xffd49d6a11e7c732 ; 74 => crc641e85548e048e352e/MainActivity_GuideCanvas
], align 8

@module0_managed_to_java = internal dso_local constant [3 x %struct.TypeMapModuleEntry] [
	%struct.TypeMapModuleEntry {
		i32 u0x02000002, ; uint32_t type_token_id
		i32 39; uint32_t java_map_index
	}, ; 0
	%struct.TypeMapModuleEntry {
		i32 u0x02000004, ; uint32_t type_token_id
		i32 2; uint32_t java_map_index
	}, ; 1
	%struct.TypeMapModuleEntry {
		i32 u0x02000005, ; uint32_t type_token_id
		i32 74; uint32_t java_map_index
	} ; 2
], align 4

@module1_managed_to_java = internal dso_local constant [60 x %struct.TypeMapModuleEntry] [
	%struct.TypeMapModuleEntry {
		i32 u0x02000042, ; uint32_t type_token_id
		i32 62; uint32_t java_map_index
	}, ; 0
	%struct.TypeMapModuleEntry {
		i32 u0x02000043, ; uint32_t type_token_id
		i32 25; uint32_t java_map_index
	}, ; 1
	%struct.TypeMapModuleEntry {
		i32 u0x02000045, ; uint32_t type_token_id
		i32 19; uint32_t java_map_index
	}, ; 2
	%struct.TypeMapModuleEntry {
		i32 u0x02000046, ; uint32_t type_token_id
		i32 53; uint32_t java_map_index
	}, ; 3
	%struct.TypeMapModuleEntry {
		i32 u0x02000047, ; uint32_t type_token_id
		i32 70; uint32_t java_map_index
	}, ; 4
	%struct.TypeMapModuleEntry {
		i32 u0x02000048, ; uint32_t type_token_id
		i32 73; uint32_t java_map_index
	}, ; 5
	%struct.TypeMapModuleEntry {
		i32 u0x0200004b, ; uint32_t type_token_id
		i32 4; uint32_t java_map_index
	}, ; 6
	%struct.TypeMapModuleEntry {
		i32 u0x0200004d, ; uint32_t type_token_id
		i32 5; uint32_t java_map_index
	}, ; 7
	%struct.TypeMapModuleEntry {
		i32 u0x0200004e, ; uint32_t type_token_id
		i32 1; uint32_t java_map_index
	}, ; 8
	%struct.TypeMapModuleEntry {
		i32 u0x0200004f, ; uint32_t type_token_id
		i32 18; uint32_t java_map_index
	}, ; 9
	%struct.TypeMapModuleEntry {
		i32 u0x02000050, ; uint32_t type_token_id
		i32 54; uint32_t java_map_index
	}, ; 10
	%struct.TypeMapModuleEntry {
		i32 u0x02000051, ; uint32_t type_token_id
		i32 63; uint32_t java_map_index
	}, ; 11
	%struct.TypeMapModuleEntry {
		i32 u0x02000052, ; uint32_t type_token_id
		i32 52; uint32_t java_map_index
	}, ; 12
	%struct.TypeMapModuleEntry {
		i32 u0x02000053, ; uint32_t type_token_id
		i32 59; uint32_t java_map_index
	}, ; 13
	%struct.TypeMapModuleEntry {
		i32 u0x02000055, ; uint32_t type_token_id
		i32 15; uint32_t java_map_index
	}, ; 14
	%struct.TypeMapModuleEntry {
		i32 u0x02000059, ; uint32_t type_token_id
		i32 26; uint32_t java_map_index
	}, ; 15
	%struct.TypeMapModuleEntry {
		i32 u0x0200005a, ; uint32_t type_token_id
		i32 42; uint32_t java_map_index
	}, ; 16
	%struct.TypeMapModuleEntry {
		i32 u0x0200005c, ; uint32_t type_token_id
		i32 7; uint32_t java_map_index
	}, ; 17
	%struct.TypeMapModuleEntry {
		i32 u0x0200005f, ; uint32_t type_token_id
		i32 11; uint32_t java_map_index
	}, ; 18
	%struct.TypeMapModuleEntry {
		i32 u0x02000060, ; uint32_t type_token_id
		i32 33; uint32_t java_map_index
	}, ; 19
	%struct.TypeMapModuleEntry {
		i32 u0x02000061, ; uint32_t type_token_id
		i32 0; uint32_t java_map_index
	}, ; 20
	%struct.TypeMapModuleEntry {
		i32 u0x02000076, ; uint32_t type_token_id
		i32 40; uint32_t java_map_index
	}, ; 21
	%struct.TypeMapModuleEntry {
		i32 u0x02000078, ; uint32_t type_token_id
		i32 10; uint32_t java_map_index
	}, ; 22
	%struct.TypeMapModuleEntry {
		i32 u0x02000083, ; uint32_t type_token_id
		i32 35; uint32_t java_map_index
	}, ; 23
	%struct.TypeMapModuleEntry {
		i32 u0x02000089, ; uint32_t type_token_id
		i32 12; uint32_t java_map_index
	}, ; 24
	%struct.TypeMapModuleEntry {
		i32 u0x0200008b, ; uint32_t type_token_id
		i32 27; uint32_t java_map_index
	}, ; 25
	%struct.TypeMapModuleEntry {
		i32 u0x0200008e, ; uint32_t type_token_id
		i32 71; uint32_t java_map_index
	}, ; 26
	%struct.TypeMapModuleEntry {
		i32 u0x0200008f, ; uint32_t type_token_id
		i32 50; uint32_t java_map_index
	}, ; 27
	%struct.TypeMapModuleEntry {
		i32 u0x02000090, ; uint32_t type_token_id
		i32 43; uint32_t java_map_index
	}, ; 28
	%struct.TypeMapModuleEntry {
		i32 u0x02000091, ; uint32_t type_token_id
		i32 49; uint32_t java_map_index
	}, ; 29
	%struct.TypeMapModuleEntry {
		i32 u0x02000092, ; uint32_t type_token_id
		i32 29; uint32_t java_map_index
	}, ; 30
	%struct.TypeMapModuleEntry {
		i32 u0x02000093, ; uint32_t type_token_id
		i32 8; uint32_t java_map_index
	}, ; 31
	%struct.TypeMapModuleEntry {
		i32 u0x02000095, ; uint32_t type_token_id
		i32 21; uint32_t java_map_index
	}, ; 32
	%struct.TypeMapModuleEntry {
		i32 u0x02000098, ; uint32_t type_token_id
		i32 20; uint32_t java_map_index
	}, ; 33
	%struct.TypeMapModuleEntry {
		i32 u0x02000099, ; uint32_t type_token_id
		i32 60; uint32_t java_map_index
	}, ; 34
	%struct.TypeMapModuleEntry {
		i32 u0x0200009e, ; uint32_t type_token_id
		i32 66; uint32_t java_map_index
	}, ; 35
	%struct.TypeMapModuleEntry {
		i32 u0x020000a0, ; uint32_t type_token_id
		i32 68; uint32_t java_map_index
	}, ; 36
	%struct.TypeMapModuleEntry {
		i32 u0x020000a2, ; uint32_t type_token_id
		i32 41; uint32_t java_map_index
	}, ; 37
	%struct.TypeMapModuleEntry {
		i32 u0x020000a3, ; uint32_t type_token_id
		i32 69; uint32_t java_map_index
	}, ; 38
	%struct.TypeMapModuleEntry {
		i32 u0x020000a4, ; uint32_t type_token_id
		i32 34; uint32_t java_map_index
	}, ; 39
	%struct.TypeMapModuleEntry {
		i32 u0x020000a6, ; uint32_t type_token_id
		i32 23; uint32_t java_map_index
	}, ; 40
	%struct.TypeMapModuleEntry {
		i32 u0x020000a7, ; uint32_t type_token_id
		i32 44; uint32_t java_map_index
	}, ; 41
	%struct.TypeMapModuleEntry {
		i32 u0x020000a9, ; uint32_t type_token_id
		i32 31; uint32_t java_map_index
	}, ; 42
	%struct.TypeMapModuleEntry {
		i32 u0x020000aa, ; uint32_t type_token_id
		i32 13; uint32_t java_map_index
	}, ; 43
	%struct.TypeMapModuleEntry {
		i32 u0x020000ab, ; uint32_t type_token_id
		i32 56; uint32_t java_map_index
	}, ; 44
	%struct.TypeMapModuleEntry {
		i32 u0x020000ac, ; uint32_t type_token_id
		i32 48; uint32_t java_map_index
	}, ; 45
	%struct.TypeMapModuleEntry {
		i32 u0x020000ad, ; uint32_t type_token_id
		i32 32; uint32_t java_map_index
	}, ; 46
	%struct.TypeMapModuleEntry {
		i32 u0x020000ae, ; uint32_t type_token_id
		i32 55; uint32_t java_map_index
	}, ; 47
	%struct.TypeMapModuleEntry {
		i32 u0x020000af, ; uint32_t type_token_id
		i32 45; uint32_t java_map_index
	}, ; 48
	%struct.TypeMapModuleEntry {
		i32 u0x020000b1, ; uint32_t type_token_id
		i32 37; uint32_t java_map_index
	}, ; 49
	%struct.TypeMapModuleEntry {
		i32 u0x020000b2, ; uint32_t type_token_id
		i32 57; uint32_t java_map_index
	}, ; 50
	%struct.TypeMapModuleEntry {
		i32 u0x020000b3, ; uint32_t type_token_id
		i32 36; uint32_t java_map_index
	}, ; 51
	%struct.TypeMapModuleEntry {
		i32 u0x020000b4, ; uint32_t type_token_id
		i32 58; uint32_t java_map_index
	}, ; 52
	%struct.TypeMapModuleEntry {
		i32 u0x020000b6, ; uint32_t type_token_id
		i32 6; uint32_t java_map_index
	}, ; 53
	%struct.TypeMapModuleEntry {
		i32 u0x020000b9, ; uint32_t type_token_id
		i32 72; uint32_t java_map_index
	}, ; 54
	%struct.TypeMapModuleEntry {
		i32 u0x020000bb, ; uint32_t type_token_id
		i32 17; uint32_t java_map_index
	}, ; 55
	%struct.TypeMapModuleEntry {
		i32 u0x020000bc, ; uint32_t type_token_id
		i32 65; uint32_t java_map_index
	}, ; 56
	%struct.TypeMapModuleEntry {
		i32 u0x020000bd, ; uint32_t type_token_id
		i32 38; uint32_t java_map_index
	}, ; 57
	%struct.TypeMapModuleEntry {
		i32 u0x020000be, ; uint32_t type_token_id
		i32 24; uint32_t java_map_index
	}, ; 58
	%struct.TypeMapModuleEntry {
		i32 u0x020000cb, ; uint32_t type_token_id
		i32 28; uint32_t java_map_index
	} ; 59
], align 4

@module1_managed_to_java_duplicates = internal dso_local constant [14 x %struct.TypeMapModuleEntry] [
	%struct.TypeMapModuleEntry {
		i32 u0x02000044, ; uint32_t type_token_id
		i32 25; uint32_t java_map_index
	}, ; 0
	%struct.TypeMapModuleEntry {
		i32 u0x0200004c, ; uint32_t type_token_id
		i32 4; uint32_t java_map_index
	}, ; 1
	%struct.TypeMapModuleEntry {
		i32 u0x02000054, ; uint32_t type_token_id
		i32 59; uint32_t java_map_index
	}, ; 2
	%struct.TypeMapModuleEntry {
		i32 u0x0200005d, ; uint32_t type_token_id
		i32 7; uint32_t java_map_index
	}, ; 3
	%struct.TypeMapModuleEntry {
		i32 u0x02000062, ; uint32_t type_token_id
		i32 11; uint32_t java_map_index
	}, ; 4
	%struct.TypeMapModuleEntry {
		i32 u0x0200008a, ; uint32_t type_token_id
		i32 12; uint32_t java_map_index
	}, ; 5
	%struct.TypeMapModuleEntry {
		i32 u0x02000094, ; uint32_t type_token_id
		i32 29; uint32_t java_map_index
	}, ; 6
	%struct.TypeMapModuleEntry {
		i32 u0x0200009f, ; uint32_t type_token_id
		i32 66; uint32_t java_map_index
	}, ; 7
	%struct.TypeMapModuleEntry {
		i32 u0x020000a1, ; uint32_t type_token_id
		i32 68; uint32_t java_map_index
	}, ; 8
	%struct.TypeMapModuleEntry {
		i32 u0x020000a5, ; uint32_t type_token_id
		i32 34; uint32_t java_map_index
	}, ; 9
	%struct.TypeMapModuleEntry {
		i32 u0x020000a8, ; uint32_t type_token_id
		i32 44; uint32_t java_map_index
	}, ; 10
	%struct.TypeMapModuleEntry {
		i32 u0x020000b5, ; uint32_t type_token_id
		i32 58; uint32_t java_map_index
	}, ; 11
	%struct.TypeMapModuleEntry {
		i32 u0x020000b7, ; uint32_t type_token_id
		i32 32; uint32_t java_map_index
	}, ; 12
	%struct.TypeMapModuleEntry {
		i32 u0x020000ba, ; uint32_t type_token_id
		i32 72; uint32_t java_map_index
	} ; 13
], align 4

@module2_managed_to_java = internal dso_local constant [14 x %struct.TypeMapModuleEntry] [
	%struct.TypeMapModuleEntry {
		i32 u0x02000006, ; uint32_t type_token_id
		i32 64; uint32_t java_map_index
	}, ; 0
	%struct.TypeMapModuleEntry {
		i32 u0x0200000b, ; uint32_t type_token_id
		i32 36; uint32_t java_map_index
	}, ; 1
	%struct.TypeMapModuleEntry {
		i32 u0x0200000c, ; uint32_t type_token_id
		i32 55; uint32_t java_map_index
	}, ; 2
	%struct.TypeMapModuleEntry {
		i32 u0x0200002c, ; uint32_t type_token_id
		i32 22; uint32_t java_map_index
	}, ; 3
	%struct.TypeMapModuleEntry {
		i32 u0x02000030, ; uint32_t type_token_id
		i32 51; uint32_t java_map_index
	}, ; 4
	%struct.TypeMapModuleEntry {
		i32 u0x02000034, ; uint32_t type_token_id
		i32 16; uint32_t java_map_index
	}, ; 5
	%struct.TypeMapModuleEntry {
		i32 u0x02000038, ; uint32_t type_token_id
		i32 46; uint32_t java_map_index
	}, ; 6
	%struct.TypeMapModuleEntry {
		i32 u0x0200003c, ; uint32_t type_token_id
		i32 30; uint32_t java_map_index
	}, ; 7
	%struct.TypeMapModuleEntry {
		i32 u0x02000040, ; uint32_t type_token_id
		i32 47; uint32_t java_map_index
	}, ; 8
	%struct.TypeMapModuleEntry {
		i32 u0x02000044, ; uint32_t type_token_id
		i32 9; uint32_t java_map_index
	}, ; 9
	%struct.TypeMapModuleEntry {
		i32 u0x02000048, ; uint32_t type_token_id
		i32 61; uint32_t java_map_index
	}, ; 10
	%struct.TypeMapModuleEntry {
		i32 u0x0200004b, ; uint32_t type_token_id
		i32 3; uint32_t java_map_index
	}, ; 11
	%struct.TypeMapModuleEntry {
		i32 u0x0200004c, ; uint32_t type_token_id
		i32 14; uint32_t java_map_index
	}, ; 12
	%struct.TypeMapModuleEntry {
		i32 u0x02000094, ; uint32_t type_token_id
		i32 67; uint32_t java_map_index
	} ; 13
], align 4

@module2_managed_to_java_duplicates = internal dso_local constant [2 x %struct.TypeMapModuleEntry] [
	%struct.TypeMapModuleEntry {
		i32 u0x0200000a, ; uint32_t type_token_id
		i32 64; uint32_t java_map_index
	}, ; 0
	%struct.TypeMapModuleEntry {
		i32 u0x0200000d, ; uint32_t type_token_id
		i32 64; uint32_t java_map_index
	} ; 1
], align 4

; Java to managed map
@map_java = dso_local local_unnamed_addr constant [75 x %struct.TypeMapJava] [
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000061, ; uint32_t type_token_id
		i32 20; uint32_t java_name_index
	}, ; 0
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200004e, ; uint32_t type_token_id
		i32 8; uint32_t java_name_index
	}, ; 1
	%struct.TypeMapJava {
		i32 0, ; uint32_t module_index
		i32 u0x02000004, ; uint32_t type_token_id
		i32 62; uint32_t java_name_index
	}, ; 2
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x0200004b, ; uint32_t type_token_id
		i32 72; uint32_t java_name_index
	}, ; 3
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x00000000, ; uint32_t type_token_id
		i32 6; uint32_t java_name_index
	}, ; 4
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200004d, ; uint32_t type_token_id
		i32 7; uint32_t java_name_index
	}, ; 5
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000b6, ; uint32_t type_token_id
		i32 53; uint32_t java_name_index
	}, ; 6
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200005c, ; uint32_t type_token_id
		i32 17; uint32_t java_name_index
	}, ; 7
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000093, ; uint32_t type_token_id
		i32 31; uint32_t java_name_index
	}, ; 8
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x02000044, ; uint32_t type_token_id
		i32 70; uint32_t java_name_index
	}, ; 9
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000078, ; uint32_t type_token_id
		i32 22; uint32_t java_name_index
	}, ; 10
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200005f, ; uint32_t type_token_id
		i32 18; uint32_t java_name_index
	}, ; 11
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000089, ; uint32_t type_token_id
		i32 24; uint32_t java_name_index
	}, ; 12
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000aa, ; uint32_t type_token_id
		i32 43; uint32_t java_name_index
	}, ; 13
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x0200004c, ; uint32_t type_token_id
		i32 73; uint32_t java_name_index
	}, ; 14
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000055, ; uint32_t type_token_id
		i32 14; uint32_t java_name_index
	}, ; 15
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x02000034, ; uint32_t type_token_id
		i32 66; uint32_t java_name_index
	}, ; 16
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000bb, ; uint32_t type_token_id
		i32 55; uint32_t java_name_index
	}, ; 17
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200004f, ; uint32_t type_token_id
		i32 9; uint32_t java_name_index
	}, ; 18
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000045, ; uint32_t type_token_id
		i32 2; uint32_t java_name_index
	}, ; 19
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000098, ; uint32_t type_token_id
		i32 33; uint32_t java_name_index
	}, ; 20
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000095, ; uint32_t type_token_id
		i32 32; uint32_t java_name_index
	}, ; 21
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x0200002c, ; uint32_t type_token_id
		i32 64; uint32_t java_name_index
	}, ; 22
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000a6, ; uint32_t type_token_id
		i32 40; uint32_t java_name_index
	}, ; 23
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000be, ; uint32_t type_token_id
		i32 58; uint32_t java_name_index
	}, ; 24
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x00000000, ; uint32_t type_token_id
		i32 1; uint32_t java_name_index
	}, ; 25
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000059, ; uint32_t type_token_id
		i32 15; uint32_t java_name_index
	}, ; 26
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200008b, ; uint32_t type_token_id
		i32 25; uint32_t java_name_index
	}, ; 27
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000cb, ; uint32_t type_token_id
		i32 59; uint32_t java_name_index
	}, ; 28
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000092, ; uint32_t type_token_id
		i32 30; uint32_t java_name_index
	}, ; 29
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x0200003c, ; uint32_t type_token_id
		i32 68; uint32_t java_name_index
	}, ; 30
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000a9, ; uint32_t type_token_id
		i32 42; uint32_t java_name_index
	}, ; 31
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x00000000, ; uint32_t type_token_id
		i32 46; uint32_t java_name_index
	}, ; 32
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000060, ; uint32_t type_token_id
		i32 19; uint32_t java_name_index
	}, ; 33
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000a4, ; uint32_t type_token_id
		i32 39; uint32_t java_name_index
	}, ; 34
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000083, ; uint32_t type_token_id
		i32 23; uint32_t java_name_index
	}, ; 35
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000b3, ; uint32_t type_token_id
		i32 51; uint32_t java_name_index
	}, ; 36
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000b1, ; uint32_t type_token_id
		i32 49; uint32_t java_name_index
	}, ; 37
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000bd, ; uint32_t type_token_id
		i32 57; uint32_t java_name_index
	}, ; 38
	%struct.TypeMapJava {
		i32 0, ; uint32_t module_index
		i32 u0x02000002, ; uint32_t type_token_id
		i32 60; uint32_t java_name_index
	}, ; 39
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000076, ; uint32_t type_token_id
		i32 21; uint32_t java_name_index
	}, ; 40
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000a2, ; uint32_t type_token_id
		i32 37; uint32_t java_name_index
	}, ; 41
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200005a, ; uint32_t type_token_id
		i32 16; uint32_t java_name_index
	}, ; 42
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000090, ; uint32_t type_token_id
		i32 28; uint32_t java_name_index
	}, ; 43
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000a7, ; uint32_t type_token_id
		i32 41; uint32_t java_name_index
	}, ; 44
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000af, ; uint32_t type_token_id
		i32 48; uint32_t java_name_index
	}, ; 45
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x02000038, ; uint32_t type_token_id
		i32 67; uint32_t java_name_index
	}, ; 46
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x02000040, ; uint32_t type_token_id
		i32 69; uint32_t java_name_index
	}, ; 47
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000ac, ; uint32_t type_token_id
		i32 45; uint32_t java_name_index
	}, ; 48
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000091, ; uint32_t type_token_id
		i32 29; uint32_t java_name_index
	}, ; 49
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200008f, ; uint32_t type_token_id
		i32 27; uint32_t java_name_index
	}, ; 50
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x02000030, ; uint32_t type_token_id
		i32 65; uint32_t java_name_index
	}, ; 51
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000052, ; uint32_t type_token_id
		i32 12; uint32_t java_name_index
	}, ; 52
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000046, ; uint32_t type_token_id
		i32 3; uint32_t java_name_index
	}, ; 53
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000050, ; uint32_t type_token_id
		i32 10; uint32_t java_name_index
	}, ; 54
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000ae, ; uint32_t type_token_id
		i32 47; uint32_t java_name_index
	}, ; 55
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000ab, ; uint32_t type_token_id
		i32 44; uint32_t java_name_index
	}, ; 56
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000b2, ; uint32_t type_token_id
		i32 50; uint32_t java_name_index
	}, ; 57
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000b4, ; uint32_t type_token_id
		i32 52; uint32_t java_name_index
	}, ; 58
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x00000000, ; uint32_t type_token_id
		i32 13; uint32_t java_name_index
	}, ; 59
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000099, ; uint32_t type_token_id
		i32 34; uint32_t java_name_index
	}, ; 60
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x02000048, ; uint32_t type_token_id
		i32 71; uint32_t java_name_index
	}, ; 61
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000042, ; uint32_t type_token_id
		i32 0; uint32_t java_name_index
	}, ; 62
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000051, ; uint32_t type_token_id
		i32 11; uint32_t java_name_index
	}, ; 63
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x00000000, ; uint32_t type_token_id
		i32 63; uint32_t java_name_index
	}, ; 64
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000bc, ; uint32_t type_token_id
		i32 56; uint32_t java_name_index
	}, ; 65
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200009e, ; uint32_t type_token_id
		i32 35; uint32_t java_name_index
	}, ; 66
	%struct.TypeMapJava {
		i32 2, ; uint32_t module_index
		i32 u0x02000094, ; uint32_t type_token_id
		i32 74; uint32_t java_name_index
	}, ; 67
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000a0, ; uint32_t type_token_id
		i32 36; uint32_t java_name_index
	}, ; 68
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x020000a3, ; uint32_t type_token_id
		i32 38; uint32_t java_name_index
	}, ; 69
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000047, ; uint32_t type_token_id
		i32 4; uint32_t java_name_index
	}, ; 70
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x0200008e, ; uint32_t type_token_id
		i32 26; uint32_t java_name_index
	}, ; 71
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x00000000, ; uint32_t type_token_id
		i32 54; uint32_t java_name_index
	}, ; 72
	%struct.TypeMapJava {
		i32 1, ; uint32_t module_index
		i32 u0x02000048, ; uint32_t type_token_id
		i32 5; uint32_t java_name_index
	}, ; 73
	%struct.TypeMapJava {
		i32 0, ; uint32_t module_index
		i32 u0x02000005, ; uint32_t type_token_id
		i32 61; uint32_t java_name_index
	} ; 74
], align 4

; Java type names
@java_type_names = dso_local local_unnamed_addr constant [75 x ptr] [
	ptr @.tmr.0, ; 0 ('android/speech/tts/TextToSpeech')
	ptr @.tmr.1, ; 1 ('android/speech/tts/TextToSpeech$OnInitListener')
	ptr @.tmr.2, ; 2 ('android/widget/TextView')
	ptr @.tmr.3, ; 3 ('android/widget/Button')
	ptr @.tmr.4, ; 4 ('android/widget/LinearLayout')
	ptr @.tmr.5, ; 5 ('android/widget/LinearLayout$LayoutParams')
	ptr @.tmr.6, ; 6 ('android/util/AttributeSet')
	ptr @.tmr.7, ; 7 ('android/os/Handler')
	ptr @.tmr.8, ; 8 ('android/os/BaseBundle')
	ptr @.tmr.9, ; 9 ('android/os/Bundle')
	ptr @.tmr.10, ; 10 ('android/os/Looper')
	ptr @.tmr.11, ; 11 ('android/os/SystemClock')
	ptr @.tmr.12, ; 12 ('android/view/View')
	ptr @.tmr.13, ; 13 ('android/view/View$OnClickListener')
	ptr @.tmr.14, ; 14 ('mono/android/view/View_OnClickListenerImplementor')
	ptr @.tmr.15, ; 15 ('android/view/MotionEvent')
	ptr @.tmr.16, ; 16 ('android/view/ContextThemeWrapper')
	ptr @.tmr.17, ; 17 ('android/view/InputEvent')
	ptr @.tmr.18, ; 18 ('android/view/ViewGroup')
	ptr @.tmr.19, ; 19 ('android/view/ViewGroup$LayoutParams')
	ptr @.tmr.20, ; 20 ('android/view/ViewGroup$MarginLayoutParams')
	ptr @.tmr.21, ; 21 ('mono/android/runtime/InputStreamAdapter')
	ptr @.tmr.22, ; 22 ('android/runtime/JavaProxyThrowable')
	ptr @.tmr.23, ; 23 ('mono/android/runtime/OutputStreamAdapter')
	ptr @.tmr.24, ; 24 ('android/net/Uri')
	ptr @.tmr.25, ; 25 ('android/graphics/Canvas')
	ptr @.tmr.26, ; 26 ('android/graphics/Color')
	ptr @.tmr.27, ; 27 ('android/graphics/Paint')
	ptr @.tmr.28, ; 28 ('android/graphics/Paint$Style')
	ptr @.tmr.29, ; 29 ('android/graphics/RectF')
	ptr @.tmr.30, ; 30 ('android/content/Context')
	ptr @.tmr.31, ; 31 ('android/content/Intent')
	ptr @.tmr.32, ; 32 ('android/content/ContextWrapper')
	ptr @.tmr.33, ; 33 ('android/app/Activity')
	ptr @.tmr.34, ; 34 ('android/app/Application')
	ptr @.tmr.35, ; 35 ('java/nio/channels/FileChannel')
	ptr @.tmr.36, ; 36 ('java/nio/channels/spi/AbstractInterruptibleChannel')
	ptr @.tmr.37, ; 37 ('java/io/File')
	ptr @.tmr.38, ; 38 ('java/io/FileInputStream')
	ptr @.tmr.39, ; 39 ('java/io/InputStream')
	ptr @.tmr.40, ; 40 ('java/io/IOException')
	ptr @.tmr.41, ; 41 ('java/io/OutputStream')
	ptr @.tmr.42, ; 42 ('java/util/Locale')
	ptr @.tmr.43, ; 43 ('java/lang/Class')
	ptr @.tmr.44, ; 44 ('java/lang/ClassNotFoundException')
	ptr @.tmr.45, ; 45 ('java/lang/Exception')
	ptr @.tmr.46, ; 46 ('java/lang/CharSequence')
	ptr @.tmr.47, ; 47 ('java/lang/Object')
	ptr @.tmr.48, ; 48 ('java/lang/String')
	ptr @.tmr.49, ; 49 ('java/lang/Thread')
	ptr @.tmr.50, ; 50 ('mono/java/lang/RunnableImplementor')
	ptr @.tmr.51, ; 51 ('java/lang/Throwable')
	ptr @.tmr.52, ; 52 ('java/lang/Enum')
	ptr @.tmr.53, ; 53 ('java/lang/Error')
	ptr @.tmr.54, ; 54 ('java/lang/Runnable')
	ptr @.tmr.55, ; 55 ('java/lang/LinkageError')
	ptr @.tmr.56, ; 56 ('java/lang/NoClassDefFoundError')
	ptr @.tmr.57, ; 57 ('java/lang/ReflectiveOperationException')
	ptr @.tmr.58, ; 58 ('java/lang/StackTraceElement')
	ptr @.tmr.59, ; 59 ('mono/android/TypeManager')
	ptr @.tmr.60, ; 60 ('crc641e85548e048e352e/MainActivity')
	ptr @.tmr.61, ; 61 ('crc641e85548e048e352e/MainActivity_GuideCanvas')
	ptr @.tmr.62, ; 62 ('crc64cacf3ba476784638/AndroidTtsService')
	ptr @.tmr.63, ; 63 ('[Ljava/lang/Object;')
	ptr @.tmr.64, ; 64 ('[Z')
	ptr @.tmr.65, ; 65 ('[B')
	ptr @.tmr.66, ; 66 ('[C')
	ptr @.tmr.67, ; 67 ('[S')
	ptr @.tmr.68, ; 68 ('[I')
	ptr @.tmr.69, ; 69 ('[J')
	ptr @.tmr.70, ; 70 ('[F')
	ptr @.tmr.71, ; 71 ('[D')
	ptr @.tmr.72, ; 72 ('net/dot/jni/internal/JavaProxyObject')
	ptr @.tmr.73, ; 73 ('net/dot/jni/internal/JavaProxyThrowable')
	ptr @.tmr.74 ; 74 ('net/dot/jni/ManagedPeer')
], align 8

; Strings
@.tmr.0 = private unnamed_addr constant [32 x i8] c"android/speech/tts/TextToSpeech\00", align 1
@.tmr.1 = private unnamed_addr constant [47 x i8] c"android/speech/tts/TextToSpeech$OnInitListener\00", align 1
@.tmr.2 = private unnamed_addr constant [24 x i8] c"android/widget/TextView\00", align 1
@.tmr.3 = private unnamed_addr constant [22 x i8] c"android/widget/Button\00", align 1
@.tmr.4 = private unnamed_addr constant [28 x i8] c"android/widget/LinearLayout\00", align 1
@.tmr.5 = private unnamed_addr constant [41 x i8] c"android/widget/LinearLayout$LayoutParams\00", align 1
@.tmr.6 = private unnamed_addr constant [26 x i8] c"android/util/AttributeSet\00", align 1
@.tmr.7 = private unnamed_addr constant [19 x i8] c"android/os/Handler\00", align 1
@.tmr.8 = private unnamed_addr constant [22 x i8] c"android/os/BaseBundle\00", align 1
@.tmr.9 = private unnamed_addr constant [18 x i8] c"android/os/Bundle\00", align 1
@.tmr.10 = private unnamed_addr constant [18 x i8] c"android/os/Looper\00", align 1
@.tmr.11 = private unnamed_addr constant [23 x i8] c"android/os/SystemClock\00", align 1
@.tmr.12 = private unnamed_addr constant [18 x i8] c"android/view/View\00", align 1
@.tmr.13 = private unnamed_addr constant [34 x i8] c"android/view/View$OnClickListener\00", align 1
@.tmr.14 = private unnamed_addr constant [50 x i8] c"mono/android/view/View_OnClickListenerImplementor\00", align 1
@.tmr.15 = private unnamed_addr constant [25 x i8] c"android/view/MotionEvent\00", align 1
@.tmr.16 = private unnamed_addr constant [33 x i8] c"android/view/ContextThemeWrapper\00", align 1
@.tmr.17 = private unnamed_addr constant [24 x i8] c"android/view/InputEvent\00", align 1
@.tmr.18 = private unnamed_addr constant [23 x i8] c"android/view/ViewGroup\00", align 1
@.tmr.19 = private unnamed_addr constant [36 x i8] c"android/view/ViewGroup$LayoutParams\00", align 1
@.tmr.20 = private unnamed_addr constant [42 x i8] c"android/view/ViewGroup$MarginLayoutParams\00", align 1
@.tmr.21 = private unnamed_addr constant [40 x i8] c"mono/android/runtime/InputStreamAdapter\00", align 1
@.tmr.22 = private unnamed_addr constant [35 x i8] c"android/runtime/JavaProxyThrowable\00", align 1
@.tmr.23 = private unnamed_addr constant [41 x i8] c"mono/android/runtime/OutputStreamAdapter\00", align 1
@.tmr.24 = private unnamed_addr constant [16 x i8] c"android/net/Uri\00", align 1
@.tmr.25 = private unnamed_addr constant [24 x i8] c"android/graphics/Canvas\00", align 1
@.tmr.26 = private unnamed_addr constant [23 x i8] c"android/graphics/Color\00", align 1
@.tmr.27 = private unnamed_addr constant [23 x i8] c"android/graphics/Paint\00", align 1
@.tmr.28 = private unnamed_addr constant [29 x i8] c"android/graphics/Paint$Style\00", align 1
@.tmr.29 = private unnamed_addr constant [23 x i8] c"android/graphics/RectF\00", align 1
@.tmr.30 = private unnamed_addr constant [24 x i8] c"android/content/Context\00", align 1
@.tmr.31 = private unnamed_addr constant [23 x i8] c"android/content/Intent\00", align 1
@.tmr.32 = private unnamed_addr constant [31 x i8] c"android/content/ContextWrapper\00", align 1
@.tmr.33 = private unnamed_addr constant [21 x i8] c"android/app/Activity\00", align 1
@.tmr.34 = private unnamed_addr constant [24 x i8] c"android/app/Application\00", align 1
@.tmr.35 = private unnamed_addr constant [30 x i8] c"java/nio/channels/FileChannel\00", align 1
@.tmr.36 = private unnamed_addr constant [51 x i8] c"java/nio/channels/spi/AbstractInterruptibleChannel\00", align 1
@.tmr.37 = private unnamed_addr constant [13 x i8] c"java/io/File\00", align 1
@.tmr.38 = private unnamed_addr constant [24 x i8] c"java/io/FileInputStream\00", align 1
@.tmr.39 = private unnamed_addr constant [20 x i8] c"java/io/InputStream\00", align 1
@.tmr.40 = private unnamed_addr constant [20 x i8] c"java/io/IOException\00", align 1
@.tmr.41 = private unnamed_addr constant [21 x i8] c"java/io/OutputStream\00", align 1
@.tmr.42 = private unnamed_addr constant [17 x i8] c"java/util/Locale\00", align 1
@.tmr.43 = private unnamed_addr constant [16 x i8] c"java/lang/Class\00", align 1
@.tmr.44 = private unnamed_addr constant [33 x i8] c"java/lang/ClassNotFoundException\00", align 1
@.tmr.45 = private unnamed_addr constant [20 x i8] c"java/lang/Exception\00", align 1
@.tmr.46 = private unnamed_addr constant [23 x i8] c"java/lang/CharSequence\00", align 1
@.tmr.47 = private unnamed_addr constant [17 x i8] c"java/lang/Object\00", align 1
@.tmr.48 = private unnamed_addr constant [17 x i8] c"java/lang/String\00", align 1
@.tmr.49 = private unnamed_addr constant [17 x i8] c"java/lang/Thread\00", align 1
@.tmr.50 = private unnamed_addr constant [35 x i8] c"mono/java/lang/RunnableImplementor\00", align 1
@.tmr.51 = private unnamed_addr constant [20 x i8] c"java/lang/Throwable\00", align 1
@.tmr.52 = private unnamed_addr constant [15 x i8] c"java/lang/Enum\00", align 1
@.tmr.53 = private unnamed_addr constant [16 x i8] c"java/lang/Error\00", align 1
@.tmr.54 = private unnamed_addr constant [19 x i8] c"java/lang/Runnable\00", align 1
@.tmr.55 = private unnamed_addr constant [23 x i8] c"java/lang/LinkageError\00", align 1
@.tmr.56 = private unnamed_addr constant [31 x i8] c"java/lang/NoClassDefFoundError\00", align 1
@.tmr.57 = private unnamed_addr constant [39 x i8] c"java/lang/ReflectiveOperationException\00", align 1
@.tmr.58 = private unnamed_addr constant [28 x i8] c"java/lang/StackTraceElement\00", align 1
@.tmr.59 = private unnamed_addr constant [25 x i8] c"mono/android/TypeManager\00", align 1
@.tmr.60 = private unnamed_addr constant [35 x i8] c"crc641e85548e048e352e/MainActivity\00", align 1
@.tmr.61 = private unnamed_addr constant [47 x i8] c"crc641e85548e048e352e/MainActivity_GuideCanvas\00", align 1
@.tmr.62 = private unnamed_addr constant [40 x i8] c"crc64cacf3ba476784638/AndroidTtsService\00", align 1
@.tmr.63 = private unnamed_addr constant [20 x i8] c"[Ljava/lang/Object;\00", align 1
@.tmr.64 = private unnamed_addr constant [3 x i8] c"[Z\00", align 1
@.tmr.65 = private unnamed_addr constant [3 x i8] c"[B\00", align 1
@.tmr.66 = private unnamed_addr constant [3 x i8] c"[C\00", align 1
@.tmr.67 = private unnamed_addr constant [3 x i8] c"[S\00", align 1
@.tmr.68 = private unnamed_addr constant [3 x i8] c"[I\00", align 1
@.tmr.69 = private unnamed_addr constant [3 x i8] c"[J\00", align 1
@.tmr.70 = private unnamed_addr constant [3 x i8] c"[F\00", align 1
@.tmr.71 = private unnamed_addr constant [3 x i8] c"[D\00", align 1
@.tmr.72 = private unnamed_addr constant [37 x i8] c"net/dot/jni/internal/JavaProxyObject\00", align 1
@.tmr.73 = private unnamed_addr constant [40 x i8] c"net/dot/jni/internal/JavaProxyThrowable\00", align 1
@.tmr.74 = private unnamed_addr constant [24 x i8] c"net/dot/jni/ManagedPeer\00", align 1

;TypeMapModule
@.TypeMapModule.0_assembly_name = private unnamed_addr constant [20 x i8] c"SmartBridge.Android\00", align 1
@.TypeMapModule.1_assembly_name = private unnamed_addr constant [13 x i8] c"Mono.Android\00", align 1
@.TypeMapModule.2_assembly_name = private unnamed_addr constant [13 x i8] c"Java.Interop\00", align 1

; Metadata
!llvm.module.flags = !{!0, !1, !7, !8, !9, !10}
!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!llvm.ident = !{!2}
!2 = !{!".NET for Android remotes/origin/release/10.0.1xx @ 350a375fc202f0072ac4191624986d8c642b93fa"}
!3 = !{!4, !4, i64 0}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{i32 1, !"branch-target-enforcement", i32 0}
!8 = !{i32 1, !"sign-return-address", i32 0}
!9 = !{i32 1, !"sign-return-address-all", i32 0}
!10 = !{i32 1, !"sign-return-address-with-bkey", i32 0}
