; ModuleID = 'compressed_assemblies.arm64-v8a.ll'
source_filename = "compressed_assemblies.arm64-v8a.ll"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-android21"

%struct.CompressedAssemblyDescriptor = type {
	i32, ; uint32_t uncompressed_file_size
	i1, ; bool loaded
	i32 ; uint32_t buffer_offset
}

@compressed_assembly_count = dso_local local_unnamed_addr constant i32 21, align 4

@compressed_assembly_descriptors = dso_local local_unnamed_addr global [21 x %struct.CompressedAssemblyDescriptor] [
	%struct.CompressedAssemblyDescriptor {
		i32 2560, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 0; uint32_t buffer_offset
	}, ; 0: _Microsoft.Android.Resource.Designer
	%struct.CompressedAssemblyDescriptor {
		i32 70656, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 2560; uint32_t buffer_offset
	}, ; 1: SmartBridge.Core
	%struct.CompressedAssemblyDescriptor {
		i32 16896, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 73216; uint32_t buffer_offset
	}, ; 2: SmartBridge.Android
	%struct.CompressedAssemblyDescriptor {
		i32 22016, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 90112; uint32_t buffer_offset
	}, ; 3: System.Collections.Concurrent
	%struct.CompressedAssemblyDescriptor {
		i32 26624, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 112128; uint32_t buffer_offset
	}, ; 4: System.Collections
	%struct.CompressedAssemblyDescriptor {
		i32 11776, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 138752; uint32_t buffer_offset
	}, ; 5: System.Console
	%struct.CompressedAssemblyDescriptor {
		i32 6144, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 150528; uint32_t buffer_offset
	}, ; 6: System.IO.Pipelines
	%struct.CompressedAssemblyDescriptor {
		i32 37376, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 156672; uint32_t buffer_offset
	}, ; 7: System.Linq
	%struct.CompressedAssemblyDescriptor {
		i32 14336, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 194048; uint32_t buffer_offset
	}, ; 8: System.Memory
	%struct.CompressedAssemblyDescriptor {
		i32 61440, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 208384; uint32_t buffer_offset
	}, ; 9: System.Private.Uri
	%struct.CompressedAssemblyDescriptor {
		i32 9216, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 269824; uint32_t buffer_offset
	}, ; 10: System.Runtime.InteropServices
	%struct.CompressedAssemblyDescriptor {
		i32 7680, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 279040; uint32_t buffer_offset
	}, ; 11: System.Runtime
	%struct.CompressedAssemblyDescriptor {
		i32 12288, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 286720; uint32_t buffer_offset
	}, ; 12: System.Security.Cryptography
	%struct.CompressedAssemblyDescriptor {
		i32 29696, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 299008; uint32_t buffer_offset
	}, ; 13: System.Text.Encodings.Web
	%struct.CompressedAssemblyDescriptor {
		i32 350208, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 328704; uint32_t buffer_offset
	}, ; 14: System.Text.Json
	%struct.CompressedAssemblyDescriptor {
		i32 142848, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 678912; uint32_t buffer_offset
	}, ; 15: System.Text.RegularExpressions
	%struct.CompressedAssemblyDescriptor {
		i32 12288, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 821760; uint32_t buffer_offset
	}, ; 16: System.Threading
	%struct.CompressedAssemblyDescriptor {
		i32 1652736, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 834048; uint32_t buffer_offset
	}, ; 17: System.Private.CoreLib
	%struct.CompressedAssemblyDescriptor {
		i32 162304, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 2486784; uint32_t buffer_offset
	}, ; 18: Java.Interop
	%struct.CompressedAssemblyDescriptor {
		i32 22560, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 2649088; uint32_t buffer_offset
	}, ; 19: Mono.Android.Runtime
	%struct.CompressedAssemblyDescriptor {
		i32 256512, ; uint32_t uncompressed_file_size
		i1 false, ; bool loaded
		i32 2671648; uint32_t buffer_offset
	} ; 20: Mono.Android
], align 4

@uncompressed_assemblies_data_size = dso_local local_unnamed_addr constant i32 2928160, align 4

@uncompressed_assemblies_data_buffer = dso_local local_unnamed_addr global [2928160 x i8] zeroinitializer, align 1

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
