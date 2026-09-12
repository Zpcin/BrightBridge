; ModuleID = 'marshal_methods.arm64-v8a.ll'
source_filename = "marshal_methods.arm64-v8a.ll"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-android21"

%struct.MarshalMethodName = type {
	i64, ; uint64_t id
	ptr ; char* name
}

%struct.MarshalMethodsManagedClass = type {
	i32, ; uint32_t token
	ptr ; MonoClass klass
}

@assembly_image_cache = dso_local local_unnamed_addr global [21 x ptr] zeroinitializer, align 8

; Each entry maps hash of an assembly name to an index into the `assembly_image_cache` array
@assembly_image_cache_hashes = dso_local local_unnamed_addr constant [63 x i64] [
	i64 u0x02abedc11addc1ed, ; 0: lib_Mono.Android.Runtime.dll.so => 19
	i64 u0x0581db89237110e9, ; 1: lib_System.Collections.dll.so => 4
	i64 u0x09d144a7e214d457, ; 2: System.Security.Cryptography => 12
	i64 u0x0c59ad9fbbd43abe, ; 3: Mono.Android => 20
	i64 u0x13f1e5e209e91af4, ; 4: lib_Java.Interop.dll.so => 18
	i64 u0x17f9358913beb16a, ; 5: System.Text.Encodings.Web => 13
	i64 u0x1a91866a319e9259, ; 6: lib_System.Collections.Concurrent.dll.so => 3
	i64 u0x1c753b5ff15bce1b, ; 7: Mono.Android.Runtime.dll => 19
	i64 u0x2174319c0d835bc9, ; 8: System.Runtime => 11
	i64 u0x2407aef2bbe8fadf, ; 9: System.Console => 5
	i64 u0x27b410442fad6cf1, ; 10: Java.Interop.dll => 18
	i64 u0x2af298f63581d886, ; 11: System.Text.RegularExpressions.dll => 15
	i64 u0x2d169d318a968379, ; 12: System.Threading.dll => 16
	i64 u0x2db915caf23548d2, ; 13: System.Text.Json.dll => 14
	i64 u0x31195fef5d8fb552, ; 14: _Microsoft.Android.Resource.Designer.dll => 0
	i64 u0x434c4e1d9284cdae, ; 15: Mono.Android.dll => 20
	i64 u0x4b7b6532ded934b7, ; 16: System.Text.Json => 14
	i64 u0x4d877bfbe4a21cd8, ; 17: SmartBridge.Core.dll => 1
	i64 u0x4e32f00cb0937401, ; 18: Mono.Android.Runtime => 19
	i64 u0x54795225dd1587af, ; 19: lib_System.Runtime.dll.so => 11
	i64 u0x571c5cfbec5ae8e2, ; 20: System.Private.Uri => 9
	i64 u0x579a06fed6eec900, ; 21: System.Private.CoreLib.dll => 17
	i64 u0x5a8f6699f4a1caa9, ; 22: lib_System.Threading.dll.so => 16
	i64 u0x5db0cbbd1028510e, ; 23: lib_System.Runtime.InteropServices.dll.so => 10
	i64 u0x5ea92fdb19ec8c4c, ; 24: System.Text.Encodings.Web.dll => 13
	i64 u0x60f62d786afcf130, ; 25: System.Memory => 8
	i64 u0x622eef6f9e59068d, ; 26: System.Private.CoreLib => 17
	i64 u0x6692e924eade1b29, ; 27: lib_System.Console.dll.so => 5
	i64 u0x6a4d7577b2317255, ; 28: System.Runtime.InteropServices.dll => 10
	i64 u0x73e4ce94e2eb6ffc, ; 29: lib_System.Memory.dll.so => 8
	i64 u0x7dfc3d6d9d8d7b70, ; 30: System.Collections => 4
	i64 u0x875699647fd4b4dc, ; 31: lib_SmartBridge.Android.dll.so => 2
	i64 u0x89f6fa8da7343264, ; 32: SmartBridge.Android.dll => 2
	i64 u0x8d7b8ab4b3310ead, ; 33: System.Threading => 16
	i64 u0x8da188285aadfe8e, ; 34: System.Collections.Concurrent => 3
	i64 u0x903101b46fb73a04, ; 35: _Microsoft.Android.Resource.Designer => 0
	i64 u0x9157bd523cd7ed36, ; 36: lib_System.Text.Json.dll.so => 14
	i64 u0x91a74f07b30d37e2, ; 37: System.Linq.dll => 7
	i64 u0x97e144c9d3c6976e, ; 38: System.Collections.Concurrent.dll => 3
	i64 u0xa0d8259f4cc284ec, ; 39: lib_System.Security.Cryptography.dll.so => 12
	i64 u0xa2572680829d2c7c, ; 40: System.IO.Pipelines.dll => 6
	i64 u0xa5f1ba49b85dd355, ; 41: System.Security.Cryptography.dll => 12
	i64 u0xae282bcd03739de7, ; 42: Java.Interop => 18
	i64 u0xb220631954820169, ; 43: System.Text.RegularExpressions => 15
	i64 u0xb4bd7015ecee9d86, ; 44: System.IO.Pipelines => 6
	i64 u0xb81a2c6e0aee50fe, ; 45: lib_System.Private.CoreLib.dll.so => 17
	i64 u0xb9857fc7fbe1f6f6, ; 46: SmartBridge.Android => 2
	i64 u0xba48785529705af9, ; 47: System.Collections.dll => 4
	i64 u0xc0d928351ab5ca77, ; 48: System.Console.dll => 5
	i64 u0xc12b8b3afa48329c, ; 49: lib_System.Linq.dll.so => 7
	i64 u0xc5a0f4b95a699af7, ; 50: lib_System.Private.Uri.dll.so => 9
	i64 u0xcbd4fdd9cef4a294, ; 51: lib__Microsoft.Android.Resource.Designer.dll.so => 0
	i64 u0xcc2876b32ef2794c, ; 52: lib_System.Text.RegularExpressions.dll.so => 15
	i64 u0xd333d0af9e423810, ; 53: System.Runtime.InteropServices => 10
	i64 u0xd3651b6fc3125825, ; 54: System.Private.Uri.dll => 9
	i64 u0xdbf9607a441b4505, ; 55: System.Linq => 7
	i64 u0xdd2b722d78ef5f43, ; 56: System.Runtime.dll => 11
	i64 u0xdd67031857c72f96, ; 57: lib_System.Text.Encodings.Web.dll.so => 13
	i64 u0xe192a588d4410686, ; 58: lib_System.IO.Pipelines.dll.so => 6
	i64 u0xe5434e8a119ceb69, ; 59: lib_Mono.Android.dll.so => 20
	i64 u0xe75cf684b1b5c362, ; 60: lib_SmartBridge.Core.dll.so => 1
	i64 u0xedc632067fb20ff3, ; 61: System.Memory.dll => 8
	i64 u0xfd2437f7cfb527bb ; 62: SmartBridge.Core => 1
], align 8

