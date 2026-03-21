# Prevent R8 from stripping Conscrypt classes used by OkHttp
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep Jackson core classes
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

# For java.beans (if required)
-dontwarn java.beans.**

# For DOMImplementationRegistry
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry
-keep class org.w3c.dom.bootstrap.DOMImplementationRegistry { *; }

# General rule to avoid removing required classes
-keepattributes *Annotation*