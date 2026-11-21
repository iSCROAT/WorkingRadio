# WorkingRadio — regras ProGuard (release)
-keep class com.workingradio.data.model.** { *; }
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