@assembly_image_cache_indices = dso_local local_unnamed_addr constant [63 x i32] [
	i32 19, i32 4, i32 12, i32 20, i32 18, i32 13, i32 3, i32 19,
	i32 11, i32 5, i32 18, i32 15, i32 16, i32 14, i32 0, i32 20,
	i32 14, i32 1, i32 19, i32 11, i32 9, i32 17, i32 16, i32 10,
	i32 13, i32 8, i32 17, i32 5, i32 10, i32 8, i32 4, i32 2,
	i32 2, i32 16, i32 3, i32 0, i32 14, i32 7, i32 3, i32 12,
	i32 6, i32 12, i32 18, i32 15, i32 6, i32 17, i32 2, i32 4,
	i32 5, i32 7, i32 9, i32 0, i32 15, i32 10, i32 9, i32 7,
	i32 11, i32 13, i32 6, i32 20, i32 1, i32 8, i32 1
], align 4

@marshal_methods_number_of_classes = dso_local local_unnamed_addr constant i32 8, align 4

@marshal_methods_class_cache = dso_local local_unnamed_addr global [8 x %struct.MarshalMethodsManagedClass] [
	%struct.MarshalMethodsManagedClass {
		i32 u0x02000054, ; class name: Android.Views.View/IOnClickListenerInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	}, ; 0
	%struct.MarshalMethodsManagedClass {
		i32 u0x020000a4, ; class name: Java.IO.InputStream, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	}, ; 1
	%struct.MarshalMethodsManagedClass {
		i32 u0x020000a7, ; class name: Java.IO.OutputStream, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	}, ; 2
	%struct.MarshalMethodsManagedClass {
		i32 u0x020000ba, ; class name: Java.Lang.IRunnableInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	}, ; 3
	%struct.MarshalMethodsManagedClass {
		i32 u0x02000098, ; class name: Android.App.Activity, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	}, ; 4
	%struct.MarshalMethodsManagedClass {
		i32 u0x02000052, ; class name: Android.Views.View, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	}, ; 5
	%struct.MarshalMethodsManagedClass {
		i32 u0x02000044, ; class name: Android.Speech.Tts.TextToSpeech/IOnInitListenerInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	}, ; 6
	%struct.MarshalMethodsManagedClass {
		i32 u0x020000cb, ; class name: Java.Interop.TypeManager/JavaTypeManager, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
		ptr null; MonoClass* klass
	} ; 7
], align 8

; Names of classes in which marshal methods reside
@mm_class_names = dso_local local_unnamed_addr constant [8 x ptr] [
	ptr @.mm.0, ; 0 ('Android.Views.View/IOnClickListenerInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
	ptr @.mm.1, ; 1 ('Java.IO.InputStream, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
	ptr @.mm.2, ; 2 ('Java.IO.OutputStream, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
	ptr @.mm.3, ; 3 ('Java.Lang.IRunnableInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
	ptr @.mm.4, ; 4 ('Android.App.Activity, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
	ptr @.mm.5, ; 5 ('Android.Views.View, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
	ptr @.mm.6, ; 6 ('Android.Speech.Tts.TextToSpeech/IOnInitListenerInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
	ptr @.mm.7 ; 7 ('Java.Interop.TypeManager/JavaTypeManager, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065')
], align 8

@mm_method_names = dso_local local_unnamed_addr constant [19 x %struct.MarshalMethodName] [
	%struct.MarshalMethodName {
		i64 u0x0000001406000186, ; name: n_OnClick_Landroid_view_View__mm_wrapper(IntPtr,IntPtr,IntPtr)
		ptr @.MarshalMethodName.0_name; char* name
	}, ; 0
	%struct.MarshalMethodName {
		i64 u0x0000001406000487, ; name: n_Close_mm_wrapper(IntPtr,IntPtr)
		ptr @.MarshalMethodName.1_name; char* name
	}, ; 1
	%struct.MarshalMethodName {
		i64 u0x0000001406000488, ; name: n_Read_mm_wrapper(IntPtr,IntPtr)
		ptr @.MarshalMethodName.2_name; char* name
	}, ; 2
	%struct.MarshalMethodName {
		i64 u0x0000001406000489, ; name: n_Read_arrayB_mm_wrapper(IntPtr,IntPtr,IntPtr)
		ptr @.MarshalMethodName.3_name; char* name
	}, ; 3
	%struct.MarshalMethodName {
		i64 u0x000000140600048a, ; name: n_Read_arrayBII_mm_wrapper(IntPtr,IntPtr,IntPtr,Int32,Int32)
		ptr @.MarshalMethodName.4_name; char* name
	}, ; 4
	%struct.MarshalMethodName {
		i64 u0x00000014060004a8, ; name: n_Close_mm_wrapper(IntPtr,IntPtr)
		ptr @.MarshalMethodName.1_name; char* name
	}, ; 5
	%struct.MarshalMethodName {
		i64 u0x00000014060004a9, ; name: n_Flush_mm_wrapper(IntPtr,IntPtr)
		ptr @.MarshalMethodName.5_name; char* name
	}, ; 6
	%struct.MarshalMethodName {
		i64 u0x00000014060004aa, ; name: n_Write_arrayB_mm_wrapper(IntPtr,IntPtr,IntPtr)
		ptr @.MarshalMethodName.6_name; char* name
	}, ; 7
	%struct.MarshalMethodName {
		i64 u0x00000014060004ab, ; name: n_Write_arrayBII_mm_wrapper(IntPtr,IntPtr,IntPtr,Int32,Int32)
		ptr @.MarshalMethodName.7_name; char* name
	}, ; 8
	%struct.MarshalMethodName {
		i64 u0x00000014060004ac, ; name: n_Write_I_mm_wrapper(IntPtr,IntPtr,Int32)
		ptr @.MarshalMethodName.8_name; char* name
	}, ; 9
	%struct.MarshalMethodName {
		i64 u0x000000140600057a, ; name: n_Run_mm_wrapper(IntPtr,IntPtr)
		ptr @.MarshalMethodName.9_name; char* name
	}, ; 10
	%struct.MarshalMethodName {
		i64 u0x0000001406000425, ; name: n_OnDestroy_mm_wrapper(IntPtr,IntPtr)
		ptr @.MarshalMethodName.10_name; char* name
	}, ; 11
	%struct.MarshalMethodName {
		i64 u0x0000001406000426, ; name: n_OnCreate_Landroid_os_Bundle__mm_wrapper(IntPtr,IntPtr,IntPtr)
		ptr @.MarshalMethodName.11_name; char* name
	}, ; 12
	%struct.MarshalMethodName {
		i64 u0x0000001406000427, ; name: n_OnActivityResult_IILandroid_content_Intent__mm_wrapper(IntPtr,IntPtr,Int32,Int32,IntPtr)
		ptr @.MarshalMethodName.12_name; char* name
	}, ; 13
	%struct.MarshalMethodName {
		i64 u0x0000001406000179, ; name: n_OnDraw_Landroid_graphics_Canvas__mm_wrapper(IntPtr,IntPtr,IntPtr)
		ptr @.MarshalMethodName.13_name; char* name
	}, ; 14
	%struct.MarshalMethodName {
		i64 u0x000000140600017a, ; name: n_OnTouchEvent_Landroid_view_MotionEvent__mm_wrapper(IntPtr,IntPtr,IntPtr)
		ptr @.MarshalMethodName.14_name; char* name
	}, ; 15
	%struct.MarshalMethodName {
		i64 u0x00000014060000a0, ; name: n_OnInit_I_mm_wrapper(IntPtr,IntPtr,Int32)
		ptr @.MarshalMethodName.15_name; char* name
	}, ; 16
	%struct.MarshalMethodName {
		i64 u0x00000014060005bf, ; name: n_Activate_mm(IntPtr,IntPtr,IntPtr,IntPtr,IntPtr,IntPtr)
		ptr @.MarshalMethodName.16_name; char* name
	}, ; 17
	%struct.MarshalMethodName {
		i64 u0x0000000000000000, ; name: 
		ptr @.MarshalMethodName.17_name; char* name
	} ; 18
], align 8

; get_function_pointer (uint32_t mono_image_index, uint32_t class_index, uint32_t method_token, void*& target_ptr)
@get_function_pointer = internal dso_local unnamed_addr global ptr null, align 8

; Marshal methods backing fields, pointers to native functions
@native_cb_onClick_0_0_6000186 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_close_0_1_6000487 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_read_0_1_6000488 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_read_0_1_6000489 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_read_0_1_600048a = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_close_0_2_60004a8 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_flush_0_2_60004a9 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_write_0_2_60004aa = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_write_0_2_60004ab = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_write_0_2_60004ac = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_run_0_3_600057a = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_onDestroy_0_4_6000425 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_onCreate_0_4_6000426 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_onActivityResult_0_4_6000427 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_onDraw_0_5_6000179 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_onTouchEvent_0_5_600017a = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_onInit_0_6_60000a0 = internal dso_local unnamed_addr global ptr null, align 8
@native_cb_activate_0_7_60005bf = internal dso_local unnamed_addr global ptr null, align 8

; Functions

; Function attributes: memory(write, argmem: none, inaccessiblemem: none) "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" nofree norecurse nosync nounwind "stack-protector-buffer-size"="8" uwtable willreturn
define void @xamarin_app_init(ptr nocapture noundef readnone %env, ptr noundef %fn) local_unnamed_addr #0
{
	%fnIsNull = icmp eq ptr %fn, null
	br i1 %fnIsNull, label %1, label %2

1: ; preds = %0
	%putsResult = call noundef i32 @puts(ptr @.mm.8)
	call void @abort()
	unreachable 

2: ; preds = %1, %0
	store ptr %fn, ptr @get_function_pointer, align 8, !tbaa !3
	ret void
}

; Method: System.Void Android.Views.View/IOnClickListenerInvoker::n_OnClick_Landroid_view_View__mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Android.Views.View/IOnClickListener::OnClick(Android.Views.View)
; Implemented: System.Void Android.Views.View/IOnClickListener::OnClick(Android.Views.View)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_view_View_1OnClickListenerImplementor_n_1onClick(ptr noundef %env, ptr noundef %klass, ptr noundef %0) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_onClick_0_0_6000186, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %1
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 0, i32 noundef 100663686, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_onClick_0_0_6000186)
	%cb2 = load ptr, ptr @native_cb_onClick_0_0_6000186, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %1
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %1]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %0)
	ret void
}

; Method: System.Void Java.IO.InputStream::n_Close_mm_wrapper(System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Java.IO.InputStream::Close()
; Implemented: System.Void Android.Runtime.InputStreamAdapter::Close()
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_runtime_InputStreamAdapter_n_1close(ptr noundef %env, ptr noundef %klass) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_close_0_1_6000487, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 1, i32 noundef 100664455, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_close_0_1_6000487)
	%cb2 = load ptr, ptr @native_cb_close_0_1_6000487, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass)
	ret void
}

; Method: System.Int32 Java.IO.InputStream::n_Read_mm_wrapper(System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Int32 Java.IO.InputStream::Read()
; Implemented: System.Int32 Android.Runtime.InputStreamAdapter::Read()
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define i32 @Java_mono_android_runtime_InputStreamAdapter_n_1read__(ptr noundef %env, ptr noundef %klass) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_read_0_1_6000488, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 1, i32 noundef 100664456, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_read_0_1_6000488)
	%cb2 = load ptr, ptr @native_cb_read_0_1_6000488, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	%1 = tail call noundef i32 %fn(ptr noundef %env, ptr noundef %klass)
	ret i32 %1
}

; Method: System.Int32 Java.IO.InputStream::n_Read_arrayB_mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Int32 Java.IO.InputStream::Read(System.Byte[])
; Implemented: System.Int32 Android.Runtime.InputStreamAdapter::Read(System.Byte[])
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define i32 @Java_mono_android_runtime_InputStreamAdapter_n_1read___3B(ptr noundef %env, ptr noundef %klass, ptr noundef %bytes) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_read_0_1_6000489, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 1, i32 noundef 100664457, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_read_0_1_6000489)
	%cb2 = load ptr, ptr @native_cb_read_0_1_6000489, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	%1 = tail call noundef i32 %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %bytes)
	ret i32 %1
}

; Method: System.Int32 Java.IO.InputStream::n_Read_arrayBII_mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr,System.Int32,System.Int32)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Int32 Java.IO.InputStream::Read(System.Byte[],System.Int32,System.Int32)
; Implemented: System.Int32 Android.Runtime.InputStreamAdapter::Read(System.Byte[],System.Int32,System.Int32)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define i32 @Java_mono_android_runtime_InputStreamAdapter_n_1read___3BII(ptr noundef %env, ptr noundef %klass, ptr noundef %bytes, i32 noundef %offset, i32 noundef %length) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_read_0_1_600048a, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 1, i32 noundef 100664458, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_read_0_1_600048a)
	%cb2 = load ptr, ptr @native_cb_read_0_1_600048a, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	%1 = tail call noundef i32 %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %bytes, i32 noundef %offset, i32 noundef %length)
	ret i32 %1
}

; Method: System.Void Java.IO.OutputStream::n_Close_mm_wrapper(System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Java.IO.OutputStream::Close()
; Implemented: System.Void Android.Runtime.OutputStreamAdapter::Close()
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_runtime_OutputStreamAdapter_n_1close(ptr noundef %env, ptr noundef %klass) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_close_0_2_60004a8, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 2, i32 noundef 100664488, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_close_0_2_60004a8)
	%cb2 = load ptr, ptr @native_cb_close_0_2_60004a8, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass)
	ret void
}

; Method: System.Void Java.IO.OutputStream::n_Flush_mm_wrapper(System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Java.IO.OutputStream::Flush()
; Implemented: System.Void Android.Runtime.OutputStreamAdapter::Flush()
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_runtime_OutputStreamAdapter_n_1flush(ptr noundef %env, ptr noundef %klass) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_flush_0_2_60004a9, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 2, i32 noundef 100664489, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_flush_0_2_60004a9)
	%cb2 = load ptr, ptr @native_cb_flush_0_2_60004a9, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass)
	ret void
}

; Method: System.Void Java.IO.OutputStream::n_Write_arrayB_mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Java.IO.OutputStream::Write(System.Byte[])
; Implemented: System.Void Android.Runtime.OutputStreamAdapter::Write(System.Byte[])
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_runtime_OutputStreamAdapter_n_1write___3B(ptr noundef %env, ptr noundef %klass, ptr noundef %buffer) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_write_0_2_60004aa, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 2, i32 noundef 100664490, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_write_0_2_60004aa)
	%cb2 = load ptr, ptr @native_cb_write_0_2_60004aa, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %buffer)
	ret void
}

; Method: System.Void Java.IO.OutputStream::n_Write_arrayBII_mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr,System.Int32,System.Int32)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Java.IO.OutputStream::Write(System.Byte[],System.Int32,System.Int32)
; Implemented: System.Void Android.Runtime.OutputStreamAdapter::Write(System.Byte[],System.Int32,System.Int32)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_runtime_OutputStreamAdapter_n_1write___3BII(ptr noundef %env, ptr noundef %klass, ptr noundef %buffer, i32 noundef %offset, i32 noundef %length) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_write_0_2_60004ab, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 2, i32 noundef 100664491, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_write_0_2_60004ab)
	%cb2 = load ptr, ptr @native_cb_write_0_2_60004ab, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %buffer, i32 noundef %offset, i32 noundef %length)
	ret void
}

; Method: System.Void Java.IO.OutputStream::n_Write_I_mm_wrapper(System.IntPtr,System.IntPtr,System.Int32)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Java.IO.OutputStream::Write(System.Int32)
; Implemented: System.Void Android.Runtime.OutputStreamAdapter::Write(System.Int32)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_runtime_OutputStreamAdapter_n_1write__I(ptr noundef %env, ptr noundef %klass, i32 noundef %oneByte) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_write_0_2_60004ac, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 2, i32 noundef 100664492, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_write_0_2_60004ac)
	%cb2 = load ptr, ptr @native_cb_write_0_2_60004ac, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, i32 noundef %oneByte)
	ret void
}

; Method: System.Void Java.Lang.IRunnableInvoker::n_Run_mm_wrapper(System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Java.Lang.IRunnable::Run()
; Implemented: System.Void Java.Lang.IRunnable::Run()
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_java_lang_RunnableImplementor_n_1run(ptr noundef %env, ptr noundef %klass) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_run_0_3_600057a, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 3, i32 noundef 100664698, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_run_0_3_600057a)
	%cb2 = load ptr, ptr @native_cb_run_0_3_600057a, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass)
	ret void
}

; Method: System.Void Android.App.Activity::n_OnDestroy_mm_wrapper(System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Android.App.Activity::OnDestroy()
; Implemented: System.Void SmartBridge.Android.MainActivity::OnDestroy()
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_crc641e85548e048e352e_MainActivity_n_1onDestroy(ptr noundef %env, ptr noundef %klass) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_onDestroy_0_4_6000425, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 4, i32 noundef 100664357, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_onDestroy_0_4_6000425)
	%cb2 = load ptr, ptr @native_cb_onDestroy_0_4_6000425, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass)
	ret void
}

; Method: System.Void Android.App.Activity::n_OnCreate_Landroid_os_Bundle__mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Android.App.Activity::OnCreate(Android.OS.Bundle)
; Implemented: System.Void SmartBridge.Android.MainActivity::OnCreate(Android.OS.Bundle)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_crc641e85548e048e352e_MainActivity_n_1onCreate(ptr noundef %env, ptr noundef %klass, ptr noundef %savedInstanceState) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_onCreate_0_4_6000426, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 4, i32 noundef 100664358, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_onCreate_0_4_6000426)
	%cb2 = load ptr, ptr @native_cb_onCreate_0_4_6000426, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %savedInstanceState)
	ret void
}

; Method: System.Void Android.App.Activity::n_OnActivityResult_IILandroid_content_Intent__mm_wrapper(System.IntPtr,System.IntPtr,System.Int32,System.Int32,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Android.App.Activity::OnActivityResult(System.Int32,Android.App.Result,Android.Content.Intent)
; Implemented: System.Void SmartBridge.Android.MainActivity::OnActivityResult(System.Int32,Android.App.Result,Android.Content.Intent)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_crc641e85548e048e352e_MainActivity_n_1onActivityResult(ptr noundef %env, ptr noundef %klass, i32 noundef %requestCode, i32 noundef %resultCode, ptr noundef %data) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_onActivityResult_0_4_6000427, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 4, i32 noundef 100664359, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_onActivityResult_0_4_6000427)
	%cb2 = load ptr, ptr @native_cb_onActivityResult_0_4_6000427, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, i32 noundef %requestCode, i32 noundef %resultCode, ptr noundef %data)
	ret void
}

; Method: System.Void Android.Views.View::n_OnDraw_Landroid_graphics_Canvas__mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Android.Views.View::OnDraw(Android.Graphics.Canvas)
; Implemented: System.Void SmartBridge.Android.MainActivity/GuideCanvas::OnDraw(Android.Graphics.Canvas)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_crc641e85548e048e352e_MainActivity_1GuideCanvas_n_1onDraw(ptr noundef %env, ptr noundef %klass, ptr noundef %canvas) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_onDraw_0_5_6000179, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 5, i32 noundef 100663673, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_onDraw_0_5_6000179)
	%cb2 = load ptr, ptr @native_cb_onDraw_0_5_6000179, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %canvas)
	ret void
}

; Method: System.SByte Android.Views.View::n_OnTouchEvent_Landroid_view_MotionEvent__mm_wrapper(System.IntPtr,System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Boolean Android.Views.View::OnTouchEvent(Android.Views.MotionEvent)
; Implemented: System.Boolean SmartBridge.Android.MainActivity/GuideCanvas::OnTouchEvent(Android.Views.MotionEvent)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define i1 @Java_crc641e85548e048e352e_MainActivity_1GuideCanvas_n_1onTouchEvent(ptr noundef %env, ptr noundef %klass, ptr noundef %e) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_onTouchEvent_0_5_600017a, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 5, i32 noundef 100663674, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_onTouchEvent_0_5_600017a)
	%cb2 = load ptr, ptr @native_cb_onTouchEvent_0_5_600017a, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	%1 = tail call noundef i1 %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %e)
	ret i1 %1
}

; Method: System.Void Android.Speech.Tts.TextToSpeech/IOnInitListenerInvoker::n_OnInit_I_mm_wrapper(System.IntPtr,System.IntPtr,System.Int32)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: System.Void Android.Speech.Tts.TextToSpeech/IOnInitListener::OnInit(Android.Speech.Tts.OperationResult)
; Implemented: System.Void Android.Speech.Tts.TextToSpeech/IOnInitListener::OnInit(Android.Speech.Tts.OperationResult)
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_crc64cacf3ba476784638_AndroidTtsService_n_1onInit(ptr noundef %env, ptr noundef %klass, i32 noundef %0) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_onInit_0_6_60000a0, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %1
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 6, i32 noundef 100663456, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_onInit_0_6_60000a0)
	%cb2 = load ptr, ptr @native_cb_onInit_0_6_60000a0, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %1
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %1]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, i32 noundef %0)
	ret void
}

; Method: System.Void Java.Interop.TypeManager/JavaTypeManager::n_Activate_mm(System.IntPtr,System.IntPtr,System.IntPtr,System.IntPtr,System.IntPtr,System.IntPtr)
; Assembly: Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065
; Registered: none
; Implemented: none
;
; Function attributes: "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" uwtable
define void @Java_mono_android_TypeManager_n_1activate(ptr noundef %env, ptr noundef %klass, ptr noundef %jnienv, ptr noundef %jclass, ptr noundef %typename_ptr, ptr noundef %signature_ptr) local_unnamed_addr #3
{
	%cb1 = load ptr, ptr @native_cb_activate_0_7_60005bf, align 8, !tbaa !3
	%isNull = icmp eq ptr %cb1, null
	br i1 %isNull, label %loadCallback, label %callbackLoaded

loadCallback: ; preds = %0
	%get_func_ptr = load ptr, ptr @get_function_pointer, align 8, !tbaa !3
	call void %get_func_ptr(i32 noundef 20, i32 noundef 7, i32 noundef 100664767, ptr nonnull noundef align(8) dereferenceable(8) @native_cb_activate_0_7_60005bf)
	%cb2 = load ptr, ptr @native_cb_activate_0_7_60005bf, align 8, !tbaa !3
	br label %callbackLoaded

callbackLoaded: ; preds = %loadCallback, %0
	%fn = phi ptr
		 [%cb2, %loadCallback],
		 [%cb1, %0]
	tail call void %fn(ptr noundef %env, ptr noundef %klass, ptr noundef %jnienv, ptr noundef %jclass, ptr noundef %typename_ptr, ptr noundef %signature_ptr)
	ret void
}

; Strings
@.mm.0 = private unnamed_addr constant [124 x i8] c"Android.Views.View/IOnClickListenerInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.1 = private unnamed_addr constant [101 x i8] c"Java.IO.InputStream, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.2 = private unnamed_addr constant [102 x i8] c"Java.IO.OutputStream, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.3 = private unnamed_addr constant [108 x i8] c"Java.Lang.IRunnableInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.4 = private unnamed_addr constant [102 x i8] c"Android.App.Activity, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.5 = private unnamed_addr constant [100 x i8] c"Android.Views.View, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.6 = private unnamed_addr constant [136 x i8] c"Android.Speech.Tts.TextToSpeech/IOnInitListenerInvoker, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.7 = private unnamed_addr constant [122 x i8] c"Java.Interop.TypeManager/JavaTypeManager, Mono.Android, Version=0.0.0.0, Culture=neutral, PublicKeyToken=84e04ff9cfb79065\00", align 1
@.mm.8 = private unnamed_addr constant [40 x i8] c"get_function_pointer MUST be specified\0A\00", align 1

;MarshalMethodName
@.MarshalMethodName.0_name = private unnamed_addr constant [63 x i8] c"n_OnClick_Landroid_view_View__mm_wrapper(IntPtr,IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.1_name = private unnamed_addr constant [34 x i8] c"n_Close_mm_wrapper(IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.2_name = private unnamed_addr constant [33 x i8] c"n_Read_mm_wrapper(IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.3_name = private unnamed_addr constant [47 x i8] c"n_Read_arrayB_mm_wrapper(IntPtr,IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.4_name = private unnamed_addr constant [61 x i8] c"n_Read_arrayBII_mm_wrapper(IntPtr,IntPtr,IntPtr,Int32,Int32)\00", align 1
@.MarshalMethodName.5_name = private unnamed_addr constant [34 x i8] c"n_Flush_mm_wrapper(IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.6_name = private unnamed_addr constant [48 x i8] c"n_Write_arrayB_mm_wrapper(IntPtr,IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.7_name = private unnamed_addr constant [62 x i8] c"n_Write_arrayBII_mm_wrapper(IntPtr,IntPtr,IntPtr,Int32,Int32)\00", align 1
@.MarshalMethodName.8_name = private unnamed_addr constant [42 x i8] c"n_Write_I_mm_wrapper(IntPtr,IntPtr,Int32)\00", align 1
@.MarshalMethodName.9_name = private unnamed_addr constant [32 x i8] c"n_Run_mm_wrapper(IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.10_name = private unnamed_addr constant [38 x i8] c"n_OnDestroy_mm_wrapper(IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.11_name = private unnamed_addr constant [64 x i8] c"n_OnCreate_Landroid_os_Bundle__mm_wrapper(IntPtr,IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.12_name = private unnamed_addr constant [91 x i8] c"n_OnActivityResult_IILandroid_content_Intent__mm_wrapper(IntPtr,IntPtr,Int32,Int32,IntPtr)\00", align 1
@.MarshalMethodName.13_name = private unnamed_addr constant [68 x i8] c"n_OnDraw_Landroid_graphics_Canvas__mm_wrapper(IntPtr,IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.14_name = private unnamed_addr constant [75 x i8] c"n_OnTouchEvent_Landroid_view_MotionEvent__mm_wrapper(IntPtr,IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.15_name = private unnamed_addr constant [43 x i8] c"n_OnInit_I_mm_wrapper(IntPtr,IntPtr,Int32)\00", align 1
@.MarshalMethodName.16_name = private unnamed_addr constant [57 x i8] c"n_Activate_mm(IntPtr,IntPtr,IntPtr,IntPtr,IntPtr,IntPtr)\00", align 1
@.MarshalMethodName.17_name = private unnamed_addr constant [1 x i8] c"\00", align 1

; External functions

; Function attributes: "no-trapping-math"="true" noreturn nounwind "stack-protector-buffer-size"="8"
declare void @abort() local_unnamed_addr #2

; Function attributes: nofree nounwind
declare noundef i32 @puts(ptr noundef) local_unnamed_addr #1
attributes #0 = { memory(write, argmem: none, inaccessiblemem: none) "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" nofree norecurse nosync nounwind "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fix-cortex-a53-835769,+neon,+outline-atomics,+v8a" uwtable willreturn }
attributes #1 = { nofree nounwind }
attributes #2 = { "no-trapping-math"="true" noreturn nounwind "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fix-cortex-a53-835769,+neon,+outline-atomics,+v8a" }
attributes #3 = { "min-legal-vector-width"="0" mustprogress "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fix-cortex-a53-835769,+neon,+outline-atomics,+v8a" uwtable }

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
